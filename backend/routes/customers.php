<?php
/**
 * Sahara Infosys - Customer Routes
 * © Ibrahim Khatri since 2014
 */

$pdo = $GLOBALS['pdo'];
$method = $_SERVER['REQUEST_METHOD'];
$request_parts = array_filter(explode('/', trim($_SERVER['REQUEST_URI'], '/')));

switch($method) {
    case 'GET':
        if (isset($request_parts[2]) && is_numeric($request_parts[2])) {
            // Get single customer
            $id = $request_parts[2];
            $stmt = $pdo->prepare('SELECT * FROM customers WHERE id = ?');
            $stmt->execute([$id]);
            $customer = $stmt->fetch();
            
            if (!$customer) {
                http_response_code(404);
                echo json_encode(['error' => 'Customer not found']);
                exit;
            }
            
            echo json_encode(['status' => 'success', 'data' => $customer]);
        } else {
            // Get all customers
            $stmt = $pdo->query('SELECT * FROM customers ORDER BY created_at DESC');
            $customers = $stmt->fetchAll();
            echo json_encode(['status' => 'success', 'data' => $customers]);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (empty($data['name']) || empty($data['phone'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Name and phone are required']);
            exit;
        }
        
        try {
            $stmt = $pdo->prepare(
                'INSERT INTO customers (name, email, phone, address, city, state, zip_code, whatsapp_number, customer_type, notes, status) '
                . 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
            );
            
            $stmt->execute([
                $data['name'],
                $data['email'] ?? null,
                $data['phone'],
                $data['address'] ?? null,
                $data['city'] ?? null,
                $data['state'] ?? null,
                $data['zip_code'] ?? null,
                $data['whatsapp_number'] ?? null,
                $data['customer_type'] ?? 'individual',
                $data['notes'] ?? null,
                'active'
            ]);
            
            $customer_id = $pdo->lastInsertId();
            http_response_code(201);
            echo json_encode([
                'status' => 'success',
                'message' => 'Customer created successfully',
                'customer_id' => $customer_id
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to create customer']);
        }
        break;
        
    case 'PUT':
        if (!isset($request_parts[2]) || !is_numeric($request_parts[2])) {
            http_response_code(400);
            echo json_encode(['error' => 'Customer ID required']);
            exit;
        }
        
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $request_parts[2];
        
        try {
            $stmt = $pdo->prepare(
                'UPDATE customers SET name=?, email=?, phone=?, address=?, city=?, state=?, zip_code=?, whatsapp_number=?, customer_type=?, notes=? WHERE id=?'
            );
            
            $stmt->execute([
                $data['name'] ?? null,
                $data['email'] ?? null,
                $data['phone'] ?? null,
                $data['address'] ?? null,
                $data['city'] ?? null,
                $data['state'] ?? null,
                $data['zip_code'] ?? null,
                $data['whatsapp_number'] ?? null,
                $data['customer_type'] ?? null,
                $data['notes'] ?? null,
                $id
            ]);
            
            echo json_encode(['status' => 'success', 'message' => 'Customer updated']);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to update customer']);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
}
?>
