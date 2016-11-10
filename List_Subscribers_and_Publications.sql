/*
Returns the subscribers and publication name ordered by publication name for a given publisher.
*/


SELECT DISTINCT sp.name "Publication", syss.name "Subscriber" FROM sys.servers syss JOIN syssubscriptions ss ON syss.server_id = ss.srvid JOIN sysarticles sa ON ss.artid = sa.artid JOIN syspublications sp ON sa.pubid = sp.pubid ORDER BY sp.name