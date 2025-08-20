"""
简单LED控制示例
适合初学者快速上手的LED控制代码
"""

import machine
import time

# 配置LED引脚 (GPIO2，对应NodeMCU的D4)
led_pin = 2
led = machine.Pin(led_pin, machine.Pin.OUT)

def led_on():
    """点亮LED"""
    led.value(0)  # 低电平点亮
    print("LED已点亮")

def led_off():
    """熄灭LED"""
    led.value(1)  # 高电平熄灭
    print("LED已熄灭")

def led_toggle():
    """切换LED状态"""
    current_value = led.value()
    led.value(not current_value)
    print("LED状态已切换")

def led_blink(times=5, interval=1.0):
    """
    闪烁LED
    
    Args:
        times (int): 闪烁次数
        interval (float): 闪烁间隔(秒)
    """
    print(f"LED将闪烁{times}次，间隔{interval}秒")
    
    for i in range(times):
        print(f"闪烁 {i+1}/{times}")
        led_on()
        time.sleep(interval/2)
        led_off()
        time.sleep(interval/2)
    
    print("闪烁完成")

def led_pattern():
    """LED花样闪烁"""
    print("开始LED花样闪烁")
    
    # 快速闪烁
    print("快速闪烁...")
    for i in range(10):
        led_toggle()
        time.sleep(0.1)
    
    # 慢速闪烁
    print("慢速闪烁...")
    for i in range(5):
        led_toggle()
        time.sleep(0.5)
    
    # 双闪
    print("双闪模式...")
    for i in range(3):
        led_on()
        time.sleep(0.1)
        led_off()
        time.sleep(0.1)
        led_on()
        time.sleep(0.1)
        led_off()
        time.sleep(0.5)
    
    print("花样闪烁完成")

# 主程序
if __name__ == "__main__":
    print("=== 简单LED控制示例 ===")
    print("LED引脚: GPIO2")
    print()
    
    # 基本控制演示
    print("1. 基本控制演示")
    led_on()
    time.sleep(1)
    led_off()
    time.sleep(1)
    print()
    
    # 切换演示
    print("2. 状态切换演示")
    for i in range(5):
        led_toggle()
        time.sleep(0.5)
    print()
    
    # 闪烁演示
    print("3. 闪烁演示")
    led_blink(5, 0.8)
    print()
    
    # 花样演示
    print("4. 花样闪烁演示")
    led_pattern()
    print()
    
    print("=== 演示完成 ===") 