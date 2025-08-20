# LED闪烁项目配置文件

# LED引脚配置
LED_PIN = 2  # GPIO2，对应NodeMCU的D4引脚

# 闪烁参数
BLINK_INTERVAL = 1.0  # 闪烁间隔时间(秒)
BLINK_DURATION = 0.5  # LED点亮持续时间(秒)

# 闪烁模式
BLINK_MODES = {
    'normal': {'interval': 1.0, 'duration': 0.5},
    'fast': {'interval': 0.5, 'duration': 0.2},
    'slow': {'interval': 2.0, 'duration': 1.0},
    'double': {'interval': 0.3, 'duration': 0.1},
}

# 默认模式
DEFAULT_MODE = 'normal'

# 调试模式
DEBUG = True

# 错误处理
MAX_RETRY_COUNT = 3
RETRY_DELAY = 1.0 