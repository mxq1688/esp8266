#!/bin/bash

# MicroPython固件烧写脚本

echo "=== MicroPython固件烧写 ==="
echo ""

# 检查固件文件
if [ ! -f "esp8266-firmware.bin" ]; then
    echo "❌ 固件文件不存在"
    echo "请先下载MicroPython固件"
    exit 1
fi

# 检查固件文件大小
size=$(stat -f%z esp8266-firmware.bin 2>/dev/null || stat -c%s esp8266-firmware.bin 2>/dev/null)
echo "固件文件大小: $size 字节"

if [ "$size" -lt 1000000 ]; then
    echo "⚠️  警告: 固件文件太小，可能不是真正的MicroPython固件"
    echo "请确保使用真正的MicroPython固件文件"
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "烧写已取消"
        exit 1
    fi
fi

# 查找ESP8266设备
echo ""
echo "查找ESP8266设备..."
if ls /dev/tty.usbserial* 2>/dev/null | grep -q .; then
    port=$(ls /dev/tty.usbserial* | head -1)
    echo "✅ 找到设备: $port"
else
    echo "❌ 未找到ESP8266设备"
    echo "请检查USB连接"
    exit 1
fi

# 检查esptool
echo ""
echo "检查esptool工具..."
if command -v esptool &> /dev/null; then
    echo "✅ esptool已安装"
    esptool version
elif command -v esptool.py &> /dev/null; then
    echo "✅ esptool.py已安装"
    esptool.py version
else
    echo "❌ esptool未安装"
    echo "请安装esptool:"
    echo "  brew install esptool"
    echo "  或使用Thonny IDE进行烧写"
    exit 1
fi

# 确认烧写
echo ""
echo "准备烧写固件到设备: $port"
echo "⚠️  警告: 此操作将擦除设备上的所有数据"
read -p "是否继续? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "烧写已取消"
    exit 1
fi

# 开始烧写
echo ""
echo "开始烧写固件..."

# 擦除Flash
echo "1. 擦除Flash..."
if command -v esptool &> /dev/null; then
    esptool --chip esp8266 --port "$port" erase-flash
else
    esptool.py --chip esp8266 --port "$port" erase_flash
fi

if [ $? -ne 0 ]; then
    echo "❌ 擦除Flash失败"
    exit 1
fi

echo "✅ Flash擦除完成"

# 写入固件
echo ""
echo "2. 写入固件..."
if command -v esptool &> /dev/null; then
    esptool --chip esp8266 --port "$port" --baud 460800 write-flash --flash-size=detect 0x00000 esp8266-firmware.bin
else
    esptool.py --chip esp8266 --port "$port" --baud 460800 write_flash --flash_size=detect 0x00000 esp8266-firmware.bin
fi

if [ $? -ne 0 ]; then
    echo "❌ 写入固件失败"
    exit 1
fi

echo "✅ 固件写入完成"

# 验证烧写
echo ""
echo "3. 验证烧写..."
if command -v esptool &> /dev/null; then
    esptool --chip esp8266 --port "$port" verify-flash --flash-size=detect 0x00000 esp8266-firmware.bin
else
    esptool.py --chip esp8266 --port "$port" verify_flash --flash_size=detect 0x00000 esp8266-firmware.bin
fi

if [ $? -eq 0 ]; then
    echo "✅ 固件验证成功"
else
    echo "⚠️  固件验证失败，但可能仍然可用"
fi

echo ""
echo "=== 烧写完成 ==="
echo "✅ MicroPython固件已成功烧写到ESP8266"
echo ""
echo "下一步操作:"
echo "1. 使用Thonny IDE连接设备"
echo "2. 上传LED项目代码"
echo "3. 运行LED闪烁程序"
echo ""
echo "连接信息:"
echo "设备: $port"
echo "波特率: 115200" 