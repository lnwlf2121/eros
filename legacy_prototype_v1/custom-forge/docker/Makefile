# Makefile for the EROS Custom Forge
# -----------------------------------------------------------------------------
# This file lives in the `custom-forge` directory and automates the entire
# process of building the custom Docker image and the EROS application.
# -----------------------------------------------------------------------------

# --- Configuration ---
SHELL := /bin/bash
# The name for our custom Docker image
FORGE_IMAGE_NAME := eros-forge:latest
# The path to the directory where Nextcloud apps are developed
APPS_DIR := ../../..
# The path to our specific EROS app
EROS_APP_DIR := $(APPS_DIR)/eros
# The occ commands which include ":"
OCC_DE := "cd /var/www/html && ./occ app:disable eros && ./occ app:enable eros"
# The Git repository for the EROS app
EROS_REPO := https://github.com/lnwlf2121/eros.git

# --- Phony Targets ---
.PHONY: all build-forge fetch-eros install build clean

# --- Main Targets ---

# Default target: Does everything from a clean slate.
all: clean build-forge fetch-eros build
	@echo "--- EROS Forge and App build complete. ---"

# Builds the custom Docker image for our Forge environment.
build-forge:
	@echo "--- Building custom Forge Docker image: $(FORGE_IMAGE_NAME)..."
	@sudo docker build -t $(FORGE_IMAGE_NAME) .

# Fetches the latest version of the EROS app from GitHub.
# It removes any old version first to ensure a clean state.
fetch-eros:
	@echo "--- Fetching EROS app source code from GitHub..."
	@rm -rf $(EROS_APP_DIR)
	@git clone $(EROS_REPO) $(EROS_APP_DIR)

# Installs the frontend dependencies for the EROS app.
install:
	@echo "--- Installing EROS app dependencies..."
	@cd $(EROS_APP_DIR) && npm install

# Builds the frontend assets for the EROS app. Depends on install.
build: install
	@echo "--- Building EROS app frontend..."
	@cd $(EROS_APP_DIR) && npm run build

# refreshes the app in occ
refresh: build
	@echo "--- Refreshing EROS app frontend..."
	@echo "cd $(APPS_DIR)/.. && ./occ app:disable eros && ./occ app:enable eros"|bash -


# Cleans the EROS app build artifacts and dependencies.
clean:
	@echo "--- Cleaning EROS app workspace..."
	@rm -rf $(EROS_APP_DIR)/node_modules $(EROS_APP_DIR)/package-lock.json $(EROS_APP_DIR)/js/ $(EROS_APP_DIR)/css/
