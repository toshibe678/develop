FROM ubuntu:18.04

RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install language-pack-ja-base language-pack-ja && \
#    apt -y install locales task-japanese && \
    locale-gen ja_JP.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# set TimeZone
ENV TZ Asia/Tokyo

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install vim git curl wget zip unzip net-tools iproute2 iputils-ping && \
    rm -rf /var/lib/apt/lists/*

# ansible
RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install ansible && \
    rm -rf /var/lib/apt/lists/*

## python
RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install python3-distutils && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py && \
    pip install -U pip && \
    mkdir /code && \
    rm -rf /var/lib/apt/lists/* && \
    pip install ansible-lint awscli

# gcloud
# バージョンはhttps://console.cloud.google.com/storage/browser/cloud-sdk-release?authuser=0&pli=1 を確認
ARG CLOUD_SDK_VERSION=261.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV PATH /google-cloud-sdk/bin:$PATH
RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install curl python && \
    rm -rf /var/lib/apt/lists/* && \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz && \
    gcloud components install kubectl && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

## go
ENV GO_VERSION=1.12
ENV HOME /root
ENV PATH $PATH:/usr/local/go/bin
ENV GOPATH $HOME/work
RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install curl git && \
    rm -rf /var/lib/apt/lists/* && \
    curl -s -o /tmp/go.tar.gz https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

## filelint入れる
RUN go get -u github.com/synchro-food/filelint

# ruby
ARG RUBY_PATH=/usr/local/
ARG RUBY_VERSION=2.6.0
ENV RUBY_VERSION=2.6.0
RUN apt update && \
    apt upgrade -y -q && \
    apt -y -q install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev && \
    git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    echo 'export RBENV_ROOT="/usr/local/rbenv"' >> $HOME/.bashrc && \
    echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> $HOME/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc && \
    . $HOME/.bashrc && CONFIGURE_OPTS="--disable-install-rdoc" rbenv install --skip-existing $RUBY_VERSION && \
    . $HOME/.bashrc && rbenv rehash && \
    . $HOME/.bashrc && rbenv global $RUBY_VERSION && \
    . $HOME/.bashrc && gem install bundler

# nodebrew + nodejs
ENV NODE_VERSION 10.16.3
ENV PATH $HOME/.nodebrew/current/bin:$PATH
RUN wget git.io/nodebrew && \
    perl nodebrew setup && \
    echo 'export PATH=$HOME/.nodebrew/current/bin:$PATH' >> $HOME/.bashrc && \
    . $HOME/.bashrc && nodebrew install-binary $NODE_VERSION && \
    . $HOME/.bashrc && nodebrew use $NODE_VERSION

WORKDIR $HOME/work
CMD ["/bin/bash"]
