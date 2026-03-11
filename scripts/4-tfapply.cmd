@echo off
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
goto normal_start

:print_help
echo You must run 3-tfplan.cmd to create a Terraform execution plan before running 4-tfapply.cmd
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
if "%plan_id%"=="" (
    echo ERROR: No plan ID found. Run 3-tfplan.cmd first.
    exit /b 1
)

REM --- Validate plan file exists ---
set plan_file="tfplans/%config_version%_%env%_%plan_id%"
set plan_path=..\terraform\tfplans\%config_version%_%env%_%plan_id%
if not exist "%plan_path%" (
    echo ERROR: Plan file not found: %plan_path%
    echo Run 3-tfplan.cmd to generate a plan before applying.
    exit /b 1
)

set command=terraform apply %plan_file%
echo Your active AWS profile is: %AWS_PROFILE%
echo Environment: %env%
echo Plan file:   %plan_path%
echo.
echo %command%
echo.
echo WARNING: This will apply infrastructure changes to the %env% environment.
echo.
set /p confirm=Type YES to confirm, or anything else to cancel:
if /I "%confirm%"=="yes" goto execute
goto no_execute

:execute
pushd ..\terraform
%command%
popd
goto end

:no_execute
echo Execution of %command% has been canceled.
goto end

:end
