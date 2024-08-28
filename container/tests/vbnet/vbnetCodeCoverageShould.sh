#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "vbnet" "main" "SUM" "100"
computeCoverageForChallenge "vbnet" "main" "TST" "50"
computeCoverageForChallenge "vbnet" "main" "CHK" "0"

checkForFailingCoverageResults "vbnet" "main" "xyz" ""

displayPassFailSummary
