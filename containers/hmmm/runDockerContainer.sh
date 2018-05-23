#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ "$#" -eq 4 ] || echo >&2 "Usage: $0 PARTICIPANT_ID ROUND_ID REPO TAG CHALLENGE_ID"
PARTICIPANT_ID=$1
ROUND_ID=$2
REPO=$3
TAG=$4
CHALLENGE_ID=$5

dockerImageName="accelerate-io/dpnt-coverage-hmmm"
dockerImageVersion="0.1"

echo "Quickly triggering a re-build of the docker image '${dockerImageName}":"${dockerImageVersion}'"
${SCRIPT_CURRENT_DIR}/buildDockerImage.sh "${dockerImageName}" "${dockerImageVersion}"

echo "Running ${dockerImageName}":"${dockerImageVersion} from the local docker registry"
docker run                                                                      \
      --env S3_ENDPOINT=unused                                                  \
      --env S3_REGION=unused                                                    \
      --env SQS_ENDPOINT=unused                                                 \
      --env SQS_REGION=unused                                                   \
      --env SQS_QUEUE_URL=unused                                                \
      --env PARTICIPANT_ID=${PARTICIPANT_ID}                                    \
      --env ROUND_ID=${ROUND_ID}                                                \
      --env REPO=${REPO}                                                        \
      --env TAG=${TAG}                                                          \
      --env CHALLENGE_ID=${CHALLENGE_ID}                                        \
      ${dockerImageName}:${dockerImageVersion}
