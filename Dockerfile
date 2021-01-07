FROM docker:dind


# Install packages for building ruby
RUN apk update && \
    apk add \ 
        build-base \ 
        curl \
        git \
        zlib-dev \
        openssl-dev \
        readline-dev \
        yaml-dev \
        libxml2-dev \
        libxslt-dev \
        bash \
    && \
    rm -rf /var/cache/apk/* && \
    git clone https://github.com/sstephenson/rbenv.git /root/.rbenv  && \
    git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build  && \
    /root/.rbenv/plugins/ruby-build/install.sh  && \
    echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile  && \
    echo 'eval "$(rbenv init -)"' >> .bashrc 

ENV RUBY_VERSION=2.6.3
ENV PATH=/root/.rbenv/bin:$PATH
RUN rbenv install $RUBY_VERSION  && \
    rbenv global $RUBY_VERSION

RUN gem install bundler -v 2.1 && gem install rake -v 10.0

EXPOSE 9000
ENV RACK_ENV development
WORKDIR /code

COPY . /code
RUN bundle config set without 'development test' && bundle install

CMD [ "/bin/sh", "run.sh" ]
