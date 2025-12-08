-- LED Control Project - 配置文件
-- 包含所有项目配置参数
-- 作者: NodeMCU Developer
-- 版本: 1.0.0

print("Loading LED Control configuration...")

-- 全局配置对象
CONFIG = {}

-- ==================== 基本设置 ====================
CONFIG.PROJECT_NAME = "LED Control System"
CONFIG.VERSION = "1.0.0"
CONFIG.DEBUG_MODE = true  -- 调试模式开关

-- ==================== GPIO 引脚配置 ====================
CONFIG.GPIO = {
    -- LED 引脚配置 (NodeMCU引脚映射)
    LED_BUILTIN = 4,    -- D2 - 内置LED (低电平点亮)
    LED_RED = 5,        -- D1 - 红色LED
    LED_GREEN = 6,      -- D6 - 绿色LED  
    LED_BLUE = 7,       -- D7 - 蓝色LED
    
    -- 控制按钮引脚
    BUTTON_1 = 0,       -- D3 - 按钮1 (模式切换)
    BUTTON_2 = 2,       -- D4 - 按钮2 (开关控制)
    
    -- 其他GPIO
    BUZZER = 8,         -- D8 - 蜂鸣器
    SENSOR = 0          -- A0 - 模拟传感器输入
}

-- ==================== LED 控制配置 ====================
CONFIG.LED = {
    -- LED 默认状态
    DEFAULT_STATE = false,  -- 默认关闭
    
    -- 闪烁模式配置
    BLINK_MODES = {
        SLOW = 1000,        -- 慢闪 (1秒)
        NORMAL = 500,       -- 正常 (0.5秒)
        FAST = 200,         -- 快闪 (0.2秒)
        RAPID = 100         -- 急闪 (0.1秒)
    },
    
    -- 呼吸灯配置
    BREATH_SPEED = 50,      -- 呼吸灯变化速度(ms)
    BREATH_STEPS = 20,      -- 呼吸灯亮度级别
    
    -- PWM配置
    PWM_FREQ = 1000,        -- PWM频率 (Hz)
    PWM_RESOLUTION = 1023   -- PWM分辨率
}

-- ==================== WiFi 配置 ====================
CONFIG.WIFI = {
    SSID = "Your_WiFi_SSID",        -- 替换为你的WiFi名称
    PASSWORD = "Your_WiFi_Password", -- 替换为你的WiFi密码
    TIMEOUT = 30,                    -- 连接超时时间(秒)
    RETRY_COUNT = 3,                 -- 重试次数
    AUTO_CONNECT = true              -- 自动连接WiFi
}

-- ==================== Web服务器配置 ====================
CONFIG.WEB_SERVER = {
    ENABLED = true,         -- 启用Web服务器
    PORT = 80,             -- 服务器端口
    TIMEOUT = 30           -- 请求超时时间
}

-- ==================== 定时器配置 ====================
CONFIG.TIMERS = {
    HEARTBEAT_INTERVAL = 5000,  -- 心跳间隔(ms)
    STATUS_REPORT_INTERVAL = 10000,  -- 状态报告间隔(ms)
    AUTO_SAVE_INTERVAL = 60000  -- 自动保存间隔(ms)
}

-- ==================== 串口命令配置 ====================
CONFIG.COMMANDS = {
    -- 可用的串口命令列表
    AVAILABLE = {
        "help", "status", "restart", "shutdown",
        "led_on", "led_off", "led_toggle", "led_blink",
        "led_breath", "led_rainbow", "led_brightness",
        "wifi_connect", "wifi_status", "wifi_scan",
        "memory", "files", "gpio_status"
    }
}

-- ==================== 调试配置 ====================
CONFIG.DEBUG = {
    PRINT_MEMORY = true,    -- 打印内存使用情况
    PRINT_GPIO_STATUS = false,  -- 打印GPIO状态
    PRINT_WIFI_STATUS = true,   -- 打印WiFi状态
    LOG_COMMANDS = true     -- 记录命令执行
}

-- ==================== 安全配置 ====================
CONFIG.SECURITY = {
    ENABLE_WEB_AUTH = false,    -- Web界面认证
    WEB_USERNAME = "admin",     -- Web用户名
    WEB_PASSWORD = "12345678",  -- Web密码
    MAX_FAILED_ATTEMPTS = 5     -- 最大失败尝试次数
}

-- 配置验证函数
function CONFIG.validate()
    local errors = {}
    
    -- 检查必要的GPIO引脚
    if not CONFIG.GPIO.LED_BUILTIN then
        table.insert(errors, "LED_BUILTIN pin not configured")
    end
    
    -- 检查WiFi配置
    if CONFIG.WIFI.AUTO_CONNECT and (not CONFIG.WIFI.SSID or CONFIG.WIFI.SSID == "Your_WiFi_SSID") then
        table.insert(errors, "WiFi SSID not configured")
    end
    
    if #errors > 0 then
        print("Configuration errors found:")
        for i, error in ipairs(errors) do
            print("  " .. i .. ". " .. error)
        end
        return false
    end
    
    return true
end

-- 打印配置信息
function CONFIG.print_info()
    if CONFIG.DEBUG_MODE then
        print("=== Configuration Info ===")
        print("Project:", CONFIG.PROJECT_NAME)
        print("Version:", CONFIG.VERSION)
        print("Debug Mode:", CONFIG.DEBUG_MODE)
        print("WiFi Auto Connect:", CONFIG.WIFI.AUTO_CONNECT)
        print("Web Server:", CONFIG.WEB_SERVER.ENABLED and "Enabled" or "Disabled")
        print("==========================")
    end
end

-- 保存配置到文件
function CONFIG.save()
    -- 这里可以添加配置保存逻辑
    print("Configuration saved")
end

-- 配置加载完成
print("LED Control configuration loaded successfully")

-- 验证配置
if not CONFIG.validate() then
    print("WARNING: Configuration validation failed!")
end

-- 打印配置信息
CONFIG.print_info()
