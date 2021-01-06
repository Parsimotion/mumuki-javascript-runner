#/bin/sh

./docker-pull.sh && \
    bundle exec rackup --host "0.0.0.0" -p 9000