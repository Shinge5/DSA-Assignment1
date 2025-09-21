# NUST Asset Management API - Makefile

.PHONY: help build run test clean docker-build docker-run docker-stop install-deps format lint

# Default target
help:
	@echo "Available targets:"
	@echo "  build         - Build the Ballerina project"
	@echo "  run           - Run the server"
	@echo "  test          - Run tests"
	@echo "  clean         - Clean build artifacts"
	@echo "  docker-build  - Build Docker image"
	@echo "  docker-run    - Run with Docker Compose"
	@echo "  docker-stop   - Stop Docker containers"
	@echo "  install-deps  - Install Ballerina dependencies"
	@echo "  format        - Format Ballerina code"
	@echo "  lint          - Lint Ballerina code"

# Build the project
build:
	bal build

# Run the server
run:
	bal run server.bal

# Run tests
test:
	bal test

# Clean build artifacts
clean:
	bal clean

# Install dependencies
install-deps:
	bal build --skip-tests

# Format code
format:
	bal format

# Lint code
lint:
	bal build --skip-tests

# Docker operations
docker-build:
	docker build -t nust/asset-api:latest .

docker-run:
	docker-compose up -d

docker-stop:
	docker-compose down

# Development workflow
dev: clean install-deps run

# Production build
prod: clean build docker-build

# Full test suite
test-all: clean test
