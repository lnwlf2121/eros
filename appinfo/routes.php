<?php
return [
	'routes' => [
		// The main route for the app's user interface
		['name' => 'page#index', 'url' => '/', 'verb' => 'GET'],
		// The API endpoint for the broadcast function
		['name' => 'eros#broadcast', 'url' => '/api/v1/broadcast', 'verb' => 'POST'],
	]
];
