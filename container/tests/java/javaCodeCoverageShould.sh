#!/usr/bin/env bash

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

   dockerImagePresent=$(docker images -q -f reference=accelerate-io/dpnt-coverage-${language_id}:latest)
   if [[ -z "${dockerImagePresent}" ]] || [[ $? -ne 0 ]]; then
      echo "Test failed during setup, due to failing to find docker image for ${language_id} language" 1>&2
   fi

   # when
   actualResult=$( . ${SCRIPT_CURRENT_DIR}/../../runDockerContainer.sh ${language_id} ${participant_id} ${round_id} ${repo} ${tag} ${challenge_id} | tail -1 )

   # then
   exitCode=$?
   if [[ ${exitCode} -eq 0 ]]; then
      echo "Test passed"
   else
      echo "Test failed due to exit code mismatch" 1>&2
      echo "   Actual exit code: ${exitCode}"      1>&2
      echo "   Expected exit code: 0"              1>&2
   fi

   if [[ "${actualResult}" = "${expectedResult}" ]]; then
      echo "Test passed"
   else
      echo "Test failed due to result mismatch"      1>&2
      echo "   Actual result: '${actualResult}'"     1>&2
      echo "   Expected result: '${expectedResult}'" 1>&2
   fi

}

computeCoverageForChallenge "java" "adjust-script-to-run-with-new-changes" "SUM" "100"
computeCoverageForChallenge "java" "adjust-script-to-run-with-new-changes" "CHK" "0"
