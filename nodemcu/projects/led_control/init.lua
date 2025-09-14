-- LED Control Project - 初始化文件
-- 系统启动时自动执行
-- 作者: NodeMCU Developer
-- 版本: 1.0.0

print("=== LED Control Project Starting ===")
print("Version: 1.0.0")
print("Free heap:", node.heap())

-- 延时启动，避免启动时的干扰
tmr.create():alarm(3000, tmr.ALARM_SINGLE, function()
    print("Loading configuration...")
    
    -- 检查配置文件是否存在
    if file.exists("config.lua") then
        dofile("config.lua")
        print("Configuration loaded successfully")
    else
        print("ERROR: config.lua not found!")
        return
    end
    
    -- 检查主程序文件是否存在
    if file.exists("main.lua") then
        print("Starting main program...")
        dofile("main.lua")
    else
        print("ERROR: main.lua not found!")
        return
    end
    
    print("=== LED Control Project Ready ===")
    print("Type 'help' for available commands")
end)

-- 错误处理函数
function handle_error(err)
    print("ERROR:", err)
    print("System will restart in 10 seconds...")
    tmr.create():alarm(10000, tmr.ALARM_SINGLE, function()
        node.restart()
    end)
end

-- 设置全局错误处理
node.setcpufreq(node.CPU160MHZ) -- 设置CPU频率为160MHz
collectgarbage() -- 清理内存
