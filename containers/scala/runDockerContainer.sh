#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO=$1
TAG=$2	
CHALLENGE_ID=$3

dockerImageName="accelerate-io/dpnt-coverage-scala"
dockerImageVersion="0.1"

echo "Quickly triggering a re-build of the docker image '${dockerImageName}":"${dockerImageVersion}'"
${SCRIPT_CURRENT_DIR}/buildDockerImage.sh "${dockerImageName}" "${dockerImageVersion}"

echo "Running ${dockerImageName}":"${dockerImageVersion} from the local docker registry"
docker run                                                                      \
      --rm                                                                      \
      --interactive                                                             \
      --workdir=/home/ubuntu                                                    \
      --env REPO=${REPO}                                                        \
      --env TAG=${TAG}                                                          \
      --env CHALLENGE_ID=${CHALLENGE_ID}                                        \
      ${dockerImageName}:${dockerImageVersion}
