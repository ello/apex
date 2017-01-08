# Ello.Core

Read only core data access.

Accesses Postgres and Redis values historically maintained by the mothership.

This is a standard Mix app with phoenix_ecto as a dependency.

## Migrations

The migrations only exist in order to setup/teardown the test database. They
are also configured to not conflict with the rails schema_migrations table as
managed by the mothership. All migrations should use "if not exists" for
extra safety.

## Organization

As of Phoenix 1.3 (unreleased) using a "models" directory is not suggested.
Instead the lib directory should be a nested structure where wrapper "service"
libs do the querying/work have the schemas they use nested under them. In this
way the service modules become the public API and the schemas modules are
internal implementation details.
