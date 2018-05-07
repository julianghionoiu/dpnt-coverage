#!/usr/bin/env bash

set -e
set -u
set -o pipefail

workingDir=$1
repo=$2
tag=$3
challengeId=$4

echo "Switching to $HOME and cloning repo: ${repo}"
cd ${workingDir} && git clone ${repo} tdl-runner
cd ${workingDir}/tdl-runner

echo "Switching to tag: ${tag}"
git checkout ${tag}
git pull origin ${tag}

echo "Running script to retrieve the code coverage for ${challengeId} for the repo ${repo}"
./getCodeCoverageFor.sh ${challengeId}
