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

WORKDIR /go/src/work
COPY ./ ./

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

ENTRYPOINT [ "go", "run", "main.go" ]
