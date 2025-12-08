/* *****************************************************************
 * ESP-01 继电器模块 - Blinker AP配网版本
 * 
 * 功能说明：
 * 1. 首次启动进入AP配网模式，设备会创建热点
 * 2. 手机连接热点后，通过Blinker APP配置WiFi
 * 3. 配网成功后自动保存，下次启动直接连接WiFi
 * 4. 长按重置可清除配网信息，重新进入AP模式
 * 
 * Blinker 库下载:
 * https://github.com/blinker-iot/blinker-library/archive/master.zip
 * 
 * 文档: https://diandeng.tech/doc
 * *****************************************************************/

#define BLINKER_WIFI
#define BLINKER_APCONFIG      // 启用AP配网模式
#define BLINKER_ALIGENIE_LIGHT // 可选：支持天猫精灵

#include <Blinker.h>

// ESP-01 继电器模块控制引脚
#define RELAY_PIN 0  // GPIO0 控制继电器

// Blinker 设备密钥（从Blinker APP获取）
char auth[] = "Your Device Secret Key";

// 新建组件对象
BlinkerButton Button1("btn-relay");    // 继电器开关按钮
BlinkerButton ButtonReset("btn-reset"); // 重置配网按钮

bool relayState = false;  // 继电器状态

// 继电器控制函数
void relayControl(bool state) {
    relayState = state;
    digitalWrite(RELAY_PIN, state ? HIGH : LOW);
    BLINKER_LOG("Relay: ", state ? "ON" : "OFF");
    
    // 更新按钮状态显示
    Button1.print(state ? "on" : "off");
}

// 继电器按钮回调
void button1_callback(const String & state)
{
    BLINKER_LOG("Button state: ", state);
    
    if (state == "on") {
        relayControl(true);
    } else if (state == "off") {
        relayControl(false);
    } else {
        // 点击切换状态
        relayControl(!relayState);
    }
}

// 重置配网按钮回调
void buttonReset_callback(const String & state)
{
    BLINKER_LOG("Reset button pressed!");
    
    // 清除配网信息，重启后进入AP配网模式
    Blinker.reset();
}

// 心跳包回调 - 同步设备状态到APP
void heartbeat()
{
    Button1.print(relayState ? "on" : "off");
}

// 数据读取回调
void dataRead(const String & data)
{
    BLINKER_LOG("Blinker readString: ", data);
    
    // 可以处理自定义指令
    if (data == "on") {
        relayControl(true);
    } else if (data == "off") {
        relayControl(false);
    }
}

void setup()
{
    // 初始化串口（调试用）
    Serial.begin(115200);
    BLINKER_DEBUG.stream(Serial);
    
    // 初始化继电器引脚
    pinMode(RELAY_PIN, OUTPUT);
    digitalWrite(RELAY_PIN, LOW);  // 初始状态：继电器关闭
    
    // 初始化 Blinker（AP配网模式）
    // 自定义热点名称和密码
    // 参数：密钥, 热点名称, 热点密码
    Blinker.begin(auth, "ESP01_Relay", "12345678");
    
    // 绑定回调函数
    Blinker.attachData(dataRead);
    Blinker.attachHeartbeat(heartbeat);
    
    Button1.attach(button1_callback);
    ButtonReset.attach(buttonReset_callback);
    
    BLINKER_LOG("ESP-01 Relay Ready!");
    BLINKER_LOG("如未配网，请连接设备热点进行配网");
}

void loop() {
    Blinker.run();
}

