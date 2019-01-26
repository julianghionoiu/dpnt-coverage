#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

# This test is expected to pass, as we are expecting a non-zero exit code returned by the docker container execution
checkForFailingCoverageResults "java-replace-jacoco-with-clover" "java" "master" "xyz" ""               # no results

displayPassFailSummary