#!/usr/bin/env bash

# entrypoint-functions.sh script for UniFi running within a container
# License: MIT
ENTRYPOINT_FUNCTIONS_VERSION="1.0"
# Last updated date: 2021-11-15

function generate_password() {
    # We disable exit on error because we close the pipe
    # when we have enough characters, which results in a
    # non-zero exit status
    set +e
    tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 | tr -cd '[:alnum:]'
    set -e
}

function kill_devpi() {
    _PID=$(pgrep devpi-server)
    echo "ENTRYPOINT: Sending SIGTERM to PID $_PID"
    kill -SIGTERM "$_PID"
}