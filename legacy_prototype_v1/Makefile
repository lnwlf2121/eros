# Makefile for the EROS Nextcloud App
# -----------------------------------------------------------------------------
# This file automates the common build tasks for the EROS app.
# It allows you to run a clean build with a single command.
# -----------------------------------------------------------------------------

# Use bash for commands
SHELL := /bin/bash

# Phony targets don't represent actual files.
.PHONY: all clean install build

# The default command if you just type "make"
all: build

# Target to remove all installed dependencies and old build artifacts.
# This is the "clean" part of the process.
clean:
	@echo "--- Cleaning project workspace..."
	@rm -rf node_modules package-lock.json js/ css/

# Target to install all frontend dependencies from package.json.
install:
	@echo "--- Installing dependencies..."
	@npm install

# Target to build the frontend assets.
# This automatically depends on 'install' to ensure dependencies are present.
build: install
	@echo "--- Building frontend assets..."
	@npm run build

