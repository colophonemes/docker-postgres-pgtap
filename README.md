# Docker + Postgres + pgTap

This Docker image makes it straightforward to run a Postgres install with pgTap, for unit testing database behaviours.

From the [PGTap docs](https://pgtap.org/):

> pgTAP is a suite of database functions that make it easy to write TAP-emitting unit tests in psql scripts or xUnit-style test functions.

The Docker file is based on [the official Postgres image](https://hub.docker.com/_/postgres), and is designed to deviate from it as minimally as possible. See instructions there for how to set up Postgres.

## Running locally

### Setting up the database

Pull the [colophonemes/postgres-pgtap](https://hub.docker.com/repository/docker/colophonemes/postgres-pgtap) Docker image:

```sh
docker pull colophonemes/postgres-pgtap
```

Start the database server:

- `-p 5432:5432`: expose port 5432 of the Docker container to localhost
- `-e POSTGRES_HOST_AUTH_METHOD=trust`: makes the DB trust incoming connections, so we don't need a password (**Important:** this is insecure! It's fine for local testing, but make sure you [read the docs](https://hub.docker.com/_/postgres) to understand what this means!)
- `--name pg`: name the Docker container, so that we can easily restart the same instance in the future
- `-d`: run the container in detached state

```sh
docker run -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust --name pg -d colophonemes/postgres-pgtap
```

In future if you want to start the database server, you can now run

```sh
docker start pg
```

If you want to connect to postgres with `psql`, you just need to supply a host (`-h localhost`) and username (`-U postgres`). This also applies to e.g. `createdb`/`dropdb`

```sh
createdb -U postgres -h localhost my_database
psql -U postgres -h localhost my_database
dropdb -U postgres -h localhost my_database
```

### Setting up `pg_prove`

The test runner for `pgtap` is `pg_prove`. `pg_prove` is a CPAN (Perl) module, so you might need to install Perl first:

```sh
brew install perl
```

Then install `pg_prove` from CPAN:

```sh
cpan TAP::Parser::SourceHandler::pgTAP
```

By default, CPAN module binaries are not exposed on your shell's `$PATH`. To find the install location, run the following:

```sh
perl -V:'install.*' | grep installbin | sed "s/^installbin='\(.*\)';/\1/"
```

You can also use this to add this folder to your path:

```sh
export PATH=$PATH:$(perl -V:'install.*' | grep installbin | sed "s/^installbin='\(.*\)';/\1/")
```

You should now be able to see the `pg_prove` executable:

```sh
which pg_prove
# e.g. /opt/homebrew/Cellar/perl/5.34.0/bin/pg_prove
```

## Running in CI (Github Actions)

_TODO_

## Rebuilding the Dockerfile

We need to build a multi-architecture image so that we can use it locally (e.g. on an M1 Mac running `linux/arm64`) as well as CI (which is likely to be running `linux/amd64`).

### Set up `docker buildx`

See [the Docker blog](https://www.docker.com/blog/multi-arch-images/) for more info

```sh
# create a new build context called 'builder' and tell buildx to use it
docker buildx create --name builder --use
# bootstrap the 'builder' context with buildkit
docker buildx inspect --bootstrap
```

## Build and push multi-arch build

```sh
docker buildx build --platform linux/amd64,linux/arm64 -t colophonemes/postgres-pgtap --push .
```
