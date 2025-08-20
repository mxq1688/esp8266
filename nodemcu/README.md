# NodeMCU 开发

## 概述
使用NodeMCU固件进行ESP8266开发，基于Lua脚本语言，轻量级且易于使用。

## 优势
- 使用Lua脚本语言，语法简单
- 轻量级，资源占用少
- 快速开发，适合简单应用
- 丰富的模块支持
- 适合物联网原型开发

## 环境搭建

### 1. 下载NodeMCU固件
- 官方固件: https://nodemcu.readthedocs.io/en/release/
- 自定义固件: https://nodemcu-build.com/
- 选择需要的模块进行编译

### 2. 烧录固件
使用esptool工具烧录：
```bash
pip install esptool
esptool.py --port /dev/ttyUSB0 erase_flash
esptool.py --port /dev/ttyUSB0 write_flash 0x00000 nodemcu-firmware.bin
```

### 3. 开发工具
- ESPlorer (推荐)
- LuaLoader
- PuTTY (Windows)
- Screen (macOS/Linux)

## 项目结构
```
nodemcu/
├── README.md              # 说明文档
├── examples/              # 示例代码
│   ├── wifi_connect.lua  # WiFi连接示例
│   ├── web_server.lua    # Web服务器示例
│   ├── mqtt_client.lua   # MQTT客户端示例
│   ├── sensor_read.lua   # 传感器读取示例
│   └── gpio_control.lua  # GPIO控制示例
├── modules/              # 自定义模块
│   ├── my_sensor.lua    # 传感器模块
│   └── my_display.lua   # 显示模块
├── projects/            # 项目代码
├── docs/               # 文档资料
└── firmware/           # 固件文件
```

## 核心模块
- wifi: WiFi连接管理
- net: 网络通信
- gpio: GPIO控制
- pwm: PWM输出
- adc: ADC读取
- uart: 串口通信
- i2c: I2C通信
- spi: SPI通信
- file: 文件系统
- timer: 定时器

## 快速开始
1. 连接ESP8266到电脑
2. 打开ESPlorer
3. 选择正确的串口
4. 编写Lua代码
5. 运行或保存到设备

## 示例代码
```lua
-- WiFi配置
wifi.setmode(wifi.STATION)
wifi.sta.config("your_wifi_ssid", "your_wifi_password")

-- 等待连接
tmr.create():alarm(1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() then
        print("WiFi已连接")
        print("IP地址: " .. wifi.sta.getip())
        tmr.stop(0)
    else
        print("连接中...")
    end
end)

-- GPIO控制示例
gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.HIGH)

-- 定时器示例
tmr.create():alarm(5000, tmr.ALARM_AUTO, function()
    print("定时器触发")
end)
```

## 常用命令
```lua
-- 查看内存使用
print(node.heap())

-- 查看文件系统
file.list()

-- 重启设备
node.restart()

-- 查看WiFi状态
print(wifi.sta.status())

-- 查看MAC地址
print(wifi.sta.getmac())
```

## 模块开发
```lua
-- 自定义模块示例
local M = {}

function M.init()
    print("模块初始化")
end

function M.read_sensor()
    return adc.read(0)
end

return M
```

## 固件定制
1. 访问 https://nodemcu-build.com/
2. 选择需要的模块
3. 输入邮箱地址
4. 等待编译完成
5. 下载自定义固件

## 常用模块组合
- 基础版: wifi, net, gpio, timer
- 传感器版: wifi, net, gpio, adc, i2c
- 显示版: wifi, net, gpio, i2c, u8g
- 完整版: 包含所有模块 