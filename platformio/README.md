# PlatformIO 开发

## 概述
使用PlatformIO进行ESP8266开发，这是一个跨平台的物联网开发环境，支持多种框架和IDE。

## 优势
- 支持多种开发框架 (Arduino、ESP-IDF、MicroPython等)
- 强大的依赖管理
- 支持多种IDE (VS Code、CLion、Eclipse等)
- 跨平台支持
- 专业的项目管理

## 环境搭建

### 1. 安装PlatformIO Core
```bash
# 使用pip安装
pip install platformio

# 或使用官方安装脚本
python3 -c "$(curl -fsSL https://raw.githubusercontent.com/platformio/platformio/master/scripts/get-platformio.py)"
```

### 2. 安装IDE扩展
- VS Code: 安装PlatformIO IDE扩展
- CLion: 安装PlatformIO插件
- Eclipse: 安装PlatformIO插件

### 3. 验证安装
```bash
pio --version
pio platform list
```

## 项目结构
```
platformio/
├── README.md              # 说明文档
├── examples/              # 示例项目
│   ├── arduino_wifi/     # Arduino WiFi示例
│   ├── esp-idf_wifi/     # ESP-IDF WiFi示例
│   ├── micropython_wifi/ # MicroPython WiFi示例
│   └── custom_framework/ # 自定义框架示例
├── projects/            # 项目代码
├── docs/               # 文档资料
└── tools/              # 工具脚本
```

## 支持的框架
- Arduino Framework
- ESP-IDF Framework
- MicroPython Framework
- Zephyr RTOS
- FreeRTOS
- 自定义框架

## 快速开始

### 1. 创建新项目
```bash
# 创建Arduino项目
pio project init --board nodemcuv2 --framework arduino

# 创建ESP-IDF项目
pio project init --board nodemcuv2 --framework espidf

# 创建MicroPython项目
pio project init --board nodemcuv2 --framework micropython
```

### 2. 项目配置
编辑`platformio.ini`文件：
```ini
[env:nodemcuv2]
platform = espressif8266
board = nodemcuv2
framework = arduino
monitor_speed = 115200
```

### 3. 编译和上传
```bash
# 编译项目
pio run

# 上传固件
pio run --target upload

# 监控串口
pio device monitor

# 清理编译
pio run --target clean
```

## 示例项目

### Arduino框架示例
```cpp
#include <Arduino.h>
#include <ESP8266WiFi.h>

const char* ssid = "your_wifi_ssid";
const char* password = "your_wifi_password";

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println("WiFi connected");
  Serial.println(WiFi.localIP());
}

void loop() {
  // 主循环代码
}
```

### MicroPython框架示例
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
```bash
# 查看可用开发板
pio boards esp8266

# 查看可用平台
pio platform list

# 查看可用框架
pio framework list

# 安装库
pio lib install "库名"

# 搜索库
pio lib search "关键词"

# 更新平台
pio platform update

# 运行测试
pio test
```

## 高级功能
- 多环境配置
- 自定义构建脚本
- 持续集成支持
- 调试支持
- 单元测试
- 代码分析

## IDE集成
- VS Code: 完整的开发体验
- CLion: 专业的C/C++开发
- Eclipse: 传统IDE支持
- Vim/Emacs: 命令行开发 