.PHONY: help setup start stop restart logs logs-follow status health clean backup restore test

# Default target
help:
	@echo "LiteLLM Proxy Management"
	@echo ""
	@echo "Available targets:"
	@echo "  setup        - Run initial setup (creates .env and starts services)"
	@echo "  start        - Start all services"
	@echo "  stop         - Stop all services"
	@echo "  restart      - Restart all services"
	@echo "  logs         - View logs (last 100 lines)"
	@echo "  logs-follow  - Follow logs in real-time"
	@echo "  status       - Check service status"
	@echo "  health       - Check health endpoint"
	@echo "  clean        - Stop services and remove volumes (WARNING: deletes data)"
	@echo "  backup       - Backup PostgreSQL database"
	@echo "  restore      - Restore PostgreSQL database from backup.sql"
	@echo "  test         - Test the API with a simple request"

# Run setup script
setup:
	@./setup.sh

# Start services
start:
	@echo "Starting LiteLLM services..."
	@docker-compose up -d
	@echo "Services started. Access at http://localhost:4000"

# Stop services
stop:
	@echo "Stopping LiteLLM services..."
	@docker-compose down
	@echo "Services stopped."

# Restart services
restart:
	@echo "Restarting LiteLLM services..."
	@docker-compose restart
	@echo "Services restarted."

# View logs
logs:
	@docker-compose logs --tail=100

# Follow logs
logs-follow:
	@docker-compose logs -f

# Check status
status:
	@docker-compose ps

# Check health
health:
	@echo "Checking health endpoint..."
	@curl -f http://localhost:4000/health || echo "Health check failed"

# Clean up (WARNING: deletes data)
clean:
	@echo "WARNING: This will delete all data!"
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "Services stopped and volumes removed."; \
	else \
		echo "Cancelled."; \
	fi

# Backup database
backup:
	@echo "Backing up PostgreSQL database..."
	@docker-compose exec -T postgres pg_dump -U litellm litellm > backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "Backup created: backup-$$(date +%Y%m%d-%H%M%S).sql"

# Restore database
restore:
	@if [ ! -f backup.sql ]; then \
		echo "Error: backup.sql not found"; \
		exit 1; \
	fi
	@echo "Restoring PostgreSQL database from backup.sql..."
	@docker-compose exec -T postgres psql -U litellm litellm < backup.sql
	@echo "Database restored."

# Test API
test:
	@if [ -z "$${LITELLM_MASTER_KEY}" ]; then \
		echo "Error: LITELLM_MASTER_KEY not set in environment"; \
		echo "Run: export LITELLM_MASTER_KEY=your-key"; \
		exit 1; \
	fi
	@echo "Testing API with gpt-3.5-turbo..."
	@curl -X POST http://localhost:4000/chat/completions \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $${LITELLM_MASTER_KEY}" \
		-d '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "Say hello!"}]}' \
		| jq '.' || echo "Test failed"
