#!/usr/bin/env bash

set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO=$1
TAG=$2	
CHALLENGE_ID=$3

dockerImageName="accelerate-io/dpnt-coverage-java"
dockerImageVersion="0.1"

echo "Checking for the presence of ${dockerImageName}":"${dockerImageVersion} in the local docker registry"
foundDockerImage=$(docker images --filter="reference=${dockerImageName}" | grep "${dockerImageName}" || true)
if [[ -z ${foundDockerImage} ]]; then
  ${SCRIPT_CURRENT_DIR}/buildDockerImage.sh "${dockerImageName}" "${dockerImageVersion}"

  if [[ $? -ne 0 ]]; then
    echo "There was a problem building the docker image needed to run this task, process exited with error code '$?'"
    exit -1
  fi
fi

echo "Running ${dockerImageName}":"${dockerImageVersion} from the local docker registry"
docker run                                                                      \
      --rm                                                                      \
      --interactive                                                             \
      --workdir=/home/ubuntu                                                    \
      --env REPO=${REPO}                                                        \
      --env TAG=${TAG}                                                          \
      --env CHALLENGE_ID=${CHALLENGE_ID}                                        \
      ${dockerImageName}:${dockerImageVersion}
