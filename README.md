# dpnt-coverage
Collect coverage from SRCS files

# Directories
The main directories for this code

- cloudformation
  Contains cloudformation definition for CodeBuild runs the tests and collect coverage.
- docker
  Contains docker definition for CodeBuild image for running the test and collect the coverage.
- lambda
  Contains lambda definition that receives the SRCS files and execute the cloudformation to run the coverage.

# Docker Image

To run the docker image, execute

```
docker build -t julianghionoiu/tdl-coverage - < ./docker/Dockerfile
```

To test the docker image, execute

```
docker run \
        -v \"$PWD/etc":/tmp/etc/ \
    julianghionoiu/tdl-coverage \
        java -jar /opt/dev-sourcecode-record.jar \
            convert-to-git \
                --input /tmp/etc/test.srcs \
                --output /tmp/etc/output
```


# CloudFormation

To deploy cloudformation files

```
cd cloudformation
source ../.env.local && export $(cut -d= -f1 ../.env.local) && bash ./deploy.sh
```
