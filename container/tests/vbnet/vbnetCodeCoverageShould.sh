#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "vbnet" "master" "SUM" "100"
computeCoverageForChallenge "vbnet" "master" "TST" "50"
computeCoverageForChallenge "vbnet" "master" "CHK" "0"
computeCoverageForChallenge "vbnet" "master" "xyz" "0"

displayPassFailSummary
