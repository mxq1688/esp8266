-- NodeMCU 项目配置文件
-- 修改此文件来配置你的项目设置

CONFIG = {
    -- WiFi配置
    WIFI_SSID = "your_wifi_ssid",           -- 替换为你的WiFi名称
    WIFI_PASSWORD = "your_wifi_password",   -- 替换为你的WiFi密码
    
    -- 设备配置
    DEVICE_NAME = "NodeMCU_" .. node.chipid(),  -- 设备名称
    DEBUG_MODE = true,                      -- 调试模式
    AUTO_START = true,                      -- 自动启动主程序
    
    -- GPIO配置
    GPIO = {
        LED_PIN = 4,        -- GPIO4 (D2) - 状态LED
        BUTTON_PIN = 5,     -- GPIO5 (D1) - 按钮输入
        PWM_PIN = 6,        -- GPIO12 (D6) - PWM输出
        RELAY_PIN = 7,      -- GPIO13 (D7) - 继电器控制
        SENSOR_PIN = 0      -- ADC0 (A0) - 传感器输入
    },
    
    -- 网络配置
    NETWORK = {
        WEB_SERVER_PORT = 80,       -- Web服务器端口
        MQTT_HOST = "broker.hivemq.com",  -- MQTT服务器
        MQTT_PORT = 1883,           -- MQTT端口
        MQTT_CLIENT_ID = "NodeMCU_" .. node.chipid(),
        MQTT_USERNAME = "",         -- MQTT用户名 (如需要)
        MQTT_PASSWORD = ""          -- MQTT密码 (如需要)
    },
    
    -- 传感器配置
    SENSORS = {
        DHT_PIN = 2,                -- DHT22传感器引脚
        DS18B20_PIN = 1,            -- DS18B20传感器引脚
        SAMPLE_INTERVAL = 30000,    -- 采样间隔 (毫秒)
        ENABLE_DHT = false,         -- 启用DHT传感器
        ENABLE_DS18B20 = false,     -- 启用DS18B20传感器
        ENABLE_ADC = true           -- 启用ADC采样
    },
    
    -- 定时器配置
    TIMERS = {
        HEARTBEAT_INTERVAL = 2000,  -- 心跳间隔 (毫秒)
        MONITOR_INTERVAL = 30000,   -- 监控间隔 (毫秒)
        SENSOR_INTERVAL = 10000     -- 传感器读取间隔 (毫秒)
    },
    
    -- 应用配置
    APP = {
        NAME = "NodeMCU基础项目",
        VERSION = "1.0.0",
        AUTHOR = "Your Name",
        DESCRIPTION = "NodeMCU Lua开发基础模板"
    }
}

-- 配置验证函数
local function validate_config()
    local errors = {}
    
    -- 检查必要配置
    if not CONFIG.DEVICE_NAME or CONFIG.DEVICE_NAME == "" then
        table.insert(errors, "设备名称不能为空")
    end
    
    -- 检查GPIO配置
    if CONFIG.GPIO then
        for name, pin in pairs(CONFIG.GPIO) do
            if type(pin) ~= "number" or pin < 0 or pin > 16 then
                table.insert(errors, "GPIO配置错误: " .. name .. " = " .. tostring(pin))
            end
        end
    end
    
    -- 检查网络配置
    if CONFIG.NETWORK then
        if CONFIG.NETWORK.WEB_SERVER_PORT and 
           (CONFIG.NETWORK.WEB_SERVER_PORT < 1 or CONFIG.NETWORK.WEB_SERVER_PORT > 65535) then
            table.insert(errors, "Web服务器端口配置错误")
        end
        
        if CONFIG.NETWORK.MQTT_PORT and 
           (CONFIG.NETWORK.MQTT_PORT < 1 or CONFIG.NETWORK.MQTT_PORT > 65535) then
            table.insert(errors, "MQTT端口配置错误")
        end
    end
    
    -- 输出验证结果
    if #errors > 0 then
        print("配置验证失败:")
        for i, error in ipairs(errors) do
            print("  " .. i .. ". " .. error)
        end
        return false
    else
        if CONFIG.DEBUG_MODE then
            print("配置验证通过")
        end
        return true
    end
end

-- 显示配置信息
local function show_config()
    if not CONFIG.DEBUG_MODE then
        return
    end
    
    print("\n=== 项目配置 ===")
    print("应用名称: " .. (CONFIG.APP.NAME or "未设置"))
    print("版本: " .. (CONFIG.APP.VERSION or "未设置"))
    print("设备名称: " .. CONFIG.DEVICE_NAME)
    print("调试模式: " .. (CONFIG.DEBUG_MODE and "开启" or "关闭"))
    print("自动启动: " .. (CONFIG.AUTO_START and "开启" or "关闭"))
    
    if CONFIG.WIFI_SSID and CONFIG.WIFI_SSID ~= "your_wifi_ssid" then
        print("WiFi SSID: " .. CONFIG.WIFI_SSID)
    else
        print("WiFi: 未配置")
    end
    
    print("===============\n")
end

-- 执行配置验证和显示
if validate_config() then
    show_config()
else
    print("请修正配置错误后重新启动")
end

-- 返回配置对象
return CONFIG
