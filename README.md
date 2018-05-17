# dpnt-coverage
Collect coverage from SRCS files

- [Java](./java/README.md)


## Acceptance test

Start external dependencies
```bash
python local-sqs/elasticmq-wrapper.py start
python local-ecs/ecs-server-wrapper.py start
python local-s3/minio-wrapper.py start
```

Run the acceptance test

```
./gradlew --rerun-tasks test jacocoTestReport
```

Stop external dependencies
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

## Remote deployment

Build all container images.
Push images to ECR.

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
SLS_DEBUG=* serverless invoke --stage dev --function call-ecs-to-compute-coverage --path src/test/resources/tdl/datapoint/sourcecode/sample_s3_event.json
```

