#include <Arduino.h>
#include <ESP8266WiFi.h>

// WiFi配置
const char* ssid = "your_wifi_ssid";      // 替换为你的WiFi名称
const char* password = "your_wifi_password";  // 替换为你的WiFi密码

// LED引脚定义
const int ledPin = 2;  // NodeMCU板载LED

void setup() {
  // 初始化串口
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("ESP8266 PlatformIO 项目启动");
  
  // 设置LED引脚
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, HIGH);  // 关闭LED（NodeMCU LED是低电平有效）
  
  // 连接WiFi
  WiFi.begin(ssid, password);
  Serial.print("正在连接到WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    // LED闪烁表示正在连接
    digitalWrite(ledPin, !digitalRead(ledPin));
  }
  
  Serial.println();
  Serial.println("WiFi连接成功！");
  Serial.print("IP地址: ");
  Serial.println(WiFi.localIP());
  
  // 连接成功后LED常亮
  digitalWrite(ledPin, LOW);
}

void loop() {
  // 检查WiFi连接状态
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi连接断开，尝试重连...");
    WiFi.reconnect();
    delay(5000);
  }
  
  // 主循环代码
  Serial.println("ESP8266运行中...");
  
  // LED呼吸灯效果
  for (int brightness = 0; brightness <= 255; brightness++) {
    analogWrite(ledPin, brightness);
    delay(10);
  }
  
  for (int brightness = 255; brightness >= 0; brightness--) {
    analogWrite(ledPin, brightness);
    delay(10);
  }
  
  delay(2000);
}
