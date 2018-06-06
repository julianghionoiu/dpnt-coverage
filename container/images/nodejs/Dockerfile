ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base dependencies
RUN apt-get update && apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /root/.nvm
ENV NVM_VERSION 0.33.11
ENV NODE_VERSION 5.6.0

RUN mkdir -p ${NVM_DIR}

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash \
    && . ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default

ENV NODE_PATH ${NVM_DIR}/v${NODE_VERSION}/lib/node_modules
ENV PATH      ${NVM_DIR}/v${NODE_VERSION}/bin:${PATH}

RUN /bin/bash -l -c 'echo "***** nvm version $(nvm --version) *****"'
RUN /bin/bash -l -c 'echo "***** npm version $(npm --version) *****"'
RUN /bin/bash -l -c 'echo "***** node version $(node --version) *****"'
