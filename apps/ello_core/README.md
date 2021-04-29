# Ello.Core

Read only core data access.

Accesses Postgres and Redis values historically maintained by the Mothership.

This is a standard Mix app with `phoenix_ecto` as a dependency.

## Migrations

The migrations only exist in order to setup/teardown the test database. They are
also configured to not conflict with the rails schema_migrations table as
managed by the Mothership. All migrations should use “if not exists” for
extra safety.

## Organization

As of Phoenix 1.3 (unreleased) using a `models` directory is not suggested.
Instead the lib directory should be a nested structure where wrapper “service”
libs do the querying/work have the schemas they use nested under them. In this
way the service modules become the public API and the schemas modules are
internal implementation details.

## Configuration

Ello.Core expects the following environmental variables in production
(like) environments:

- `REDIS_URL` – for redis access, should be same as Mothership
- `DATABASE_URL` – for postgres access, should be same as Mothership
- `REDIS_POOL_SIZE` – how many connections per dyno to open with Redis
- `ECTO_POOL_SIZE` – how many connections per dyno to open with PostgreSQL
