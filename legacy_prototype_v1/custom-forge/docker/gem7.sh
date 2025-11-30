#!/bin/bash
# EROS - The Definitive Blueprint Script v1.2
# -----------------------------------------------------------------------------
# This script performs a complete and clean setup of the EROS Nextcloud app.
# It replaces all key configuration and code files with their final, correct
# versions, installs all dependencies, and builds the application.
#
# USAGE: Run this script from within the main 'eros' app directory inside
#        the Nextcloud development container.
# -----------------------------------------------------------------------------

set -e
echo "--- Beginning EROS Definitive Blueprint Protocol ---"

# --- PART 1: CLEAN SLATE ---
echo "--> Step 1: Purging old configurations and artifacts..."
rm -rf \
  node_modules \
  package-lock.json \
  vendor \
  composer.lock \
  js/ \
  css/ \
  tsconfig.json \
  tsconfig.node.json \
  vite.config.js \
  composer.json \
  lib/ \
  appinfo/ \
  templates/ \
  src/

# --- PART 2: FORGE THE BLUEPRINTS ---
echo "--> Step 2: Forging definitive blueprints..."

# Create necessary directories
mkdir -p appinfo lib/AppInfo lib/Controller templates src/components img

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
            <icon>img/app.svg</icon>
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

    public function __construct(array \$urlParams = []) {
        parent::__construct(self::APP_ID, \$urlParams);
    }

    public function register(IRegistrationContext \$context): void {
        \$context->registerService('PageController', function(ContainerInterface \$c) {
            return new PageController(
                \$c->get('AppName'),
                \$c->get(IRequest::class)
            );
        });
        \$context->registerService('ErosController', function(ContainerInterface \$c) {
            return new ErosController(
                \$c->get('AppName'),
                \$c->get(IRequest::class),
                \$c->get(IConfig::class),
                \$c->get(IClientService::class),
                \$c->get(ILogger::class)
            );
        });
    }

    public function boot(IBootContext \$context): void {}
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
            return new DataResponse(['response' => 'ERROR: Gemini API key is not configured.'], 500);
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
                \$this->logger->error('EROS: Gemini API returned non-200 status.', ['app' => 'eros', 'status' => \$statusCode, 'body' => \$bodyContent]);
                return new DataResponse(['response' => 'ERROR: Oracle returned status ' . \$statusCode], 500);
            }
            \$body = json_decode(\$bodyContent, true);
            if (!isset(\$body['candidates'][0]['content']['parts'][0]['text'])) {
                 \$this->logger->error('EROS: Unexpected response structure from API.', ['app' => 'eros', 'response' => \$bodyContent]);
                 return new DataResponse(['response' => 'ERROR: The Oracle\'s response was unreadable.'], 500);
            }
            \$responseText = \$body['candidates'][0]['content']['parts'][0]['text'];
            return new DataResponse(['response' => \$responseText]);
        } catch (\Exception \$e) {
            \$this->logger->logException(\$e, ['app' => 'eros']);
            return new DataResponse(['response' => 'ERROR: Critical communication failure. Check logs.'], 500);
        }
    }
}
EOF

# --- File: templates/main.php ---
cat <<'EOF' > templates/main.php
<?php
/** @var \OCP\IL10N \$l */
/** @var array \$_ */
?>
<div id="content">
	<!-- The EROS Vue.js application will be mounted here by src/main.js -->
</div>
EOF

# --- File: src/main.js ---
cat <<'EOF' > src/main.js
import { createApp } from 'vue'
import App from './App.vue'

createApp(App).mount('#content')
EOF

# --- File: src/App.vue ---
cat <<'EOF' > src/App.vue
<template>
  <Main />
</template>

<script>
import Main from './components/Main.vue'

export default {
  name: 'App',
  components: {
    Main,
  },
}
</script>
EOF

