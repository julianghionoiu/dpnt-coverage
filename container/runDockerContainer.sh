#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_DIR="${SCRIPT_CURRENT_DIR}/images"
export DEBUG="${DEBUG:-}"

function die() { echo >&2 $1; exit 1; }
[ "$#" -eq 6 ] || die "Usage: $0 LANGUAGE_ID PARTICIPANT_ID ROUND_ID REPO TAG CHALLENGE_ID"
LANGUAGE_ID=$1
PARTICIPANT_ID=$2
ROUND_ID=$3
REPO=$4
TAG=$5
CHALLENGE_ID=$6

echo "Compute language specific name+version"
DEFAULT_IMAGE_PREFIX="accelerate-io/dpnt-coverage-"
language_image_version=$( cat "${IMAGES_DIR}/${LANGUAGE_ID}/version.txt" | tr -d " " | tr -d "\n" )
language_image_name="${DEFAULT_IMAGE_PREFIX}${LANGUAGE_ID}"
language_image_tag="${language_image_name}:${language_image_version}"

echo "Running ${language_image_tag} from the local docker registry"
if [[ "${DEBUG}" == "true" ]]; then
    echo "*************************"
    echo "* Running in Debug mode *"
    echo "*************************"
    docker run                                                                      \
          --interactive                                                             \
          --tty                                                                     \
          --entrypoint "/bin/bash"                                                  \
          --env AWS_ACCESS_KEY_ID=unused                                            \
          --env AWS_SECRET_KEY=unused                                               \
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
          ${language_image_tag}

else
    docker run                                                                      \
          --env AWS_ACCESS_KEY_ID=unused                                            \
          --env AWS_SECRET_KEY=unused                                               \
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
          ${language_image_tag}
fi
