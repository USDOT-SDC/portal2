@echo off
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
goto normal_start

:print_help
echo Terraform must be initialized (tfinit.cmd) before running this script
echo Parameter one is environment (dev ^| prod)
echo Parameter two sets an alternate AWS profile (e.g., default)
echo Example: tfinit dev
echo Example: tfinit prod
echo Example: tfinit dev default
goto end

:normal_start
cls
set env=%1
if "%2"=="" set AWS_PROFILE=%env%
if not "%2"=="" set AWS_PROFILE=%2
set /P config_version=< ..\terraform\config_version.txt
set command=terraform apply -target=module.fe.data.template_file.environment_ts -target=module.fe.local_file.environment_ts -var=config_version="%config_version%" -var-file="env_vars/%env%.tfvars"
echo Your active AWS profile is: %AWS_PROFILE%
echo.
echo %command%
echo.
echo Would you like to execute the above command?
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
echo Execution of %command% has been canceled.
goto end

:end
