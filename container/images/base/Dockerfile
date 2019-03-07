FROM java:8u111-jdk
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

COPY --from=python:3.7 / /

RUN python --version
RUN pip --version
RUN java -version

RUN apt-get update && apt-get install -qy \
    groff-base \
    git \
    libxml2-utils \
    jq \
    dos2unix \
    --no-install-recommends && rm -r /var/lib/apt/lists/*
RUN pip install awscli

ENV WORKDIR /srv
WORKDIR ${WORKDIR}

ENV SRCS_VERSION 0.0.15
RUN wget https://github.com/julianghionoiu/dev-sourcecode-record/releases/download/v${SRCS_VERSION}/dev-sourcecode-record-${SRCS_VERSION}-all.jar \
    -O ${WORKDIR}/dev-sourcecode-record-all.jar

ENV INTEROP_QUEUE_VERSION 0.1.18
RUN wget https://github.com/julianghionoiu/tdl-interop-event-queue/releases/download/v${INTEROP_QUEUE_VERSION}/queue-cli-tool-${INTEROP_QUEUE_VERSION}-all.jar \
    -O ${WORKDIR}/queue-cli-tool-all.jar

COPY fetch_repo_and_collect_coverage.sh ${WORKDIR}

ENTRYPOINT ${WORKDIR}/fetch_repo_and_collect_coverage.sh
