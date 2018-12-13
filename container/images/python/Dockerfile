ARG BASE_IMAGE
FROM ${BASE_IMAGE} as baseImageLayer

FROM python:2.7.15-stretch

RUN python --version
RUN pip --version

# If we could copy the entire layer from the previous stage it would just be ideal, unfortunately 
ENV WORKDIR srv
WORKDIR ${WORKDIR}

COPY --from=baseImageLayer ${WORKDIR} ${WORKDIR}
COPY --from=baseImageLayer /usr/bin/git /usr/bin/git
COPY --from=baseImageLayer /usr/bin/groff /usr/bin/groff
COPY --from=baseImageLayer /usr/bin/jq /usr/bin/jq
COPY --from=baseImageLayer /usr/bin/dos2unix /usr/bin/dos2unix
COPY --from=baseImageLayer /usr/bin/xmllint /usr/bin/xmllint 
COPY --from=baseImageLayer /usr/share/man/man1/xmllint.1.gz /usr/share/man/man1/xmllint.1.gz

# Precache dependencies for faster run - will populate the Pip cache
RUN wget https://raw.githubusercontent.com/julianghionoiu/tdl-runner-python/master/requirements.txt \
    -O /tmp/requirements.precache && \
    pip install -r /tmp/requirements.precache

ENTRYPOINT ${WORKDIR}/fetch_repo_and_collect_coverage.sh