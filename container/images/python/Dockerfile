ARG BASE_IMAGE
FROM ${BASE_IMAGE} as baseImage

COPY --from=python:3.7 / /

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN ln -sf ${JAVA_HOME}/bin/java /usr/bin/java

RUN python --version
RUN pip --version
RUN java -version

ENV WORKDIR /srv
WORKDIR ${WORKDIR}

# Precache dependencies for faster run - will populate the Pip cache
RUN wget https://raw.githubusercontent.com/julianghionoiu/tdl-runner-python/master/requirements.txt \
    -O /tmp/requirements.precache && \
    pip install -r /tmp/requirements.precache || true

ENTRYPOINT ${WORKDIR}/fetch_repo_and_collect_coverage.sh