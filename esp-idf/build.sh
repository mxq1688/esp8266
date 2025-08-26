#!/bin/bash

# ESP-IDF 构建脚本
# 使用方法: ./build.sh [项目名称] [端口]

PROJECT_NAME=${1:-"wifi_station"}
PORT=${2:-"/dev/ttyUSB0"}

echo "构建项目: $PROJECT_NAME"
echo "目标端口: $PORT"

# 检查项目是否存在
if [ ! -d "examples/$PROJECT_NAME" ]; then
    echo "错误: 项目 $PROJECT_NAME 不存在"
    echo "可用项目:"
    ls examples/
    exit 1
fi

# 进入项目目录
cd "examples/$PROJECT_NAME"

# 设置目标芯片
idf.py set-target esp8266

# 构建项目
echo "开始构建..."
idf.py build

if [ $? -eq 0 ]; then
    echo "构建成功!"
    echo "是否要烧录到设备? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "烧录到端口 $PORT..."
        idf.py -p $PORT flash
        echo "是否要启动监控? (y/n)"
        read -r monitor_response
        if [[ "$monitor_response" =~ ^[Yy]$ ]]; then
            idf.py -p $PORT monitor
        fi
    fi
else
    echo "构建失败!"
    exit 1
fi
