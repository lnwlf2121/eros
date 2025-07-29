#!/bin/bash
#define the app dir
EROS_DIR=/var/www/html/apps-extra/eros
#These are the final, correct versions of all the core frontend configuration files. They are designed to work together in a modern Nextcloud environment.
#
#File 1: package.json (The New Tool List)
#
#Action: Replace the entire contents of this file.
#
#Location: .../apps-extra/eros/package.json
cat <<END>${EROS_DIR}/package.json
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
END



#File 2: vite.config.js (The New Build Computer)
#
#Action: Replace the contents of this file. This is the definitive, correct configuration.
#
#Location: .../apps-extra/eros/vite.config.js

cat <<END> ${EROS_DIR}/vite.config.js

import { createAppConfig } from '@nextcloud/vite-config'

export default createAppConfig({
	main: 'src/main.js',
	build: {
		outDir: 'js',
		lib: {
			entry: 'src/main.js',
			name: 'eros',
			fileName: 'eros-main',
			formats: ['iife'],
		},
		rollupOptions: {
			external: (id) => id.startsWith('@nextcloud/'),
			output: {
				assetFileNames: 'main.css',
			},
		},
		cssCodeSplit: false,
	},
})
END


#File 3: tsconfig.json & tsconfig.node.json
#These files from the previous version of this guide are correct and do not need to be changed.
#
#Part 2: The Ship's Definitive Blueprints (Backend)
#These are the final, correct versions of all the backend PHP files, updated to use modern syntax and error handling.
#
#File 4: lib/AppInfo/Application.php (The App's Core)
#
#Action: Replace the contents of this file. This uses the modern, correct service registration.
#
#Location: .../apps-extra/eros/lib/AppInfo/Application.php
#
cat <<END>${EROS_DIR}/lib/AppInfo/Application.php
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
END

#jFile 5: lib/Controller/PageController.php (The Page Handler)
#j
#A#jction: Replace the contents of this file. This correctly loads the CSS and JS.
#
#Location: .../apps-extra/eros/lib/Controller/PageController.php
cat <<END>${EROS_DIR}/lib/Controller/PageController.php
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
END

make clean && make refresh
