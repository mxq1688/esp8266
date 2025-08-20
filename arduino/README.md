# Arduino 开发

## 概述
使用Arduino IDE进行ESP8266开发，这是最简单易学的开发方式，适合初学者。

## 优势
- 丰富的库支持
- 大量现成的示例代码
- 社区支持广泛
- 图形化开发环境
- 快速原型开发

## 环境搭建

### 1. 安装Arduino IDE
- 下载地址: https://www.arduino.cc/en/software
- 支持Windows、macOS、Linux

### 2. 配置ESP8266开发板
1. 打开Arduino IDE
2. 文件 -> 首选项
3. 在"附加开发板管理器网址"中添加：
   ```
   http://arduino.esp8266.com/stable/package_esp8266com_index.json
   ```
4. 工具 -> 开发板 -> 开发板管理器
5. 搜索"ESP8266"并安装

### 3. 选择开发板
- 工具 -> 开发板 -> ESP8266 Boards -> NodeMCU 1.0 (ESP-12E Module)

## 项目结构
```
arduino/
├── README.md              # 说明文档
├── examples/              # 示例代码
│   ├── wifi_connect/     # WiFi连接示例
│   ├── web_server/       # Web服务器示例
│   ├── mqtt_client/      # MQTT客户端示例
│   └── sensor_read/      # 传感器读取示例
├── libraries/            # 自定义库
├── sketches/            # 项目代码
└── docs/               # 文档资料
```

## 常用库
- WiFi库: 内置，用于WiFi连接
- ESP8266WebServer: 内置，用于Web服务器
- ESP8266HTTPClient: 内置，用于HTTP请求
- PubSubClient: MQTT客户端
- ArduinoJson: JSON处理
- DHT: 温湿度传感器

## 快速开始
1. 创建新项目文件夹
2. 编写.ino文件
3. 选择正确的开发板和端口
4. 编译并上传

## 示例代码
```cpp
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