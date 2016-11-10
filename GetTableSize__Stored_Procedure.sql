/**********************************************************************************************
Procedure Name   : gettablesize 
Author           : Amit Jethva 
Date             : Feb 11 2004 11:31AM
Purpose          : Table Size Estimation 
Tables Referred  : sysobjects,sysindexes, sysindexkeys ,syscolumns 
Input Parameters :
	1. objectid : Id of Table For which size is to be estimated. 
Output Parameters:
   None, A Recordset containing Row Size , Data Size in KB, Clustered Index Size in KB,NonClustered Index Size in KB and total Size in KB

Source URL: http://www.sqlservercentral.com/scripts/Miscellaneous/31062/

**********************************************************************************************/
CREATE PROCEDURE gettablesize (
	@objectid INT
	,@rows FLOAT
	,@fill_factor SMALLINT
	)
AS
BEGIN
	DECLARE @num_rows FLOAT
		,@fixed_data_size INT
		,@num_cols INT
		,@num_variable_cols INT
		,@has_clust_index BIT
		,@max_var_size INT
		,@null_bitmap INT
		,@variable_data_size INT
		,@row_size INT
		,@rows_per_page INT
		,@free_rows_per_page INT
		,@num_pages INT
		,@num_ckey_cols INT
		,@fixed_ckey_size INT
		,@num_variable_ckey_cols INT
		,@max_var_ckey_size INT
		,@num_key_cols INT
		,@fixed_key_size INT
		,@num_variable_key_cols INT
		,@max_var_key_size INT
		,@cindex_null_bitmap INT
		,@variable_ckey_size INT
		,@cindex_row_size INT
		,@cindex_rows_per_page INT
		,@num_pages_clevel_0 FLOAT
		,@num_cindex_pages INT
		,@clustered_index_size_in_bytes INT
		,@index_null_bitmap INT
		,@variable_key_size INT
		,@nl_index_row_size INT
		,@index_row_size INT
		,@index_rows_per_page INT
		,@nl_index_rows_per_page INT
		,@num_pages_level_0 FLOAT
		,@num_index_pages INT
		,@nc_index_size_in_bytes INT
		,@total_nc_index_size_in_bytes INT
		,@free_index_rows_per_page INT
		,@total_nc_index_size_in_kbytes FLOAT
		,@data_space_used_in_kb FLOAT
		,@clustered_index_size_in_kbytes FLOAT
		,@data_space_used_in_byte BIGINT
		,@indid TINYINT

	IF NOT EXISTS (
			SELECT 1
			FROM sysobjects
			WHERE type = 'U'
				AND id = @objectid
			)
	BEGIN
		PRINT 'User Table specified by given id does not exits. please use a vaild objectid'

		RETURN 1
	END

	SELECT @num_rows = @rows

	SELECT @num_cols = count(*)
		,@fixed_data_size = sum(CASE 
				WHEN c.xtype IN (
						231
						,167
						,165
						,99
						)
					THEN 0
				ELSE c.length
				END)
		,@num_variable_cols = sum(CASE 
				WHEN c.xtype IN (
						231
						,167
						,165
						,99
						)
					THEN 1
				ELSE 0
				END)
		,@max_var_size = sum(CASE 
				WHEN c.xtype IN (
						231
						,167
						,165
						,99
						)
					THEN c.length
				ELSE 0
				END)
		,@has_clust_index = objectproperty(o.id, 'tablehasclustindex')
		,@num_ckey_cols = isnull((
				SELECT keycnt
				FROM sysindexes i
				WHERE i.id = o.id
					AND i.indid = 1
				), 0)
		,@fixed_ckey_size = CASE objectproperty(o.id, 'tablehasclustindex')
			WHEN 0
				THEN 0
			ELSE (
					SELECT isnull(sum(ic.length), 0)
					FROM sysindexkeys ik
					INNER JOIN syscolumns ic ON (
							ic.colid = ik.colid
							AND ic.id = ik.id
							)
					WHERE ik.id = o.id
						AND ik.indid = 1
						AND ic.xtype NOT IN (
							231
							,167
							,165
							,99
							)
					)
			END
		,@num_variable_ckey_cols = CASE objectproperty(o.id, 'tablehasclustindex')
			WHEN 0
				THEN 0
			ELSE (
					SELECT count(*)
					FROM sysindexkeys ik
					INNER JOIN syscolumns ic ON (
							ic.colid = ik.colid
							AND ic.id = ik.id
							)
					WHERE ik.id = o.id
						AND ik.indid = 1
						AND ic.xtype IN (
							231
							,167
							,165
							,99
							)
					)
			END
		,@max_var_ckey_size = CASE objectproperty(o.id, 'tablehasclustindex')
			WHEN 0
				THEN 0
			ELSE (
					SELECT isnull(sum(ic.length), 0)
					FROM sysindexkeys ik
					INNER JOIN syscolumns ic ON (
							ic.colid = ik.colid
							AND ic.id = ik.id
							)
					WHERE ik.id = o.id
						AND ik.indid = 1
						AND ic.xtype IN (
							231
							,167
							,165
							,99
							)
					)
			END
	FROM sysobjects o
	INNER JOIN syscolumns c ON (o.id = c.id)
	WHERE o.id = @objectid
	GROUP BY o.id
		,o.NAME

	/* null_bitmap) = 2 + (( num_cols + 7) / 8 ) */
	SELECT @null_bitmap = floor(2 + ((@num_cols + 7) / 8))

	/* total size of variable-length columns (variable_data_size) = 2 + (num_variable_cols x 2) + max_var_size
	if there are no variable-length columns, set variable_data_size to 0.
	this formula assumes that all variable-length columns are 100 percent full. */
	SELECT @variable_data_size = CASE 
			WHEN @num_variable_cols = 0
				THEN 0
			ELSE 2 + (@num_variable_cols * 2) + @max_var_size
			END

	/* total row size (row_size) = fixed_data_size + variable_data_size + null_bitmap +4
	the final value of 4 represents the data row header. */
	SELECT @row_size = @fixed_data_size + @variable_data_size + @null_bitmap + 4

	/* number of rows per page (rows_per_page) = ( 8096 ) / (row_size + 2) 
	because rows do not span pages, the number of rows per page should be rounded down to the nearest whole row */
	SELECT @rows_per_page = ceiling(8096 / (@row_size + 2))

	/* if a clustered index is to be created on the table, calculate the number of reserved free rows per page, 
	based on the fill factor specified. if no clustered index is to be created, specify fill_factor as 100. 
	number of free rows per page (free_rows_per_page) = 8096 x ((100 - fill_factor) / 100) / (row_size + 2)
	the fill factor used in the calculation is an integer value rather than a percentage.
	because rows do not span pages, the number of rows per page should be rounded down to the nearest whole row. as the  
fill factor grows, more data will be stored on each page and there will be fewer pages.
	*/
	SELECT @free_rows_per_page = ceiling(8096 * ((100 - @fill_factor) / 100) / (@row_size + 2))

	/*calculate the number of pages required to store all the rows: 
	number of pages (num_pages) = num_rows / (rows_per_page - free_rows_per_page) */
	SELECT @num_pages = ceiling(convert(FLOAT, @num_rows / (@rows_per_page - @free_rows_per_page)))

	/* the amount of space required to store the data in a table (8192 total bytes per page): 
	table_size_in_bytes = 8192 x num_pages */
	SELECT @data_space_used_in_byte = 8192 * @num_pages

	SELECT @data_space_used_in_kb = @data_space_used_in_byte / 1024

	/* space used to store the clustered index */
	/* if there are fixed-length columns in the clustered index, a portion of the index row is reserved for the null  
bitmap. calculate its size: 
	index null bitmap (cindex_null_bitmap) = 2 + (( num_ckey_cols + 7) / 8 ) */
	SELECT @cindex_null_bitmap = floor(2 + ((@num_ckey_cols + 7) / 8))

	/* total size of variable length columns (variable_ckey_size) = 2 + (num_variable_ckey_cols x 2) + max_var_ckey_size
	if there are no variable-length columns, set variable_ckey_size to 0.
	this formula assumes that all variable-length key columns are 100 percent full. 
	*/
	SELECT @variable_ckey_size = CASE 
			WHEN @num_variable_ckey_cols = 0
				THEN 0
			ELSE 2 + (@num_variable_ckey_cols * 2) + (@max_var_ckey_size * @fill_factor / 100)
			END

	/* total index row size (cindex_row_size) = fixed_ckey_size + variable_ckey_size + cindex_null_bitmap + 1 + 8 */
	SELECT @cindex_row_size = @fixed_ckey_size + @variable_ckey_size + @cindex_null_bitmap + 1 + 8

	/* the number of index rows per page (8096 free bytes per page): 
	number of index rows per page (cindex_rows_per_page) = ( 8096 ) / (cindex_row_size + 2)
	because index rows do not span pages, the number of index rows per page should be rounded down to the nearest whole  
row.
	*/
	SELECT @cindex_rows_per_page = ceiling((8096.0) / @cindex_row_size + 2)

	/*
	calculate the number of pages required to store all the index rows at each level of the index. 
	number of pages (level 0) (num_pages_clevel_0) = (data_space_used / 8192) / cindex_rows_per_page
	number of pages (level 1) (num_pages_clevel_1) = num_pages_clevel_0 / cindex_rows_per_page
	
	repeat the second calculation, dividing the number of pages calculated from the previous level n by  
cindex_rows_per_page until the number of pages for a given level n (num_pages_clevel_n) equals one (index root page). for  
example, to calculate the number of pages required for the second index level:
	number of pages (level 2) (num_pages_clevel_2) = num_pages_clevel_1 / cindex_rows_per_page
	
	for each level, the number of pages estimated should be rounded up to the nearest whole page.
	sum the number of pages required to store each level of the index:
	total number of pages (num_cindex_pages) = num_pages_clevel_0 + num_pages_clevel_1 +
	num_pages_clevel_2 + ... + num_pages_clevel_n   */
	SELECT @num_pages_clevel_0 = ceiling((@data_space_used_in_byte / 8192.0) / @cindex_rows_per_page)

	SELECT @num_cindex_pages = @num_pages_clevel_0

	WHILE @num_pages_clevel_0 > 1
	BEGIN
		-- print @num_pages_clevel_0 
		SELECT @num_pages_clevel_0 = ceiling(@num_pages_clevel_0 / @cindex_rows_per_page)

		SELECT @num_cindex_pages = @num_cindex_pages + @num_pages_clevel_0
	END

	/* clustered index size (bytes) = 8192 x num_cindex_pages */
	SELECT @clustered_index_size_in_bytes = 8192 * @num_cindex_pages

	IF @has_clust_index = 0
		SELECT @clustered_index_size_in_bytes = 0

	SELECT @clustered_index_size_in_kbytes = @clustered_index_size_in_bytes / 1024.0

	DECLARE ind_cursor CURSOR
	FOR
	SELECT indid
		,keycnt
	FROM sysindexes i
	WHERE i.indid BETWEEN 2
			AND 254
		AND i.NAME NOT LIKE '[_]wa[_]sys%'
		AND i.id = @objectid

	SELECT @total_nc_index_size_in_bytes = 0

	OPEN ind_cursor

	FETCH NEXT
	FROM ind_cursor
	INTO @indid
		,@num_key_cols

	WHILE @@fetch_status = 0
	BEGIN
		/* 
		calculate the space used to store each additional nonclustered index
		the following steps can be used to estimate the amount of space required to store each additional  
nonclustered index: 
		
		a nonclustered index definition can include fixed-length and variable-length columns. to estimate the size of  
the nonclustered index, you must calculate the space each of these groups of columns occupies within the index row: 
		number of columns in index key = num_key_cols */
		/* sum of bytes in all fixed-length key columns = fixed_key_size */
		SELECT @fixed_key_size = isnull(sum(ic.length), 0)
		FROM sysindexkeys ik
		INNER JOIN syscolumns ic ON (
				ic.colid = ik.colid
				AND ic.id = ik.id
				)
		WHERE ik.id = @objectid
			AND ik.indid = @indid
			AND ic.xtype NOT IN (
				231
				,167
				,165
				,99
				)

		/*
		number of variable-length columns in index key = num_variable_key_cols
		maximum size of all variable-length key columns = max_var_key_size */
		SELECT @num_variable_key_cols = count(*)
			,@max_var_key_size = isnull(sum(ic.length), 0)
		FROM sysindexkeys ik
		INNER JOIN syscolumns ic ON (
				ic.colid = ik.colid
				AND ic.id = ik.id
				)
		WHERE ik.id = @objectid
			AND ik.indid = @indid
			AND ic.xtype IN (
				231
				,167
				,165
				,99
				)

		/* if there are fixed-length columns in the index, a portion of the index row is reserved for the null  
bitmap. calculate its size: 
		index null bitmap (index_null_bitmap) = 2 + (( num_key_cols + 7) / 8 ) 
		only the integer portion of the above expression should be used; discard any remainder.  */
		SELECT @index_null_bitmap = floor(2 + ((@num_key_cols + 7) / 8))

		/* if there are variable-length columns in the index, determine how much space is used to store the columns  
within the index row:  
		total size of variable length columns (variable_key_size) = 2 + (num_variable_key_cols x 2) +  
max_var_key_size
		
		if there are no variable-length columns, set variable_key_size to 0.
		this formula assumes that all variable-length key columns are 100 percent full. if you anticipate that a  
lower percentage of the variable-length key column storage space will be used, you can adjust the result by that percentage  
to yield a more accurate estimate of the overall index size.*/
		SELECT @variable_key_size = CASE 
				WHEN @num_variable_key_cols = 0
					THEN 0
				ELSE 2 + (@num_variable_key_cols * 2) + (@max_var_key_size * @fill_factor / 100)
				END

		IF @has_clust_index = 1
		BEGIN
			/* non clustered index on a table with clustered index */
			/* calculate the nonleaf index row size: 
			total nonleaf index row size (nl_index_row_size) = fixed_key_size + variable_key_size +  
index_null_bitmap + 1 + 8 */
			SELECT @nl_index_row_size = @fixed_key_size + @variable_key_size + @index_null_bitmap + 1 + 8

			/* calculate the number of nonleaf index rows per page: 
			number of nonleaf index rows per page (nl_index_rows_per_page) = 
			( 8096 ) / (nl_index_row_size + 2)
			
			because index rows do not span pages, the number of index rows per page should be rounded down to the  
nearest whole row. */
			SELECT @nl_index_rows_per_page = ceiling((8096.0) / @nl_index_row_size + 2)

			/*
			calculate the leaf index row size: 
			total leaf index row size (index_row_size) = cindex_row_size + fixed_key_size + variable_key_size +  
index_null_bitmap + 1
			
			the final value of 1 represents the index row header. cindex_row_size is the total index row size for  
the clustered index key. */
			SELECT @index_row_size = @cindex_row_size + @fixed_key_size + @variable_key_size + @index_null_bitmap + 1

			/*	
			calculate the number of leaf level index rows per page: 
			number of leaf level index rows per page (index_rows_per_page) = ( 8096 ) / (index_row_size + 2)
		
			because index rows do not span pages, the number of index rows per page should be rounded down to the  
nearest whole row. */
			SELECT @index_rows_per_page = ceiling((8096.0) / (@index_row_size + 2))

			/* 
			calculate the number of reserved free index rows per page based on the fill factor specified for the  
nonclustered index. 
			number of free index rows per page (free_index_rows_per_page) = 8096 x ((100 - fill_factor) / 100) /  
index_row_size 
			
			the fill factor used in the calculation is an integer value rather than a percentage.
			
			because index rows do not span pages, the number of index rows per page should be rounded down to the  
nearest whole row. */
			SELECT @free_index_rows_per_page = ceiling(8096 * ((100 - @fill_factor) / 100) / @index_row_size)

			/* calculate the number of pages required to store all the index rows at each level of the index: 
			number of pages (level 0) (num_pages_level_0) = num_rows / (index_rows_per_page -  
free_index_rows_per_page) 
			
			number of pages (level 1) (num_pages_level_1) = num_pages_level_0 / nl_index_rows_per_page
			
			repeat the second calculation, dividing the number of pages calculated from the previous level n by  
nl_index_rows_per_page until the number of pages for a given level n (num_pages_level_n) equals one (root page).
			
			for example, to calculate the number of pages required for the second and third index levels:
			
			number of data pages (level 2) (num_pages_level_2) = num_pages_level_1 / nl_index_rows_per_page
			
			number of data pages (level 3) (num_pages_level_3) = num_pages_level_2 / nl_index_rows_per_page
			
			for each level, the number of pages estimated should be rounded up to the nearest whole page.
			
			sum the number of pages required to store each level of the index: 
			total number of pages (num_index_pages) = num_pages_level_0 + num_pages_level_1 +num_pages_level_2 +  
... + num_pages_level_n */
			SELECT @num_pages_level_0 = ceiling(@num_rows / (@index_rows_per_page - @free_index_rows_per_page))

			SELECT @num_index_pages = @num_pages_level_0

			WHILE @num_pages_level_0 > 1
			BEGIN
				-- print @num_pages_level_0 
				SELECT @num_pages_level_0 = ceiling(@num_pages_level_0 / @nl_index_rows_per_page)

				SELECT @num_index_pages = @num_index_pages + @num_pages_level_0
			END
		END
		ELSE
		BEGIN
			/* non clustered index on a table without a clustered index */
			/* calculate the index row size: 
			total index row size (index_row_size) = fixed_key_size + variable_key_size + index_null_bitmap + 1 +  
8 */
			SELECT @index_row_size = @fixed_key_size + @variable_key_size + @index_null_bitmap + 1 + 8

			/* calculate the number of index rows per page (8096 free bytes per page): 
			number of index rows per page (index_rows_per_page) = ( 8096 ) / (index_row_size + 2) 
			because index rows do not span pages, the number of index rows per page should be rounded down to the  
nearest whole row.*/
			SELECT @index_rows_per_page = ceiling((8096) / (@index_row_size + 2))

			/* calculate the number of reserved free index rows per leaf page, based on the fill factor specified  
for the nonclustered index. for more information, see fill factor. 
			number of free index rows per leaf page (free_index_rows_per_page) = 8096 x ((100 - fill_factor) /  
100) / 
			index_row_size
			
			the fill factor used in the calculation is an integer value rather than a percentage.
			
			because index rows do not span pages, the number of index rows per page should be rounded down to the  
nearest whole row. */
			SELECT @free_index_rows_per_page = ceiling(8096 * ((100 - @fill_factor) / 100) / @index_row_size)

			/* calculate the number of pages required to store all the index rows at each level of the index: 
			number of pages (level 0) (num_pages_level_0) = num_rows / (index_rows_per_page -  
free_index_rows_per_page)
			
			number of pages (level 1) (num_pages_level_1) = num_pages_level_0 / index_rows_per_page
			
			repeat the second calculation, dividing the number of pages calculated from the previous level n by  
index_rows_per_page until the number of pages for a given level n (num_pages_level_n) equals one (root page). for example, to  
calculate the number of pages required for the second index level:
			
			number of pages (level 2) (num_pages_level_2) = num_pages_level_1 / index_rows_per_page
			
			for each level, the number of pages estimated should be rounded up to the nearest whole page.
			
			sum the number of pages required to store each level of the index:
			
			total number of pages (num_index_pages) = num_pages_level_0 + num_pages_level_1 + num_pages_level_2 +  
... + num_pages_level_n */
			SELECT @num_pages_level_0 = ceiling(@num_rows / (@index_rows_per_page - @free_index_rows_per_page))

			SELECT @num_index_pages = @num_pages_level_0

			WHILE @num_pages_level_0 > 1
			BEGIN
				-- print @num_pages_level_0 
				SELECT @num_pages_level_0 = ceiling(@num_pages_level_0 / @index_rows_per_page)

				SELECT @num_index_pages = @num_index_pages + @num_pages_level_0
			END
		END

		/*calculate the size of the nonclustered index: nonclustered index size (bytes) = 8192 x num_index_pages	 
*/
		SELECT @nc_index_size_in_bytes = 8192 * @num_index_pages

		-- print 	@nc_index_size_in_bytes 
		SELECT @total_nc_index_size_in_bytes = @total_nc_index_size_in_bytes + @nc_index_size_in_bytes

		FETCH NEXT
		FROM ind_cursor
		INTO @indid
			,@num_key_cols
	END

	CLOSE ind_cursor

	DEALLOCATE ind_cursor

	SELECT @total_nc_index_size_in_kbytes = @total_nc_index_size_in_bytes / 1024.0

	SELECT 'row size' = @row_size
		,
		--	'number of pages' 	= @num_pages			, 
		--	'data size in bytes' 	= @data_space_used_in_byte  	,
		'data size in kb' = @data_space_used_in_kb
		,
		--	'clustered_index_size_in_bytes'   = @clustered_index_size_in_bytes  ,
		'clustered_index_size_in_kbytes' = @clustered_index_size_in_kbytes
		,
		--	'nclustered_index_size_in_bytes'   = @total_nc_index_size_in_bytes  ,
		'nclustered_index_size_in_kbytes' = @total_nc_index_size_in_kbytes
		,'total size' = @data_space_used_in_kb + @clustered_index_size_in_kbytes + @total_nc_index_size_in_kbytes
END
GO


