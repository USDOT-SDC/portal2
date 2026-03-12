@echo off
if "%1"=="-help" goto print_help
if "%1"=="--help" goto print_help
goto main

:print_help
echo Patches known vulnerabilities in frontend dependencies.
echo.
echo   (no args)   Runs npm audit fix only
echo   --ng        Also upgrades Angular packages via ng update (modifies package.json)
echo   --force     Allows breaking version upgrades on npm audit fix (use with caution)
echo   --ng --force  Both of the above
echo.
echo Example: 2.1-frontend-fix
echo Example: 2.1-frontend-fix --ng
echo Example: 2.1-frontend-fix --force
echo Example: 2.1-frontend-fix --ng --force
goto end

:main

cls

set NG_PKGS=@angular/core @angular/cli
set NG_UPDATE=0
set FORCE_FLAG=
set FORCE_WARN=

:parse_args
if "%1"=="" goto args_done
if /I "%1"=="--ng" set NG_UPDATE=1
if /I "%1"=="--force" set FORCE_FLAG=--force
if /I "%1"=="--force" set FORCE_WARN= WARNING: --force allows breaking changes. Test the build after.
shift
goto parse_args
:args_done

set audit_cmd=npm audit fix %FORCE_FLAG%

echo.
if "%NG_UPDATE%"=="1" echo Step 1: npx ng update %NG_PKGS% --allow-dirty --force
if "%NG_UPDATE%"=="1" echo Step 2: %audit_cmd%
if "%NG_UPDATE%"=="0" echo %audit_cmd%
if not "%FORCE_WARN%"=="" echo.
if not "%FORCE_WARN%"=="" echo %FORCE_WARN%
echo.
echo Would you like to execute the above to fix frontend vulnerabilities?
echo Press Y for Yes, or C to Cancel.
CHOICE /N /C YC /T 15 /D C
if "%ERRORLEVEL%"=="1" goto execute
if "%ERRORLEVEL%"=="2" goto no_execute
goto end

:execute
pushd ..\terraform\frontend\interface

if "%NG_UPDATE%"=="1" (
    echo.
    echo ===================================
    echo Step 1: Upgrading Angular packages
    echo ===================================
    call npx ng update %NG_PKGS% --allow-dirty --force
)

echo.
echo ===================================
if "%NG_UPDATE%"=="1" (echo Step 2: Running npm audit fix) else (echo Running npm audit fix)
echo ===================================
call %audit_cmd%

echo.
echo ===================================
echo Remaining vulnerabilities:
echo ===================================
call npm audit --audit-level=low 2>nul | findstr "vulnerabilities"

popd
goto end

:no_execute
echo npm audit fix has been canceled.
goto end

:end
