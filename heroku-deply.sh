#!/bin/bash
# 
# Bash script to deploy to Heroku from Bitbucket Pipelines (or any other build system, with
# some simple modifications)
#
# This script depends on two environment variables to be set in Bitbucket Pipelines
# 1. $HEROKU_API_KEY - https://devcenter.heroku.com/articles/platform-api-quickstart
# 2. $HEROKU_APP_NAME - Your app name in Heroku
#

git archive --format=tar.gz -o deploy.tgz $BITBUCKET_COMMIT

HEROKU_VERSION=$BITBUCKET_COMMIT # BITBUCKET_COMMIT is populated automatically by Pipelines
APP_NAME=$HEROKU_APP_NAME

echo "Deploying Heroku Version $HEROKU_VERSION"

URL_BLOB=`curl -s -n -X POST https://api.heroku.com/apps/$APP_NAME/sources \
-H 'Accept: application/vnd.heroku+json; version=3' \
-H "Authorization: Bearer $HEROKU_API_KEY"`

PUT_URL=`echo $URL_BLOB | python -c 'import sys, json; print(json.load(sys.stdin)["source_blob"]["put_url"])'`
GET_URL=`echo $URL_BLOB | python -c 'import sys, json; print(json.load(sys.stdin)["source_blob"]["get_url"])'`

curl $PUT_URL  -X PUT -H 'Content-Type:' --data-binary @deploy.tgz

REQ_DATA="{\"source_blob\": {\"url\":\"$GET_URL\", \"version\": \"$HEROKU_VERSION\"}}"

BUILD_OUTPUT=`curl -s -n -X POST https://api.heroku.com/apps/$APP_NAME/builds \
-d "$REQ_DATA" \
-H 'Accept: application/vnd.heroku+json; version=3' \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $HEROKU_API_KEY"`

STREAM_URL=`echo $BUILD_OUTPUT | python -c 'import sys, json; print(json.load(sys.stdin)["output_stream_url"])'`

curl $STREAM_URL
