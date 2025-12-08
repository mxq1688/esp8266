-- NodeMCU 主程序文件
-- 项目的核心逻辑代码

print("主程序启动...")

-- 引入配置
if not CONFIG then
    print("错误: 配置未加载")
    return
end

-- GPIO配置
local LED_PIN = 4        -- GPIO4 (D2)
local BUTTON_PIN = 5     -- GPIO5 (D1)

-- 初始化GPIO
gpio.mode(LED_PIN, gpio.OUTPUT)
gpio.mode(BUTTON_PIN, gpio.INPUT, gpio.PULLUP)
gpio.write(LED_PIN, gpio.LOW)

-- 状态变量
local led_state = false
local app_running = true

-- LED控制函数
local function led_on()
    gpio.write(LED_PIN, gpio.HIGH)
    led_state = true
    if CONFIG.DEBUG_MODE then
        print("LED开启")
    end
end

local function led_off()
    gpio.write(LED_PIN, gpio.LOW)
    led_state = false
    if CONFIG.DEBUG_MODE then
        print("LED关闭")
    end
end

local function led_toggle()
    led_state = not led_state
    gpio.write(LED_PIN, led_state and gpio.HIGH or gpio.LOW)
    if CONFIG.DEBUG_MODE then
        print("LED切换: " .. (led_state and "开启" or "关闭"))
    end
end

-- 按钮中断处理
local last_press_time = 0
local function button_handler(level)
    local current_time = tmr.now()
    
    -- 防抖动处理 (200ms)
    if current_time - last_press_time < 200000 then
        return
    end
    last_press_time = current_time
    
    if level == gpio.LOW then
        print("按钮按下")
        led_toggle()
    end
end

-- 设置按钮中断
gpio.trig(BUTTON_PIN, "down", button_handler)

-- 心跳LED闪烁
local function start_heartbeat()
    local heartbeat_timer = tmr.create()
    heartbeat_timer:alarm(2000, tmr.ALARM_AUTO, function()
        if app_running then
            led_on()
            tmr.create():alarm(100, tmr.ALARM_SINGLE, function()
                led_off()
            end)
        end
    end)
    
    if CONFIG.DEBUG_MODE then
        print("心跳LED启动")
    end
end

-- 状态监控
local function start_monitoring()
    local monitor_timer = tmr.create()
    monitor_timer:alarm(30000, tmr.ALARM_AUTO, function()
        if CONFIG.DEBUG_MODE then
            print("=== 状态监控 ===")
            print("运行时间: " .. tmr.time() .. " 秒")
            print("可用内存: " .. node.heap() .. " 字节")
            print("LED状态: " .. (led_state and "开启" or "关闭"))
            print("按钮状态: " .. (gpio.read(BUTTON_PIN) == gpio.LOW and "按下" or "释放"))
            if wifi.sta.getip() then
                print("WiFi IP: " .. wifi.sta.getip())
                print("信号强度: " .. wifi.sta.getrssi() .. " dBm")
            end
            print("===============")
        end
    end)
end

-- WiFi连接成功回调函数
function on_wifi_connected()
    print("WiFi连接成功，启动网络功能...")
    
    -- 在这里添加需要网络连接的功能
    -- 例如: Web服务器、MQTT客户端等
    
    if CONFIG.DEBUG_MODE then
        print("网络功能已启动")
    end
end

-- 应用程序关闭
local function shutdown()
    print("应用程序关闭中...")
    app_running = false
    led_off()
    print("应用程序已关闭")
end

-- 串口命令处理
uart.on("data", "\r", function(data)
    local cmd = string.gsub(data, "[\r\n]", "")
    
    if cmd == "status" then
        print("=== 设备状态 ===")
        print("设备名称: " .. CONFIG.DEVICE_NAME)
        print("运行状态: " .. (app_running and "运行中" or "已停止"))
        print("LED状态: " .. (led_state and "开启" or "关闭"))
        print("内存使用: " .. node.heap() .. " 字节")
        print("运行时间: " .. tmr.time() .. " 秒")
        
    elseif cmd == "restart" then
        print("重启设备...")
        node.restart()
        
    elseif cmd == "led_on" then
        led_on()
        
    elseif cmd == "led_off" then
        led_off()
        
    elseif cmd == "led_toggle" then
        led_toggle()
        
    elseif cmd == "shutdown" then
        shutdown()
        
    elseif cmd == "help" then
        print("可用命令:")
        print("  status    - 显示设备状态")
        print("  restart   - 重启设备")
        print("  led_on    - 开启LED")
        print("  led_off   - 关闭LED")
        print("  led_toggle - 切换LED")
        print("  shutdown  - 关闭应用")
        print("  help      - 显示帮助")
        
    elseif cmd ~= "" then
        print("未知命令: " .. cmd .. " (输入 help 查看帮助)")
    end
end, 0)

-- 启动应用功能
print("启动应用功能...")

-- 1. 启动心跳LED
start_heartbeat()

-- 2. 启动状态监控
if CONFIG.DEBUG_MODE then
    start_monitoring()
end

-- 3. 显示启动完成信息
print("主程序启动完成!")
print("设备名称: " .. CONFIG.DEVICE_NAME)
print("输入 'help' 查看可用命令")

-- 欢迎LED闪烁
led_on()
tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
    led_off()
    tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
        led_on()
        tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
            led_off()
        end)
    end)
end)
