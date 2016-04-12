FROM ubuntu:14.04

RUN apt-get update && apt-get install -y git-core \
  curl \
  zlib1g-dev \
  build-essential \
  libssl-dev \
  libreadline-dev \
  libyaml-dev \
  libsqlite3-dev \
  sqlite3 \
  libxml2-dev \
  libxslt1-dev \
  libcurl4-openssl-dev \
  python-software-properties \
  libffi-dev \
  software-properties-common

# Install Haskell compiler
RUN add-apt-repository -y ppa:hvr/ghc
RUN apt-get update && apt-get install -y --force-yes ghc-7.10.2
ENV PATH /opt/ghc/7.10.2/bin:$PATH

# Install nodejs 
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g elm@0.16.0
ENV PATH /usr/lib/node_modules/elm/Elm-Platform/0.16.0/.cabal-sandbox/bin:$PATH

# Setup concourse use and home environment
RUN useradd dev
RUN mkdir -p /home/dev/bin /home/dev/.local/bin /home/dev/.stack && chown -R dev: /home/dev
ENV PATH /home/dev/bin:/home/dev/.local/bin:$PATH
ENV HOME /home/dev
WORKDIR /home/dev

# Install stack
RUN curl --retry 3 -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack'

# Install Ruby 2.2.0 with rbenv
USER dev
RUN git clone https://github.com/rbenv/rbenv.git .rbenv
RUN cd .rbenv && src/configure && make -C src
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
ENV PATH /home/dev/.rbenv/shims:/home/dev/.rbenv/bin:$PATH
RUN eval "$(rbenv init -)"

RUN rbenv install -v 2.2.0 && rbenv global 2.2.0
RUN gem install bundler
RUN bundle config --global silence_root_warning 1

USER root
RUN apt-get update && apt-get install -y phantomjs
USER dev