# MicroPython ESP8266 开发

## 概述
使用MicroPython进行ESP8266开发，使用Python语言，语法简洁，开发效率高。

## 优势
- 使用Python语言，语法简洁
- 开发效率高，代码可读性强
- 支持REPL交互式开发
- 适合快速原型验证
- 适合教育和学习

## 环境搭建

### 1. 下载MicroPython固件
- 官方固件: https://micropython.org/download/esp8266/
- 选择最新的稳定版本

### 2. 烧录固件
使用esptool工具烧录：
```bash
pip install esptool
esptool.py --port /dev/ttyUSB0 erase_flash
esptool.py --port /dev/ttyUSB0 write_flash 0x00000 esp8266-firmware.bin
```

### 3. 连接工具
- Thonny IDE (推荐)
- PuTTY (Windows)
- Screen (macOS/Linux)

## 项目结构
```
microPython/
├── README.md              # 说明文档
├── 烧写脚本.sh            # 一键烧写脚本
├── led_blink/            # LED闪烁项目
│   ├── README.md         # 项目说明
│   └── src/              # 源代码
│       ├── main.py       # 主程序
│       ├── led_control.py # LED控制模块
│       ├── config.py     # 配置文件
│       └── simple_led.py # 简单示例
└── docs/                 # 文档资料
    └── 固件烧写指南.md    # 详细烧写指南
```

## 快速开始

### 1. 烧写固件
```bash
# 使用一键烧写脚本
./烧写脚本.sh

# 或手动烧写
esptool --chip esp8266 --port /dev/ttyUSB0 erase-flash
esptool --chip esp8266 --port /dev/ttyUSB0 --baud 460800 write-flash --flash-size=detect 0x00000 esp8266-firmware.bin
```

### 2. 运行LED项目
```bash
# 进入项目目录
cd led_blink/

# 上传代码到ESP8266
# 使用Thonny IDE或其他工具上传src/目录下的文件

# 运行程序
exec(open('main.py').read())
```

## 常用模块
- network: WiFi连接
- socket: 网络通信
- machine: 硬件控制
- time: 时间相关
- json: JSON处理
- urequests: HTTP请求

## 示例代码
```python
import network
import time

# WiFi配置
ssid = 'your_wifi_ssid'
password = 'your_wifi_password'

def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    
    if not wlan.isconnected():
        print('连接到WiFi...')
        wlan.connect(ssid, password)
        
        while not wlan.isconnected():
            time.sleep(1)
            print('.', end='')
    
    print('WiFi已连接')
    print('IP地址:', wlan.ifconfig()[0])

# 连接WiFi
connect_wifi()
```

## 常用命令
```python
# 查看文件系统
import os
os.listdir()

# 查看内存使用
import gc
gc.mem_free()

# 重启设备
import machine
machine.reset()
``` 