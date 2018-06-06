ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN set -ex; \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        build-essential \
        ca-certificates \
        gcc \
        git \
        libpq-dev \
        make \
        python-pip \
        python2.7 \
        python2.7-dev \
        ssh \
    && apt-get autoremove \
    && apt-get clean

RUN pip install -U "setuptools==3.4.1"
RUN pip install -U "pip==1.5.4"
RUN pip install -U "Mercurial==2.9.1"
RUN pip install -U "virtualenv==1.11.4"
