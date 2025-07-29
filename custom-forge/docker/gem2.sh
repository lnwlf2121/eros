#!/bin/bash
# EROS - The Definitive Blueprint Script v2.0
# -----------------------------------------------------------------------------
# This script performs a complete and clean refit of the EROS Nextcloud app's
# backend and configuration. It is designed to be run from within the main
# 'eros' app directory inside the Nextcloud development container.
# -----------------------------------------------------------------------------
# Capt. Ash says, again, this LIVEsin the docker dir so
base=/var/www/html/apps-extra/eros;
cd $base || die "Couldn't access $base: $!";

set -e
echo "--- Beginning EROS Definitive Blueprint Protocol ---"

# --- PART 1: CLEAN SLATE ---
echo "--> Step 1: Purging old backend blueprints..."
rm -rf lib/ appinfo/ templates/

# --- PART 2: FORGE THE DEFINITIVE BLUEPRINTS ---
echo "--> Step 2: Forging new, correct blueprints..."

# Create necessary directories
mkdir -p appinfo lib/AppInfo lib/Controller templates

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
            <icon>img/app.svg</icon> <!-- This path is correct for the icon in the nav bar -->
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
# Note: The main icon file now lives in appinfo/
cat <<'EOF' > appinfo/app.svg
<svg width="100" height="100" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M20 35C20 33.8954 20.8954 33 22 33H28C29.1046 33 30 33.8954 30 35V65C30 66.1046 29.1046 67 28 67H22C20.8954 67 20 66.1046 20 65V35Z" fill="currentColor"/>
    <path d="M45 20C45 18.8954 45.8954 18 47 18H53C54.1046 18 55 18.8954 55 20V80C55 81.1046 54.1046 82 53 82H47C45.8954 82 45 81.1046 45 80V20Z" fill="currentColor"/>
    <path d="M70 48C70 46.8954 70.8954 46 72 46H78C79.1046 46 80 46.8954 80 48V58C80 59.1046 79.1046 60 78 60H72C70.8954 60 70 59.1046 70 58V48Z" fill="currentColor"/>
</svg>
EOF
# We also need a copy in the img folder for the navigation route to find it
mkdir -p img
cp appinfo/app.svg img/app.svg

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
        $context->registerService('PageController', function(ContainerInterface $c) {
            return new PageController(
                $c->get('AppName'),
                $c->get(IRequest::class)
            );
        });
        $context->registerService('ErosController', function(ContainerInterface $c) {
            return new ErosController(
                $c->get('AppName'),
                $c->get(IRequest::class),
                $c->get(IConfig::class),
                $c->get(IClientService::class),
                $c->get(ILogger::class)
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
    public function __construct(string $appName, IRequest $request) {
        parent::__construct($appName, $request);
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
    private IConfig $config;
    private IClientService $clientService;
    private ILogger $logger;

    public function __construct(string $appName, IRequest $request, IConfig $config, IClientService $clientService, ILogger $logger){
        parent::__construct($appName, $request);
        $this->config = $config;
        $this->clientService = $clientService;
        $this->logger = $logger;
    }

    #[NoAdminRequired]
    #[NoCSRFRequired]
    public function broadcast(string $prompt): DataResponse {
        $apiKey = $this->config->getAppValue('eros', 'gemini_api_key', '');
        if (empty($apiKey)) {
            $this->logger->error('EROS: Gemini API key is not configured.', ['app' => 'eros']);
            return new DataResponse(['response' => 'ERROR: Gemini API key is not configured.'], 500);
        }
        $apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=' . $apiKey;
        $payload = ['contents' => [['parts' => [['text' => $prompt]]]]];
        try {
            $client = $this->clientService->newClient();
            $response = $client->post($apiUrl, [
                'headers' => ['Content-Type' => 'application/json'],
                'body' => json_encode($payload),
            ]);
            $statusCode = $response->getStatusCode();
            $bodyContent = $response->getBody()->getContents();
            if ($statusCode !== 200) {
                $this->logger->error('EROS: Gemini API returned non-200 status.', ['app' => 'eros', 'status' => $statusCode, 'body' => $bodyContent]);
                return new DataResponse(['response' => 'ERROR: Oracle returned status ' . $statusCode], 500);
            }
            $body = json_decode($bodyContent, true);
            if (!isset($body['candidates'][0]['content']['parts'][0]['text'])) {
                 $this->logger->error('EROS: Unexpected response structure from API.', ['app' => 'eros', 'response' => $bodyContent]);
                 return new DataResponse(['response' => 'ERROR: The Oracle\'s response was unreadable.'], 500);
            }
            $responseText = $body['candidates'][0]['content']['parts'][0]['text'];
            return new DataResponse(['response' => $responseText]);
        } catch (\Exception $e) {
            $this->logger->logException($e, ['app' => 'eros']);
            return new DataResponse(['response' => 'ERROR: Critical communication failure. Check logs.'], 500);
        }
    }
}
EOF

# --- File: templates/main.php ---
cat <<'EOF' > templates/main.php
<?php
/** @var \OCP\IL10N $l */
/** @var array $_ */
?>
<div id="content">
	<!-- The EROS Vue.js application will be mounted here by src/main.js -->
</div>
EOF

echo "--> Step 2: Complete. All blueprints have been forged."

# --- PART 3: BUILD THE SHIP ---
echo "--> Step 3: Building backend..."
composer install

echo "--> Step 4: Building frontend..."
npm install && npm run build

echo "--> Step 4: Complete. The ship has been built."

# --- PART 5: COMMISSION THE SHIP ---
echo "--> Step 5: Commissioning the EROS app..."
cd /var/www/html
./occ app:disable eros || true # Ignore error if not enabled
./occ app:enable eros
./occ maintenance:repair

echo "--- PROTOCOL COMPLETE ---"
echo "The EROS app is now built and enabled. Please set your API key and refresh your browser."

