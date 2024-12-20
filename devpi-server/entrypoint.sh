#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#!/usr/bin/env bash

# entrypoint.sh script for devpi running within a container
# License: MIT
SCRIPT_VERSION="1.0"
# Last updated date: 2023-12-28

if [ "${DEBUG}" == 'true' ]; then
    set -x
fi

. /usr/local/bin/entrypoint-functions.sh

if [ "${1:-}" == "bash" ]; then
    exec "$@"
fi

DEVPI_ROOT_PASSWORD="${DEVPI_ROOT_PASSWORD:-}"
if [ -f "$DEVPISERVER_SERVERDIR/.root_password" ]; then
    DEVPI_ROOT_PASSWORD=$(cat "$DEVPISERVER_SERVERDIR/.root_password")
elif [ -z "$DEVPI_ROOT_PASSWORD" ]; then
    DEVPI_ROOT_PASSWORD=$(generate_password)
fi

if [ ! -d "$DEVPISERVER_SERVERDIR" ]; then
    echo "ENTRYPOINT: Creating devpi-server root"
    mkdir -p "$DEVPISERVER_SERVERDIR"
fi

initialize=no
if [ ! -f "$DEVPISERVER_SERVERDIR/.serverversion" ]; then
    initialize=yes
    echo "ENTRYPOINT: Initializing server root $DEVPISERVER_SERVERDIR"
    devpi-init --serverdir "$DEVPISERVER_SERVERDIR"
fi

echo "ENTRYPOINT: Starting devpi-server"
devpi-server --host 0.0.0.0 --port 3141 --serverdir "$DEVPISERVER_SERVERDIR" "$@" &

timeout 10 bash -c 'until printf "" 2>>/dev/null >>/dev/tcp/$0/$1; do sleep 1; done' localhost 3141

echo "ENTRYPOINT: Installing signal traps"
trap kill_devpi SIGINT SIGTERM

if [ "$initialize" == "yes" ]; then
    echo "ENTRYPOINT: Initializing devpi-server"
    devpi use http://localhost:3141
    devpi login root --password=''
    echo "ENTRYPOINT: Setting root password to $DEVPI_ROOT_PASSWORD"
    devpi user -m root "password=$DEVPI_ROOT_PASSWORD"
    echo -n "$DEVPI_ROOT_PASSWORD" > "$DEVPISERVER_SERVERDIR/.root_password"
    devpi logoff
fi

echo "ENTRYPOINT: Watching devpi-server"
PID=$(pgrep devpi-server)

if [ -z "$PID" ]; then
    echo "ENTRYPOINT: Could not determine PID of devpi-server!"
    exit 1
fi

set +e

while : ; do
    kill -0 "$PID" > /dev/null 2>&1 || break
    sleep 2s
done

echo "ENTRYPOINT: devpi-server died, exiting..."