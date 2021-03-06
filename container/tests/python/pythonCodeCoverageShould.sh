#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "python" "master" "SUM" "100"
computeCoverageForChallenge "python" "master" "TST" "50"
computeCoverageForChallenge "python" "master" "CHK" "0"

checkForFailingCoverageResults "python" "master" "xyz" ""

displayPassFailSummary
