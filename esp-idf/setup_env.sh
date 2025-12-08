#!/bin/bash

# ESP-IDF 环境设置脚本

echo "设置 ESP-IDF 开发环境..."

# 检查是否已安装ESP-IDF
if [ -z "$IDF_PATH" ]; then
    echo "警告: IDF_PATH 环境变量未设置"
    echo "请先安装 ESP8266_RTOS_SDK"
    echo "参考: https://github.com/espressif/ESP8266_RTOS_SDK"
    exit 1
fi

# 设置环境变量
export IDF_PATH=$IDF_PATH
export PATH=$IDF_PATH/tools:$PATH

# 检查必要的工具
echo "检查开发工具..."

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3"
    exit 1
fi

# 检查CMake
if ! command -v cmake &> /dev/null; then
    echo "错误: 未找到 CMake"
    exit 1
fi

# 检查idf.py
if ! command -v idf.py &> /dev/null; then
    echo "错误: 未找到 idf.py，请确保ESP-IDF已正确安装"
    exit 1
fi

echo "环境设置完成!"
echo "IDF_PATH: $IDF_PATH"
echo "可用命令:"
echo "  idf.py build    - 构建项目"
echo "  idf.py flash    - 烧录固件"
echo "  idf.py monitor  - 监控输出"
echo "  idf.py menuconfig - 配置项目"
