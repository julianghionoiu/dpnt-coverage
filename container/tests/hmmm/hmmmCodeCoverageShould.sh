#!/usr/bin/env bash

set -e
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SCRIPT_CURRENT_DIR}/../test-framework/test-coverage-functions.sh

computeCoverageForChallenge "hmmm" "TCH_R1/done" "SUM" "33"
computeCoverageForChallenge "hmmm" "TCH_R2/done" "SUM" "44"

computeCoverageForChallenge "hmmm" "CRLF/test" "SUM" "55"

displayPassFailSummary
