# Makefile for Paperless-ngx Deployment

.PHONY: help up up-with-backup down logs pull clean-backups

# Define compose files
COMPOSE_FILES := -f docker-compose.yml
COMPOSE_FILES_BACKUP := -f docker-compose.yml -f docker-compose.backup.yml

# Default target when 'make' is run without arguments
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  up               - Start all services in detached mode (without backup)."
	@echo "  up-with-backup   - Start all services, including backup services."
	@echo "  down             - Stop and remove all services."
	@echo "  logs             - Follow the logs of all services."
	@echo "  logs-web         - Follow the logs for the Paperless webserver only."
	@echo "  pull             - Pull the latest images for all services."
	@echo "  clean-backups    - Remove all backup files from the backups directory."
	@echo "  help             - Show this help message."

up:
	@echo "Starting Paperless-ngx services (without backup)..."
	docker-compose $(COMPOSE_FILES) up -d

up-with-backup:
	@echo "Starting all Paperless-ngx services (with backup)..."
	docker-compose $(COMPOSE_FILES_BACKUP) up -d

down:
	@echo "Stopping and removing all Paperless-ngx services..."
	docker-compose $(COMPOSE_FILES_BACKUP) down --remove-orphans

logs:
	@echo "Following logs for all services..."
	docker-compose $(COMPOSE_FILES_BACKUP) logs -f

logs-web:
	@echo "Following logs for the Paperless-ngx webserver..."
	docker-compose $(COMPOSE_FILES) logs -f webserver

pull:
	@echo "Pulling the latest Docker images..."
	docker-compose $(COMPOSE_FILES_BACKUP) pull

clean-backups:
	@echo "WARNING: This will permanently delete all backup files."
	@read -p "Are you sure you want to continue? [y/N] " confirm; \
	if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then \
		echo "Deleting files in ./backups/ ..."; \
		rm -rf ./backups/*; \
		echo "Backup files cleaned."; \
	else \
		echo "Operation cancelled."; \
	fi
