#!/bin/bash

# MicroPython固件烧写脚本
# 适用于ESP8266开发板

echo "=== MicroPython固件烧写脚本 ==="
echo ""

# 检查esptool是否安装
if ! command -v esptool &> /dev/null; then
    echo "错误: esptool未安装"
    echo "请先安装esptool: brew install esptool"
    exit 1
fi

echo "esptool版本:"
esptool version
echo ""

# 查找串口设备
echo "查找可用的串口设备..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    PORTS=$(ls /dev/tty.usbserial* 2>/dev/null)
    if [ -z "$PORTS" ]; then
        PORTS=$(ls /dev/tty.wchusbserial* 2>/dev/null)
    fi
    if [ -z "$PORTS" ]; then
        PORTS=$(ls /dev/tty.SLAB_USBtoUART* 2>/dev/null)
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    PORTS=$(ls /dev/ttyUSB* 2>/dev/null)
else
    # Windows (Git Bash)
    PORTS=$(ls /dev/ttyS* 2>/dev/null)
fi

if [ -z "$PORTS" ]; then
    echo "错误: 未找到串口设备"
    echo "请检查:"
    echo "1. ESP8266是否正确连接"
    echo "2. USB线是否支持数据传输"
    echo "3. 驱动是否正确安装"
    exit 1
fi

echo "找到的串口设备:"
for port in $PORTS; do
    echo "  $port"
done
echo ""

# 选择串口
if [ ${#PORTS[@]} -eq 1 ]; then
    PORT=$PORTS
    echo "自动选择串口: $PORT"
else
    echo "请选择串口设备:"
    select PORT in $PORTS; do
        if [ -n "$PORT" ]; then
            break
        fi
    done
fi

echo "使用串口: $PORT"
echo ""

# 检查固件文件
FIRMWARE_FILE=""
if [ -f "esp8266-firmware.bin" ]; then
    FIRMWARE_FILE="esp8266-firmware.bin"
elif [ -f "firmware.bin" ]; then
    FIRMWARE_FILE="firmware.bin"
else
    echo "未找到固件文件"
    echo "请下载MicroPython固件并重命名为 'esp8266-firmware.bin'"
    echo "下载地址: https://micropython.org/download/esp8266/"
    echo ""
    read -p "请输入固件文件路径: " FIRMWARE_FILE
fi

if [ ! -f "$FIRMWARE_FILE" ]; then
    echo "错误: 固件文件不存在: $FIRMWARE_FILE"
    exit 1
fi

echo "使用固件文件: $FIRMWARE_FILE"
echo ""

# 确认操作
echo "即将开始烧写固件..."
echo "串口: $PORT"
echo "固件: $FIRMWARE_FILE"
echo ""
read -p "确认继续? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 0
fi

echo ""
echo "=== 开始烧写固件 ==="
echo ""

# 步骤1: 擦除Flash
echo "步骤1: 擦除Flash..."
esptool --chip esp8266 --port "$PORT" --baud 460800 erase-flash
if [ $? -ne 0 ]; then
    echo "错误: 擦除Flash失败"
    echo "请检查连接和权限"
    exit 1
fi
echo "Flash擦除完成"
echo ""

# 步骤2: 烧写固件
echo "步骤2: 烧写固件..."
esptool --chip esp8266 --port "$PORT" --baud 460800 write-flash --flash-size=detect 0x00000 "$FIRMWARE_FILE"
if [ $? -ne 0 ]; then
    echo "错误: 烧写固件失败"
    exit 1
fi
echo "固件烧写完成"
echo ""

# 步骤3: 验证烧写
echo "步骤3: 验证烧写..."
esptool --chip esp8266 --port "$PORT" --baud 460800 verify-flash --flash-size=detect 0x00000 "$FIRMWARE_FILE"
if [ $? -eq 0 ]; then
    echo "验证成功!"
else
    echo "警告: 验证失败，但固件可能仍然可用"
fi
echo ""

echo "=== 烧写完成 ==="
echo ""
echo "下一步:"
echo "1. 使用串口工具连接设备 (波特率: 115200)"
echo "2. 测试MicroPython是否正常工作"
echo "3. 上传您的Python代码"
echo ""
echo "推荐工具:"
echo "- Thonny IDE: https://thonny.org/"
echo "- PuTTY (Windows)"
echo "- Screen (macOS/Linux): screen $PORT 115200" 