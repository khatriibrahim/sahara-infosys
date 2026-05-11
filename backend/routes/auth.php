<?php
/**
 * Sahara Infosys - Authentication Routes
 * © Ibrahim Khatri since 2014
 */

$pdo = $GLOBALS['pdo'];
$method = $_SERVER['REQUEST_METHOD'];
$request_parts = array_filter(explode('/', trim($_SERVER['REQUEST_URI'], '/')));

if ($method === 'POST' && isset($request_parts[2]) && $request_parts[2] === 'login') {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['username']) || empty($data['password'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Username and password required']);
        exit;
    }
    
    try {
        $stmt = $pdo->prepare('SELECT u.*, r.name as role FROM users u JOIN roles r ON u.role_id = r.id WHERE u.username = ?');
        $stmt->execute([$data['username']]);
        $user = $stmt->fetch();
        
        if (!$user || !password_verify($data['password'], $user['password'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid credentials']);
            exit;
        }
        
        // Generate JWT Token (simple implementation)
        $header = base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
        $payload = base64_encode(json_encode([
            'user_id' => $user['id'],
            'username' => $user['username'],
            'role' => $user['role'],
            'iat' => time(),
            'exp' => time() + JWT_EXPIRY
        ]));
        
        $signature = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
        $token = "$header.$payload.$signature";
        
        http_response_code(200);
        echo json_encode([
            'status' => 'success',
            'token' => $token,
            'user' => [
                'id' => $user['id'],
                'username' => $user['username'],
                'email' => $user['email'],
                'role' => $user['role']
            ]
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Server error']);
    }
} else if ($method === 'POST' && isset($request_parts[2]) && $request_parts[2] === 'register') {
    http_response_code(501);
    echo json_encode(['message' => 'Registration endpoint not yet implemented']);
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
