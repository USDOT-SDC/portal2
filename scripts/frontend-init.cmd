@echo off
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
if "%1"=="" goto print_help
goto normal_start

:print_help
echo Parameter one is environment (dev ^| prod)
echo Example: frontend-init dev
echo Example: frontend-init prod
goto end

:normal_start
cls
set env=%1
pushd ..\terraform\frontend\interface
call npm audit fix
call npm install
if "%env%"=="dev" (set ng_build_config=development) else (set ng_build_config=production)
call ng build --configuration %ng_build_config%
popd ..\..\..\scripts
goto end

:end
