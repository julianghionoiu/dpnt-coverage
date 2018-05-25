#!/usr/bin/env bash

computeCoverageForChallenge() {
   # given
   language_id=$1
   tag=$2
   repo="https://github.com/julianghionoiu/tdl-runner-${language_id}"
   challenge_id="$3"
   expectedResult="$4"
   participant_id="participant"
   round_id="round"
   (cd ../.. && ./buildDockerImage.sh ${language_id})
   exitCode=$?
   if [[ ${exitCode} -ne 0 ]]; then
      echo "Test failed during setup, due to failing to build docker image ${language_id} language"
      echo "   Actual exit code: ${exitCode}"
      echo "   Expected exit code: 0"
   fi

   # when
   actualResult=$( cd ../.. && ./runDockerContainer.sh ${language_id} ${participant_id} ${round_id} ${repo} ${tag} ${challenge_id} | tail -1 )

   # then
   exitCode=$?
   if [[ ${exitCode} -eq 0 ]]; then
      echo "Test passed"
   else
      echo "Test failed due to exit code mismatch"
      echo "   Actual exit code: ${exitCode}"
      echo "   Expected exit code: 0"
   fi

   if [[ "${actualResult}" = "${expectedResult}" ]]; then
      echo "Test passed"
   else
      echo "Test failed due to result mismatch"
      echo "   Actual result: '${actualResult}'"
      echo "   Expected result: '${expectedResult}'"
   fi

}

computeCoverageForChallenge "scala" "master" "SUM" "100"
computeCoverageForChallenge "scala" "master" "CHK" "0"
