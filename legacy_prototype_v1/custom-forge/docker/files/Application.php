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
