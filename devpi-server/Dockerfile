# base image
FROM python:3.9-slim-bookworm

# Local Arguements
ARG VERSION
ARG VCS_REF
ARG BUILD_DATE

# image labels using OCI spec
LABEL \
	org.opencontainers.image.vendor="Blue Sky Specialty Pharmacy" \
	org.opencontainers.image.url="https://github.com/bssprx/devpi-server" \
	org.opencontainers.image.title="devpi-server" \
	org.opencontainers.image.description="devpi server instance running on Debian within a container" \
	org.opencontainers.image.version=${VERSION} \
	org.opencontainers.image.source="https://github.com/bssprx/devpi-server" \
	org.opencontainers.image.revision=${VCS_REF} \
	org.opencontainers.image.created=${BUILD_DATE} \
	org.opencontainers.image.licenses="MIT"

# build environment variables
ENV \
        DEBUG=false \
        DEVPISERVER_SERVERDIR=/usr/lib/devpi \
        PGID=999 \
        PUID=999

# setup security context for the devpi user
RUN set -x \
	&& groupadd -r devpi -g $PGID \
	&& useradd --no-log-init -r -u $PUID -g $PGID devpi

# copy in sensible defaults for devpi
COPY requirements.txt entrypoint.sh entrypoint-functions.sh healthcheck.sh /usr/local/bin/

# install unifi dependencies
RUN set -x \
    && fetchDeps=' \
        sudo \
        git \
        procps \
    ' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $fetchDeps \
    && apt-get autoremove --purge \
    && apt-get clean autoclean 

# Install DevPi
WORKDIR ${DEVPISERVER_SERVERDIR}
RUN sudo su - devpi \
    && pip install -r /usr/local/bin/requirements.txt

EXPOSE 3141
VOLUME ["$DEVPISERVER_SERVERDIR"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]