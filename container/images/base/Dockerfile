FROM java:8u111-jdk

RUN apt-get update && apt-get install -qy \
    python-pip \
    groff-base \
    git \
    libxml2-utils \
    --no-install-recommends && rm -r /var/lib/apt/lists/*
RUN pip install awscli

WORKDIR /srv

ENV SRCS_VERSION 0.0.12
RUN wget https://github.com/julianghionoiu/dev-sourcecode-record/releases/download/v${SRCS_VERSION}/dev-sourcecode-record-${SRCS_VERSION}-all.jar \
    -O ./dev-sourcecode-record-all.jar

ENV INTEROP_QUEUE_VERSION 0.1.18
RUN wget https://github.com/julianghionoiu/tdl-interop-event-queue/releases/download/v${INTEROP_QUEUE_VERSION}/queue-cli-tool-${INTEROP_QUEUE_VERSION}-all.jar \
    -O ./queue-cli-tool-all.jar

COPY fetch_repo_and_collect_coverage.sh .

ENTRYPOINT ./fetch_repo_and_collect_coverage.sh