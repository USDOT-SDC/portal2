@echo off
setlocal EnableDelayedExpansion
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
goto normal_start

:print_help
echo You must run tfplan.cmd to create a Terraform execution plan before running tfapply.cmd
goto end

:normal_start
cls
set plan_file="tfplans/%config_version%_%env%_%plan_id%"
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
@REM for /F "tokens=*" %%t in ('git tag --points-at HEAD') do (set current_tag=%%t)
@REM for /F %%b in ('git branch --show-current') do (set branch=%%b)
@REM if %config_version% NEQ %current_tag% (
@REM     git tag -f %config_version%
@REM     git push --set-upstream origin %branch%
@REM     git push -u origin
@REM     git push --delete origin %config_version%
@REM     git push -f origin %config_version%
@REM )
goto end

:no_execute
echo Execution of %command% has been canceled.
goto end

:end
