.PHONY: help setup bootstrap dev build test lint clean submodule:init submodule:update submodule:status

# Default target
help:
	@echo "Kingdom Monorepo Commands:"
	@echo "  setup          - Run the complete setup script"
	@echo "  bootstrap      - Install dependencies and build all workspaces"
	@echo "  dev            - Start development servers for all workspaces"
	@echo "  build          - Build all workspaces"
	@echo "  test           - Run tests for all workspaces"
	@echo "  lint           - Run linting for all workspaces"
	@echo "  clean          - Clean all build artifacts and dependencies"
	@echo "  submodule:init - Initialize git submodules"
	@echo "  submodule:update - Update git submodules"
	@echo "  submodule:status - Show submodule status"

setup:
	./setup.sh

bootstrap:
	npm install && npm run build --workspaces

dev:
	npm run dev --workspaces

build:
	npm run build --workspaces

test:
	npm run test --workspaces

lint:
	npm run lint --workspaces

clean:
	npm run clean --workspaces && rm -rf node_modules

submodule:init:
	git submodule update --init --recursive

submodule:update:
	git submodule update --remote --merge

submodule:status:
	git submodule status