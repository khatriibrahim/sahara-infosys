<?php
/**
 * Sahara Infosys - Smart Service Center Management System
 * © Ibrahim Khatri since 2014
 * 
 * Main API Entry Point
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Load environment variables
require_once __DIR__ . '/../config/config.php';

// Simple routing
$request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$request_method = $_SERVER['REQUEST_METHOD'];
$request_parts = array_filter(explode('/', trim($request_uri, '/')));

// Route handler (basic routing)
if (empty($request_parts)) {
    echo json_encode([
        'status' => 'success',
        'message' => 'Sahara Infosys API v1.0',
        'version' => '1.0.0',
        'author' => 'Ibrahim Khatri',
        'since' => 2014
    ]);
    exit;
}

// Route: /api/...
if ($request_parts[0] === 'api') {
    if (!isset($request_parts[1])) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid API endpoint']);
        exit;
    }
    
    $resource = $request_parts[1];
    
    // Load appropriate controller
    switch($resource) {
        case 'auth':
            require_once __DIR__ . '/../routes/auth.php';
            break;
        case 'customers':
            require_once __DIR__ . '/../routes/customers.php';
            break;
        case 'jobs':
            require_once __DIR__ . '/../routes/jobs.php';
            break;
        case 'inventory':
            require_once __DIR__ . '/../routes/inventory.php';
            break;
        case 'invoices':
            require_once __DIR__ . '/../routes/invoices.php';
            break;
        default:
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint not found']);
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Not Found']);
}
?>
