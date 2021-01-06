#/bin/sh

JAVASCRIPT_WORKER_VERSION=${JAVASCRIPT_WORKER_VERSION:-productecadev/mumuki-mocha-worker-node12:1.0}

docker pull $JAVASCRIPT_WORKER_VERSION && \
    bundle exec rackup --host "0.0.0.0" -p 9000