FROM postgres:latest

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt-get update \
    && apt-get -y install vim git curl wget zip unzip procps time \
    && rm -rf /var/lib/apt/lists/*
