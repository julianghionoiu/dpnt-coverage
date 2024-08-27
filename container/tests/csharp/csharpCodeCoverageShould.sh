#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "csharp" "main" "SUM" "100"
computeCoverageForChallenge "csharp" "main" "TST" "50"
computeCoverageForChallenge "csharp" "main" "CHK" "0"

checkForFailingCoverageResults "csharp" "main" "xyz" ""

displayPassFailSummary
