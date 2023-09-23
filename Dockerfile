FROM ruby:3.2-alpine

RUN apk add --no-cache \
    bash \
    build-base \
    git \
    less \
    libxml2-dev \
    libxslt-dev \
    mariadb-dev \
    shared-mime-info \
    tzdata
