<?php
/**
 * Sahara Infosys - Configuration
 * © Ibrahim Khatri since 2014
 */

// Load environment variables
if (file_exists(__DIR__ . '/.env')) {
    $env_file = file_get_contents(__DIR__ . '/.env');
    $lines = explode("\n", $env_file);
    foreach ($lines as $line) {
        $line = trim($line);
        if (!empty($line) && strpos($line, '#') !== 0) {
            list($key, $value) = array_pad(explode('=', $line, 2), 2, null);
            $_ENV[trim($key)] = trim($value, '"');
        }
    }
}

// Application Settings
define('APP_NAME', $_ENV['APP_NAME'] ?? 'Sahara Infosys');
define('APP_ENV', $_ENV['APP_ENV'] ?? 'development');
define('APP_DEBUG', $_ENV['APP_DEBUG'] ?? false);
define('APP_URL', $_ENV['APP_URL'] ?? 'http://localhost:8000');
define('APP_KEY', $_ENV['APP_KEY'] ?? 'no-key-set');

// Database Configuration
define('DB_HOST', $_ENV['DB_HOST'] ?? 'localhost');
define('DB_PORT', $_ENV['DB_PORT'] ?? 3306);
define('DB_NAME', $_ENV['DB_NAME'] ?? 'sahara_infosys');
define('DB_USER', $_ENV['DB_USER'] ?? 'root');
define('DB_PASS', $_ENV['DB_PASSWORD'] ?? '');
define('DB_CHARSET', $_ENV['DB_CHARSET'] ?? 'utf8mb4');

// JWT Configuration
define('JWT_SECRET', $_ENV['JWT_SECRET'] ?? 'your-secret-key');
define('JWT_EXPIRY', $_ENV['JWT_EXPIRY'] ?? 3600);

// Database Connection
try {
    $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;
    $pdo = new PDO($dsn, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    if (APP_DEBUG) {
        die('Database Connection Error: ' . $e->getMessage());
    }
    die('Database connection failed');
}

// Global PDO instance
$GLOBALS['pdo'] = $pdo;
?>
