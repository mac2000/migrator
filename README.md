MIGRATOR
========

Rules
-----

**Do Not Apply apply any scripts in your DB if they are not from source control.**

1. Each version should live in /sql/#version_number# folder.
2. Each version should have `up.sql` to migrate up and `down.sql` to rollback database.
3. Each version should have `README.md` with description of migration.
4. Each version may have `fixtures.sql` to load some dummy data.
5. Migration scripts may be commited only if they run on previous version of database without errors.
6. Each migration should change `version` table value.
7. Version number folder must be numric.

TODO
----

- Write migration script for unix like systems.
- Write migration script for php.
- Deside test strategy for stored routines.
