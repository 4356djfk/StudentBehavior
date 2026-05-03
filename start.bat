@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Student Behavior - Docker Deploy

:: ============================================================
::  Student Behavior Demo - Docker Auto Deploy Script
:: ============================================================

goto :main

:: ==================== Functions ====================

:check_docker
    docker --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Docker not found. Please install Docker Desktop first.
        echo          https://www.docker.com/products/docker-desktop
        pause
        exit /b 1
    )

    docker info >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Docker daemon is not running. Please start Docker Desktop.
        pause
        exit /b 1
    )
    exit /b 0

:check_compose
    docker compose version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] docker compose plugin not available.
        pause
        exit /b 1
    )
    exit /b 0

:deploy
    echo.
    echo [1/3] Stopping existing containers...
    docker compose down 2>nul
    echo.
    echo [2/3] Building and starting containers...
    docker compose up -d --build
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to build/start containers.
        pause
        exit /b 1
    )
    echo.
    echo [3/3] Waiting for services to be ready...
    call :wait_for_service "http://localhost:8000/scalar" 60
    if %errorlevel% equ 0 (
        call :show_info
    ) else (
        echo [WARN] Backend may still be starting. Check logs with option [4].
    )
    exit /b 0

:wait_for_service
    set "url=%~1"
    set "max_retries=%~2"
    set "count=0"

    :: Use PowerShell to curl with retry
    powershell -Command ^
        "$url='%url%'; $max=%max_retries%; " ^
        "for ($i=0; $i -lt $max; $i++) { " ^
        "  try { $r=Invoke-WebRequest -Uri $url -TimeoutSec 2 -UseBasicParsing; " ^
        "    if ($r.StatusCode -eq 200) { Write-Host 'READY'; exit 0 } } catch {}; " ^
        "  Start-Sleep 2; Write-Host '.' -NoNewline; " ^
        "} Write-Host 'TIMEOUT'; exit 1" > "%TEMP%\docker_wait_result.txt"

    set /p result=<"%TEMP%\docker_wait_result.txt"
    del "%TEMP%\docker_wait_result.txt" 2>nul
    echo.

    if "%result%"=="READY" ( exit /b 0 ) else ( exit /b 1 )

:stop
    echo.
    echo Stopping all containers...
    docker compose down
    echo Done.
    exit /b 0

:restart
    echo.
    echo Restarting all containers...
    docker compose restart
    if %errorlevel% equ 0 (
        echo Done.
    ) else (
        echo [WARN] restart failed, trying full rebuild...
        call :deploy
    )
    exit /b 0

:logs
    echo.
    echo Showing logs (Ctrl+C to exit)...
    docker compose logs -f
    exit /b 0

:status
    echo.
    docker compose ps
    echo.
    docker stats --no-stream
    exit /b 0

:show_info
    echo.
    echo ============================================
    echo   Deployment Complete!
    echo ============================================
    echo.
    echo   Frontend : http://localhost
    echo   Backend  : http://localhost:8000
    echo   API Docs : http://localhost:8000/scalar
    echo.
    echo   Login credentials:
    echo     Username: demo_admin
    echo     Password: demo_only
    echo.
    echo   Run option [2] to stop all containers.
    echo ============================================
    exit /b 0

:menu
    echo.
    echo ============================================
    echo   Student Behavior Demo - Docker Deploy
    echo ============================================
    echo.
    echo   [1] Deploy / Start
    echo   [2] Stop
    echo   [3] Restart
    echo   [4] View Logs
    echo   [5] Status
    echo   [6] Exit
    echo.
    set /p "choice=  Enter option [1-6]: "

    if "%choice%"=="1" call :deploy
    if "%choice%"=="2" call :stop
    if "%choice%"=="3" call :restart
    if "%choice%"=="4" call :logs
    if "%choice%"=="5" call :status
    if "%choice%"=="6" exit /b 0

    goto :menu

:: ==================== Entry ====================

:main
    call :check_docker
    if %errorlevel% neq 0 exit /b 1
    call :check_compose
    if %errorlevel% neq 0 exit /b 1

    echo.
    echo Docker environment OK.
    goto :menu
