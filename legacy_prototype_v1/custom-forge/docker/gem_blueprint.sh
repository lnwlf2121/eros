#!/bin/bash
# EROS - The Definitive Blueprint Script v1.0
# -----------------------------------------------------------------------------
# This script performs a complete and clean setup of the EROS Nextcloud app.
# It replaces all key configuration and code files with their final, correct
# versions, installs all dependencies, and builds the application.
#
# USAGE: Run this script from within the main 'eros' app directory inside
#        the Nextcloud development container.
# -----------------------------------------------------------------------------
# Capt. Ash says you can specify that location and run it from the Makefile
base=/var/www/html/apps-extra/eros
cd $base || die "Couldn't access $base"

set -e
echo "--- Beginning EROS Definitive Blueprint Protocol ---"

# --- PART 1: CLEAN SLATE ---
echo "--> Step 1: Purging old configurations and artifacts..."
rm -rf \
  node_modules \
  package-lock.json \
  vendor \
  composer.lock \
  js \
  css \
  tsconfig.json \
  tsconfig.node.json \
  vite.config.js \
  composer.json \
  lib/ \
  appinfo/ \
  templates/

# --- PART 2: FORGE THE BLUEPRINTS ---
echo "--> Step 2: Forging definitive blueprints..."

# Create necessary directories
mkdir -p appinfo lib/AppInfo lib/Controller templates src/components

# --- File: package.json ---
cat <<'EOF' > package.json
{
  "name": "eros",
  "version": "1.0.0",
  "description": "The EROS Application",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "serve": "vite preview"
  },
  "dependencies": {
    "@nextcloud/axios": "^2.5.0",
    "vue": "^3.4.0"
  },
  "devDependencies": {
    "@nextcloud/browserslist-config": "^3.0.0",
    "@nextcloud/vite-config": "^2.0.0",
    "@vitejs/plugin-vue": "^5.0.0",
    "@vue/tsconfig": "^0.5.0",
    "vite": "^5.2.0"
  }
}
EOF

# --- File: vite.config.js ---
cat <<'EOF' > vite.config.js
import { defineConfig } from 'vite'
import { createAppConfig } from '@nextcloud/vite-config'

export default defineConfig(createAppConfig({
	main: 'src/main.js'
}))
EOF

# --- File: tsconfig.json ---
cat <<'EOF' > tsconfig.json
{
  "extends": "@vue/tsconfig/tsconfig.json",
  "include": [ "src/**/*" ],
  "compilerOptions": {
    "baseUrl": ".",
    "paths": { "@/*": [ "src/*" ] }
  },
  "references": [ { "path": "./tsconfig.node.json" } ]
}
EOF

# --- File: tsconfig.node.json ---
cat <<'EOF' > tsconfig.node.json
{
  "extends": "@vue/tsconfig/tsconfig.node.json",
  "include": [ "vite.config.js" ],
  "compilerOptions": {
    "composite": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "types": [ "node" ]
  }
}
EOF

# --- File: composer.json ---
cat <<'EOF' > composer.json
{
	"name": "lnwlf2121/eros",
	"description": "The EROS Application for Nextcloud.",
	"type": "nextcloud-app",
	"license": "AGPL-3.0-or-later",
	"authors": [ { "name": "Phoenix Ash", "email": "einzeln@gmail.com", "homepage": "https://mtdews.com" } ],
	"autoload": { "psr-4": { "OCA\\EROS\\": "lib/" } },
	"require": { "php": "^8.1" },
	"require-dev": { "nextcloud/coding-standard": "^1.0.0" },
	"scripts": {
		"cs:check": "php-cs-fixer fix --dry-run --diff",
		"cs:fix": "php-cs-fixer fix"
	}
}
EOF

