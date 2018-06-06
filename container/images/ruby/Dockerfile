ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG RUBY_VERSION
ENV RUBY_VERSION="2.2.2"

RUN /bin/bash -l -c "curl -sL https://deb.nodesource.com/setup_8.x | bash -"
RUN /bin/bash -l -c "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -"
RUN /bin/bash -l -c 'echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list'

RUN apt-get update && apt-get install -qy \
    ruby \
    ruby-dev \
    ruby-bundler \
    curl \
    openssl \
    patch \
    gawk \
    g++ \
    gcc \
    make \
    libc6-dev \
    libreadline6-dev \
    zlib1g-dev \
    libssl-dev \
    libyaml-dev \
    libsqlite3-dev \
    sqlite3 \
    autoconf \
    libgdbm-dev \
    libncurses5-dev \
    automake \
    libtool \
    bison \
    pkg-config \
    libffi-dev \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"
RUN /bin/bash -l -c "rvm install ${RUBY_VERSION}"
RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c "echo 'source /etc/profile.d/rvm.sh' > ~/.bashrc"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
