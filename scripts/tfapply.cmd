@echo off
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
goto normal_start

:print_help
echo You must run tfplan.cmd to create a Terraform execution plan before running tfapply.cmd
goto end

:normal_start
cls
set plan_file="tfplans/%tf_config_version%_%env%_%plan_id%"
set command=terraform apply %plan_file%
echo Your active AWS profile is: %AWS_PROFILE%
echo.
echo %command%
echo.
echo Would you like to execute the above command to apply a Terraform execution plan?
echo Press Y for Yes, or C to Cancel.
CHOICE /N /C YC /T 15 /D C
if "%ERRORLEVEL%"=="1" goto execute
if "%ERRORLEVEL%"=="2" goto no_execute
goto end

:execute
pushd ..\terraform
%command%
popd ..\scripts
@REM set current_tag=(git tag --points-at HEAD)
for /F "tokens=*" %%g in ('git tag --points-at HEAD') do (SET current_tag=%%g)
if %tf_config_version% NEQ %current_tag% (
    git tag -f %tf_config_version%
    set branch=git branch --show-current
    git push -u origin
    git push --delete origin %tf_config_version%
    git push -f origin %tf_config_version%
)
goto end

:no_execute
echo Execution of %command% has been canceled.
goto end

:end
