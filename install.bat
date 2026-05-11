@echo off
REM ============================================================================
REM Sahara Infosys - Smart Service Center Management System
REM Easy Installer for Windows
REM © Ibrahim Khatri since 2014
REM ============================================================================

setlocal enabledelayedexpansion
cd /d "%~dp0"

REM Colors and styling
color 0A
cls

echo.
echo ============================================================================
echo.
echo   Sahara Infosys - Smart Service Center Management System
echo   © Ibrahim Khatri since 2014
echo.
echo   Easy Installer for Windows
echo.
echo ============================================================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] WARNING: This script requires Administrator privileges
    echo [!] Please run as Administrator for best results
    echo.
    pause
)

REM Check for PHP
echo [*] Checking for PHP installation...
php -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] PHP not found in system PATH
    echo.
    echo [!] Please install PHP first:
    echo    - Download from: https://windows.php.net/download/
    echo    - Or use: https://www.apachefriends.org/ (XAMPP)
    echo.
    pause
    exit /b 1
) else (
    for /f "tokens=2" %%i in ('php -v ^| findstr /R "PHP [0-9]"') do set PHP_VERSION=%%i
    echo [OK] PHP !PHP_VERSION! found
)

REM Check for MySQL/MariaDB
echo [*] Checking for MySQL/MariaDB installation...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] MySQL/MariaDB not found in system PATH
    echo.
    echo [!] Please install MySQL or MariaDB:
    echo    - MySQL: https://dev.mysql.com/downloads/mysql/
    echo    - MariaDB: https://mariadb.org/download/
    echo    - Or use: https://www.apachefriends.org/ (XAMPP)
    echo.
    pause
    exit /b 1
) else (
    echo [OK] MySQL/MariaDB found
)

REM Check for Git (optional but recommended)
echo [*] Checking for Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Git not found (optional - install from https://git-scm.com/)
) else (
    echo [OK] Git found
)

cls
echo.
echo ============================================================================
echo   INSTALLATION MENU
echo ============================================================================
echo.
echo 1. Full Installation (Recommended)
echo    - Setup database
    echo    - Create environment file
    echo    - Initialize tables
echo.
echo 2. Database Only
    echo    - Create and initialize database
echo.
echo 3. Environment Setup Only
    echo    - Create .env configuration file
echo.
echo 4. Start Development Server
    echo    - Run PHP built-in server
echo.
echo 5. View API Documentation
    echo    - Open API docs in browser
echo.
echo 6. Reset Everything
    echo    - Reset database and config (WARNING: Destructive)
echo.
echo 0. Exit
echo.
set /p choice="Enter your choice (0-6): "

if "%choice%"=="1" goto full_install
if "%choice%"=="2" goto db_only
if "%choice%"=="3" goto env_only
if "%choice%"=="4" goto start_server
if "%choice%"=="5" goto view_docs
if "%choice%"=="6" goto reset_all
if "%choice%"=="0" goto exit_script
goto invalid_choice

REM ============================================================================
REM FULL INSTALLATION
REM ============================================================================
:full_install
cls
echo.
echo [*] Starting Full Installation...
echo.

REM Setup Environment File
echo [*] Setting up environment configuration...
if exist backend\config\.env (
    echo [!] .env file already exists
    set /p overwrite="Overwrite existing .env? (y/n): "
    if /i not "!overwrite!"=="y" goto skip_env_full
)

setlocal enabledelayedexpansion
set /p db_host="Enter Database Host (default: localhost): "
if "!db_host!"=="" set db_host=localhost

set /p db_name="Enter Database Name (default: sahara_infosys): "
if "!db_name!"=="" set db_name=sahara_infosys

set /p db_user="Enter Database User (default: root): "
if "!db_user!"=="" set db_user=root

set /p db_pass="Enter Database Password (press Enter for no password): "

set /p jwt_secret="Enter JWT Secret (press Enter for random): "
if "!jwt_secret!"=="" (
    set jwt_secret=your-secret-key-here
)

