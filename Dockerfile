FROM debian:jessie
MAINTAINER Piotr Król <piotr.krol@3mdeb.com>
RUN apt-get update && apt-get install -y \
  apt-utils \
  git \
  vim \
  tmux \
  python \
  python-dev \
  ntpdate \
  ca-certificates \
  tftpd-hpa