# --- File: appinfo/info.xml ---
cat <<'EOF' > appinfo/info.xml
<?xml version="1.0"?>
<info xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:noNamespaceSchemaLocation="https://apps.nextcloud.com/schema/apps/info.xsd">
    <id>eros</id>
    <name>EROS</name>
    <summary>A unified interface for a regenerative future.</summary>
    <description><![CDATA[The EROS application provides a "starship captain" style command console for interacting with AI and managing personal and planetary regeneration quests.]]></description>
    <version>1.0.0</version>
    <licence>agpl</licence>
    <author mail="einzeln@gmail.com" homepage="https://mtdews.com">Phoenix Ash</author>
    <namespace>EROS</namespace>
    <category>tools</category>
    <icon>app.svg</icon>
    <dependencies>
        <nextcloud min-version="29" max-version="32"/>
    </dependencies>
    <navigations>
        <navigation>
            <id>eros</id>
            <name>EROS</name>
            <route>eros.page.index</route>
            <icon>app.svg</icon>
            <type>link</type>
        </navigation>
    </navigations>
</info>
EOF

# --- File: appinfo/routes.php ---
cat <<'EOF' > appinfo/routes.php
<?php
return [
	'routes' => [
		['name' => 'page#index', 'url' => '/', 'verb' => 'GET'],
		['name' => 'eros#broadcast', 'url' => '/api/v1/broadcast', 'verb' => 'POST'],
	]
];
EOF

# --- File: appinfo/app.svg ---
cat <<'EOF' > appinfo/app.svg
<svg width="100" height="100" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M20 35C20 33.8954 20.8954 33 22 33H28C29.1046 33 30 33.8954 30 35V65C30 66.1046 29.1046 67 28 67H22C20.8954 67 20 66.1046 20 65V35Z" fill="currentColor"/>
    <path d="M45 20C45 18.8954 45.8954 18 47 18H53C54.1046 18 55 18.8954 55 20V80C55 81.1046 54.1046 82 53 82H47C45.8954 82 45 81.1046 45 80V20Z" fill="currentColor"/>
    <path d="M70 48C70 46.8954 70.8954 46 72 46H78C79.1046 46 80 46.8954 80 48V58C80 59.1046 79.1046 60 78 60H72C70.8954 60 70 59.1046 70 58V48Z" fill="currentColor"/>
</svg>
EOF

# --- File: lib/AppInfo/Application.php ---
cat <<'EOF' > lib/AppInfo/Application.php
<?php
declare(strict_types=1);

namespace OCA\EROS\AppInfo;

use OCP\AppFramework\App;
use OCP\AppFramework\Bootstrap\IBootContext;
use OCP\AppFramework\Bootstrap\IBootstrap;
use OCP\AppFramework\Bootstrap\IRegistrationContext;
use OCA\EROS\Controller\ErosController;
use OCA\EROS\Controller\PageController;
use OCP\IConfig;
use OCP\Http\Client\IClientService;
use OCP\ILogger;
use OCP\IRequest;
use Psr\Container\ContainerInterface;

class Application extends App implements IBootstrap {
    public const APP_ID = 'eros';

    public function __construct(array $urlParams = []) {
        parent::__construct(self::APP_ID, $urlParams);
    }

    public function register(IRegistrationContext $context): void {
        $context->registerService('PageController', function(ContainerInterface \$c) {
            return new PageController(
                \$c->get('AppName'),
                \$c->get(IRequest::class)
            );
        });
        $context->registerService('ErosController', function(ContainerInterface \$c) {
            return new ErosController(
                \$c->get('AppName'),
                \$c->get(IRequest::class),
                \$c->get(IConfig::class),
                \$c->get(IClientService::class),
                \$c->get(ILogger::class)
            );
        });
    }

    public function boot(IBootContext $context): void {}
}
EOF

# --- File: lib/Controller/PageController.php ---
cat <<'EOF' > lib/Controller/PageController.php
<?php
namespace OCA\EROS\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\AppFramework\Http\Attribute\NoAdminRequired;
use OCP\AppFramework\Http\Attribute\NoCSRFRequired;
use OCP\IRequest;
use OCP\Util;

class PageController extends Controller {
    public function __construct(string \$appName, IRequest \$request) {
        parent::__construct(\$appName, \$request);
    }

