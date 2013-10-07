ALTER TABLE customer
	ADD COLUMN first_name VARCHAR(128),
	ADD COLUMN last_name VARCHAR(128);

UPDATE customer SET
	first_name = SUBSTRING_INDEX(name, ' ', 1),
	last_name = SUBSTRING_INDEX(name, ' ', -1);

ALTER TABLE customer DROP COLUMN name;


UPDATE version SET version = 3;
