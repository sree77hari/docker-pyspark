FROM java:8-jdk-alpine

# GENERAL DEPENDENCIES

RUN apk update && \
    apk add curl && \
    apk add bash


# PYTHON 3

ENV PYTHON_VERSION 3.4.3-r2
ENV ALPINE_OLD_VERSION 3.2
# Hack: using older alpine version to install specific python version
RUN sed -n \
    's|^http://dl-cdn\.alpinelinux.org/alpine/v\([0-9]\+\.[0-9]\+\)/main$|\1|p' \
    /etc/apk/repositories > curr_version.tmp && \
    sed -i 's|'$(cat curr_version.tmp)'/main|'$ALPINE_OLD_VERSION'/main|' \
    /etc/apk/repositories
# Installing given python3 version
RUN apk update && \
    apk add python3=$PYTHON_VERSION
# Reverting hack
RUN sed -i 's|'$(cat curr_version.tmp)'/main|'$ALPINE_OLD_VERSION'/main|' \
    /etc/apk/repositories && \
    rm curr_version.tmp
# Upgrading pip to the last compatible version
RUN pip3 install --upgrade pip


CMD ["python3"]
