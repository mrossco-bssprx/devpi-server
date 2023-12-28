#!/usr/bin/env bash

# healthcheck.sh script for devpi running within a container
# License: MIT
HEALTHCHECK_VERSION="1.0"
# Last updated date: 2023-12-28

BASEDIR="$DEVPISERVER_SERVERDIR"
PID=$(pgrep devpi-server)

if [ -z "$PID" ]; then
    echo "HEALTHCHECK: Could not determine PID of devpi-server!"
    exit 1
fi

set +e

while : ; do
    kill -0 "$PID" > /dev/null 2>&1 || break
    sleep 2s
done

echo "HEALTHCHECK: devpi-server died, exiting..."