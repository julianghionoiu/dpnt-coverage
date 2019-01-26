#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

checkForFailingCoverageResults "java-replace-jacoco-with-clover" "java" "master" "xyz" "0"

displayPassFailSummary