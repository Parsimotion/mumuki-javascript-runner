FROM ruby:2.6.3
RUN gem install bundler -v 2.1

WORKDIR /code
COPY . /code
RUN bundle install

EXPOSE 9000
ENV RACK_ENV development
CMD ["rackup", "--host", "0.0.0.0", "-p", "9000"]