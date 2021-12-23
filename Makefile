#
# Makefile for Golang projects
# 
# Copyright (c) 2020-2021 Roozbeh Farahbod
#

include ./MANIFEST

.DEFAULT_GOAL := go-build

GOOS ?= darwin

BIN_DIR=./bin

DATE := $(shell date | sed 's/\ /_/g')
BIN_NAME := $(BINARY)
TARGET := $(BIN_NAME)

CMD_ROOT_PACKAGE=$(shell head -n 1 go.mod | sed 's/^module //g')/cmd

OS=$(shell uname)
CMD_XARGS=xargs
ifeq "$(OS)" "Linux"
	CMD_XARGS=xargs -r
endif

TAG=$(VERSION)

# --- Init

.PHONY: init init-gitignore init-dockerfile clean 

init: init-gitignore init-dockerfile

# Fetches .gitignore from Github
init-gitignore: 
	@if [ ! -e ".gitignore" ]; then \
		curl -q https://raw.githubusercontent.com/github/gitignore/master/Go.gitignore > .gitignore; \
		echo "\n/bin" >> .gitignore; \
		echo "Created '.gitignore'"; \
	else \
		echo "Did not change '.gitignore'"; \
	fi

# Creates a Dockerfile based on the template
TEMP_DOCKERFILE=Dockerfile.new
init-dockerfile:
	@cat  Dockerfile.template \
		| sed 's/$$(PROJECT)/'$(PROJECT)'/g' \
		| sed 's/$$(BINARY)/'$(BINARY)'/g' \
		> $(TEMP_DOCKERFILE)
	@if [ -e "Dockerfile" ]; then \
		if diff Dockerfile $(TEMP_DOCKERFILE); then \
			echo "Did not change 'Dockerfile'"; \
		else \
			cp $(TEMP_DOCKERFILE) Dockerfile; rm -f $(TEMP_DOCKERFILE); \
			echo "Updated 'Dockerfile'"; \
		fi; \
	else \
		mv $(TEMP_DOCKERFILE) Dockerfile; \
		echo "Created 'Dockerfile'"; \
	fi
	@rm -f $(TEMP_DOCKERFILE)

clean:
	@rm -f $(BIN_DIR)/*
	@rm -f $(TEMP_DOCKERFILE)

# --- Golang

.PHONY: go-fmt go-lint go-test go-mod go-build go-build-linux go-build-mac go-build-docker go-build-all 

go-fmt:
	@go fmt .

go-mod:
	@go mod tidy
	@go mod verify

go-lint: go-mod
	@golint -set_exit_status .

go-test: go-mod
	@go test ./...

go-build-linux: 
	@echo "build linux binary"
	$(MAKE) go-build GOOS=linux GOARCH=amd64 TARGET=$(BIN_NAME)-linux-amd64

go-build-mac: 
	@echo "build Mac binary"
	$(MAKE) go-build GOOS=darwin GOARCH=amd64 TARGET=$(BIN_NAME)-darwin-amd64

go-build-docker: clean
	@echo "build for Docker container"
	$(MAKE) go-build CGO_ENABLED=0 GOOS=linux TARGET=$(BIN_NAME)

TARGET ?= $(BIN_NAME)

go-build: go-mod
	go build \
		-ldflags="-X $(CMD_ROOT_PACKAGE).ExecutableFileName=$(TARGET) \
			-X $(CMD_ROOT_PACKAGE).GitRevision=$(shell git rev-parse HEAD 2> /dev/null) \
			-X $(CMD_ROOT_PACKAGE).BuildVersion=$(VERSION) \
			-X $(CMD_ROOT_PACKAGE).BuildTime=$(DATE)" \
		-o $(BIN_DIR)/$(TARGET) 

go-build-all: go-build-linux go-build-mac

# --- Docker

.PHONY: docker-clean docker-build docker-run

docker-clean: init-dockerfile
	docker ps -a -q --filter name=$(IMAGE_NAME) | $(CMD_XARGS) docker stop | $(CMD_XARGS) docker rm

docker-build: docker-clean
	docker build --pull --force-rm --tag $(IMAGE_NAME)\:$(TAG) .

docker-run: docker-clean
	docker run --name $(IMAGE_NAME) $(IMAGE_NAME)\:$(TAG)

# --- Run

.PHONY: run

run: go-build
	$(BIN_DIR)/$(TARGET) --help

# --- Release

.PHONY: release-all

release-all: clean 
	$(MAKE) go-build-all
	mkdir -p ./release
	rm -rf ./release/*
	chmod +x bin/*
	cp $(BIN_DIR)/* ./release
	for bf in ./release/*; do shasum -a 256 "$$bf" > "$$bf".sha256; done
