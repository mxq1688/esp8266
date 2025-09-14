# ESPlorer 开发工具配置指南

## 简介
ESPlorer 是 NodeMCU 开发的首选 IDE，提供代码编辑、文件管理、串口通信等功能。

## 下载安装

### 1. 下载 ESPlorer
- 官方地址: https://esp8266.ru/esplorer/
- GitHub: https://github.com/4refr0nt/ESPlorer
- 下载 ESPlorer.zip 文件

### 2. 系统要求
- Java 8 或更高版本
- Windows/macOS/Linux 支持
- 至少 512MB 内存

### 3. 安装步骤
```bash
# 1. 解压文件
unzip ESPlorer.zip  也可以使用ESPlorer源码去编译ESPlorer.jar，./mvnw clean package命令编译

# 2. 运行 (Windows)
java -jar ESPlorer.jar

# 3. 运行 (macOS/Linux)
chmod +x ESPlorer.jar
java -jar ESPlorer.jar 或者 sh ESPlorer.sh
```

## 界面配置

### 1. 串口设置
- 选择正确的串口 (COM1, /dev/ttyUSB0 等)
- 波特率设置为 115200
- 点击 "Open" 连接设备

### 2. 编辑器设置
- 字体大小: 12-14pt
- 主题: Dark 或 Light
- 自动完成: 启用
- 语法高亮: Lua

### 3. 文件管理
- 左侧面板显示设备文件
- 右侧面板显示本地文件
- 支持拖拽上传文件

## 常用功能

### 1. 代码编辑
- 语法高亮
- 自动缩进
- 括号匹配
- 查找替换

### 2. 文件操作
- 上传文件到设备
- 从设备下载文件
- 删除设备文件
- 重命名文件

### 3. 代码执行
- 直接运行 Lua 代码
- 保存并运行文件
- 查看输出结果

### 4. 串口监控
- 实时查看串口输出
- 发送命令到设备
- 清空输出缓冲区

## 快捷键

| 功能 | 快捷键 |
|------|--------|
| 新建文件 | Ctrl+N |
| 打开文件 | Ctrl+O |
| 保存文件 | Ctrl+S |
| 运行代码 | F5 |
| 上传文件 | F1 |
| 格式化代码 | Ctrl+Shift+F |
| 查找 | Ctrl+F |
| 替换 | Ctrl+H |

## 插件扩展

### 1. 代码片段
创建常用代码模板：
```lua
-- WiFi连接模板
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID", "PASSWORD")

-- GPIO控制模板
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.HIGH)

-- 定时器模板
tmr.create():alarm(1000, tmr.ALARM_AUTO, function()
    print("Timer triggered")
end)
```

### 2. 自定义函数库
创建 `lib.lua` 文件：
```lua
local M = {}

function M.connect_wifi(ssid, password)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, password)
end

function M.blink_led(pin, times)
    for i = 1, times do
        gpio.write(pin, gpio.HIGH)
        tmr.delay(500000)
        gpio.write(pin, gpio.LOW)
        tmr.delay(500000)
    end
end

return M
```

## 调试技巧

### 1. 串口调试
```lua
-- 调试输出
print("Debug: variable =", variable)

-- 内存监控
print("Heap:", node.heap())

-- 错误处理
local success, result = pcall(function()
    -- 可能出错的代码
    return risky_function()
end)

if not success then
    print("Error:", result)
end
```

### 2. 文件调试
```lua
-- 检查文件是否存在
if file.exists("config.lua") then
    dofile("config.lua")
else
    print("Config file not found")
end

-- 列出所有文件
for name, size in pairs(file.list()) do
    print(name, size)
end
```

## 常见问题

### 1. 连接问题
- 检查串口驱动是否安装
- 确认波特率设置正确
- 尝试按 RST 按钮重启设备

### 2. 上传失败
- 文件名不能包含中文
- 确保设备有足够存储空间
- 检查文件格式是否正确

### 3. 代码执行错误
- 检查 Lua 语法错误
- 确认模块是否正确加载
- 查看错误信息定位问题

## 高级配置

### 1. 自定义工具栏
添加常用命令按钮：
```
node.restart()
file.list()
wifi.sta.getip()
node.heap()
```

### 2. 代码模板
创建项目模板文件夹：
```
templates/
├── basic_project/
│   ├── init.lua
│   ├── config.lua
│   └── main.lua
├── web_server/
│   ├── init.lua
│   ├── server.lua
│   └── index.html
└── iot_sensor/
    ├── init.lua
    ├── sensor.lua
    └── mqtt.lua
```

### 3. 批处理脚本
创建自动化脚本：
```bash
#!/bin/bash
# upload_project.sh

echo "Uploading NodeMCU project..."
java -jar ESPlorer.jar -upload init.lua
java -jar ESPlorer.jar -upload main.lua
java -jar ESPlorer.jar -upload config.lua
echo "Upload complete!"
```

## 最佳实践

1. **代码组织**: 将代码分解为多个模块文件
2. **错误处理**: 使用 pcall 处理可能的错误
3. **内存管理**: 定期检查内存使用情况
4. **版本控制**: 使用 Git 管理代码版本
5. **文档注释**: 为函数添加详细注释

## 参考资源

- [ESPlorer 官方文档](https://esp8266.ru/esplorer/)
- [NodeMCU 固件文档](https://nodemcu.readthedocs.io/)
- [Lua 语言参考](https://www.lua.org/manual/5.1/)
- [ESP8266 技术规格](https://www.espressif.com/en/products/socs/esp8266)
