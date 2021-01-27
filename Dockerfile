FROM sofianinho/dind

ARG DEBIAN_FRONTEND=noninteractive

ENV RUBY_VERSION 2.6.3

RUN apt-get update            && \
  apt-get install -y             \
    build-essential              \
    curl                         \
    git                          \
    zlib1g-dev                   \
    libssl-dev                   \
    libreadline-dev              \
    libxml2-dev                  \
    libyaml-dev                  \
    libxslt-dev                  \
                              && \
  rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv && \
   git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
   /root/.rbenv/plugins/ruby-build/install.sh

ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> .bashrc

RUN rbenv install $RUBY_VERSION

RUN rbenv global $RUBY_VERSION && gem install bundler -v 2.1 && gem install rake -v 10.0

EXPOSE 9000
ENV RACK_ENV development
WORKDIR /code

COPY . /code
RUN bundle config set without 'development test' && bundle install

CMD [ "/bin/sh", "run.sh" ]
