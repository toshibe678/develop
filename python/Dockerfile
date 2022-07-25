FROM python:latest

# locale
RUN apt-get update \
    && apt-get -y install locales \
    && rm -rf /var/lib/apt/lists/*
RUN localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8

# 環境変数を設定
# Pythonがpyc filesとdiscへ書き込むことを防ぐ
ENV PYTHONDONTWRITEBYTECODE 1
# Pythonが標準入出力をバッファリングすることを防ぐ
ENV PYTHONUNBUFFERED 1
ENV DEBIAN_FRONTEND=noninteractive

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt-get update \
    && apt-get -y install vim git curl wget zip unzip procps time \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ADD requirements.txt /usr/src/app/

RUN pip install -U pip
RUN pip install -r requirements.txt
