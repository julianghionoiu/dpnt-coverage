#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

# To check if an ENV variable exists, we dereference the input string $1 -> !1
# then then we attempt parameter expansion with the "+x" string
# it should return an empty string if ENV not defined
# Reference: https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
function ensure_env {
    if [ -z "${!1+x}" ]; then echo "Environment variable $1 not set"; exit 1; fi
}

ensure_env "WORK_DIR"

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

# Configure local files
LOCAL_REPO_DESTINATION="${WORK_DIR}/tdl-runner"
LOCAL_SRCS_FILE="${WORK_DIR}/file.srcs"


echo  "~~~~~~ Clone and switch to TAG ~~~~~~" > /dev/null
if [[ "${REPO}" == s3://* ]]; then
    echo "S3 based SRCS file detected"
    aws s3  --endpoint-url ${S3_ENDPOINT} \
            --region ${S3_REGION} \
            --no-verify-ssl \
            cp ${REPO} ${LOCAL_SRCS_FILE}
    java -jar "${WORK_DIR}/dev-sourcecode-record-all.jar" export \
        --input ${LOCAL_SRCS_FILE} \
        --output ${LOCAL_REPO_DESTINATION} \
        --tag ${TAG}
else
    echo "Assuming Git repo"
    git clone ${REPO} ${LOCAL_REPO_DESTINATION}
    local_git="git --git-dir=${LOCAL_REPO_DESTINATION}/.git --work-tree=${LOCAL_REPO_DESTINATION}"
    ${local_git} checkout ${TAG}
    ${local_git} pull origin ${TAG}
fi


# Run the coverage
COVERAGE_SCRIPT="${LOCAL_REPO_DESTINATION}/get_coverage_for_challenge.sh"
chmod a+x ${COVERAGE_SCRIPT}
sed -i 's/\r//g' ${COVERAGE_SCRIPT} `# Remove Windows carriage returns`
echo  "~~~~~~ START run external script ~~~~~~" > /dev/null
${COVERAGE_SCRIPT} ${CHALLENGE_ID}
echo "~~~~~~ STOP run external script ~~~~~~" > /dev/null


echo  "~~~~~~ Publish results ~~~~~~" > /dev/null
COVERAGE_VALUE=$(cat "${LOCAL_REPO_DESTINATION}/coverage.tdl" | tr -d " " | tr -d "\n")
INTEROP_QUEUE_CONFIG="${WORK_DIR}/sqs_queue.conf"
cat > ${INTEROP_QUEUE_CONFIG} <<EOL
sqs {
  serviceEndpoint = "${SQS_ENDPOINT}"
  signingRegion = "${SQS_REGION}"
  queueUrl = "${SQS_QUEUE_URL}"
}
EOL


if [[ "${SQS_QUEUE_URL}" == *queue* ]]; then
    echo "Publish coverage to interop event queue"
    cat ${INTEROP_QUEUE_CONFIG}
    DRY_RUN=false java -Dconfig.file="${INTEROP_QUEUE_CONFIG}" \
        -jar "${WORK_DIR}/queue-cli-tool-all.jar" \
        send coverageComputed \
        participant=${PARTICIPANT_ID} roundId=${ROUND_ID} coverage=${COVERAGE_VALUE}
else
    echo "participant=${PARTICIPANT_ID} roundId=${ROUND_ID} coverage=${COVERAGE_VALUE}"
fi



