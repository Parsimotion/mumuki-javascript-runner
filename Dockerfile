FROM ruby:2.6.3
RUN gem install bundler -v 2.1 && gem install rake -v 10.0

EXPOSE 9000
ENV RACK_ENV development
WORKDIR /code

COPY . /code
RUN bundle install

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9000"]
