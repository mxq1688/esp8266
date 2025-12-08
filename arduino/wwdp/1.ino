#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

// 硬件配置
const int ledPin = 2;        // 板载LED引脚（D4）
const int buttonPin = 4;     // 按钮引脚（D2，GPIO4）

// 状态变量
bool requestSent = false;    // 防止重复发送请求的标志
bool lastButtonState = false; // 记录上一次按钮状态，用于检测边沿

// WiFi配置
const char* ssid = "HUAWEI";
const char* password = "11111111";

// 服务器配置
const char* host = "wenyan-avatar.mobvoi.com";
const int httpsPort = 443;
const char* path = "/avatar/openApi/avatarControl";

// 请求参数
const char* token = "d7af85777566b4df0ca99af5e17f842d";
String payload;

// HTTPS客户端
WiFiClientSecure client;

void setup() {
  Serial.begin(115200);
  while (!Serial); // 等待串口就绪
  
  // 初始化引脚
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT_PULLUP);  // 按钮引脚设为输入，启用内部上拉电阻
  digitalWrite(ledPin, LOW);  // 初始LED灭

  Serial.println("=== 系统启动 ===");

  // 连接WiFi
  if (connectWiFi()) {
    digitalWrite(ledPin, HIGH);  // WiFi连接成功后LED常亮
    Serial.println("=== WiFi连接成功，等待按钮触发 ===");
    delay(1000);
    
    // 构建请求数据（提前准备，提高响应速度）
    buildPayload();
  } else {
    Serial.println("=== WiFi连接失败 ===");
  }
}

void loop() {
  // 检查WiFi连接状态，断开时尝试重连
  if (WiFi.status() != WL_CONNECTED) {
    digitalWrite(ledPin, LOW);
    Serial.println("\nWiFi已断开，尝试重连...");
    if (connectWiFi()) {
      digitalWrite(ledPin, HIGH);
      Serial.println("WiFi重连成功");
    }
    delay(1000);
    return;
  }
  
  // 检测按钮状态（按下时为低电平，因为使用上拉电阻）
  int buttonState = digitalRead(buttonPin);
  bool buttonPressed = (buttonState == LOW); // 按钮按下时为低电平
  
  // 检测按钮按下边沿（从高电平变为低电平）
  if (buttonPressed && !lastButtonState) {
    Serial.println("\n检测到按钮按下！");
    
    // 防止长按导致重复发送
    if (!requestSent) {
      Serial.println("开始发送请求...");
      postHttpsRequest();  // 发送请求
      blinkLED(3);         // LED闪烁3次
      requestSent = true;  // 标记为已发送
    }
  } else if (!buttonPressed && lastButtonState) {
    // 按钮释放时重置标志
    requestSent = false;
    Serial.println("按钮已释放");
  }
  
  // 更新上一次按钮状态
  lastButtonState = buttonPressed;
  
  delay(50);  // 简单防抖
}

// WiFi连接函数
bool connectWiFi() {
  Serial.printf("连接WiFi: %s...\n", ssid);
  WiFi.begin(ssid, password);
  
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 20000) {
    digitalWrite(ledPin, HIGH);
    delay(50);
    digitalWrite(ledPin, LOW);
    delay(50);
    Serial.print(".");
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi连接成功");
    Serial.print("IP地址: ");
    Serial.println(WiFi.localIP());
    return true;
  } else {
    Serial.println("\nWiFi连接超时");
    return false;
  }
}

// 构建请求体
void buildPayload() {
  Serial.println("\n构建请求数据:");
  StaticJsonDocument<200> doc;
  doc["projectId"] = "1955467463458168832";
  doc["type"] = "chat";
  doc["text"] = "明天的天气";
  serializeJson(doc, payload);
  Serial.print("请求体: ");
  Serial.println(payload);
}

// 发送HTTPS请求
void postHttpsRequest() {
  Serial.println("\n=== 开始HTTPS请求 ===");
  
  // 配置SSL
  client.setSSLVersion(BR_TLS11);  // 强制TLS 1.1
  client.setInsecure();            // 禁用证书验证
  
  // 连接服务器
  Serial.printf("连接 %s:%d...\n", host, httpsPort);
  if (!client.connect(host, httpsPort)) {
    Serial.println("服务器连接失败！");
    return;
  }
  Serial.println("服务器连接成功");
  
  // 构建并发送请求
  String request = "";
  request += "POST " + String(path) + " HTTP/1.1\r\n";
  request += "Host: " + String(host) + "\r\n";
  request += "Content-Type: application/json\r\n";
  request += "token: " + String(token) + "\r\n";
  request += "Content-Length: " + String(payload.length()) + "\r\n";
  request += "Connection: close\r\n\r\n";
  request += payload;
  
  client.print(request);
  Serial.println("请求已发送，等待响应...");
  
  // 读取响应
  unsigned long timeout = millis() + 10000;
  while (client.available() == 0 && millis() < timeout) delay(100);
  
  if (client.available() == 0) {
    Serial.println("响应超时（10秒）");
  } else {
    Serial.println("\n收到响应：");
    Serial.println("------------------------------");
    while (client.available()) {
      Serial.print((char)client.read());
    }
    Serial.println("\n------------------------------");
  }
  
  client.stop();
  Serial.println("连接已关闭");
}

// LED闪烁指定次数
void blinkLED(int times) {
  Serial.printf("\nLED闪烁 %d 次...\n", times);
  for (int i = 0; i < times; i++) {
    digitalWrite(ledPin, LOW);   // 灭
    delay(300);
    digitalWrite(ledPin, HIGH);  // 亮
    delay(300);
  }
  // 闪烁完成后保持常亮（表示WiFi仍连接）
  digitalWrite(ledPin, HIGH);
}
    