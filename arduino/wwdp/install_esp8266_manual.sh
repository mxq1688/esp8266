#!/bin/bash

# ESP8266 手动安装脚本 (macOS)
# 用于解决网络下载问题

echo "=== ESP8266 手动安装脚本 ==="
echo "正在检查系统环境..."

# 检查操作系统
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "检测到 macOS 系统"
    ARDUINO_DIR="$HOME/Documents/Arduino"
    CACHE_DIR="$HOME/Library/Arduino15/cache"
else
    echo "不支持的操作系统: $OSTYPE"
    exit 1
fi

# 创建必要的目录
echo "创建目录结构..."
mkdir -p "$ARDUINO_DIR/hardware/esp8266com"
mkdir -p "$ARDUINO_DIR/tools"

# 下载ESP8266核心包
echo "正在下载ESP8266核心包..."
ESP8266_URL="https://github.com/esp8266/Arduino/releases/download/3.1.2/esp8266-3.1.2.zip"
TEMP_DIR="/tmp/esp8266_install"

# 清理临时目录
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 尝试下载
echo "从GitHub下载ESP8266包..."
if curl -L -o "$TEMP_DIR/esp8266.zip" "$ESP8266_URL"; then
    echo "下载成功！"
else
    echo "下载失败，尝试备用链接..."
    # 备用下载链接
    BACKUP_URL="https://arduino.esp8266.com/stable/package_esp8266com_index.json"
    echo "请手动下载: $BACKUP_URL"
    echo "或访问: https://github.com/esp8266/Arduino/releases"
    exit 1
fi

# 解压文件
echo "解压文件..."
cd "$TEMP_DIR"
unzip -q esp8266.zip

# 检查解压结果
if [ -d "esp8266" ]; then
    echo "解压成功！"
else
    echo "解压失败！"
    exit 1
fi

# 安装到Arduino目录
echo "安装到Arduino目录..."
cp -r esp8266 "$ARDUINO_DIR/hardware/esp8266com/"

# 清理缓存
echo "清理Arduino缓存..."
rm -rf "$CACHE_DIR"

echo "=== 安装完成 ==="
echo "请重启Arduino IDE"
echo "然后在开发板管理器中选择: ESP8266 Boards -> NodeMCU 1.0 (ESP-12E Module)"

# 显示安装信息
echo ""
echo "安装位置: $ARDUINO_DIR/hardware/esp8266com/esp8266"
echo "缓存已清理: $CACHE_DIR"
echo ""
echo "如果仍有问题，请尝试:"
echo "1. 重启Arduino IDE"
echo "2. 检查开发板管理器"
echo "3. 选择正确的开发板配置" 