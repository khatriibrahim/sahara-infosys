<?php
/**
 * Sahara Infosys - Inventory Routes
 * © Ibrahim Khatri since 2014
 */

$pdo = $GLOBALS['pdo'];
$method = $_SERVER['REQUEST_METHOD'];
$request_parts = array_filter(explode('/', trim($_SERVER['REQUEST_URI'], '/')));

switch($method) {
    case 'GET':
        if (isset($request_parts[2]) && is_numeric($request_parts[2])) {
            // Get single item
            $id = $request_parts[2];
            $stmt = $pdo->prepare('SELECT i.*, c.name as category_name FROM inventory i LEFT JOIN inventory_categories c ON i.category_id = c.id WHERE i.id = ?');
            $stmt->execute([$id]);
            $item = $stmt->fetch();
            
            if (!$item) {
                http_response_code(404);
                echo json_encode(['error' => 'Inventory item not found']);
                exit;
            }
            
            echo json_encode(['status' => 'success', 'data' => $item]);
        } else {
            // Get all items
            $stmt = $pdo->query(
                'SELECT i.*, c.name as category_name FROM inventory i '
                . 'LEFT JOIN inventory_categories c ON i.category_id = c.id '
                . 'ORDER BY i.part_name'
            );
            $items = $stmt->fetchAll();
            echo json_encode(['status' => 'success', 'data' => $items]);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (empty($data['part_name']) || empty($data['part_code'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Part name and code are required']);
            exit;
        }
        
        try {
            $stmt = $pdo->prepare(
                'INSERT INTO inventory (part_name, part_code, category_id, quantity, min_quantity, unit_price, supplier, notes) '
                . 'VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
            );
            
            $stmt->execute([
                $data['part_name'],
                $data['part_code'],
                $data['category_id'] ?? null,
                $data['quantity'] ?? 0,
                $data['min_quantity'] ?? 5,
                $data['unit_price'] ?? 0,
                $data['supplier'] ?? null,
                $data['notes'] ?? null
            ]);
            
            $item_id = $pdo->lastInsertId();
            http_response_code(201);
            echo json_encode([
                'status' => 'success',
                'message' => 'Inventory item created successfully',
                'item_id' => $item_id
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to create inventory item']);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
}
?>
