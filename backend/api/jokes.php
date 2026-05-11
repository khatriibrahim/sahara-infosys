<?php
/**
 * Sahara Infosys - Joke Generator API
 * © Ibrahim Khatri since 2014
 * 
 * Fetches random jokes from JokeAPI
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

// Handle CORS preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

/**
 * Fetch a random joke from JokeAPI
 * API: https://jokeapi.dev
 */
function getRandomJoke() {
    try {
        // JokeAPI endpoint - excludes nsfw and political jokes
        $url = 'https://v2.jokeapi.dev/joke/Any?blacklistFlags=nsfw,political&type=single';
        
        // Initialize cURL
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 5,
            CURLOPT_HTTPHEADER => ['User-Agent: Sahara-Infosys/1.0']
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode !== 200) {
            return [
                'success' => false,
                'error' => 'Failed to fetch joke from API',
                'code' => $httpCode
            ];
        }
        
        $data = json_decode($response, true);
        
        if ($data['error']) {
            return [
                'success' => false,
                'error' => 'No jokes available for this category'
            ];
        }
        
        return [
            'success' => true,
            'joke' => $data['joke'],
            'category' => $data['category'],
            'type' => $data['type'],
            'id' => $data['id']
        ];
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'error' => 'Exception: ' . $e->getMessage()
        ];
    }
}

/**
 * Fetch joke by category
 */
function getJokeByCategory($category) {
    try {
        $validCategories = ['general', 'programming', 'knock-knock'];
        
        if (!in_array($category, $validCategories)) {
            return [
                'success' => false,
                'error' => 'Invalid category. Valid: ' . implode(', ', $validCategories)
            ];
        }
        
        $url = "https://v2.jokeapi.dev/joke/{$category}?blacklistFlags=nsfw,political&type=single";
        
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 5,
            CURLOPT_HTTPHEADER => ['User-Agent: Sahara-Infosys/1.0']
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode !== 200) {
            return [
                'success' => false,
                'error' => 'Failed to fetch joke'
            ];
        }
        
        $data = json_decode($response, true);
        
        return [
            'success' => true,
            'joke' => $data['joke'],
            'category' => $data['category'],
            'type' => $data['type']
        ];
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'error' => 'Exception: ' . $e->getMessage()
        ];
    }
}

// Route handling
$request = $_GET['action'] ?? 'random';

switch ($request) {
    case 'random':
        echo json_encode(getRandomJoke());
        break;
    
    case 'category':
        $category = $_GET['category'] ?? 'general';
        echo json_encode(getJokeByCategory($category));
        break;
    
    case 'categories':
        echo json_encode([
            'success' => true,
            'categories' => ['general', 'programming', 'knock-knock']
        ]);
        break;
    
    default:
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'Invalid action. Use: random, category, categories'
        ]);
}
?>
