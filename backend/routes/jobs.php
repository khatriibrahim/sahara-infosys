<?php
/**
 * Sahara Infosys - Repair Jobs Routes
 * © Ibrahim Khatri since 2014
 */

$pdo = $GLOBALS['pdo'];
$method = $_SERVER['REQUEST_METHOD'];
$request_parts = array_filter(explode('/', trim($_SERVER['REQUEST_URI'], '/')));

switch($method) {
    case 'GET':
        if (isset($request_parts[2]) && is_numeric($request_parts[2])) {
            // Get single job
            $id = $request_parts[2];
            $stmt = $pdo->prepare(
                'SELECT j.*, c.name as customer_name, c.phone as customer_phone, u.username as assigned_to_name '
                . 'FROM repair_jobs j '
                . 'LEFT JOIN customers c ON j.customer_id = c.id '
                . 'LEFT JOIN users u ON j.assigned_to = u.id '
                . 'WHERE j.id = ?'
            );
            $stmt->execute([$id]);
            $job = $stmt->fetch();
            
            if (!$job) {
                http_response_code(404);
                echo json_encode(['error' => 'Job not found']);
                exit;
            }
            
            echo json_encode(['status' => 'success', 'data' => $job]);
        } else {
            // Get all jobs
            $stmt = $pdo->query(
                'SELECT j.*, c.name as customer_name FROM repair_jobs j '
                . 'LEFT JOIN customers c ON j.customer_id = c.id '
                . 'ORDER BY j.created_at DESC'
            );
            $jobs = $stmt->fetchAll();
            echo json_encode(['status' => 'success', 'data' => $jobs]);
        }
        break;
        
    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (empty($data['customer_id']) || empty($data['issue_description'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Customer ID and issue description are required']);
            exit;
        }
        
        try {
            // Generate unique job number
            $job_number = 'JOB-' . date('Ymd') . '-' . strtoupper(substr(uniqid(), -4));
            
            $stmt = $pdo->prepare(
                'INSERT INTO repair_jobs (job_number, customer_id, device_type, device_model, device_serial, issue_description, assigned_to, status, priority, estimated_cost, notes) '
                . 'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
            );
            
            $stmt->execute([
                $job_number,
                $data['customer_id'],
                $data['device_type'] ?? null,
                $data['device_model'] ?? null,
                $data['device_serial'] ?? null,
                $data['issue_description'],
                $data['assigned_to'] ?? null,
                $data['status'] ?? 'pending',
                $data['priority'] ?? 'medium',
                $data['estimated_cost'] ?? null,
                $data['notes'] ?? null
            ]);
            
            $job_id = $pdo->lastInsertId();
            http_response_code(201);
            echo json_encode([
                'status' => 'success',
                'message' => 'Repair job created successfully',
                'job_id' => $job_id,
                'job_number' => $job_number
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to create job']);
        }
        break;
        
    case 'PUT':
        if (!isset($request_parts[2]) || !is_numeric($request_parts[2])) {
            http_response_code(400);
            echo json_encode(['error' => 'Job ID required']);
            exit;
        }
        
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $request_parts[2];
        
        try {
            $fields = [];
            $values = [];
            
            foreach ($data as $key => $value) {
                if (in_array($key, ['issue_description', 'status', 'priority', 'actual_cost', 'assigned_to', 'notes'])) {
                    $fields[] = "$key = ?";
                    $values[] = $value;
                }
            }
            
            $values[] = $id;
            
            $stmt = $pdo->prepare('UPDATE repair_jobs SET ' . implode(', ', $fields) . ' WHERE id = ?');
            $stmt->execute($values);
            
            echo json_encode(['status' => 'success', 'message' => 'Job updated']);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to update job']);
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
}
?>
