#!/bin/bash -e

# Deliver the docker container to docker hub

trap finish EXIT

DOCKER_IMAGE_NAME=`buildkite-agent meta-data get "docker-image"`

update_status() {
  ./scripts/update-status.sh \
    --sha="$BUILDKITE_COMMIT" \
    --repo="$BUILDKITE_ORGANIZATION_SLUG/$BUILDKITE_PIPELINE_SLUG" \
    --message="$2" \
    --url="$BUILDKITE_BUILD_URL" \
    --context="edyn/docker-deliver" \
    --status=$1
}

finish() {
  # Your cleanup code here
  if [[ "$DELIVERY_SUCCEEDED" != "true" ]]; then
    update_status failure ''
    exit 1
  else
  	update_status success "Pushed docker image: $DOCKER_IMAGE_NAME"
    exit 0
  fi
}

update_status pending 'Pushing to dockerhub'

docker push $DOCKER_IMAGE_NAME

DELIVERY_SUCCEEDED="true"
