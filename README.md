# dpnt-coverage

Collect coverage from SRCS files

- [Java](./container/images/java/)
- [Scala](./container/images/scala/)
- [Hmmm](./container/images/hmmm/)

### Updating sub-modules

Root project contains three git submodules:

- local-sqs
- local-s3
- local-ecs

Run the below command in the project root to update the above submodules:

```bash
git submodule update --init
```

## Acceptance test

Start the local S3 and SQS simulators
```bash
python3 local-sqs/elasticmq-wrapper.py start
python3 local-s3/minio-wrapper.py start
```

We use the `hmmm` language to test the application.
The language container image needs to be build and tagged as `latest`:
```bash
./container/buildDockerImage.sh hmmm
```

**Note: to avoid failing CoverageDatapointAcceptanceTest acceptance tests due to timeouts please follow the below instructions** 

Start the local ECS simulator. The simulator will use the containers available in the local Docker registry.

Try the below first:

```bash 
ping host.docker.internal
```

If there is response, run the below command:

```bash
python local-ecs/ecs-server-wrapper.py start config/local.params.yml
```

Otherwise see below:

A note on the container networking. The container will attempt to call services on the docker host by using the `host.docker.internal` name.
https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds. 

Also see https://stackoverflow.com/questions/48546124/what-is-linux-equivalent-of-docker-for-mac-host-internal (especially for Windows or MacOS)
If this is not supported on your machine, you have the option of changing the hostname used to locate the Docker host:
```bash
DOCKER_HOST_WITHIN_CONTAINER=host.docker.internal python local-ecs/ecs-server-wrapper.py start config/local.params.yml
```
or

```bash
DOCKER_HOST_WITHIN_CONTAINER=n.n.n.n python local-ecs/ecs-server-wrapper.py start config/local.params.yml
```

#### Linux
`host.docker.internal` or `n.n.n.n` static ip address (for e.g. 172.17.0.1) on which the containers are running  

#### MacOS
`docker.for.mac.host.internal` or `docker.for.mac.localhost` or `n.n.n.n` - supported DNS entry of host (via Docker Host for MacOS) on which the containers are running 

#### Windows
`docker.for.win.host.internal` or `docker.for.win.localhost` or `n.n.n.n` - supported DNS entry of host (via Docker Host for Windows) on which the containers are running

### Run the acceptance test

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v "1.8.0_302")
./gradlew --rerun-tasks test
```

Stop dependencies
```bash
python3 local-sqs/elasticmq-wrapper.py stop
python3 local-ecs/ecs-server-wrapper.py stop
python3 local-s3/minio-wrapper.py stop
```

## Packaging

Install Serverless

Ensure you have new version (v6.4.0) of `npm` installed, installing `serverless` fails with older versions of npm:

```bash
brew install nvm

# add to ~/.bash_locations
. /usr/local/Cellar/nvm/0.39.1_1/nvm.sh

# Install the node version we know serverless works with
nvm install v12.13.0

# Install serverless 
npm install serverless@3.31.0

serverless --version
serverless info --stage dev
```

## Local testing

Build package
```bash
./gradlew clean test shadowJar
```

Setup local bucket

```bash
export AWS_PROFILE=befaster                      # pre-configured profile contained in ~/.aws/credentials

minio mb myminio
minio mb myminio/tdl-test-auth/TCH/user01/
minio cp ./build/resources/test/HmmmLang_R1Cov33_R2Cov44.srcs myminio/tdl-test-auth/TCH/user01/test1.srcs
```

Invoke function manually
```bash
SLS_DEBUG=* serverless invoke local --function call-ecs-to-compute-coverage --path ../dpnt-sourcecode/src/test/resources/tdl/datapoint/sourcecode/sample_s3_via_sns_event.json
```
or

```bash
SLS_DEBUG=* serverless invoke local --function call-ecs-to-compute-coverage --path src/test/resources/tdl/datapoint/coverage/sample_s3_via_sns_event.json
```

Note: the `sample_s3_via_sns_event.json` file contains the reference to the bucket `tdl-test-auth` and the key referring to the file at `TCH/user01/test1.srcs`.

## Container deployment

See the AWS ECR registry instructions on how to deploy a container into AWS


## Cluster deployment

Define an environment by duplicating the configuration file in `./config`

Get a Python env configured
```shell
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

Trigger AWS CloudFormation to deploy or update an ECS Cluster
```bash
./ecs-cluster-definition/deploy.sh dev
```

## Lambda deployment

Build package
```bash
./gradlew clean test shadowJar
```

Create config file for respective env profiles:

```bash
cp config/local.params.yml config/dev.params.yml
```

or

```bash
cp config/dev.params.yml config/live.params.yml
```

Setup environment variables

```bash
export AWS_PROFILE=befaster                        # pre-configured profile contained in ~/.aws/credentials
```

Deploy to DEV
```bash
serverless deploy --stage dev
```

Deploy to LIVE
```bash
serverless deploy --stage live
```

## Remote testing

Create an S3 event json and place it in a temp folder, say `xyz/s3_event.json`
Set the bucket and the key to some meaningful values.

Invoke the dev lambda
```bash
TEST_INPUT_SRCS="HLO/julian_2505/sourcecode_20230525T215055.srcs"

PAYLOAD_FILE=$(mktemp)
cat << EOF > ${PAYLOAD_FILE}
{
  "Records": [
    {
      "Sns": {
        "Message": "{\"Records\":[{\"s3\":{\"bucket\":{\"name\":\"tdl-test-auth\"},\"object\":{\"key\":\"${TEST_INPUT_SRCS}\"}}}]}"
      }
    }
  ]
}
EOF

SLS_DEBUG=* serverless invoke --stage dev --function call-ecs-to-compute-coverage --path ${PAYLOAD_FILE} --log
```

Check the destination queue for that particular environment.
Check the ECS Task status and logs

Note: the `sample_s3_via_sns_event.json` file contains the reference to the bucket `tdl-test-auth` and the key referring to the file at `TCH/user01/test1.srcs`.
