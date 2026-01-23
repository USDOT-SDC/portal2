@echo off

REM ===================================
REM Required Versions (update as needed)
REM ===================================
set NODE_REQUIRED=24
set NPM_REQUIRED=10
set NG_REQUIRED=21

if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
if "%1"=="" goto print_help
goto normal_start

:print_help
echo Parameter one is environment (dev ^| prod)
echo Example: 2-frontend-init dev
echo Example: 2-frontend-init prod
goto end

:normal_start

cls

echo ===================================
echo Tool Stack Version Checks
echo ===================================

REM --- Check Node.js version ---
pushd ..\terraform\frontend\interface
for /f "tokens=1 delims=." %%A in ('node --version 2^>nul') do (
    set NODE_MAJOR=%%A
)
set NODE_MAJOR=%NODE_MAJOR:v=%

if "%NODE_MAJOR%"=="" (
    echo ERROR: Node.js is not installed or not available in PATH.
    echo Install from: https://nodejs.org/
    exit /b 1
)

if %NODE_MAJOR% LSS %NODE_REQUIRED% (
    echo ERROR: Node.js version %NODE_REQUIRED%.x is required.
    echo Detected: Node %NODE_MAJOR%
    echo Install from: https://nodejs.org/
    exit /b 1
)

REM --- Check npm version ---
for /f "tokens=1 delims=." %%A in ('npm --version 2^>nul') do (
    set NPM_MAJOR=%%A
)

if "%NPM_MAJOR%"=="" (
    echo ERROR: npm is not installed or not available in PATH.
    echo npm ships with Node.js - install from: https://nodejs.org/
    exit /b 1
)

if %NPM_MAJOR% LSS %NPM_REQUIRED% (
    echo ERROR: npm version %NPM_REQUIRED%.x or higher is required.
    echo Detected: npm %NPM_MAJOR%
    echo Run: npm install -g npm@latest
    exit /b 1
)

REM --- Check Angular CLI version (local project install) ---
for /f "tokens=3 delims=@" %%A in ('npm list @angular/cli --depth=0 2^>nul ^| findstr "@angular/cli"') do (
    for /f "tokens=1 delims=." %%B in ("%%A") do set NG_MAJOR=%%B
)

if "%NG_MAJOR%"=="" (
    echo ERROR: Angular CLI is not installed in the project.
    echo Run: cd terraform\frontend\interface ^&^& npm install
    exit /b 1
)

if %NG_MAJOR% LSS %NG_REQUIRED% (
    echo ERROR: Angular CLI version %NG_REQUIRED%.x is required.
    echo Detected: ng %NG_MAJOR%
    echo Run: cd terraform\frontend\interface ^&^& npm update @angular/cli
    exit /b 1
)

REM --- All checks passed ---
popd
echo Tool stack verified:
echo   Node %NODE_MAJOR%
echo   npm %NPM_MAJOR%
echo   Angular CLI %NG_MAJOR%
echo.

REM --- Continue script ---

echo ===================================
echo Frontend Initialization
echo ===================================

set env=%1
@REM if "%env%"=="dev" (set npm_cmd=update --include=dev) else (set npm_cmd=install)
@REM set command1=npm %npm_cmd%
set command1=npm install
if "%env%"=="dev" (set npm_audit_cmd=npm audit)
if "%env%"=="dev" (set command2=%npm_audit_cmd%)
if "%env%"=="dev" (set ng_build_config=development) else (set ng_build_config=production)
set command3=ng build --configuration %ng_build_config%
echo %command1%
if "%env%"=="dev" (echo %command2%)
echo %command3%
echo.
echo Would you like to execute the above commands to build the frontend?
echo Press Y for Yes, or C to Cancel.
CHOICE /N /C YC /T 15 /D C
if "%ERRORLEVEL%"=="1" goto execute
if "%ERRORLEVEL%"=="2" goto no_execute
goto end

:execute
pushd ..\terraform\frontend\interface
echo.
echo %command1%
call %command1%
if "%env%"=="dev" (echo.)
if "%env%"=="dev" (echo %command2%)
if "%env%"=="dev" (call %command2%)
echo.
echo %command3%
call %command3%
popd
goto end

:no_execute
echo Building the frontend has been canceled.
goto end

:end
