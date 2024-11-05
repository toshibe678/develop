FROM ghcr.io/toshibe678/develop/tools:latest

####################################################################################################
# set go Env
# https://go.dev/dl/
####################################################################################################
RUN mkdir -p /src/app/go
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
    typescript \
    aws-cdk \
    textlint \
    textlint-rule-ja-hiragana-fukushi \
    textlint-rule-ja-hiragana-hojodoushi \
    textlint-rule-ja-hiragana-keishikimeishi \
    textlint-rule-preset-ja-technical-writing \
    textlint-rule-preset-ja-spacing \
    textlint-rule-spellcheck-tech-word

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

COPY ./.terraformrc /root/.terraformrc
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
