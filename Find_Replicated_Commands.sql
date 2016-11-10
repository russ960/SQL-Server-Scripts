sp_browsereplcmds [ [ @xact_seqno_start = ] 'xact_seqno_start' ]
    [ , [ @xact_seqno_end = ] 'xact_seqno_end' ] 
    [ , [ @originator_id = ] 'originator_id' ]
    [ , [ @publisher_database_id = ] 'publisher_database_id' ]
    [ , [ @article_id = ] 'article_id' ]
    [ , [ @command_id= ] command_id ]
    [ , [ @agent_id = ] agent_id ]
    [ , [ @compatibility_level = ] compatibility_level ]
	
	
	/*
	[ @xact_seqno_start =] 'xact_seqno_start'

    Specifies the lowest valued exact sequence number to return. xact_seqno_start is nchar(22), with a default of 0x00000000000000000000.

[ @xact_seqno_end =] 'xact_seqno_end'

    Specifies the highest exact sequence number to return. xact_seqno_end is nchar(22), with a default of 0xFFFFFFFFFFFFFFFFFFFF.

[ @originator_id =] 'originator_id'

    Specifies if commands with the specified originator_id are returned. originator_id is int, with a default of NULL.

[ @publisher_database_id =] 'publisher_database_id'

    Specifies if commands with the specified publisher_database_id are returned. publisher_database_id is int, with a default of NULL.

[ @article_id =] 'article_id'

    Specifies if commands with the specified article_id are returned. article_id is int, with a default of NULL.

[ @command_id =] command_id

    Is the location of the command in MSrepl_commands (Transact-SQL) to be decoded. command_id is int, with a default of NULL. If specified, all other parameters must be specified also, and xact_seqno_start must be identical to xact_seqno_end.

[ @agent_id =] agent_id

    Specifies that only commands for a specific replication agent are returned. agent_id is int, with a default value of NULL.

[ @compatibility_level =] compatibility_level

    Is the version of Microsoft SQL Server on which the compatibility_level is int, with a default value of 9000000.

*/