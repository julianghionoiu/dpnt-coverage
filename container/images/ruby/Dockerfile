ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV RUBY_VERSION="2.2.2"

# Manually install dependency to be able to clean up after ourselves
RUN apt-get update && apt-get install -qy \
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
    libgmp-dev \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -L get.rvm.io | bash -s stable
ENV RVM_PATH  /usr/local/rvm
ENV PATH      ${RVM_PATH}/bin:${PATH}

# Install RUBY
RUN rvm install ${RUBY_VERSION}
RUN rvm --default use ${RUBY_VERSION}
ENV RUBY_PATH /usr/local/rvm/rubies/ruby-${RUBY_VERSION}
ENV GEM_HOME  /usr/local/rvm/gems/ruby-${RUBY_VERSION}
ENV GEM_PATH  ${GEM_HOME}:${GEM_PATH}
ENV PATH      ${RUBY_PATH}/bin:${GEM_HOME}/bin:${PATH}
RUN rvm info

# Install BUNDLER
RUN echo 'gem: --no-ri --no-rdoc' > ~/.gemrc
RUN gem install bundler --no-ri --no-rdoc

# Precache dependencies for faster run
RUN wget https://raw.githubusercontent.com/julianghionoiu/tdl-runner-ruby/master/Gemfile \
    -O /tmp/Gemfile.precache && \
    bundle install --gemfile=/tmp/Gemfile.precache