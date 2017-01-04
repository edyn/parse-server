#!/bin/bash

# Exit on error
set -ex

# We will write in this file the final docker image, remove it in case it exists
rm -rf .docker-image

CURRENT=`pwd`
BASENAME=`basename "$CURRENT"`
SHA1_FULL=`git rev-parse --verify HEAD`
SHA1=${SHA1_FULL:0:8}
BUILDKITE_PIPELINE_SLUG=${BUILDKITE_PIPELINE_SLUG:-}


update_status() {
  ./scripts/update-status.sh \
    --sha="$BUILDKITE_COMMIT" \
    --repo="$BUILDKITE_ORGANIZATION_SLUG/$BUILDKITE_PIPELINE_SLUG" \
    --message="$2" \
    --url="$BUILDKITE_BUILD_URL" \
    --context="edyn/docker-build" \
    --status=$1
}

update_status pending 'Building docker image'

echo "edyn/$BUILDKITE_PIPELINE_SLUG:$SHA1" > .docker-image
DOCKER_IMAGE_NAME=`cat .docker-image`
buildkite-agent meta-data set "docker-image" "$DOCKER_IMAGE_NAME"

docker build -t "$DOCKER_IMAGE_NAME" .

update_status success 'Done building docker image'
