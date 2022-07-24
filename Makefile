export COMPOSE_HTTP_TIMEOUT := 300

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
