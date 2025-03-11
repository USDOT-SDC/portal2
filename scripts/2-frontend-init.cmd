@echo off
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
set env=%1
set command1=npm install
if "%env%"=="dev" (set ng_build_config=development) else (set ng_build_config=production)
set command2=ng build --configuration %ng_build_config%
echo.
echo %command1%
echo %command2%
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
echo.
echo %command2%
call %command2%
popd ..\..\..\scripts
goto end

:no_execute
echo Building the frontend has been canceled.
goto end

:end
