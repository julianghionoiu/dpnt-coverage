#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "scala" "master" "SUM" "100"
computeCoverageForChallenge "scala" "master" "TST" "50"
computeCoverageForChallenge "scala" "master" "CHK" "0"
computeCoverageForChallenge "scala" "master" "xyz" "0"

displayPassFailSummary