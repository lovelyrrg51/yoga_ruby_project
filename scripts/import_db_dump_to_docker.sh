#!/bin/sh
DB_CONTAINER=db
DB_NAME=shivyog_development
DB_USER=postgres
LOCAL_DUMP_PATH="./tmp/development.dump"

docker-compose up -d "${DB_CONTAINER}"
sleep 15s
docker-compose exec -T "${DB_CONTAINER}" pg_restore --verbose -C --clean --no-acl --no-owner -U "${DB_USER}" -d "${DB_NAME}" < "${LOCAL_DUMP_PATH}"
docker-compose stop "${DB_CONTAINER}"
