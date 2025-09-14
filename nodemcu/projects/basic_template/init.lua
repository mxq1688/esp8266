-- NodeMCU 基础项目模板
-- 系统初始化文件，设备启动时自动执行

print("NodeMCU 基础项目启动中...")
print("芯片ID: " .. node.chipid())
print("固件版本: " .. string.format("%d.%d.%d", node.info()))
print("可用内存: " .. node.heap() .. " 字节")

-- 配置文件检查
if file.exists("config.lua") then
    print("加载配置文件...")
    dofile("config.lua")
else
    print("警告: 配置文件不存在，使用默认配置")
    -- 创建默认配置
    local default_config = [[
-- 默认配置文件
CONFIG = {
    WIFI_SSID = "your_wifi_ssid",
    WIFI_PASSWORD = "your_wifi_password",
    DEVICE_NAME = "NodeMCU_]] .. node.chipid() .. [[",
    DEBUG_MODE = true,
    AUTO_START = true
}
return CONFIG
]]
    
    local f = file.open("config.lua", "w")
    if f then
        f:write(default_config)
        f:close()
        print("已创建默认配置文件")
        dofile("config.lua")
    end
end

-- 错误处理函数
local function handle_error(err)
    print("错误: " .. tostring(err))
    if CONFIG and CONFIG.DEBUG_MODE then
        print("调试模式: 重启设备")
        tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
            node.restart()
        end)
    end
end

-- 安全执行函数
local function safe_execute(func, name)
    local success, result = pcall(func)
    if not success then
        print("执行 " .. name .. " 失败: " .. tostring(result))
        handle_error(result)
        return false
    end
    return true, result
end

-- WiFi连接函数
local function connect_wifi()
    if not CONFIG.WIFI_SSID or CONFIG.WIFI_SSID == "your_wifi_ssid" then
        print("WiFi未配置，跳过连接")
        return
    end
    
    print("连接WiFi: " .. CONFIG.WIFI_SSID)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(CONFIG.WIFI_SSID, CONFIG.WIFI_PASSWORD)
    
    -- 连接超时处理
    local connection_timer = tmr.create()
    local timeout_timer = tmr.create()
    
    -- 30秒超时
    timeout_timer:alarm(30000, tmr.ALARM_SINGLE, function()
        connection_timer:stop()
        print("WiFi连接超时")
    end)
    
    connection_timer:alarm(1000, tmr.ALARM_AUTO, function()
        local status = wifi.sta.status()
        local ip = wifi.sta.getip()
        
        if status == wifi.STA_GOTIP and ip then
            connection_timer:stop()
            timeout_timer:stop()
            print("WiFi连接成功!")
            print("IP地址: " .. ip)
            print("MAC地址: " .. wifi.sta.getmac())
            
            -- WiFi连接成功回调
            if on_wifi_connected then
                safe_execute(on_wifi_connected, "WiFi连接回调")
            end
        end
    end)
end

-- 主程序启动
local function start_main()
    if file.exists("main.lua") then
        print("启动主程序...")
        safe_execute(function() dofile("main.lua") end, "主程序")
    else
        print("警告: main.lua 不存在")
        -- 创建示例主程序
        local main_template = [[
-- 主程序文件
print("主程序启动")

-- GPIO示例
local LED_PIN = 4
gpio.mode(LED_PIN, gpio.OUTPUT)

-- LED闪烁示例
local function blink_led()
    local state = false
    tmr.create():alarm(1000, tmr.ALARM_AUTO, function()
        state = not state
        gpio.write(LED_PIN, state and gpio.HIGH or gpio.LOW)
        print("LED状态: " .. (state and "开启" or "关闭"))
    end)
end

-- 启动LED闪烁
blink_led()

print("主程序运行中...")
]]
        
        local f = file.open("main.lua", "w")
        if f then
            f:write(main_template)
            f:close()
            print("已创建示例主程序")
            safe_execute(function() dofile("main.lua") end, "主程序")
        end
    end
end

-- 系统信息显示
local function show_system_info()
    print("\n=== 系统信息 ===")
    print("设备名称: " .. (CONFIG.DEVICE_NAME or "未设置"))
    print("芯片ID: " .. node.chipid())
    print("Flash ID: " .. node.flashid())
    print("Flash大小: " .. node.flashsize() .. " 字节")
    print("可用内存: " .. node.heap() .. " 字节")
    print("CPU频率: " .. node.getcpufreq() .. " MHz")
    print("运行时间: " .. tmr.time() .. " 秒")
    
    -- 文件系统信息
    print("\n=== 文件系统 ===")
    local total_size = 0
    for name, size in pairs(file.list()) do
        print(string.format("%-15s %6d 字节", name, size))
        total_size = total_size + size
    end
    print(string.format("总计: %d 字节", total_size))
    print("================\n")
end

-- 启动序列
print("开始系统初始化...")

-- 1. 显示系统信息
show_system_info()

-- 2. 连接WiFi
if CONFIG.WIFI_SSID and CONFIG.WIFI_SSID ~= "your_wifi_ssid" then
    connect_wifi()
end

-- 3. 延迟启动主程序
if CONFIG.AUTO_START then
    tmr.create():alarm(2000, tmr.ALARM_SINGLE, function()
        start_main()
    end)
else
    print("自动启动已禁用，手动运行 dofile('main.lua')")
end

print("系统初始化完成")
