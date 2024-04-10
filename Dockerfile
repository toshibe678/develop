FROM ubuntu:24.04

# set TimeZone
ARG tz=Asia/Tokyo
ENV TZ=${tz}

# set Locale
RUN apt-get update && \
    apt-get -y install language-pack-ja-base language-pack-ja && \
    locale-gen ja_JP.UTF-8 && \
    rm -rf /var/lib/apt/lists/*
ENV LC_ALL=ja_JP.UTF-8 \
    LC_CTYPE=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:jp
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8

RUN mkdir -p /src/app/go

####################################################################################################
# set Env
####################################################################################################
ENV HOME /src/app

####################################################################################################
# set go Env
####################################################################################################
ENV GOLANG_VERSION 1.22.1
ENV GOPATH /src/app/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt-get update && \
#    apt-get -y install vim && \
    apt-get -y install \
    git \
    curl \
    wget \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 調査用ソフトインストール
RUN apt-get update && \
    apt-get -y install \
    procps \
    util-linux \
    iputils-ping \
    net-tools \
    iproute2 \
    sysstat \
    numactl \
    tcpdump \
    linux-tools-common \
    trace-cmd \
    nicstat \
    ethtool \
    tiptop \
    cpuid \
    msr-tools \
    && rm -rf /var/lib/apt/lists/*

# DockerfileのLintツール
RUN curl -L https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

# Aptで入れられる開発ツール入れておく
RUN apt-get update && \
    apt-get -y install \
    ansible \
    && rm -rf /var/lib/apt/lists/*

## go
RUN wget -O go.tgz "https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz" --progress=dot:giga; \
    tar -C /usr/local -xzf go.tgz && \
    rm go.tgz && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"

# install go tools（自動補完等に必要なツールをコンテナにインストール）
#RUN go install github.com/uudashr/gopkgs/v2/cmd/gopkgs
#  github.com/ramya-rao-a/go-outline \
#  github.com/nsf/gocode \
#  github.com/acroca/go-symbols \
#  github.com/fatih/gomodifytags \
#  github.com/josharian/impl \
#  github.com/haya14busa/goplay/cmd/goplay \
#  github.com/go-delve/delve/cmd/dlv \
#  golang.org/x/lint/golint \
#  golang.org/x/tools/gopls

# go fmt ,gometalinter, goimports, golint, go vet, golangci-lint

## python
# 環境変数を設定
# Pythonがpyc filesとdiscへ書き込むことを防ぐ
ENV PYTHONDONTWRITEBYTECODE 1
# Pythonが標準入出力をバッファリングすることを防ぐ
ENV PYTHONUNBUFFERED 1
ENV PATH /src/app/.local/bin:$PATH
#ADD ./requirements.txt /tmp/requirements.txt
RUN apt-get update && \
    apt-get -y install pipx && \
    rm -rf /var/lib/apt/lists/* && \
    pipx install --include-deps ansible-lint awscli uv && \
    pipx install --include-deps pandas xlrd pandas-datareader flake8 black mypy pytest

# nodebrew + nodejs
# node version: https://nodejs.org/en/download/releases/
ENV NODE_VERSION 20.12.1
ENV PATH $HOME/.nodebrew/current/bin:$PATH
RUN wget git.io/nodebrew && \
    perl nodebrew setup && \
    echo 'export PATH=$HOME/.nodebrew/current/bin:$PATH' >> $HOME/.bashrc && \
    . $HOME/.bashrc && nodebrew install-binary $NODE_VERSION && \
    . $HOME/.bashrc && nodebrew use $NODE_VERSION
RUN npm update -g npm
RUN npm install -g \
    textlint \
    textlint-rule-ja-hiragana-fukushi \
    textlint-rule-ja-hiragana-hojodoushi \
    textlint-rule-ja-hiragana-keishikimeishi \
    textlint-rule-preset-ja-technical-writing \
    textlint-rule-preset-ja-spacing \
    textlint-rule-spellcheck-tech-word

WORKDIR /src/app
CMD ["/bin/bash"]
