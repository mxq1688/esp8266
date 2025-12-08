# NodeMCU 基础项目模板

这是一个完整的 NodeMCU Lua 开发项目模板，提供了标准的项目结构和常用功能。

## 项目结构

```
basic_template/
├── README.md          # 项目说明文档
├── init.lua          # 系统初始化文件 (自动执行)
├── main.lua          # 主程序文件
├── config.lua        # 配置文件
└── modules/          # 自定义模块目录
    ├── wifi_manager.lua
    ├── web_server.lua
    └── sensor_reader.lua
```

## 快速开始

### 1. 配置项目
编辑 `config.lua` 文件，修改以下配置：

```lua
CONFIG = {
    WIFI_SSID = "你的WiFi名称",
    WIFI_PASSWORD = "你的WiFi密码",
    DEVICE_NAME = "你的设备名称",
    DEBUG_MODE = true
}
```

### 2. 上传文件
使用 ESPlorer 或其他工具上传以下文件到 NodeMCU：
- `init.lua`
- `main.lua`
- `config.lua`

### 3. 重启设备
重启 NodeMCU，系统将自动执行 `init.lua`

## 功能特性

### 系统功能
- ✅ 自动WiFi连接
- ✅ 配置文件管理
- ✅ 错误处理和恢复
- ✅ 串口命令接口
- ✅ 状态监控
- ✅ 内存管理

### GPIO功能
- ✅ LED状态指示
- ✅ 按钮中断处理
- ✅ 心跳LED闪烁
- ✅ GPIO状态监控

### 网络功能
- ✅ WiFi连接管理
- ✅ 网络状态检测
- ✅ 连接失败重试

## 串口命令

连接串口后，可以使用以下命令：

| 命令 | 功能 |
|------|------|
| `status` | 显示设备状态 |
| `restart` | 重启设备 |
| `led_on` | 开启LED |
| `led_off` | 关闭LED |
| `led_toggle` | 切换LED状态 |
| `shutdown` | 关闭应用程序 |
| `help` | 显示帮助信息 |

## 配置说明

### WiFi配置
```lua
WIFI_SSID = "your_wifi_ssid"      -- WiFi网络名称
WIFI_PASSWORD = "your_wifi_password"  -- WiFi密码
```

### GPIO配置
```lua
GPIO = {
    LED_PIN = 4,        -- 状态LED (D2)
    BUTTON_PIN = 5,     -- 按钮输入 (D1)
    PWM_PIN = 6,        -- PWM输出 (D6)
    RELAY_PIN = 7,      -- 继电器控制 (D7)
    SENSOR_PIN = 0      -- 传感器输入 (A0)
}
```

### 网络配置
```lua
NETWORK = {
    WEB_SERVER_PORT = 80,
    MQTT_HOST = "broker.hivemq.com",
    MQTT_PORT = 1883
}
```

## 扩展开发

### 添加新模块
1. 在 `modules/` 目录创建模块文件
2. 在 `main.lua` 中引入模块
3. 在 `config.lua` 中添加相关配置

### 示例模块结构
```lua
-- modules/my_module.lua
local M = {}

function M.init(config)
    -- 模块初始化
end

function M.start()
    -- 启动模块功能
end

return M
```

## 故障排除

### 常见问题

**1. WiFi连接失败**
- 检查SSID和密码是否正确
- 确认WiFi信号强度
- 检查路由器设置

**2. 设备无响应**
- 检查电源供电
- 重新烧录固件
- 检查串口连接

**3. 内存不足**
- 减少加载的模块
- 优化代码逻辑
- 清理无用变量

### 调试技巧

**启用调试模式:**
```lua
CONFIG.DEBUG_MODE = true
```

**查看内存使用:**
```lua
print("可用内存:", node.heap())
```

**查看文件列表:**
```lua
for name, size in pairs(file.list()) do
    print(name, size)
end
```

## 性能优化

### 内存优化
- 使用局部变量
- 及时清理大对象
- 避免全局变量污染

### 代码优化
- 模块化设计
- 异步处理
- 错误处理

### 网络优化
- 连接池管理
- 超时设置
- 重连机制

## 版本历史

- **v1.0.0** - 初始版本
  - 基础项目结构
  - WiFi连接管理
  - GPIO控制
  - 串口命令接口

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关资源

- [NodeMCU 官方文档](https://nodemcu.readthedocs.io/)
- [ESP8266 技术参考](https://www.espressif.com/en/products/socs/esp8266)
- [Lua 语言参考](https://www.lua.org/manual/5.1/)
- [ESPlorer IDE](https://esp8266.ru/esplorer/)
