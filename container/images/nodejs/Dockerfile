ARG BASE_IMAGE
FROM --platform=linux/amd64 ${BASE_IMAGE}

ENV NVM_DIR /root/.nvm
ENV NVM_VERSION 0.34.0
ENV NODE_VERSION 10.16.3

RUN mkdir -p ${NVM_DIR}

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash \
    && . ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default \
    && npm install -g npm

ENV NODE_MODULES_PATH ${NVM_DIR}/v${NODE_VERSION}/lib/node_modules
ENV NODE_PATH ${NVM_DIR}/versions/node/v${NODE_VERSION}
ENV PATH      ${NODE_PATH}/bin:${NODE_MODULES_PATH}/bin:${PATH}

RUN npm --version
RUN node --version

# Precache dependencies for faster run - will populate the npm cache (~/.npm/_cacache)
ENV NPM_BUILD_TMP /tmp/nodejs
RUN mkdir -p ${NPM_BUILD_TMP} && \
    git clone --depth 1 https://github.com/julianghionoiu/tdl-runner-nodejs.git ${NPM_BUILD_TMP}
RUN ( cd ${NPM_BUILD_TMP} && npm install --g)