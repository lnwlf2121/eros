# Start with the official developer image as our foundation
# This ensures we have all the correct base tools and configurations
FROM ghcr.io/juliusknorr/nextcloud-dev-php83:latest

# Switch to the root user to install new software
USER root

# Update package lists and install the prerequisites for adding a new repository
RUN apt-get update && apt-get install -y curl gnupg && \
	# Add the official repository for modern Node.js versions
	curl -fsSLvvv https://deb.nodesource.com/setup_20.x | bash - && \
	apt-get update && apt-get install nodejs git gh -y && \
	rm -rf /var/lib/apt/lists/*

# CRITICAL: Switch back to the standard, non-privileged 'www-data' user for security
RUN chown -R www-data:www-data /var/www/
USER www-data
