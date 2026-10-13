FROM debian:jessie

MAINTAINER Piotr Król <piotr.krol@3mdeb.com>

RUN echo "deb http://archive.debian.org/debian jessie main" > /etc/apt/sources.list && \
  echo "deb http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list && \
  echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
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
