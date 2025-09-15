# Makefile for al2023-ruby Docker image

IMAGE_NAME := al2023-ruby
CONTAINER_NAME := al2023-ruby
RUBY_VERSION ?= 3.4.5
RUBY_MAJOR ?= 3.4
RUBY_PREFIX ?= /opt/ruby/$(RUBY_MAJOR)
RUBYGEMS_VERSION ?= 3.7.2
BUNDLER_VERSION ?= 2.7.2
GEM_SOURCE ?= https://rubygems.org

# Default target
.DEFAULT_GOAL := build

.PHONY: build
build:
	@echo "Building Docker image: $(IMAGE_NAME):$(RUBY_VERSION) with Ruby $(RUBY_VERSION), RubyGems $(RUBYGEMS_VERSION), Bundler $(BUNDLER_VERSION) at $(RUBY_PREFIX)"
	docker build \
		--build-arg RUBY_VERSION=$(RUBY_VERSION) \
		--build-arg RUBY_MAJOR=$(RUBY_MAJOR) \
		--build-arg RUBY_PREFIX=$(RUBY_PREFIX) \
		--build-arg RUBYGEMS_VERSION=$(RUBYGEMS_VERSION) \
		--build-arg BUNDLER_VERSION=$(BUNDLER_VERSION) \
		--build-arg GEM_SOURCE=$(GEM_SOURCE) \
		-t $(IMAGE_NAME):$(RUBY_VERSION) \
		-t $(IMAGE_NAME):$(RUBY_MAJOR) \
		-t $(IMAGE_NAME):latest \
		.

.PHONY: run
run:
	@echo "Running Docker container: $(CONTAINER_NAME)"
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):latest

.PHONY: clean
clean:
	@echo "Removing all Docker images for: $(IMAGE_NAME)"
	docker rmi $(IMAGE_NAME):$(RUBY_VERSION) $(IMAGE_NAME):$(RUBY_MAJOR) $(IMAGE_NAME):latest 2>/dev/null || true

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build  - Build the Docker image (default)"
	@echo "  run    - Run the Docker container interactively"
	@echo "  clean  - Remove the Docker image"
	@echo "  help   - Show this help message"
	@echo ""
	@echo "Build arguments:"
	@echo "  RUBY_VERSION     - Ruby version to build (default: $(RUBY_VERSION))"
	@echo "  RUBY_MAJOR       - Ruby major version (default: $(RUBY_MAJOR))"
	@echo "  RUBYGEMS_VERSION - RubyGems version to install (default: $(RUBYGEMS_VERSION))"
	@echo "  BUNDLER_VERSION  - Bundler version to install (default: $(BUNDLER_VERSION))"
	@echo "  RUBY_PREFIX      - Installation directory (default: $(RUBY_PREFIX))"
	@echo "  GEM_SOURCE       - RubyGems source URL (default: $(GEM_SOURCE))"
	@echo ""
	@echo "Examples:"
	@echo "  make                                    # Build with default Ruby 3.4.5 at /opt/ruby/3.4"
	@echo "  make RUBY_VERSION=3.3.6 RUBY_MAJOR=3.3  # Build with Ruby 3.3.6 at /opt/ruby/3.3"
	@echo "  make RUBY_PREFIX=/usr/local             # Install Ruby to /usr/local"
