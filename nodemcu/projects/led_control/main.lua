-- LED Control Project - 主程序文件
-- 实现LED控制的核心功能
-- 作者: NodeMCU Developer
-- 版本: 1.0.0

print("Starting LED Control main program...")

-- ==================== 全局变量 ====================
local led_state = false         -- LED当前状态
local current_mode = "manual"   -- 当前模式: manual, blink, breath, rainbow
local blink_timer = nil         -- 闪烁定时器
local breath_timer = nil        -- 呼吸灯定时器
local breath_direction = 1      -- 呼吸灯方向 (1=变亮, -1=变暗)
local breath_level = 0          -- 呼吸灯当前亮度级别
local rainbow_timer = nil       -- 彩虹灯定时器
local rainbow_step = 0          -- 彩虹灯步骤

-- ==================== LED 控制模块 ====================
local LED = {}

-- 初始化LED GPIO
function LED.init()
    print("Initializing LED GPIO pins...")
    
    -- 设置LED引脚为输出模式
    gpio.mode(CONFIG.GPIO.LED_BUILTIN, gpio.OUTPUT)
    gpio.mode(CONFIG.GPIO.LED_RED, gpio.OUTPUT)
    gpio.mode(CONFIG.GPIO.LED_GREEN, gpio.OUTPUT)
    gpio.mode(CONFIG.GPIO.LED_BLUE, gpio.OUTPUT)
    
    -- 设置按钮引脚为输入模式，启用内部上拉
    gpio.mode(CONFIG.GPIO.BUTTON_1, gpio.INT, gpio.PULLUP)
    gpio.mode(CONFIG.GPIO.BUTTON_2, gpio.INT, gpio.PULLUP)
    
    -- 设置PWM (用于呼吸灯效果)
    pwm.setup(CONFIG.GPIO.LED_BUILTIN, CONFIG.LED.PWM_FREQ, 0)
    pwm.start(CONFIG.GPIO.LED_BUILTIN)
    
    -- 初始化LED状态
    LED.set_all(false)
    
    print("LED GPIO initialized successfully")
end

-- 设置单个LED状态
function LED.set(pin, state)
    if pin == CONFIG.GPIO.LED_BUILTIN then
        -- 内置LED是低电平点亮
        gpio.write(pin, state and gpio.LOW or gpio.HIGH)
    else
        -- 外部LED是高电平点亮
        gpio.write(pin, state and gpio.HIGH or gpio.LOW)
    end
end

-- 设置所有LED状态
function LED.set_all(state)
    LED.set(CONFIG.GPIO.LED_BUILTIN, state)
    LED.set(CONFIG.GPIO.LED_RED, state)
    LED.set(CONFIG.GPIO.LED_GREEN, state)
    LED.set(CONFIG.GPIO.LED_BLUE, state)
    led_state = state
end

-- 切换LED状态
function LED.toggle()
    led_state = not led_state
    LED.set_all(led_state)
    print("LED toggled:", led_state and "ON" or "OFF")
end

-- 设置LED亮度 (PWM)
function LED.set_brightness(pin, brightness)
    -- brightness: 0-100
    local duty = math.floor(brightness * CONFIG.LED.PWM_RESOLUTION / 100)
    pwm.setduty(pin, duty)
end

-- ==================== LED 效果模式 ====================

-- 停止所有定时器
function LED.stop_all_timers()
    if blink_timer then blink_timer:stop() blink_timer = nil end
    if breath_timer then breath_timer:stop() breath_timer = nil end
    if rainbow_timer then rainbow_timer:stop() rainbow_timer = nil end
end

-- 闪烁模式
function LED.start_blink(speed)
    LED.stop_all_timers()
    current_mode = "blink"
    
    speed = speed or "NORMAL"
    local interval = CONFIG.LED.BLINK_MODES[speed] or CONFIG.LED.BLINK_MODES.NORMAL
    
    print("Starting blink mode, speed:", speed, "interval:", interval)
    
    blink_timer = tmr.create()
    blink_timer:alarm(interval, tmr.ALARM_AUTO, function()
        LED.toggle()
    end)
end

-- 呼吸灯模式
function LED.start_breath()
    LED.stop_all_timers()
    current_mode = "breath"
    breath_level = 0
    breath_direction = 1
    
    print("Starting breath mode")
    
    breath_timer = tmr.create()
    breath_timer:alarm(CONFIG.LED.BREATH_SPEED, tmr.ALARM_AUTO, function()
        -- 计算亮度
        local brightness = math.floor(breath_level * 100 / CONFIG.LED.BREATH_STEPS)
        LED.set_brightness(CONFIG.GPIO.LED_BUILTIN, brightness)
        
        -- 更新亮度级别
        breath_level = breath_level + breath_direction
        
        -- 改变方向
        if breath_level >= CONFIG.LED.BREATH_STEPS then
            breath_direction = -1
        elseif breath_level <= 0 then
            breath_direction = 1
        end
    end)
