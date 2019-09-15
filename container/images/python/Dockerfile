ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN python --version

# Precache dependencies for faster run - will populate the Pip cache
RUN wget https://raw.githubusercontent.com/julianghionoiu/tdl-runner-python/master/requirements.txt \
    -O /tmp/requirements.precache && \
    pip install -r /tmp/requirements.precache || true
