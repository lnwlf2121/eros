#!/bin/bash
#### created to script this stupid 'learning doc' that has me copying and pasting like some newb

echo <<END > /var/www/html/apps-extra/eros/vite.config.js 
import { defineConfig } from 'vite'
import { createAppConfig } from '@nextcloud/vite-config'

export default defineConfig(
	createAppConfig({
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
	}),
)
END

echo <<END>/var/www/html/apps-extra/eros/lib/AppInfo/Application.php
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

echo <<END>/var/www/html/apps-extra/eros/lib/Controller/PageController.php
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

echo <<END>/var/www/html/apps-extra/eros/lib/Controller/ErosController.php

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
            return new DataResponse(['response' => 'ERROR: Gemini API key is not configured. Please ask the server administrator to set it.'], 500);
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
                $this->logger->error('EROS: Gemini API returned a non-200 status code.', ['app' => 'eros', 'status' => $statusCode, 'body' => $bodyContent]);
                return new DataResponse(['response' => 'ERROR: The Oracle is not responding correctly. Status code: ' . $statusCode], 500);
            }

            $body = json_decode($bodyContent, true);
            
            if (!isset($body['candidates'][0]['content']['parts'][0]['text'])) {
                 $this->logger->error('EROS: Unexpected response structure from Gemini API.', ['app' => 'eros', 'response' => $bodyContent]);
                 return new DataResponse(['response' => 'ERROR: The Oracle\'s response was unreadable.'], 500);
            }

            $responseText = $body['candidates'][0]['content']['parts'][0]['text'];
            return new DataResponse(['response' => $responseText]);

        } catch (\Exception $e) {
            $this->logger->logException($e, ['app' => 'eros']);
            return new DataResponse(['response' => 'ERROR: A critical error occurred while communicating with the Oracle. Check the Nextcloud log for details.'], 500);
        }
    }
}
END

