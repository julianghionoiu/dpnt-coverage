ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG RUBY_VERSION
ENV RUBY_VERSION="2.2.2"

RUN /bin/bash -l -c "curl -sL https://deb.nodesource.com/setup_8.x | bash -"
RUN /bin/bash -l -c "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -"
RUN /bin/bash -l -c 'echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list'

RUN apt-get update && apt-get install -qy \
    autoconf \
    automake \
    bison \
    build-essential \
    curl \
    g++ \
    gawk \
    gcc \
    git-core \
    libc6-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libreadline-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libssl1.0.0 \
    libtool \
    libxslt1-dev \
    libyaml-dev \
    libxml2-dev \
    make \
    nodejs \
    openssl \
    patch \
    pkg-config \
    software-properties-common \
    python-software-properties \
    sqlite3 \
    yarn  \
    zlib1g-dev \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN /bin/bash -l -c "echo progress-bar >> ~/.curlrc"
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN echo "Downloading and installing 'rvm'" && curl -sSL https://get.rvm.io | bash -s stable

RUN echo "Downloading and installing 'rbenv'" && git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN echo "export PATH=$HOME/.rbenv/bin:$PATH" >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
RUN echo 'export PATH="$HOME/.rbenv/versions/${RUBY_VERSION}/bin:$PATH"' >> ~/.bashrc

RUN /bin/bash -l -c "echo Downloading and installing \'ruby via rbenv\'"
RUN /bin/bash -l -c "curl -fsSL https://gist.github.com/mislav/055441129184a1512bb5.txt | rbenv install --patch ${RUBY_VERSION}"
RUN /bin/bash -l -c "rbenv global ${RUBY_VERSION}"
RUN /bin/bash -l -c "ruby --version"
RUN /bin/bash -l -c "gem install bundler"
RUN /bin/bash -l -c "rbenv rehash"