end

-- 彩虹灯模式 (RGB LED)
function LED.start_rainbow()
    LED.stop_all_timers()
    current_mode = "rainbow"
    rainbow_step = 0
    
    print("Starting rainbow mode")
    
    rainbow_timer = tmr.create()
    rainbow_timer:alarm(100, tmr.ALARM_AUTO, function()
        -- 简单的RGB循环
        local r = math.sin(rainbow_step * 0.1) > 0
        local g = math.sin(rainbow_step * 0.1 + 2) > 0
        local b = math.sin(rainbow_step * 0.1 + 4) > 0
        
        LED.set(CONFIG.GPIO.LED_RED, r)
        LED.set(CONFIG.GPIO.LED_GREEN, g)
        LED.set(CONFIG.GPIO.LED_BLUE, b)
        
        rainbow_step = rainbow_step + 1
        if rainbow_step > 60 then rainbow_step = 0 end
    end)
end

-- 手动模式
function LED.set_manual_mode()
    LED.stop_all_timers()
    current_mode = "manual"
    print("Manual mode activated")
end

-- ==================== 按钮中断处理 ====================
local button_pressed = false

-- 按钮1中断处理 (模式切换)
gpio.trig(CONFIG.GPIO.BUTTON_1, "down", function(level, when)
    if not button_pressed then
        button_pressed = true
        print("Button 1 pressed - Mode switch")
        
        -- 循环切换模式
        if current_mode == "manual" then
            LED.start_blink("NORMAL")
        elseif current_mode == "blink" then
            LED.start_breath()
        elseif current_mode == "breath" then
            LED.start_rainbow()
        else
            LED.set_manual_mode()
            LED.set_all(false)
        end
        
        -- 防抖动
        tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
            button_pressed = false
        end)
    end
end)

-- 按钮2中断处理 (开关控制)
gpio.trig(CONFIG.GPIO.BUTTON_2, "down", function(level, when)
    if not button_pressed then
        button_pressed = true
        print("Button 2 pressed - Toggle LED")
        
        if current_mode == "manual" then
            LED.toggle()
        else
            -- 在其他模式下，切换到手动模式
            LED.set_manual_mode()
            LED.toggle()
        end
        
        -- 防抖动
        tmr.create():alarm(500, tmr.ALARM_SINGLE, function()
            button_pressed = false
        end)
    end
end)

-- ==================== 串口命令处理 ====================
local COMMANDS = {}

-- 帮助命令
function COMMANDS.help()
    print("=== LED Control Commands ===")
    print("Basic Control:")
    print("  led_on        - Turn on LED")
    print("  led_off       - Turn off LED") 
    print("  led_toggle    - Toggle LED state")
    print("")
    print("Effect Modes:")
    print("  led_blink [speed]  - Blink mode (SLOW/NORMAL/FAST/RAPID)")
    print("  led_breath    - Breathing effect")
    print("  led_rainbow   - Rainbow effect")
    print("  led_manual    - Manual control mode")
    print("")
    print("Brightness:")
    print("  led_brightness <0-100>  - Set LED brightness")
    print("")
    print("System:")
    print("  status        - Show system status")
    print("  restart       - Restart device")
    print("  memory        - Show memory usage")
    print("  gpio_status   - Show GPIO status")
    print("=============================")
end

-- LED控制命令
function COMMANDS.led_on()
    LED.set_manual_mode()
    LED.set_all(true)
    print("LED turned ON")
end

function COMMANDS.led_off()
    LED.set_manual_mode()
    LED.set_all(false)
    print("LED turned OFF")
end

function COMMANDS.led_toggle()
    if current_mode ~= "manual" then
        LED.set_manual_mode()
    end
    LED.toggle()
end

function COMMANDS.led_blink(speed)
    LED.start_blink(speed)
end

function COMMANDS.led_breath()
    LED.start_breath()
end

function COMMANDS.led_rainbow()
    LED.start_rainbow()
end

function COMMANDS.led_manual()
    LED.set_manual_mode()
end

function COMMANDS.led_brightness(level)
    level = tonumber(level) or 50
    if level < 0 then level = 0 end
    if level > 100 then level = 100 end
    
    LED.set_brightness(CONFIG.GPIO.LED_BUILTIN, level)
    print("LED brightness set to:", level .. "%")
end

-- 系统命令
function COMMANDS.status()
    print("=== System Status ===")
    print("Project:", CONFIG.PROJECT_NAME)
    print("Version:", CONFIG.VERSION)
    print("Current Mode:", current_mode)
    print("LED State:", led_state and "ON" or "OFF")
    print("Free Memory:", node.heap(), "bytes")
    print("Uptime:", tmr.time(), "seconds")
    if wifi.sta.getip() then
        print("WiFi IP:", wifi.sta.getip())
    else
        print("WiFi: Not connected")
    end
    print("====================")
