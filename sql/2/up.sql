CREATE TABLE IF NOT EXISTS customer (
	id INT NOT NULL AUTO_INCREMENT,
	name varchar(128) NOT NULL,
	PRIMARY KEY (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

UPDATE version SET version = 2;
