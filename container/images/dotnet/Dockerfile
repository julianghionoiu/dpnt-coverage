ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -qy \
    mono-complete \
    mono-devel    \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN mono --version