# --- File: src/components/Main.vue ---
cat <<'EOF' > src/components/Main.vue
<template>
  <div id="eros-app" class="h-full w-full bg-slate-900 text-cyan-200 flex flex-col font-mono">
    <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/stardust.png')] opacity-20 z-0"></div>
    <div class="absolute inset-0 bg-gradient-to-b from-slate-800/50 via-transparent to-slate-900 z-0"></div>
    <header class="relative text-center p-4 border-b border-cyan-500/30 shadow-[0_4px_15px_-5px_rgba(0,255,255,0.2)]">
        <h1 class="text-3xl font-bold text-cyan-300 tracking-widest uppercase">StarShip EROS</h1>
        <p class="text-sm text-cyan-400/70">Unified Command Interface</p>
    </header>
    <main class="w-full h-full flex-grow flex flex-col md:flex-row gap-4 p-4 overflow-hidden">
        <div class="w-full md:w-1/3 lg:w-1/4 flex flex-col gap-4">
            <div class="bg-black/30 p-4 rounded-md border border-cyan-500/30 h-1/2 flex flex-col">
                <h2 class="text-lg font-bold text-cyan-300 uppercase mb-3">System Status</h2>
                <div class="space-y-2 text-sm">
                    <p>Oracle (Gemini): <span class="text-green-400 font-bold">ONLINE</span></p>
                    <p>Quartermaster (Alexa): <span class="text-yellow-400">STANDBY</span></p>
                    <p>Guardian (Siri): <span class="text-yellow-400">STANDBY</span></p>
                    <p>Citadel Connection: <span class="text-green-400 font-bold">SECURE</span></p>
                </div>
            </div>
            <div class="bg-black/30 p-4 rounded-md border border-cyan-500/30 h-1/2 flex flex-col">
                <h2 class="text-lg font-bold text-cyan-300 uppercase mb-3">Active Quests</h2>
                <div class="space-y-2 text-sm overflow-y-auto">
                    <p class="text-cyan-300">> Poseidon's Legacy</p>
                    <p class="text-cyan-500/70">> Prizmatic Bricks</p>
                    <p class="text-cyan-500/70">> Rise of the LightBringer</p>
                </div>
            </div>
        </div>
        <div class="w-full md:w-2/3 lg:w-3/4 flex flex-col bg-black/30 rounded-md border border-cyan-500/30">
            <div id="transcript-log" class="flex-grow p-4 space-y-4 overflow-y-auto">
                <div v-for="message in transcript" :key="message.id">
                    <div v-if="message.author === 'Captain'" class="text-right">
                        <p class="text-sm text-cyan-300">> {{ message.text }}</p>
                    </div>
                    <div v-else class="text-left">
                        <p class="text-sm text-green-400">{{ message.author }}: <span class="text-cyan-400">{{ message.text }}</span></p>
                    </div>
                </div>
            </div>
            <div class="p-4 border-t border-cyan-500/30">
                <div class="flex items-center gap-4">
                    <span class="text-cyan-300 font-bold text-lg">CMD:></span>
                    <input v-model="newMessage" @keydown.enter="broadcastMessage" :disabled="isLoading" class="flex-grow bg-transparent text-cyan-300 focus:outline-none placeholder-cyan-500/50" type="text" placeholder="Issue command...">
                    <button @click="broadcastMessage" :disabled="isLoading" class="bg-cyan-500/20 hover:bg-cyan-500/40 text-cyan-300 font-bold py-1 px-4 rounded-sm border border-cyan-500/50 transition disabled:opacity-50">
                        <span v-if="!isLoading">EXECUTE</span>
                        <span v-else>...</span>
                    </button>
                </div>
            </div>
        </div>
    </main>
  </div>
</template>
<script>
import axios from '@nextcloud/axios'
export default {
  name: 'Main',
  data() {
    return {
      newMessage: '',
      isLoading: false,
      transcript: [ { id: 1, author: 'ORACLE', text: "Bridge is online. Awaiting command, Captain." } ]
    }
  },
  methods: {
    async broadcastMessage() {
        if (this.newMessage.trim() === '' || this.isLoading) return;
        this.isLoading = true;
        const userMessage = this.newMessage.trim();
        this.transcript.push({ id: Date.now(), author: 'Captain', text: userMessage });
        this.newMessage = '';
        this.scrollToBottom();
        try {
            const response = await axios.post('/apps/eros/api/v1/broadcast', { prompt: userMessage });
            this.transcript.push({ id: Date.now() + 1, author: 'ORACLE', text: response.data.response });
        } catch (error) {
            this.transcript.push({ id: Date.now() + 1, author: 'SYSTEM', text: 'Connection to Oracle failed. Check logs.' });
        } finally {
            this.isLoading = false;
            this.scrollToBottom();
        }
    },
    scrollToBottom() {
        this.$nextTick(() => {
            const log = document.getElementById('transcript-log');
            if (log) { log.scrollTop = log.scrollHeight; }
        });
    }
  }
}
</script>
EOF

echo "--> Step 2: Complete. All blueprints have been forged."

# --- PART 3: BUILD THE SHIP ---
echo "--> Step 3: Building backend..."
composer install

echo "--> Step 4: Building frontend..."
npm install
npm run build

echo "--> Step 4: Complete. The ship has been built."

# --- PART 5: COMMISSION THE SHIP ---
echo "--> Step 5: Commissioning the EROS app..."
cd /var/www/html
./occ app:disable eros || true # Ignore error if not enabled
./occ app:enable eros
./occ maintenance:repair

echo "--- PROTOCOL COMPLETE ---"
echo "The EROS app is now built and enabled. Please set your API key and refresh your browser."

