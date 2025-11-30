# Makefile for the EROS Custom Forge (In-Container Version)
# -----------------------------------------------------------------------------
# This file is designed to be run from INSIDE the Nextcloud container,
# specifically from the `.../apps-extra/eros/custom-forge` directory.
# It automates the EROS app's build process and configuration.
# -----------------------------------------------------------------------------

# --- Configuration ---
SHELL := /bin/bash
# The path to the EROS app root, relative to this Makefile
EROS_APP_DIR := ..
# The path to the Nextcloud occ command, relative to this Makefile
OCC_CMD := ../../../occ

# --- Phony Targets ---
.PHONY: all install build clean set-key debug-on debug-off

# --- Main Targets ---

# Default target: Does a clean build and sets the API key.
all: clean build set-key
	@echo "--- EROS app build complete. ---"

# Installs the frontend dependencies for the EROS app.
install:
	@echo "--- Installing EROS app dependencies..."
	@cd $(EROS_APP_DIR) && npm install

# Builds the frontend assets for the EROS app. Depends on install.
build: install
	@echo "--- Building EROS app frontend..."
	@cd $(EROS_APP_DIR) && npm run build

# Cleans the EROS app build artifacts and dependencies.
clean:
	@echo "--- Cleaning EROS app workspace..."
	@rm -rf $(EROS_APP_DIR)/node_modules $(EROS_APP_DIR)/package-lock.json $(EROS_APP_DIR)/js/ $(EROS_APP_DIR)/css/

# --- Diagnostic and Configuration Targets ---

# Securely sets the Gemini API key.
# USAGE: make set-key KEY="YOUR_API_KEY_HERE"
set-key:
	@if [ -z "$(KEY)" ]; then \
		echo "ERROR: Please provide the API key. Usage: make set-key KEY=YOUR_API_KEY"; \
		exit 1; \
	fi
	@echo "Registering key with the Forge..."; \
	php $(OCC_CMD) config:app:set eros gemini_api_key --value="$(KEY)"; \
	echo "API Key has been set."

# Sets the Nextcloud log level to DEBUG (0) for detailed output.
debug-on:
	@echo "--- Setting Nextcloud log level to DEBUG ---"
	@php $(OCC_CMD) config:system:set loglevel --value=0 --type=integer

# Resets the Nextcloud log level to the default of WARN (2).
debug-off:
	@echo "--- Setting Nextcloud log level to WARN ---"
	@php $(OCC_CMD) config:system:set loglevel --value=2 --type=integer
