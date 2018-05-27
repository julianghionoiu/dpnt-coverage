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
 
```
git submodule update --init
```

## Acceptance test

Start the local S3 and SQS simulators
```bash
python local-sqs/elasticmq-wrapper.py start
python local-s3/minio-wrapper.py start
```

We use the `hmmm` language to test the application.
The language container image needs to be build and tagged as `latest`:
```
./container/buildDockerImage.sh hmmm
```

Start the local ECS simulator. The simulator will use the containers available in the local Docker registry.
```bash
python local-ecs/ecs-server-wrapper.py start config/local.params.yml
```

A note on the container networking. The container will attempt to call sevices on the docker host by using the `host.docker.internal` name.
https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds. 

Also see https://stackoverflow.com/questions/48546124/what-is-linux-equivalent-of-docker-for-mac-host-internal
If this is not supported on your machine, you have the option of changing the hostname used to locate the Docker host:
```bash
DOCKER_HOST_WITHIN_CONTAINER=host.docker.internal python local-ecs/ecs-server-wrapper.py start config/local.params.yml
```
or

```bash
DOCKER_HOST_WITHIN_CONTAINER=n.n.n.n python local-ecs/ecs-server-wrapper.py start config/local.params.yml
```

`host.docker.internal` should be static ip address or supported DNS entry of host (via Docker Host for Mac/Windows) on which the containers are running.

Run the acceptance test

```
./gradlew --rerun-tasks test jacocoTestReport
```

Stop dependencies
```bash
python local-sqs/elasticmq-wrapper.py stop
python local-ecs/ecs-server-wrapper.py stop
python local-s3/minio-wrapper.py stop
```

## Packaging

Install Serverless
```
npm install -g serverless

serverless info
```

## Local testing

Build package
```
./gradlew clean test shadowJar
```

Invoke function manually
```
SLS_DEBUG=* serverless invoke local --function srcs-github-export --path tdl/dpnt-sourcecode/src/test/resources/tdl/datapoint/sourcecode/sample_s3_event.json
```

## Container deployment

See the AWS ECR registry instructions on how to deploy a container into AWS


## Cluster deployment

Define an environment by dupicating the configuration file in `./config`

Trigger AWS CloudFormation to deploy or update an ECS Cluster
```
./ecs-cluster-definition/deploy.sh dev
```

## Lambda deployment

Build package
```
./gradlew clean test shadowJar
```

Deploy to DEV
```
serverless deploy --stage dev
```

Deploy to LIVE
```
serverless deploy --stage live
```

## Remote testing

Create an S3 event json and place it in a temp folder, say `xyz/s3_event.json`
Set the bucket and the key to some meaningful values.

Invoke the dev lambda
```
SLS_DEBUG=* serverless invoke --stage dev --function call-ecs-to-compute-coverage --path src/test/resources/tdl/datapoint/coverage/sample_s3_event.json
```

Check the destination queue for that particular environment.
Check the ECS Task status and logs