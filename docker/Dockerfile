FROM debian:jessie

MAINTAINER Piotr Król <piotr.krol@3mdeb.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
  apt-utils \
  git \
  vim \
  tmux \
  python \
  python-dev \
  ntpdate \
  ca-certificates \
  nfs-kernel-server \
  nfs-common \
  netbase \
  udhcpd 

RUN mkdir -p /srv/nfs
RUN mkdir -p /srv/http

VOLUME /srv/nfs
VOLUME /srv/http

ADD run.sh /usr/local/bin/run.sh

EXPOSE 111/tcp 111/udp 2049/tcp 2049/udp 32765/tcp 32765/udp 32766/tcp 32766/udp 32767/tcp 32767/udp
