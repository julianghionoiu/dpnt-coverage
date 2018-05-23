
# The coverage container

Use the scripts provided to create the language specific containers.

The build follows a multi-stage process:
1. Build the base image `./base`
2. Build the language specific image `./LANGUAGE_ID`

In order to run this in one go, you can use:
```
./buildDockerImage.sh <language_id>
```

## Versioning

Each folder, including `base` contains a `version.txt` file.
This file should be incremented when the version changes.

The `base` image version is injected into the language specific images via the use of ARG in Dockerfile.

The `latest` tag has a special meaning and it is used by the ECS local simulator to match the Docker container to be run.

If you want your container to be picked up and used by the ECS Task Run:
```
./makeLatest <language_id>
```

## Running

In a nutshell the container operate in 3 steps:
1. Get the target REPO
2. Compute coverage
3. Publish coverage

Step `1.` can work with either public Github repos or S3 SRCS files.
When working with S3 files, appropriate AWS S3 ENV variables should be provided.
Step `3.` can publish to console (`echo`) or to an SQS queue. If AWS SQS ENV variables are populated, SQS will be used.


## Manual Testing

The containers can be tested against public Git repos.
Example:
```
./runDockerContainer.sh hmmm participant round https://github.com/julianghionoiu/tdl-runner-hmmm TCH_R1/done TCH

# should display "coverage=33"
```
Running in this way will cover everything except reading from S3 and publishing to SQS.


## Automated Testing

By running the `local-ecs` and then the Acceptance test, one will cover the:
- passing AWS ENV variables into container
- reading SRCS from S3
- exporting SRCS files to local folders
- publishing coverage data to SQS

This testing does not cover language specific support. That should be covered by the container tests.


