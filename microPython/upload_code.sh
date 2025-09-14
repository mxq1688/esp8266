#!/bin/bash

# MicroPython 代码上传脚本
# 使用 ampy 工具上传所有项目文件到 ESP8266

echo "=== MicroPython 代码上传 ==="
echo ""

# 设置设备端口
PORT="/dev/tty.usbserial-10"

# 检查设备连接
echo "检查设备连接..."
if [ ! -e "$PORT" ]; then
    echo "❌ 设备未连接: $PORT"
    echo "请检查 ESP8266 USB 连接"
    exit 1
fi
echo "✅ 设备已连接: $PORT"

# 检查 ampy 工具
echo ""
echo "检查 ampy 工具..."
if ! command -v ampy &> /dev/null; then
    echo "❌ ampy 未安装"
    echo "请安装 ampy: pip install adafruit-ampy"
    exit 1
fi
echo "✅ ampy 工具已安装"

# 源代码目录
SRC_DIR="led_blink/src"

# 检查源代码文件
echo ""
echo "检查源代码文件..."
files=("config.py" "led_control.py" "simple_led.py" "main.py")
for file in "${files[@]}"; do
    if [ -f "$SRC_DIR/$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file 不存在"
        exit 1
    fi
done

# 开始上传
echo ""
echo "开始上传代码文件..."
echo "目标设备: $PORT"
echo ""

# 上传每个文件
for file in "${files[@]}"; do
    echo "上传: $file"
    if ampy --port "$PORT" put "$SRC_DIR/$file" "$file"; then
        echo "✅ $file 上传成功"
    else
        echo "❌ $file 上传失败"
        exit 1
    fi
    sleep 1  # 避免连续操作过快
done

echo ""
echo "=== 上传完成 ==="
echo "✅ 所有文件已成功上传到 ESP8266"
echo ""

# 验证上传
echo "验证上传的文件..."
echo "设备上的文件列表:"
ampy --port "$PORT" ls

echo ""
echo "下一步操作:"
echo "1. 连接到设备 REPL"
echo "2. 运行: exec(open('main.py').read())"
echo "3. 或者重启设备自动运行"
echo ""
echo "连接命令:"
echo "  screen $PORT 115200"
echo "  或使用 Thonny IDE 连接"
