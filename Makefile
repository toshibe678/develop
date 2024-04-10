export COMPOSE_HTTP_TIMEOUT := 500

# makefile内のすべてのコマンドが単一のシェルスクリプトで実行されるようになるおまじない
.ONESHELL:

.PHONY: up build ps restart log recreate config_check node dev
setup:
	@make build
	@make up
	@make ps

build:
	docker compose build

up:
	docker compose up -d

restart:
	docker compose restart

d:
	docker compose down

ps:
	docker compose ps

log:
	docker compose logs -f

recreate:
	docker compose up -d --force-recreate

config_check:
	docker compose config

node:
	docker compose exec node bash

dev:
	docker compose exec -it dev bash
