#
# Play 2.8 Runner Image
# Docker image with tools and scripts installed to support the running of a Play Framework 2.8 server
# Expects build artifacts mounted at /home/runner/artifacts OR details to fetch from S3 to
# be provided.

FROM eclipse-temurin:11.0.15_10-jre-alpine@sha256:dcd7942517ac38c259af1a9af0601ae138f173616c2f0c08cdc0294027e59c16
LABEL org.opencontainers.image.authors="Agile Digital <info@agiledigital.com.au>"
LABEL Description=" Docker image with tools and scripts installed to support the running of a Play Framework 2.8 server" Vendor="Agile Digital" Version="0.1"

ENV HOME /home/runner
WORKDIR /home/runner

# Install libsodium so that applications can use the kalium crypto library.
RUN apk add --update git bash tzdata libsodium-dev python3 py3-pip \
    && rm -rf /var/lib/apt/lists/*

# AWS cli
RUN pip --no-cache-dir install --upgrade pip setuptools \
    && pip --no-cache-dir install awscli

RUN addgroup --system --gid 10000 runner
RUN adduser --system --uid 10000 --home $HOME --ingroup runner runner

COPY tools /home/runner/tools
RUN chmod +x /home/runner/tools/prepare.sh
RUN chmod +x /home/runner/tools/run.sh

# We need to support Openshift's random userid's
# Openshift leaves the group as root. Exploit this to ensure we can always write to them
# Ensure we are in the the passwd file
RUN chmod g+w /etc/passwd
RUN chgrp -Rf root /home/runner && chmod -Rf g+w /home/runner
RUN chown -Rf runner:root /home/runner
ENV RUNNER_USER runner

RUN cat /etc/passwd && echo "done"

EXPOSE 9000

USER runner

ENTRYPOINT ["/home/runner/tools/run.sh"]
