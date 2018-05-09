#!/usr/bin/env bash

set -e
set -u
set -o pipefail

REPO=$1
TAG=$2
CHALLENGE_ID=$3

echo "Switching to $HOME and cloning repo: ${REPO}"
git clone ${REPO} tdl-runner
cd tdl-runner

echo "Switching to tag: ${TAG}"
git checkout ${TAG}
git pull origin ${TAG}

echo "Running script to retrieve the code coverage for ${CHALLENGE_ID} for the repo ${REPO}"
./get_coverage_for_challenge.sh ${CHALLENGE_ID}
