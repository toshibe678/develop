export COMPOSE_HTTP_TIMEOUT := 300

# makefile内のすべてのコマンドが単一のシェルスクリプトで実行されるようになるおまじない
.ONESHELL:

.PHONY: build
build:
	@docker compose build

.PHONY: up
up:
	@docker compose up -d

.PHONY: restart
restart:
	@docker compose restart

.PHONY: del
del:
	@docker compose down

.PHONY: status
status:
	@docker compose ps

.PHONY: log
log:
	@docker compose logs -f

.PHONY: recreate
recreate:
	@docker compose up -d --force-recreate

.PHONY: config_check
config_check:
	@docker compose config
