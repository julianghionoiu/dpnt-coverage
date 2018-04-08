################################################################################
# Docker definition.
################################################################################
FROM ubuntu:16.04

# Installing dependencies
# Installing python
RUN apt-get update -y \
    && apt-get upgrade -y \
    ########### Installs Python dependencies
    && apt-get -y install \
        --no-install-recommends \
            python \
            python-pip \
    ########### Installs Java8 dependencies
    && apt-get install -y  software-properties-common \
        && add-apt-repository ppa:webupd8team/java -y \
        && apt-get update \
        && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
        && apt-get install -y oracle-java8-installer \
    && apt-get clean

# Downloading SRCS
RUN wget \
    -O /opt/dev-sourcecode-record.jar \
    https://github.com/julianghionoiu/dev-sourcecode-record/releases/download/v0.0.11/dev-sourcecode-record-0.0.11-all.jar
