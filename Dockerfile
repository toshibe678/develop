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

# nodejs
# node version: https://nodejs.org/en/download/releases/
# https://deb.nodesource.com/
ARG node_version=22.x
ENV NODE_VERSION=${node_version}
RUN curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g npm@latest
RUN npm update -g npm && \
    npm install -g \
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

# 一般ユーザーの作成
ARG USERNAME=toshi
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN deluser ubuntu \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && cp /root/.bashrc /home/$USERNAME/.bashrc \
    && cp /root/.profile /home/$USERNAME/.profile \
    && cp -r /root/.npm /home/$USERNAME/.npm \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/
USER $USERNAME

####################################################################################################
# set Env
####################################################################################################
RUN mkdir -p /src/app
ENV HOME /src/app

RUN sudo chown -R $USERNAME:$USERNAME /src/app
WORKDIR /src/app

ENTRYPOINT ["entrypoint.sh"]