end

function COMMANDS.restart()
    print("Restarting device in 2 seconds...")
    LED.stop_all_timers()
    tmr.create():alarm(2000, tmr.ALARM_SINGLE, function()
        node.restart()
    end)
end

function COMMANDS.memory()
    print("Free heap memory:", node.heap(), "bytes")
    collectgarbage()
    print("After GC:", node.heap(), "bytes")
end

function COMMANDS.gpio_status()
    print("=== GPIO Status ===")
    print("LED_BUILTIN (pin " .. CONFIG.GPIO.LED_BUILTIN .. "):", gpio.read(CONFIG.GPIO.LED_BUILTIN))
    print("LED_RED (pin " .. CONFIG.GPIO.LED_RED .. "):", gpio.read(CONFIG.GPIO.LED_RED))
    print("LED_GREEN (pin " .. CONFIG.GPIO.LED_GREEN .. "):", gpio.read(CONFIG.GPIO.LED_GREEN))
    print("LED_BLUE (pin " .. CONFIG.GPIO.LED_BLUE .. "):", gpio.read(CONFIG.GPIO.LED_BLUE))
    print("BUTTON_1 (pin " .. CONFIG.GPIO.BUTTON_1 .. "):", gpio.read(CONFIG.GPIO.BUTTON_1))
    print("BUTTON_2 (pin " .. CONFIG.GPIO.BUTTON_2 .. "):", gpio.read(CONFIG.GPIO.BUTTON_2))
    print("==================")
end

-- ==================== 串口输入处理 ====================
uart.on("data", "\r", function(data)
    local command = string.gsub(data, "\r", "")
    command = string.gsub(command, "\n", "")
    
    if command == "" then return end
    
    -- 解析命令和参数
    local parts = {}
    for part in string.gmatch(command, "%S+") do
        table.insert(parts, part)
    end
    
    local cmd = parts[1]
    local args = {}
    for i = 2, #parts do
        table.insert(args, parts[i])
    end
    
    if CONFIG.DEBUG.LOG_COMMANDS then
        print("Command received:", cmd, "args:", table.concat(args, " "))
    end
    
    -- 执行命令
    if COMMANDS[cmd] then
        COMMANDS[cmd](unpack(args))
    else
        print("Unknown command:", cmd)
        print("Type 'help' for available commands")
    end
end)

-- ==================== WiFi 管理 ====================
local WiFi = {}

function WiFi.connect()
    if not CONFIG.WIFI.AUTO_CONNECT then
        return
    end
    
    print("Connecting to WiFi:", CONFIG.WIFI.SSID)
    
    wifi.setmode(wifi.STATION)
    wifi.sta.config(CONFIG.WIFI.SSID, CONFIG.WIFI.PASSWORD)
    
    -- WiFi连接状态检查
    local wifi_timer = tmr.create()
    local retry_count = 0
    
    wifi_timer:alarm(2000, tmr.ALARM_AUTO, function()
        local ip = wifi.sta.getip()
        if ip then
            print("WiFi connected! IP:", ip)
            wifi_timer:stop()
        else
            retry_count = retry_count + 1
            print("Connecting to WiFi... (" .. retry_count .. "/" .. CONFIG.WIFI.RETRY_COUNT .. ")")
            
            if retry_count >= CONFIG.WIFI.RETRY_COUNT then
                print("WiFi connection failed after", CONFIG.WIFI.RETRY_COUNT, "attempts")
                wifi_timer:stop()
            end
        end
    end)
end

-- ==================== 心跳监控 ====================
local heartbeat_timer = tmr.create()
heartbeat_timer:alarm(CONFIG.TIMERS.HEARTBEAT_INTERVAL, tmr.ALARM_AUTO, function()
    if CONFIG.DEBUG.PRINT_MEMORY then
        print("Heartbeat - Free memory:", node.heap(), "bytes")
    end
    
    -- 内存清理
    if node.heap() < 10000 then
        collectgarbage()
        print("Low memory detected, garbage collection performed")
    end
end)

-- ==================== 主程序初始化 ====================
function main()
    print("Initializing LED Control System...")
    
    -- 初始化LED
    LED.init()
    
    -- 连接WiFi
    WiFi.connect()
    
    -- 显示欢迎信息
    print("=== LED Control System Ready ===")
    print("Current mode:", current_mode)
    print("Type 'help' for available commands")
    print("Press Button 1 to cycle modes")
    print("Press Button 2 to toggle LED")
    print("===============================")
    
    -- 启动心跳监控
    print("Heartbeat monitor started")
    
    -- 初始LED状态指示
    LED.set_all(CONFIG.LED.DEFAULT_STATE)
end

-- 启动主程序
main()

print("LED Control main program loaded successfully")