(
    echo # Sahara Infosys - Environment Configuration
    echo # © Ibrahim Khatri since 2014
    echo.
    echo # Application
    echo APP_NAME="Sahara Infosys"
    echo APP_ENV=development
    echo APP_DEBUG=true
    echo APP_URL=http://localhost:8000
    echo APP_KEY=sahara-key-2014
    echo.
    echo # Database
    echo DB_HOST=!db_host!
    echo DB_PORT=3306
    echo DB_NAME=!db_name!
    echo DB_USER=!db_user!
    echo DB_PASSWORD=!db_pass!
    echo DB_CHARSET=utf8mb4
    echo.
    echo # JWT
    echo JWT_SECRET=!jwt_secret!
    echo JWT_EXPIRY=3600
    echo.
    echo # CORS
    echo CORS_ALLOW_ORIGINS=http://localhost:3000,http://localhost
    echo.
    echo # File Upload
    echo MAX_UPLOAD_SIZE=10485760
    echo UPLOAD_PATH=uploads/
) > backend\config\.env

echo [OK] Environment file created at backend\config\.env

:skip_env_full

REM Create database
echo [*] Creating database...
mysql -h !db_host! -u !db_user! %if not "!db_pass!"=="" (-p!db_pass!) > nul 2>&1 << EOF
CREATE DATABASE IF NOT EXISTS `!db_name!`;
EOF

if !errorlevel! equ 0 (
    echo [OK] Database created
) else (
    echo [X] Failed to create database
    echo [!] Make sure MySQL is running and credentials are correct
    pause
    exit /b 1
)

REM Import schema
echo [*] Importing database schema...
mysql -h !db_host! -u !db_user! %if not "!db_pass!"=="" (-p!db_pass!) !db_name! < backend\database\schema.sql

if !errorlevel! equ 0 (
    echo [OK] Database schema imported successfully
) else (
    echo [X] Failed to import schema
    pause
    exit /b 1
)

REM Create directories
echo [*] Creating necessary directories...
if not exist uploads mkdir uploads
if not exist temp mkdir temp
if not exist cache mkdir cache
echo [OK] Directories created

echo.
echo ============================================================================
echo [OK] Installation completed successfully!
echo ============================================================================
echo.
echo Next steps:
echo 1. Start the server: Choose option 4 from the menu
echo 2. Access Admin Panel: http://localhost:8000/../admin-panel
echo 3. View API Documentation: Choose option 5 from the menu
echo.
pause
goto menu

REM ============================================================================
REM DATABASE ONLY
REM ============================================================================
:db_only
cls
echo.
echo [*] Database Setup Only...
echo.

set /p db_host="Enter Database Host (default: localhost): "
if "!db_host!"=="" set db_host=localhost

set /p db_name="Enter Database Name (default: sahara_infosys): "
if "!db_name!"=="" set db_name=sahara_infosys

set /p db_user="Enter Database User (default: root): "
if "!db_user!"=="" set db_user=root

set /p db_pass="Enter Database Password (press Enter for no password): "

echo [*] Creating database...
mysql -h !db_host! -u !db_user! %if not "!db_pass!"=="" (-p!db_pass!) > nul 2>&1 << EOF
CREATE DATABASE IF NOT EXISTS `!db_name!`;
EOF

if !errorlevel! equ 0 (
    echo [OK] Database created
) else (
    echo [X] Failed to create database
    pause
    exit /b 1
)

echo [*] Importing schema...
mysql -h !db_host! -u !db_user! %if not "!db_pass!"=="" (-p!db_pass!) !db_name! < backend\database\schema.sql

if !errorlevel! equ 0 (
    echo [OK] Database setup completed
) else (
    echo [X] Failed to import schema
    pause
    exit /b 1
)

pause
goto menu

REM ============================================================================
REM ENVIRONMENT SETUP ONLY
REM ============================================================================
:env_only
cls
echo.
echo [*] Environment Configuration Setup...
echo.

if exist backend\config\.env (
    echo [!] .env file already exists
    set /p overwrite="Overwrite? (y/n): "
    if /i not "!overwrite!"=="y" (
        pause
        goto menu
    )
)

set /p db_host="Enter Database Host (default: localhost): "
if "!db_host!"=="" set db_host=localhost

set /p db_name="Enter Database Name (default: sahara_infosys): "
if "!db_name!"=="" set db_name=sahara_infosys

set /p db_user="Enter Database User (default: root): "
if "!db_user!"=="" set db_user=root

set /p db_pass="Enter Database Password (leave blank for none): "

