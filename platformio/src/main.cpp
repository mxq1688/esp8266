#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include "led_control.h"

// WiFi 配置
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Web 服务器
ESP8266WebServer server(80);

// LED 控制器
LEDController ledController(2); // GPIO2 (NodeMCU D4)

void setup() {
    Serial.begin(115200);
    Serial.println("\n=== ESP8266 PlatformIO 示例启动 ===");
    
    // 初始化 LED
    ledController.begin();
    ledController.blink(3, 200); // 启动时闪烁3次
    
    // 连接 WiFi
    WiFi.begin(ssid, password);
    Serial.print("连接 WiFi");
    
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
        ledController.toggle(); // 连接时 LED 闪烁
    }
    
    Serial.println();
    Serial.print("WiFi 已连接! IP 地址: ");
    Serial.println(WiFi.localIP());
    
    // 设置 Web 服务器路由
    setupWebServer();
    
    // 启动服务器
    server.begin();
    Serial.println("HTTP 服务器已启动");
    
    // 连接成功，LED 常亮
    ledController.on();
}

void loop() {
    server.handleClient();
    
    // 每5秒输出一次状态
    static unsigned long lastStatus = 0;
    if (millis() - lastStatus > 5000) {
        Serial.printf("运行时间: %lu ms, 空闲内存: %u bytes\n", 
                     millis(), ESP.getFreeHeap());
        lastStatus = millis();
    }
    
    delay(10);
}

void setupWebServer() {
    // 主页
    server.on("/", HTTP_GET, []() {
        String html = R"(
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ESP8266 LED 控制</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .button { 
            background-color: #4CAF50; 
            border: none; 
            color: white; 
            padding: 15px 32px; 
            text-align: center; 
            text-decoration: none; 
            display: inline-block; 
            font-size: 16px; 
            margin: 4px 2px; 
            cursor: pointer; 
            border-radius: 4px;
        }
        .button.off { background-color: #f44336; }
    </style>
</head>
<body>
    <h1>ESP8266 LED 控制面板</h1>
    <p>当前状态: <span id="status">未知</span></p>
    <button class="button" onclick="ledControl('on')">开启 LED</button>
    <button class="button off" onclick="ledControl('off')">关闭 LED</button>
    <button class="button" onclick="ledControl('blink')">闪烁 LED</button>
    
    <script>
        function ledControl(action) {
            fetch('/led/' + action)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('status').innerText = data;
                });
        }
        
        // 定期更新状态
        setInterval(() => {
            fetch('/status')
                .then(response => response.text())
                .then(data => {
                    document.getElementById('status').innerText = data;
                });
        }, 2000);
    </script>
</body>
</html>
        )";
        server.send(200, "text/html", html);
    });
    
    // LED 控制 API
    server.on("/led/on", HTTP_GET, []() {
        ledController.on();
        server.send(200, "text/plain", "LED 已开启");
    });
    
    server.on("/led/off", HTTP_GET, []() {
        ledController.off();
        server.send(200, "text/plain", "LED 已关闭");
    });
    
    server.on("/led/blink", HTTP_GET, []() {
        ledController.blink(5, 300);
        server.send(200, "text/plain", "LED 闪烁中");
    });
    
    // 状态查询
    server.on("/status", HTTP_GET, []() {
        String status = ledController.isOn() ? "开启" : "关闭";
        server.send(200, "text/plain", status);
    });
    
    // 系统信息
    server.on("/info", HTTP_GET, []() {
        String info = "芯片ID: " + String(ESP.getChipId()) + "\n";
        info += "运行时间: " + String(millis()) + " ms\n";
        info += "空闲内存: " + String(ESP.getFreeHeap()) + " bytes\n";
        info += "WiFi 信号强度: " + String(WiFi.RSSI()) + " dBm\n";
        server.send(200, "text/plain", info);
    });
}
