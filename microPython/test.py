#!/usr/bin/env python3
"""
ESP8266 LED快速测试脚本
用于验证设备连接和LED功能
"""

import machine
import time

def test_led():
    """测试LED基本功能"""
    print("=== ESP8266 LED测试 ===")
    
    # 初始化LED
    led = machine.Pin(2, machine.Pin.OUT)
    print("LED初始化完成 (GPIO2)")
    
    # 测试1: 基本开关
    print("\n1. 基本开关测试")
    led.value(0)  # 点亮
    print("LED已点亮")
    time.sleep(1)
    
    led.value(1)  # 熄灭
    print("LED已熄灭")
    time.sleep(1)
    
    # 测试2: 闪烁测试
    print("\n2. 闪烁测试 (5次)")
    for i in range(5):
        print(f"闪烁 {i+1}/5")
        led.value(0)  # 点亮
        time.sleep(0.3)
        led.value(1)  # 熄灭
        time.sleep(0.3)
    
    # 测试3: 快速闪烁
    print("\n3. 快速闪烁测试 (10次)")
    for i in range(10):
        led.value(0)
        time.sleep(0.1)
        led.value(1)
        time.sleep(0.1)
    
    print("\n✅ LED测试完成")
    
    # 最终状态
    led.value(1)  # 确保LED熄灭
    print("LED已熄灭")

def test_system():
    """测试系统信息"""
    print("\n=== 系统信息 ===")
    print(f"频率: {machine.freq()} Hz")
    print(f"内存: {machine.mem_free()} bytes")
    
    # 测试时间
    import time
    print(f"时间戳: {time.time()}")

if __name__ == "__main__":
    try:
        test_led()
        test_system()
    except KeyboardInterrupt:
        print("\n测试被用户中断")
    except Exception as e:
        print(f"\n❌ 测试失败: {e}")