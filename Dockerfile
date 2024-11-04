FROM ubuntu:24.04

# set TimeZone
ARG tz=Asia/Tokyo
ENV TZ=${tz}

# 日本語環境設定
RUN apt-get update && \
    apt-get install -y locales task-japanese && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -f UTF-8 -i ja_JP ja_JP
ENV LC_ALL=ja_JP.UTF-8 \
    LC_CTYPE=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:jp \
    LANG=ja_JP.UTF-8

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt-get update && \
    apt-get -y install \
    vim \
    git \
    curl \
    wget \
    zip \
    unzip \
    ansible \
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
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /src/app/go

####################################################################################################
# set Env
####################################################################################################
ENV HOME /src/app

####################################################################################################
# set go Env
# https://go.dev/dl/
####################################################################################################
ARG golang_version=1.23.2
ENV GOLANG_VERSION ${golang_version}
ENV GOPATH /src/app/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# don't auto-upgrade the gotoolchain
# https://github.com/docker-library/golang/issues/472
ENV GOTOOLCHAIN=local
ENV GO111MODULE=auto
## go
RUN if [ $(uname -m) = "x86_64" ]; then \
              arch="amd64"; \
          else \
              arch="arm64"; \
          fi && \
    wget -O go.tgz "https://go.dev/dl/go${GOLANG_VERSION}.linux-${arch}.tar.gz" --progress=dot:giga; \
    tar -C /usr/local -xzf go.tgz && \
    rm go.tgz && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"

# DockerfileのLintツール
ARG hadolint_version=2.12.0
ENV HADOLINT_VERSION=${hadolint_version}
RUN if [ $(uname -m) = "x86_64" ]; then \
                  arch="x86_64"; \
              else \
                  arch="arm64"; \
              fi && \
    curl -L "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-${arch}" -o /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

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
    pipx install --include-deps ansible-lint uv && \
    pipx install --include-deps pandas xlrd pandas-datareader flake8 black mypy pytest awscli

# nodebrew + nodejs
# node version: https://nodejs.org/en/download/releases/
ARG node_version=22.11.0
ENV NODE_VERSION=${node_version}
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

### AWS CLI
RUN arch=$(uname -m) && \
    if [ "$arch" != "x86_64" ]; then \
        arch="aarch64"; \
    fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "aws-cli.zip" && \
    unzip aws-cli.zip && \
    ./aws/install && \
    rm -rf aws aws-cli.zip

# terraform
# 最新バージョン確認：https://www.terraform.io/downloads.html
ARG terraform_version=1.9.8
ENV TERRAFORM_VERSION=${terraform_version}
RUN apt-get update \
    && apt-get -y install zip \
    && rm -rf /var/lib/apt/lists/* \
    && if [ $(uname -m) = "x86_64" ]; then \
          arch="amd64"; \
      else \
          arch="arm64"; \
      fi \
    && wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${arch}.zip" \
    && unzip "terraform_${TERRAFORM_VERSION}_linux_${arch}.zip" \
    && mv terraform /bin \
    && rm "terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"

# tflintを使えるようにする
# 最新バージョン確認：https://github.com/terraform-linters/tflint/releases/
ARG tflint_version=0.53.0
ENV TFLINT_VERSION=${tflint_version}
RUN  if [ $(uname -m) = "x86_64" ]; then \
              arch="amd64"; \
          else \
              arch="arm64"; \
          fi \
    && wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${arch}.zip -O tflint.zip \
    && unzip tflint.zip -d /bin \
    && rm tflint.zip

# gcloud
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk \
    && rm -rf /var/lib/apt/lists/*
# gcloudの初期設定 使用レポートの無効化とアップデートチェックの無効化
RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true \

# azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

WORKDIR /src/app
CMD ["/bin/bash"]
COPY ./.terraformrc /root/.terraformrc
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
