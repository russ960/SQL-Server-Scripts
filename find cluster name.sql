USE SERVERINFO
select a.server_name, b.server_node_name
  from server a, server_cluster_node b
 where a.server_id=b.server_id
   and b.server_node_name like '%PRI%'

--  Replace like clause.