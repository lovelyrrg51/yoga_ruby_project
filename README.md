# Shivyog Portal

## Setup deveopment

This projects uses Ruby 2.4.1, Rails 5.1.4, Postgresql.

First, create `config/application.yml`

```yml
cp config/application.yml.example config/application.yml
```

### Convetional setup

Follow the process to setup a local DB at https://bitbucket.org/syit/shivyog-rails/wiki/Setup_local_database

### Docker

Replace `config/database.yml` content with `config/database.yml.docker.example`

Build containers:

```
docker-compose build
```

Create development and test DBs:

```
docker-compose run web rails db:create
```

Run the following script to import staging DB dump to Docker DB:

```
./scripts/import_db_dump_to_docker.sh
```

Note: Remeber to update `LOCAL_DUMP_PATH` in the script before running.
If you encounter errors before anything is imported, that may be because your computer is slow and Postgres container is not ready for import process. Please increase sleep time.

Run following command to create a schema file:

```
docker-compose run web rails db:schema:dump
```

Common commands

```
# start whole stack
docker-compose up

# stop everything
docker-compose down

# run rails console
docker-compose run web rails c

# migrate
docker-compose run web rails db:migrate
```

If you update `Gemfile` you need to rebuild web container

```
docker-compose run web bundle
```

## Coding Guidelines

Follow the 2 following style guide when writing Ruby code:

- [The Ruby Style Guide](https://github.com/rubocop-hq/ruby-style-guide)
- [The Rails Style Guide](https://github.com/rubocop-hq/rails-style-guide)

To verify if you write the code properly, use Rubocop.

For example:

```sh
rubocop app/models/user.rb
```
