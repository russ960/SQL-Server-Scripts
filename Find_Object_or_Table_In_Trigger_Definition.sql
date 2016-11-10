-- Place your object search in the '%%' of the WHERE clause.
-- Searches for you search term in the OBJECT_DEFINITION of the trigger then returns the trigger name and DEFINITION.
SELECT name, OBJECT_DEFINITION(object_id) FROM sys.triggers WHERE OBJECT_DEFINITION(object_id) LIKE '%%'