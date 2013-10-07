-- TODO: http://stackoverflow.com/questions/14381895/mysql-add-column-if-not-exist
-- TODO: add column if it not already exists

ALTER TABLE customer ADD COLUMN name VARCHAR(256);

UPDATE customer SET name = CONCAT(first_name, ' ', last_name);

ALTER TABLE customer DROP COLUMN first_name, DROP COLUMN last_name;

UPDATE version SET version = 2;
