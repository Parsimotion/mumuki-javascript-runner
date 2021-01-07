#/bin/sh

JAVASCRIPT_WORKER_VERSION=${JAVASCRIPT_WORKER_VERSION:-productecadev/mumuki-mocha-worker-node12:1.1}
docker pull $JAVASCRIPT_WORKER_VERSION 