    #[NoAdminRequired]
    #[NoCSRFRequired]
    public function index(): TemplateResponse {
        Util::addScript('eros', 'eros-main');
        Util::addStyle('eros', 'main');
        return new TemplateResponse('eros', 'main');
    }
}
EOF

# --- File: lib/Controller/ErosController.php ---
cat <<'EOF' > lib/Controller/ErosController.php
<?php
namespace OCA\EROS\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Http\Attribute\NoAdminRequired;
use OCP\AppFramework\Http\Attribute\NoCSRFRequired;
use OCP\IConfig;
use OCP\Http\Client\IClientService;
use OCP\ILogger;
use OCP\IRequest;

class ErosController extends Controller {
    private IConfig \$config;
    private IClientService \$clientService;
    private ILogger \$logger;

    public function __construct(string \$appName, IRequest \$request, IConfig \$config, IClientService \$clientService, ILogger \$logger){
        parent::__construct(\$appName, \$request);
        \$this->config = \$config;
        \$this->clientService = \$clientService;
        \$this->logger = \$logger;
    }

    #[NoAdminRequired]
    #[NoCSRFRequired]
    public function broadcast(string \$prompt): DataResponse {
        \$apiKey = \$this->config->getAppValue('eros', 'gemini_api_key', '');

        if (empty(\$apiKey)) {
            \$this->logger->error('EROS: Gemini API key is not configured.', ['app' => 'eros']);
            return new DataResponse(['response' => 'ERROR: Gemini API key is not configured. Please ask the server administrator to set it.'], 500);
        }

        \$apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=' . \$apiKey;
        \$payload = ['contents' => [['parts' => [['text' => \$prompt]]]]];

        try {
            \$client = \$this->clientService->newClient();
            \$response = \$client->post(\$apiUrl, [
                'headers' => ['Content-Type' => 'application/json'],
                'body' => json_encode(\$payload),
            ]);

            \$statusCode = \$response->getStatusCode();
            \$bodyContent = \$response->getBody()->getContents();

            if (\$statusCode !== 200) {
                \$this->logger->error('EROS: Gemini API returned a non-200 status code.', ['app' => 'eros', 'status' => \$statusCode, 'body' => \$bodyContent]);
                return new DataResponse(['response' => 'ERROR: The Oracle is not responding correctly. Status code: ' . \$statusCode], 500);
            }

            \$body = json_decode(\$bodyContent, true);
            
            if (!isset(\$body['candidates'][0]['content']['parts'][0]['text'])) {
                 \$this->logger->error('EROS: Unexpected response structure from Gemini API.', ['app' => 'eros', 'response' => \$bodyContent]);
                 return new DataResponse(['response' => 'ERROR: The Oracle\'s response was unreadable.'], 500);
            }

            \$responseText = \$body['candidates'][0]['content']['parts'][0]['text'];
            return new DataResponse(['response' => \$responseText]);

        } catch (\Exception \$e) {
            \$this->logger->logException(\$e, ['app' => 'eros']);
            return new DataResponse(['response' => 'ERROR: A critical error occurred while communicating with the Oracle. Check the Nextcloud log for details.'], 500);
        }
    }
}
EOF

# --- File: templates/main.php ---
cat <<'EOF' > templates/main.php
<?php
/**
 * @var \OCP\IL10N \$l
 * @var array \$_
 */
?>
<div id="content">
	<!-- The EROS Vue.js application will be mounted here by src/main.js -->
</div>
EOF

echo "--> Step 2: Complete. All blueprints have been forged."

# --- PART 3: BUILD THE SHIP ---
echo "--> Step 3: Installing backend dependencies..."
composer install

echo "--> Step 4: Installing frontend dependencies..."
npm install

echo "--> Step 5: Building frontend assets..."
npm run build

echo "--> Step 5: Complete. The ship has been built."

# --- PART 4: COMMISSION THE SHIP ---
echo "--> Step 6: Commissioning the EROS app..."
cd /var/www/html
./occ app:enable eros
./occ maintenance:repair

echo "--- PROTOCOL COMPLETE ---"
echo "The EROS app is now built and enabled. Please set your API key and refresh your browser."
