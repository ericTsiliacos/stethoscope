FROM ubuntu:14.04

RUN mkdir -p ~/.local/bin
RUN export PATH=$HOME/.local/bin:$PATH
RUN export PATH=/opt/ghc/7.10.2/bin:$PATH

RUN apt-get update
RUN apt-get install -y curl software-properties-common python-software-properties

RUN add-apt-repository -y ppa:hvr/ghc
RUN add-apt-repository -y ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get install -y ghc-7.10.2 ruby2.0 ruby-switch
RUN ruby-switch --set ruby2.0

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

RUN curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack'

RUN npm install -g elm@0.16.0

RUN sudo gem install bundler
