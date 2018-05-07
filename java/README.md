# Java code coverage

Scripts for retrieving code coverage for `java` related `tdl-runner` projects.

`Dockerfile` contains definition of the image to build and copies `getLineCoverageFor.sh` into the `/home/ubuntu` directory. The `buildDockerImage.sh` script builds the needed base docker image. It takes two parameters i.e. image name and image version, which by default are set (see script for default values).

Usage `getLineCoverageFor.sh`:

Takes in 3 parameters:
	- repo url i.e.  https://github.com/julianghionoiu/tdl-runner-java.git    
	- tag name i.e. xxx-2.0
	- challengeId i.e. HLO