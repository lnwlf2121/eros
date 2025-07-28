<?php
namespace OCA\EROS\Controller;

use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\DataResponse;
use OCP\AppFramework\Http\Attribute\NoAdminRequired;
use OCP\AppFramework\Http\Attribute\NoCSRFRequired;
use OCP\IConfig;
use OCP\Http\Client\IClientService;
use OCP\IRequest;

class ErosController extends Controller {

    private IConfig $config;
    private IClientService $clientService;

    public function __construct($AppName, IRequest $request, IConfig $config, IClientService $clientService){
        parent::__construct($AppName, $request);
        $this->config = $config;
        $this->clientService = $clientService;
    }

    #[NoAdminRequired]
    #[NoCSRFRequired]
    public function broadcast(string $prompt): DataResponse {
        $apiKey = $this->config->getAppValue('eros', 'gemini_api_key', '');

        if (empty($apiKey)) {
            return new DataResponse(['response' => 'ERROR: Gemini API key is not configured. Please set it via the occ command.'], 500);
        }

        $apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=' . $apiKey;
        $payload = ['contents' => [['parts' => [['text' => $prompt]]]]];

        try {
            $client = $this->clientService->newClient();
            $response = $client->post($apiUrl, [
                'headers' => ['Content-Type' => 'application/json'],
                'body' => json_encode($payload),
            ]);

            $body = json_decode($response->getBody()->getContents(), true);
            $responseText = $body['candidates'][0]['content']['parts'][0]['text'] ?? 'No valid response from AI.';
            
            return new DataResponse(['response' => $responseText]);
        } catch (\Exception $e) {
            return new DataResponse(['response' => 'ERROR: Failed to communicate with the Gemini API. Details: ' . $e->getMessage()], 500);
        }
    }
}

