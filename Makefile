export COMPOSE_HTTP_TIMEOUT := 500

# makefile内のすべてのコマンドが単一のシェルスクリプトで実行されるようになるおまじない
.ONESHELL:

# 定数の定義
ENV := dev

# .SHELLFLAGS を利用するために bash を宣言
SHELL := bash
# シェルスクリプトの実行時オプション（疑似ターゲット）
# -eu: -e はbashで実行したコマンドが失敗した場合に終了させる
# -o pipefail: パイプを使った処理を書いた場合に、パイプの最初や途中で処理が失敗した場合、全体を失敗したとみなすためのオプション
# -c: .SHELLFLAGS オプションを用いるときには最後につけるのが必須です。
.SHELLFLAGS := -eu -o pipefail -c
# .DEFAULT_GOAL: デフォルト（ターゲットを未指定にした場合に選ばれる対象）
.DEFAULT_GOAL := help

# makeコマンドの実行時に、コマンドのhelpが表示されるようになるおまじない
.PHONY: help
help: ## show commands ## make
	@printf "\033[36m%-30s\033[0m %-50s %s\n" "[Sub command]" "[Description]" "[Example]"
	@grep -E '^[/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | perl -pe 's%^([/a-zA-Z_-]+):.*?(##)%$$1 $$2%' | awk -F " *?## *?" '{printf "\033[36m%-30s\033[0m %-50s %s\n", $$1, $$2, $$3}'

.PHONY: up build ps restart log recreate config_check node dev
setup:
	@make build
	@make up
	@make ps

build:
	@docker compose build

up:
	@docker compose up -d

restart:
	@docker compose restart

d:
	@docker compose down

ps:
	@docker compose ps

log:
	@docker compose logs -f

recreate:
	@docker compose up -d --force-recreate

config_check:
	docker compose config

node:
	docker compose exec node bash

dev:
	docker compose exec -it dev bash

docker-prune:
	docker system prune -a -f --filter "until=24h"
	docker system prune --volumes -f
