#!/usr/bin/env bash

set -e
set -u
set -o pipefail

repo=$1
tag=$2	
challengeId=$3

dockerImageName="accelerate-io/tdl-runner-java"
dockerImageVersion="v01"
WORKING_DIR="/home/ubuntu/"

echo "Checking for the presence of ${dockerImageName}":"${dockerImageVersion} in the local docker registry"
foundDockerImage=$(docker images --filter="reference=${dockerImageName}" | grep "${dockerImageName}" || true)
if [[ -z ${foundDockerImage} ]]; then
  ./docker/buildDockerImage.sh "${dockerImageName}" "${dockerImageVersion}"

  if [[ $? -ne 0 ]]; then
    echo "There was a problem building the docker image needed to run this task, process exited with error code '$?'"
    exit -1
  fi
fi

echo "Running ${dockerImageName}":"${dockerImageVersion} from the local docker registry"
docker run                                                                      \
      --rm                                                                      \
      --interactive                                                             \
      --volume ${PWD}/getLineCoverageFor.sh:/home/ubuntu/getLineCoverageFor.sh  \
      --workdir=${WORKING_DIR}                                                  \
      ${dockerImageName}:${dockerImageVersion}                                  \
        ./getLineCoverageFor.sh ${WORKING_DIR} ${repo} ${tag} ${challengeId}
