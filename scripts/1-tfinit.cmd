@echo off
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
if "%1"=="" goto print_help
goto normal_start

:print_help
echo Parameter one is environment (dev ^| prod)
echo Parameter two sets an alternate AWS profile (e.g., scd-dev ^| scd-prod). If not provided, the AWS profile will default to the environment name.
echo Example: tfinit dev scd-dev
echo Example: tfinit prod scd-prod
echo Example: tfinit dev default
goto end

:normal_start

REM --- Check Python version ---
for /f "tokens=2 delims= " %%A in ('python --version 2^>nul') do (
    set PYTHON_VERSION=%%A
)

if "%PYTHON_VERSION%"=="" (
    echo ERROR: Python is not installed or not available in PATH.
    exit /b 1
)

for /f "tokens=1,2 delims=." %%A in ("%PYTHON_VERSION%") do (
    set PYTHON_MAJOR=%%A
    set PYTHON_MINOR=%%B
)

if not "%PYTHON_MAJOR%"=="3" (
    echo ERROR: Python 3.14.x is required.
    echo Detected version: %PYTHON_VERSION%
    exit /b 1
)

if not "%PYTHON_MINOR%"=="14" (
    echo ERROR: Python 3.14.x is required.
    echo Detected version: %PYTHON_VERSION%
    exit /b 1
)

REM --- Continue script ---

cls
set env=%1
if "%2"=="" set AWS_PROFILE=%env%
if not "%2"=="" set AWS_PROFILE=%2
echo Your active AWS profile is: %AWS_PROFILE%
set bucket=%env%.sdc.dot.gov.platform.terraform
if "%env%"=="dev" (set options=-upgrade -reconfigure) else (set options=-reconfigure)
set command=terraform init -backend-config "bucket=%bucket%" %options%
echo.
echo %command%
echo.
echo Would you like to execute the above command to initialize Terraform?
echo Press Y for Yes, or C to Cancel.
CHOICE /N /C YC /T 15 /D C
if "%ERRORLEVEL%"=="1" goto execute
if "%ERRORLEVEL%"=="2" goto no_execute
goto end

:execute
pushd ..\terraform
%command%
popd ..\scripts
goto end

:no_execute
echo Initialization of Terraform has been canceled.
goto end

:end
