FROM golang:latest

# locale
RUN apt-get update \
    && apt-get -y install locales \
    && rm -rf /var/lib/apt/lists/*
RUN localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt-get update \
    && apt-get -y install vim git curl wget zip unzip procps time \
    && rm -rf /var/lib/apt/lists/*

#WORKDIR /go/src/work
#COPY ./ ./
