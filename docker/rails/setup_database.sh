#!/bin/bash

cd /app
bundle exec rake db:drop db:create

echo "importing compressed backup"
cp /app/db/summer_missions.dmp.zip /tmp

cd /tmp
unzip /tmp/summer_missions.dmp.zip

PGPASSWORD=$DB_ENV_POSTGRESQL_PASS pg_restore -U $DB_ENV_POSTGRESQL_USER -d summer_missions -h $DB_PORT_5432_TCP_ADDR summer_missions.dmp