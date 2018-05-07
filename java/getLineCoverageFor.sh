#!/usr/bin/env bash

set -e
set -u
set -o pipefail

repo=$1
tag=$2	
challengeId=$3

echo "Switching to $HOME and cloning repo: ${repo}"
cd $HOME && git clone ${repo} tdl-runner
cd $HOME/tdl-runner

echo "Switching to tag: ${tag}"
git checkout ${tag}
git pull origin ${tag}

echo "Running .gradlew to download gradle wrapper"
# chmod +x gradlew
# ./gradlew

echo "Running script to retrieve the code coverage for ${challengeId} for the repo ${repo}"
./getCodeCoverageFor.sh ${challengeId}