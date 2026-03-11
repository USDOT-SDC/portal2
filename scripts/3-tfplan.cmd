@echo off
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
goto normal_start

:print_help
echo Terraform must be initialized (1-tfinit.cmd) before running 3-tfplan.cmd
goto end

:normal_start
cls

REM --- Validate required session variables ---
if "%env%"=="" (
    echo ERROR: Environment not set. Run 1-tfinit.cmd first.
    exit /b 1
)
if "%AWS_PROFILE%"=="" (
    echo ERROR: AWS_PROFILE not set. Run 1-tfinit.cmd first.
    exit /b 1
)

REM --- Validate config_version file exists ---
if not exist "..\terraform\config_version.txt" (
    echo ERROR: config_version.txt not found at ..\terraform\config_version.txt
    exit /b 1
)

set /P config_version=< ..\terraform\config_version.txt
set plan_id_file=..\terraform\tfplans\%config_version%_%env%_.txt
if exist "%plan_id_file%" (
    set /p plan_id=< "%plan_id_file%"
) else (
    set plan_id=0
)
set /a plan_id+=1
set plan_file="tfplans/%config_version%_%env%_%plan_id%"
set command=terraform plan -var=config_version="%config_version%" -var-file="env_vars/%env%.tfvars" -out=%plan_file%
echo Your active AWS profile is: %AWS_PROFILE%
echo Environment:    %env%
echo Config version: %config_version%
echo Plan file:      %plan_file%
echo.
echo %command%
echo.
set /p confirm=Press Y to execute, or anything else to cancel:
if /I "%confirm%"=="y" goto execute
goto no_execute

:execute
pushd ..\terraform
if not exist "tfplans" mkdir tfplans
%command%
popd
(echo %plan_id%) > %plan_id_file%
goto end

:no_execute
echo Execution of %command% has been canceled.
goto end

:end
