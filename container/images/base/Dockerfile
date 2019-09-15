FROM buildpack-deps:stretch-scm

# Install python 3.7 by copy installed layers from another image
COPY --from=python:3.7 / /

RUN python3 --version
RUN pip --version

# Install Java 8
COPY --from=openjdk:8u222-jdk-slim /usr/local/openjdk-8 /usr/local/openjdk-8

ENV JAVA_HOME=/usr/local/openjdk-8
ENV PATH=${JAVA_HOME}/bin:${PATH}

RUN echo "JAVA_HOME=${JAVA_HOME}"
RUN echo "PATH=${PATH}"

RUN rm -fr /var/lib/apt/lists/*

RUN apt-get install --fix-missing && apt-get update && apt-get install -qy \
    groff-base \
    git \
    libxml2-utils \
    jq \
    dos2unix \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN pip install setuptools awscli

ENV WORKDIR /srv
WORKDIR ${WORKDIR}

ENV SRCS_VERSION 0.0.23
RUN wget https://github.com/julianghionoiu/dev-sourcecode-record/releases/download/v${SRCS_VERSION}/dev-sourcecode-record-${SRCS_VERSION}-all.jar \
    -O ${WORKDIR}/dev-sourcecode-record-all.jar

ENV INTEROP_QUEUE_VERSION 0.1.18
RUN wget https://github.com/julianghionoiu/tdl-interop-event-queue/releases/download/v${INTEROP_QUEUE_VERSION}/queue-cli-tool-${INTEROP_QUEUE_VERSION}-all.jar \
    -O ${WORKDIR}/queue-cli-tool-all.jar

COPY fetch_repo_and_collect_coverage.sh ${WORKDIR}

ENTRYPOINT ${WORKDIR}/fetch_repo_and_collect_coverage.sh