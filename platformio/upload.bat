@echo off
REM Windows batch script for PlatformIO ESP8266 upload
REM Usage examples:
REM   upload.bat                      - auto-detect port, build + upload
REM   upload.bat -p COM3              - specify port
REM   upload.bat -m                   - upload then open serial monitor
REM   upload.bat -e esp12e            - specify env (default: esp12e)
REM   upload.bat -b 115200            - set monitor baud (default: 115200)
REM   upload.bat --dry-run            - show what would run

setlocal enabledelayedexpansion

set ENV_NAME=esp12e
set PORT=
set OPEN_MONITOR=false
set MONITOR_BAUD=115200
set DRY_RUN=false

:parse_args
if "%~1"=="" goto end_parse
if "%~1"=="-e" (
    set ENV_NAME=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--env" (
    set ENV_NAME=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-p" (
    set PORT=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--port" (
    set PORT=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-b" (
    set MONITOR_BAUD=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--baud" (
    set MONITOR_BAUD=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-m" (
    set OPEN_MONITOR=true
    shift
    goto parse_args
)
if "%~1"=="--monitor" (
    set OPEN_MONITOR=true
    shift
    goto parse_args
)
if "%~1"=="--dry-run" (
    set DRY_RUN=true
    shift
    goto parse_args
)
if "%~1"=="-h" (
    goto show_help
)
if "%~1"=="--help" (
    goto show_help
)
echo Unknown option: %~1
goto show_help

:end_parse

REM Check if PlatformIO is installed
where pio >nul 2>&1
if errorlevel 1 (
    echo Error: PlatformIO ^(pio^) is not installed. Install with: pip install platformio
    exit /b 1
)

REM Check if platformio.ini exists
if not exist platformio.ini (
    echo Error: platformio.ini not found in %CD%. Run this script from the platformio/ folder.
    exit /b 1
)

REM Auto-detect port if not provided
if "%PORT%"=="" (
    echo Attempting to auto-detect serial port...
    for /f "tokens=2" %%i in ('pio device list 2^>nul ^| findstr "COM"') do (
        set PORT=%%i
        goto port_found
    )
    echo Warning: Could not auto-detect serial port.
    echo Hint: connect your board and try again, or pass -p COM3 manually.
    :port_found
    if not "%PORT%"=="" (
        echo Auto-detected serial port: !PORT!
    )
)

REM Build command
set BUILD_CMD=pio run -e %ENV_NAME%

REM Upload command
set UPLOAD_CMD=pio run -e %ENV_NAME% --target upload
if not "%PORT%"=="" (
    set UPLOAD_CMD=!UPLOAD_CMD! --upload-port %PORT%
)

REM Monitor command
set MONITOR_CMD=pio device monitor --baud %MONITOR_BAUD%
if not "%PORT%"=="" (
    set MONITOR_CMD=!MONITOR_CMD! --port %PORT%
)

REM Execute commands
echo + %BUILD_CMD%
if "%DRY_RUN%"=="false" (
    %BUILD_CMD%
    if errorlevel 1 (
        echo Build failed!
        exit /b 1
    )
)

echo + %UPLOAD_CMD%
if "%DRY_RUN%"=="false" (
    %UPLOAD_CMD%
    if errorlevel 1 (
        echo Upload failed!
        exit /b 1
    )
)

if "%OPEN_MONITOR%"=="true" (
    echo Opening serial monitor ^(baud=%MONITOR_BAUD%^)...
    echo + %MONITOR_CMD%
    if "%DRY_RUN%"=="false" (
        %MONITOR_CMD%
    )
)

echo Done.
goto end

:show_help
echo PlatformIO upload helper for Windows
echo.
echo Options:
echo   -e, --env ^<name^>        PlatformIO environment name ^(default: esp12e^)
echo   -p, --port ^<port^>       Serial port ^(e.g. COM3^). Auto-detect if omitted
echo   -b, --baud ^<number^>     Serial monitor baud rate ^(default: 115200^)
echo   -m, --monitor           Open serial monitor after upload
echo       --dry-run           Print commands without executing
echo   -h, --help              Show this help
echo.
echo Examples:
echo   upload.bat                      - auto-detect port, build + upload
echo   upload.bat -p COM3              - specify port
echo   upload.bat -m                   - upload then open serial monitor
echo   upload.bat -e esp12e            - specify env
echo   upload.bat --dry-run            - show what would run

:end