(
    echo # Sahara Infosys - Environment Configuration
    echo # © Ibrahim Khatri since 2014
    echo.
    echo # Application
    echo APP_NAME="Sahara Infosys"
    echo APP_ENV=development
    echo APP_DEBUG=true
    echo APP_URL=http://localhost:8000
    echo APP_KEY=sahara-key-2014
    echo.
    echo # Database
    echo DB_HOST=!db_host!
    echo DB_PORT=3306
    echo DB_NAME=!db_name!
    echo DB_USER=!db_user!
    echo DB_PASSWORD=!db_pass!
    echo DB_CHARSET=utf8mb4
    echo.
    echo # JWT
    echo JWT_SECRET=your-secret-key-here
    echo JWT_EXPIRY=3600
) > backend\config\.env

echo [OK] Environment file created
pause
goto menu

REM ============================================================================
REM START DEVELOPMENT SERVER
REM ============================================================================
:start_server
cls
echo.
echo ============================================================================
echo   Starting Sahara Infosys Development Server
echo ============================================================================
echo.

if not exist backend\config\.env (
    echo [X] .env file not found!
    echo [!] Please run Full Installation first (Option 1)
    echo.
    pause
    goto menu
)

set /p port="Enter port number (default: 8000): "
if "!port!"=="" set port=8000

echo [*] Starting PHP Development Server on port !port!...
echo [*] Press Ctrl+C to stop the server
echo.
echo ============================================================================
echo   Server Information
echo ============================================================================
echo.
echo   URL: http://localhost:!port!
echo   Admin Panel: http://localhost:!port!/../admin-panel
echo   API: http://localhost:!port!/api
echo.
echo ============================================================================
echo.

cd backend
php -S localhost:!port!

goto menu

REM ============================================================================
REM VIEW DOCUMENTATION
REM ============================================================================
:view_docs
cls
echo.
echo [*] Documentation Options
echo.
echo 1. View API Documentation
echo 2. View Setup Guide
echo 3. View Changelog
echo 4. Open GitHub Repository
echo.
set /p doc_choice="Enter your choice (1-4): "

if "!doc_choice!"=="1" (
    if exist docs\API.md (
        start notepad docs\API.md
    ) else (
        start https://github.com/khatriibrahim/sahara-infosys/blob/main/docs/API.md
    )
)

if "!doc_choice!"=="2" (
    if exist SETUP.md (
        start notepad SETUP.md
    ) else (
        start https://github.com/khatriibrahim/sahara-infosys/blob/main/SETUP.md
    )
)

if "!doc_choice!"=="3" (
    if exist CHANGELOG.md (
        start notepad CHANGELOG.md
    ) else (
        start https://github.com/khatriibrahim/sahara-infosys/blob/main/CHANGELOG.md
    )
)

if "!doc_choice!"=="4" (
    start https://github.com/khatriibrahim/sahara-infosys
)

goto menu

REM ============================================================================
REM RESET EVERYTHING
REM ============================================================================
:reset_all
cls
echo.
echo ============================================================================
echo   WARNING: DESTRUCTIVE OPERATION
echo ============================================================================
echo.
echo This will:
echo   - Delete the database
echo   - Delete the .env file
echo   - Delete all configuration
echo.
set /p confirm="Are you ABSOLUTELY SURE? Type 'YES' to confirm: "

if /i not "!confirm!"=="YES" (
    echo [!] Operation cancelled
    pause
    goto menu
)

set /p db_host="Enter Database Host (default: localhost): "
if "!db_host!"=="" set db_host=localhost

set /p db_name="Enter Database Name (default: sahara_infosys): "
if "!db_name!"=="" set db_name=sahara_infosys

set /p db_user="Enter Database User (default: root): "
if "!db_user!"=="" set db_user=root

set /p db_pass="Enter Database Password: "

echo [*] Dropping database...
mysql -h !db_host! -u !db_user! %if not "!db_pass!"=="" (-p!db_pass!) > nul 2>&1 << EOF
DROP DATABASE IF EXISTS `!db_name!`;
EOF

if exist backend\config\.env (
    echo [*] Deleting .env file...
    del backend\config\.env
)

echo [OK] Reset completed
pause
goto menu

REM ============================================================================
REM INVALID CHOICE
REM ============================================================================
:invalid_choice
cls
echo.
echo [X] Invalid choice. Please try again.
echo.
pause
:menu
goto full_install

REM ============================================================================
REM EXIT
REM ============================================================================
:exit_script
cls
echo.
echo ============================================================================
echo   Thank you for using Sahara Infosys Installer
echo   © Ibrahim Khatri since 2014
echo ============================================================================
echo.
endlocal
exit /b 0
