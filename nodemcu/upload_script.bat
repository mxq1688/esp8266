@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM NodeMCU Lua代码上传脚本 (Windows版本)
REM 使用 NodeMCU-Tool 按正确顺序上传文件

echo ========================================
echo     NodeMCU Lua 代码上传脚本
echo ========================================

REM 检查NodeMCU-Tool是否安装
echo [INFO] 检查 NodeMCU-Tool...
nodemcu-tool --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] NodeMCU-Tool 未安装!
    echo [INFO] 请运行: npm install -g nodemcu-tool
    pause
    exit /b 1
)
echo [SUCCESS] NodeMCU-Tool 已安装

REM 检查必需文件
echo [INFO] 检查必需文件...
set missing_files=
if not exist "config.lua" set missing_files=!missing_files! config.lua
if not exist "main.lua" set missing_files=!missing_files! main.lua
if not exist "init.lua" set missing_files=!missing_files! init.lua

if not "!missing_files!"=="" (
    echo [ERROR] 缺少文件:!missing_files!
    echo [INFO] 请确保当前目录包含所有必需的 .lua 文件
    pause
    exit /b 1
)
echo [SUCCESS] 所有必需文件都存在

REM 显示当前目录的文件
echo [INFO] 当前目录的 .lua 文件:
dir *.lua 2>nul
if errorlevel 1 echo [WARNING] 当前目录没有 .lua 文件

REM 询问是否继续
echo.
set /p continue="是否继续上传? (y/N): "
if /i not "!continue!"=="y" (
    echo [INFO] 上传已取消
    pause
    exit /b 0
)

REM 显示设备信息
echo [INFO] 获取设备信息...
nodemcu-tool info 2>nul
if errorlevel 1 echo [WARNING] 无法获取设备信息，请检查连接

echo.
echo [INFO] 开始按顺序上传文件...
echo [WARNING] 重要: 文件将按 config.lua → main.lua → init.lua 的顺序上传

REM 上传 config.lua
echo [INFO] 步骤 1/3: 上传 config.lua
nodemcu-tool upload config.lua
if errorlevel 1 (
    echo [ERROR] config.lua 上传失败
    pause
    exit /b 1
)
echo [SUCCESS] config.lua 上传成功
timeout /t 1 >nul

REM 上传 main.lua
echo [INFO] 步骤 2/3: 上传 main.lua
nodemcu-tool upload main.lua
if errorlevel 1 (
    echo [ERROR] main.lua 上传失败
    pause
    exit /b 1
)
echo [SUCCESS] main.lua 上传成功
timeout /t 1 >nul

REM 上传 init.lua
echo [INFO] 步骤 3/3: 上传 init.lua
nodemcu-tool upload init.lua
if errorlevel 1 (
    echo [ERROR] init.lua 上传失败
    pause
    exit /b 1
)
echo [SUCCESS] init.lua 上传成功

echo.
echo [SUCCESS] 所有文件上传完成!

REM 列出设备文件
echo [INFO] 设备上的文件列表:
nodemcu-tool fsinfo 2>nul
if errorlevel 1 echo [WARNING] 无法获取文件列表

REM 重启设备
echo [INFO] 重启设备...
nodemcu-tool reset
if errorlevel 1 (
    echo [WARNING] 设备重启失败，请手动重启
) else (
    echo [SUCCESS] 设备重启成功
)

echo.
echo [SUCCESS] 上传流程完成! 设备应该开始运行你的程序了。
echo [INFO] 你可以使用串口监视器查看输出信息

pause
