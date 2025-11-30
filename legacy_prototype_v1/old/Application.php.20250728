<?php
declare(strict_types=1);

namespace OCA\EROS\AppInfo;

use OCP\AppFramework\App;
use OCP\AppFramework\Bootstrap\IBootContext;
use OCP\AppFramework\Bootstrap\IBootstrap;
use OCP\AppFramework\Bootstrap\IRegistrationContext;
use OCA\EROS\Controller\ErosController;
use OCA\EROS\Controller\PageController;

class Application extends App implements IBootstrap {
    public const APP_ID = 'eros';

    public function __construct(array $urlParams = []) {
        parent::__construct(self::APP_ID, $urlParams);
    }

    public function register(IRegistrationContext $context): void {
        // Register controllers as services
        $context->registerService('PageController', function($c) {
            return new PageController(
                $c->get('AppName'),
                $c->get('Request')
            );
        });
        $context->registerService('ErosController', function($c) {
            return new ErosController(
                $c->get('AppName'),
                $c->get('Request'),
                $c->get('config'),
                $c->get('ClientService')
            );
        });
    }

    public function boot(IBootContext $context): void {
        // Nothing to do here for now
    }
}
