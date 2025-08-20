#!/bin/bash

# MicroPython环境检查脚本

echo "=== MicroPython环境检查 ==="
echo ""

# 检查esptool
echo "1. 检查esptool工具..."
if command -v esptool &> /dev/null; then
    echo "✅ esptool已安装"
    esptool version
else
    echo "❌ esptool未安装"
    echo "请运行: brew install esptool"
fi
echo ""

# 检查ESP8266设备
echo "2. 检查ESP8266设备..."
if ls /dev/tty.usbserial* 2>/dev/null | grep -q .; then
    echo "✅ 找到ESP8266设备:"
    ls /dev/tty.usbserial*
else
    echo "❌ 未找到ESP8266设备"
    echo "请检查USB连接"
fi
echo ""

# 检查项目文件
echo "3. 检查项目文件..."
if [ -f "led_blink/src/main.py" ]; then
    echo "✅ LED项目文件存在"
else
    echo "❌ LED项目文件缺失"
fi

if [ -f "led_blink/src/led_control.py" ]; then
    echo "✅ LED控制模块存在"
else
    echo "❌ LED控制模块缺失"
fi

if [ -f "led_blink/src/config.py" ]; then
    echo "✅ 配置文件存在"
else
    echo "❌ 配置文件缺失"
fi

if [ -f "led_blink/src/simple_led.py" ]; then
    echo "✅ 简单示例存在"
else
    echo "❌ 简单示例缺失"
fi
echo ""

# 检查固件文件
echo "4. 检查固件文件..."
if [ -f "esp8266-firmware.bin" ]; then
    size=$(stat -f%z esp8266-firmware.bin 2>/dev/null || stat -c%s esp8266-firmware.bin 2>/dev/null)
    echo "✅ 固件文件存在 (大小: $size 字节)"
    if [ "$size" -gt 100000 ]; then
        echo "✅ 固件文件大小正常"
    else
        echo "⚠️  固件文件可能不是真正的MicroPython固件"
    fi
else
    echo "❌ 固件文件不存在"
    echo "请下载MicroPython固件"
fi
echo ""

# 检查烧写脚本
echo "5. 检查烧写脚本..."
if [ -f "烧写脚本.sh" ]; then
    echo "✅ 烧写脚本存在"
    if [ -x "烧写脚本.sh" ]; then
        echo "✅ 烧写脚本可执行"
    else
        echo "⚠️  烧写脚本需要执行权限"
        echo "请运行: chmod +x 烧写脚本.sh"
    fi
else
    echo "❌ 烧写脚本不存在"
fi
echo ""

echo "=== 环境检查完成 ==="
echo ""
echo "下一步操作:"
echo "1. 如果所有检查都通过，可以开始烧写固件"
echo "2. 如果发现问题，请根据提示解决"
echo "3. 运行 './烧写脚本.sh' 开始烧写" 