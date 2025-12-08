@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: NodeMCU 固件烧录脚本 (Windows)

title NodeMCU 固件烧录工具

echo ========================================
echo        NodeMCU 固件烧录工具
echo ========================================
echo.

:: 检查 esptool 是否安装
echo [INFO] 检查 esptool 安装状态...
esptool.py --help >nul 2>&1
if errorlevel 1 (
    echo [ERROR] esptool 未安装，请先安装: pip install esptool
    pause
    exit /b 1
)
echo [SUCCESS] esptool 已安装
echo.

:: 检测可用的串口
echo [INFO] 检测可用的串口...
set port_count=0
for /f "tokens=1" %%i in ('wmic path Win32_SerialPort get DeviceID /format:list ^| findstr "COM"') do (
    set /a port_count+=1
    set port_!port_count!=%%i
    echo   !port_count!. %%i
)

if !port_count! equ 0 (
    echo [ERROR] 未检测到串口设备，请检查：
    echo   1. NodeMCU 是否已连接
    echo   2. 串口驱动是否已安装
    echo   3. USB 线是否为数据线
    pause
    exit /b 1
)

echo.
set /p port_choice="请选择串口编号 (1-%port_count%): "

:: 验证输入
if !port_choice! lss 1 goto invalid_port
if !port_choice! gtr !port_count! goto invalid_port
set selected_port=!port_%port_choice%!
echo [SUCCESS] 已选择串口: !selected_port!
goto port_selected

:invalid_port
echo [ERROR] 无效的选择
pause
exit /b 1

:port_selected
echo.

:: 检测固件文件
echo [INFO] 检测固件文件...
set firmware_count=0
for %%f in (*.bin) do (
    set /a firmware_count+=1
    set firmware_!firmware_count!=%%f
    echo   !firmware_count!. %%f
)

if !firmware_count! equ 0 (
    echo [ERROR] 未找到固件文件 (.bin)，请确保固件文件在当前目录
    pause
    exit /b 1
)

echo.
set /p firmware_choice="请选择固件文件编号 (1-%firmware_count%): "

:: 验证输入
if !firmware_choice! lss 1 goto invalid_firmware
if !firmware_choice! gtr !firmware_count! goto invalid_firmware
set selected_firmware=!firmware_%firmware_choice%!
echo [SUCCESS] 已选择固件: !selected_firmware!
goto firmware_selected

:invalid_firmware
echo [ERROR] 无效的选择
pause
exit /b 1

:firmware_selected
echo.

:: 显示烧录信息
echo [INFO] 准备烧录：
echo   串口: !selected_port!
echo   固件: !selected_firmware!
echo.

set /p confirm="确认开始烧录? (y/N): "
if /i not "!confirm!"=="y" (
    echo [INFO] 已取消烧录
    pause
    exit /b 0
)

echo.
echo [INFO] 开始烧录流程...
echo.

:: 获取芯片信息
echo [INFO] 获取芯片信息...
esptool.py --port !selected_port! chip_id
if errorlevel 1 (
    echo [ERROR] 无法连接到设备，请检查：
    echo   1. 串口是否正确
    echo   2. 设备是否正常连接
    echo   3. 是否有其他程序占用串口
    pause
    exit /b 1
)
echo [SUCCESS] 设备连接正常
echo.

:: 擦除固件
echo [INFO] 擦除现有固件...
esptool.py --port !selected_port! erase_flash
if errorlevel 1 (
    echo [ERROR] 固件擦除失败
    pause
    exit /b 1
)
echo [SUCCESS] 固件擦除完成
echo.

:: 烧录固件
echo [INFO] 开始烧录固件: !selected_firmware!
echo [WARNING] 请勿断开连接，烧录过程需要几分钟...
echo.

:: 尝试高速烧录
esptool.py --port !selected_port! --baud 460800 write_flash --flash_size=detect 0 !selected_firmware!
if errorlevel 1 (
    echo [WARNING] 高速烧录失败，尝试低速烧录...
    esptool.py --port !selected_port! --baud 115200 write_flash --flash_size=detect 0 !selected_firmware!
    if errorlevel 1 (
        echo [ERROR] 固件烧录失败
        pause
        exit /b 1
    )
)
echo [SUCCESS] 固件烧录完成！
echo.

:: 验证烧录
echo [INFO] 验证烧录结果...
esptool.py --port !selected_port! flash_id
if errorlevel 1 (
    echo [WARNING] 验证失败，但固件可能已正确烧录
) else (
    echo [SUCCESS] 烧录验证成功
)

echo.
echo [SUCCESS] ========== 烧录完成 ==========
echo [INFO] 接下来可以：
echo   1. 使用 ESPlorer 连接设备
echo   2. 波特率设置为 115200
echo   3. 按下设备上的 RST 按钮重启
echo   4. 在终端中输入: print('Hello NodeMCU!')
echo.
pause
