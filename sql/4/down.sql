ALTER TABLE customer DROP COLUMN age;

DROP TRIGGER IF EXISTS validate_customer_insert;
DROP TRIGGER IF EXISTS validate_customer_update;

UPDATE version SET version = 3;
