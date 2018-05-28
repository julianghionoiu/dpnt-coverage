#!/usr/bin/env bash

set -e
set -o pipefail

passedTests=()
failedTests=()

computeCoverageForChallenge() {
   # given
   SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   language_id=$1
   tag=$2
   repo="https://github.com/julianghionoiu/tdl-runner-${language_id}"
   challenge_id="$3"
   expectedResult="$4"
   participant_id="participant"
   round_id="round"

   echo "~~~~~~~~~~~~~~~~ Starting test ~~~~~~~~~~~~~~~~~"
   dockerImagePresent=$(docker images -q -f reference=accelerate-io/dpnt-coverage-${language_id}:latest)
   if [[ -z "${dockerImagePresent}" ]]; then
      echo "Test failed during setup, due to failing to find docker image for ${language_id} language" 1>&2
      testOutcome "Failed" "${language_id}" "${challenge_id}" "${participant_id}" "${round_id}"
      return
   fi

   # when
   actualResult=$( . ${SCRIPT_CURRENT_DIR}/../../runDockerContainer.sh ${language_id} ${participant_id} ${round_id} ${repo} ${tag} ${challenge_id} | tail -1 )
   actualResult=$(echo ${actualResult} | awk '{print coverage, $3}' | tr '="' ' ' | awk '{print $2}')

   # then
   exitCode=$?
   if [[ ${exitCode} -ne 0 ]]; then
      echo "Test failed due to non-zero exit code" 1>&2
      echo "   Actual exit code: ${exitCode}"      1>&2
      echo "   Expected exit code: 0"              1>&2
   fi

   if [[ "${actualResult}" = "${expectedResult}" ]]; then
      echo "Test passed"
      testOutcome "Passed" "${language_id}" "${challenge_id}" "${participant_id}" "${round_id}"
   else
      echo "Test failed due to result mismatch"      1>&2
      echo "   Actual result: '${actualResult}'"     1>&2
      echo "   Expected result: '${expectedResult}'" 1>&2
      testOutcome "Failed" "${language_id}" "${challenge_id}" "${participant_id}" "${round_id}"
   fi
}

testOutcome() {
    outcome="$1"
    language_id="$2"
    challenge_id="$3"
    participant_id="$4"
    round_id="$5"

    if [[ "${outcome}" = "Passed" ]]; then
        passedTests+=("language=${language_id}|challenge=${challenge_id}|participant=${participant_id}|round=${round_id}")
    elif [[ "${outcome}" = "Failed" ]]; then
        failedTests+=("language=${language_id}|challenge=${challenge_id}|participant=${participant_id}|round=${round_id}")
    fi
}

displayPassFailSummary(){
    echo ""
    echo "~~~ Summary of test executions ~~~"
    echo "  ~~~ Passed Tests ~~~"
    for passedTest in ${passedTests[@]}
    do
        echo "  ${passedTest}"
    done
    echo "  ${#passedTests[@]} test(s) passed"

    echo ""
    echo "  ~~~ Failed Tests ~~~"
    for failedTest in ${failedTests[@]}
    do
        echo "  ${failedTest}"
    done
    echo "  ${#failedTests[@]} test(s) failed"
}
