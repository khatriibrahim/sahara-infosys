<?php
/**
 * Sahara Infosys - Invoice Routes
 * © Ibrahim Khatri since 2014
 */

$pdo = $GLOBALS['pdo'];
$method = $_SERVER['REQUEST_METHOD'];
$request_parts = array_filter(explode('/', trim($_SERVER['REQUEST_URI'], '/')));

switch($method) {
    case 'GET':
        if (isset($request_parts[2]) && is_numeric($request_parts[2])) {
            // Get single invoice
            $id = $request_parts[2];
            $stmt = $pdo->prepare('SELECT i.*, c.name as customer_name FROM invoices i LEFT JOIN customers c ON i.customer_id = c.id WHERE i.id = ?');
            $stmt->execute([$id]);
            $invoice = $stmt->fetch();
            
            if (!$invoice) {
                http_response_code(404);
                echo json_encode(['error' => 'Invoice not found']);
                exit;
            }
            
            // Get invoice items
            $items_stmt = $pdo->prepare('SELECT * FROM invoice_items WHERE invoice_id = ?');
            $items_stmt->execute([$id]);
            $invoice['items'] = $items_stmt->fetchAll();
            
            echo json_encode(['status' => 'success', 'data' => $invoice]);
        } else {
            // Get all invoices
            $stmt = $pdo->query(
                'SELECT i.*, c.name as customer_name FROM invoices i '
                . 'LEFT JOIN customers c ON i.customer_id = c.id '
                . 'ORDER BY i.created_at DESC'
            );
            $invoices = $stmt->fetchAll();
            echo json_encode(['status' => 'success', 'data' => $invoices]);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (empty($data['customer_id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Customer ID is required']);
            exit;
        }
        
        try {
            // Generate invoice number
            $invoice_number = 'INV-' . date('Ymd') . '-' . strtoupper(substr(uniqid(), -4));
            
            $stmt = $pdo->prepare(
                'INSERT INTO invoices (invoice_number, job_id, customer_id, subtotal, tax, discount, total_amount, payment_method, payment_status, due_date, notes) '
                . 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
            );
            
            $stmt->execute([
                $invoice_number,
                $data['job_id'] ?? null,
                $data['customer_id'],
                $data['subtotal'] ?? 0,
                $data['tax'] ?? 0,
                $data['discount'] ?? 0,
                $data['total_amount'] ?? 0,
                $data['payment_method'] ?? 'cash',
                'unpaid',
                $data['due_date'] ?? null,
                $data['notes'] ?? null
            ]);
            
            $invoice_id = $pdo->lastInsertId();
            http_response_code(201);
            echo json_encode([
                'status' => 'success',
                'message' => 'Invoice created successfully',
                'invoice_id' => $invoice_id,
                'invoice_number' => $invoice_number
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to create invoice']);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
}
?>
