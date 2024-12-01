#!/bin/bash

set -e
set -o pipefail

function check_command {
  COMMAND_PARAMETER=$1

  if ! command -v ${COMMAND_PARAMETER} &> /dev/null
  then
    echo "Command '${COMMAND_PARAMETER}' could not be found. Please use 'brew install ${COMMAND_PARAMETER}'"
    exit
  fi
}

check_command curl
check_command jq
check_command base64

USER_NAME="${PLUGIN_USERNAME:?Registry username empty or unset}"
PASSWORD="${PLUGIN_PASSWORD:?Registry password empty or unset}"
TOKEN=$(printf '%s:%s' "$USER_NAME" "$PASSWORD" | base64)
AUTH_HEADER="authorization: Basic $TOKEN"

REGISTRY_SCHEMA="${PLUGIN_SCHEMA:-https}"
REGISTRY_HOST="${PLUGIN_HOST:?Registry host empty or unset}"
REGISTRY_PORT="${PLUGIN_PORT:-443}"
REPOSITORY="${PLUGIN_REPO:?Registry image repository empty or unset}"

DEBUG_MODE="${PLUGIN_DEBUG:-false}"
REQUEST_MODE="-s"
if [ "$DEBUG_MODE" = true ] ; then
  REQUEST_MODE="-v"
fi

IGNORE_SSL_VERIFICATION="${PLUGIN_IGNORE_SSL_VERIFICATION:-false}"
SSL_VERIFICATION=""
if [ "$IGNORE_SSL_VERIFICATION" = true ] ; then
  SSL_VERIFICATION="--insecure"
fi

NUMBER_OF_DAYS="${PLUGIN_MAX:-1}"
if [[ "$OSTYPE" == "darwin"* ]]; then
  MAX_DATE=$(date -v-${NUMBER_OF_DAYS}d -u +%FT%T%zZ)
else
  MAX_DATE=$(date -u +%FT%T%zZ -d "$NUMBER_OF_DAYS day ago")
fi

if [ "$DEBUG_MODE" = true ] ; then
  echo "DEBUG: Tags will be deleted older then: $MAX_DATE"
fi

MINIMUM_NUMBER_OF_TAGS="${PLUGIN_MIN:-3}"

RETRY_COMMAND="--retry 12 --retry-all-errors"

# MAX_DATE=$(date -u +%FT%T%zZ)

# curl $RETRY_COMMAND $REQUEST_MODE $SSL_VERIFICATION -H "$AUTH_HEADER" $REGISTRY_SCHEMA://$REGISTRY_HOST/v2/_catalog | jq .repositories[]

IMAGE_TAGS=$(curl $RETRY_COMMAND $REQUEST_MODE $SSL_VERIFICATION -H "$AUTH_HEADER" "$REGISTRY_SCHEMA://$REGISTRY_HOST:$REGISTRY_PORT/v2/$REPOSITORY/tags/list" | jq .tags)

RAW_IMAGE_TAGS=$(echo $IMAGE_TAGS | jq -r .[])

TAGS_COUNT=$(echo $IMAGE_TAGS | jq '. | length')
if [ "$DEBUG_MODE" = true ] ; then
  echo "DEBUG: Total number of tags: $TAGS_COUNT"
fi

ALL_TAGG_JSON_HOLDER="["
for IMAGE_TAG in $RAW_IMAGE_TAGS
do
  IMAGE_CREATED_DATE=$(curl $RETRY_COMMAND $REQUEST_MODE $SSL_VERIFICATION -H "$AUTH_HEADER" "$REGISTRY_SCHEMA://$REGISTRY_HOST:$REGISTRY_PORT/v2/$REPOSITORY/manifests/$IMAGE_TAG" | jq -r ".history[0].v1Compatibility" | jq ".created")
  ALL_TAGG_JSON_HOLDER+='{"tag":"'$IMAGE_TAG'", "date":'$IMAGE_CREATED_DATE"},"
done;
ALL_TAGG_JSON=$(echo $ALL_TAGG_JSON_HOLDER | sed 's/.$//')']'

ORDERED_TAGS=$(echo $ALL_TAGG_JSON | jq 'sort_by(.date, .tag) | reverse')

FILTERED_TAGS=$(echo $ORDERED_TAGS | jq --arg date "${MAX_DATE}" ['.[] | select(.date < $date) | .tag'] | jq .[$MINIMUM_NUMBER_OF_TAGS:])
RAW_FILTERED_TAGS=$(echo $FILTERED_TAGS | jq -r .[])

ACCEPT_MANIFEST="application/vnd.docker.distribution.manifest.v2+json"
ACCEPT_MANIFEST_LIST="application/vnd.docker.distribution.manifest.list.v2+json"

for FILTERED_TAG in $RAW_FILTERED_TAGS
do
  DIGEST=$(curl $RETRY_COMMAND $REQUEST_MODE $SSL_VERIFICATION -I \
    -H "$AUTH_HEADER" \
    -H "Accept: $ACCEPT_MANIFEST" \
    -H "Accept: $ACCEPT_MANIFEST_LIST" \
    "$REGISTRY_SCHEMA://$REGISTRY_HOST:$REGISTRY_PORT/v2/$REPOSITORY/manifests/$FILTERED_TAG" | awk '/docker-content-digest/{print $NF}')
  curl $RETRY_COMMAND $REQUEST_MODE $SSL_VERIFICATION \
    -H "$AUTH_HEADER" \
    -H "Accept: $ACCEPT_MANIFEST" \
    -H "Accept: $ACCEPT_MANIFEST_LIST" \
    -X DELETE "$REGISTRY_SCHEMA://$REGISTRY_HOST:$REGISTRY_PORT/v2/$REPOSITORY/manifests/$DIGEST"
  echo "Image $REGISTRY_HOST/$REPOSITORY:$FILTERED_TAG deleted!"
done;

echo "Finished!"
