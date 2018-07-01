#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

SCRIPT_CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# To check if an ENV variable exists, we dereference the input string $1 -> !1
# then then we attempt parameter expansion with the "+x" string
# it should return an empty string if ENV not defined
# Reference: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
function ensure_env {
    if [ -z "${!1+x}" ]; then echo "Environment variable $1 not set"; exit 1; fi
}

WORK_DIR=${SCRIPT_CURRENT_DIR}

ensure_env "S3_ENDPOINT"
ensure_env "S3_REGION"

ensure_env "SQS_ENDPOINT"
ensure_env "SQS_REGION"
ensure_env "SQS_QUEUE_URL"

ensure_env "PARTICIPANT_ID"
ensure_env "ROUND_ID"
ensure_env "REPO"
ensure_env "TAG"
ensure_env "CHALLENGE_ID"

echo  "~~~~~~ Clone and switch to TAG ~~~~~~" > /dev/null
LOCAL_REPO_DESTINATION="${WORK_DIR}/tdl-runner"
if [[ "${REPO}" == s3://* ]]; then
    echo "S3 based SRCS file detected"
    local_srcs_file="${WORK_DIR}/file.srcs"
    aws s3  --endpoint-url ${S3_ENDPOINT} \
            --region ${S3_REGION} \
            cp ${REPO} ${local_srcs_file}
    java -jar "${WORK_DIR}/dev-sourcecode-record-all.jar" export \
        --input ${local_srcs_file} \
        --output ${LOCAL_REPO_DESTINATION} \
        --tag ${TAG}
else
    echo "Assuming Git repo"
    git clone --branch ${TAG} --depth 1 ${REPO} ${LOCAL_REPO_DESTINATION}
fi
# Output: Repo available at ${LOCAL_REPO_DESTINATION}

echo  "~~~~~~ Convert from Dos to Unix - in case format is in non-unix format ~~~~~~" > /dev/null
pushd .
cd ${LOCAL_REPO_DESTINATION}
# Re-initialise repo, the dest might be a SRCS file
git init
git add --all
# -I         <== do not match pattern i binary files
# -l         <== only show the matching file names
# -e 'xxx'   <== match regex pattern
git grep --cached -I -l -e $'\r' | xargs -n1 -I "{}" dos2unix "{}" || true
popd
# Output: Repo text files guaranteed to have unix LF as newline

# Run the coverage
COVERAGE_SCRIPT="${LOCAL_REPO_DESTINATION}/get_coverage_for_challenge.sh"
chmod a+x ${COVERAGE_SCRIPT}
sed -i 's/\r//g' ${COVERAGE_SCRIPT} `# Remove Windows carriage returns`
echo  "~~~~~~ START run external script ~~~~~~" > /dev/null
${COVERAGE_SCRIPT} ${CHALLENGE_ID}
echo "~~~~~~ STOP run external script ~~~~~~" > /dev/null
COVERAGE_FILE="${LOCAL_REPO_DESTINATION}/coverage.tdl"
# Output: Coverage value available at ${COVERAGE_FILE}

echo  "~~~~~~ Publish results ~~~~~~" > /dev/null
coverage_value=$(cat "${COVERAGE_FILE}" | tr -d " " | tr -d "\n")

if [[ "${SQS_QUEUE_URL}" != http* ]]; then
    echo "SQS_QUEUE_URL does not seem to be valid. Will print to the console and exit" > /dev/null
    echo "participant=${PARTICIPANT_ID} roundId=${ROUND_ID} coverage=${coverage_value}"
    exit 0
fi

echo "Publish coverage to interop event queue" > /dev/null
INTEROP_QUEUE_CONFIG="${WORK_DIR}/sqs_queue.conf"
cat > ${INTEROP_QUEUE_CONFIG} <<EOL
sqs {
  serviceEndpoint = "${SQS_ENDPOINT}"
  signingRegion = "${SQS_REGION}"
  queueUrl = "${SQS_QUEUE_URL}"
}
EOL
cat ${INTEROP_QUEUE_CONFIG}
DRY_RUN=false java -Dconfig.file="${INTEROP_QUEUE_CONFIG}" \
    -jar "${WORK_DIR}/queue-cli-tool-all.jar" \
    send coverageComputed \
    participant=${PARTICIPANT_ID} roundId=${ROUND_ID} coverage=${coverage_value}
# Output: Coverage value published to SQS or printed on the console


