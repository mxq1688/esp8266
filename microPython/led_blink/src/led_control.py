"""
LED控制模块
提供LED闪烁、开关等基本功能
"""

import machine
import time
from config import *

class LEDController:
    """LED控制器类"""
    
    def __init__(self, pin=LED_PIN):
        """
        初始化LED控制器
        
        Args:
            pin (int): LED连接的GPIO引脚号
        """
        self.pin = pin
        self.led = machine.Pin(pin, machine.Pin.OUT)
        self.is_on = False
        self.blink_task = None
        
        if DEBUG:
            print(f"LED控制器初始化完成，引脚: GPIO{pin}")
    
    def on(self):
        """点亮LED"""
        try:
            self.led.value(0)  # ESP8266的LED通常是低电平点亮
            self.is_on = True
            if DEBUG:
                print("LED已点亮")
        except Exception as e:
            if DEBUG:
                print(f"点亮LED时出错: {e}")
    
    def off(self):
        """熄灭LED"""
        try:
            self.led.value(1)  # 高电平熄灭
            self.is_on = False
            if DEBUG:
                print("LED已熄灭")
        except Exception as e:
            if DEBUG:
                print(f"熄灭LED时出错: {e}")
    
    def toggle(self):
        """切换LED状态"""
        if self.is_on:
            self.off()
        else:
            self.on()
    
    def blink_once(self, duration=BLINK_DURATION):
        """
        闪烁一次
        
        Args:
            duration (float): 点亮持续时间(秒)
        """
        try:
            self.on()
            time.sleep(duration)
            self.off()
            if DEBUG:
                print(f"LED闪烁一次，持续时间: {duration}秒")
        except Exception as e:
            if DEBUG:
                print(f"LED闪烁时出错: {e}")
    
    def blink(self, interval=BLINK_INTERVAL, duration=BLINK_DURATION, count=None):
        """
        连续闪烁
        
        Args:
            interval (float): 闪烁间隔时间(秒)
            duration (float): 点亮持续时间(秒)
            count (int): 闪烁次数，None表示无限闪烁
        """
        try:
            if count is None:
                # 无限闪烁
                while True:
                    self.blink_once(duration)
                    time.sleep(interval - duration)
            else:
                # 指定次数闪烁
                for i in range(count):
                    self.blink_once(duration)
                    if i < count - 1:  # 最后一次不需要等待
                        time.sleep(interval - duration)
                        
            if DEBUG:
                print(f"LED闪烁完成，次数: {count if count else '无限'}")
        except KeyboardInterrupt:
            if DEBUG:
                print("LED闪烁被中断")
        except Exception as e:
            if DEBUG:
                print(f"LED连续闪烁时出错: {e}")
    
    def blink_mode(self, mode_name=DEFAULT_MODE, count=None):
        """
        使用预设模式闪烁
        
        Args:
            mode_name (str): 模式名称 ('normal', 'fast', 'slow', 'double')
            count (int): 闪烁次数
        """
        if mode_name not in BLINK_MODES:
            if DEBUG:
                print(f"未知模式: {mode_name}，使用默认模式")
            mode_name = DEFAULT_MODE
        
        mode = BLINK_MODES[mode_name]
        interval = mode['interval']
        duration = mode['duration']
        
        if DEBUG:
            print(f"使用模式: {mode_name}, 间隔: {interval}s, 持续时间: {duration}s")
        
        self.blink(interval, duration, count)
    
    def double_blink(self, count=None):
        """
        双闪模式 (快速闪烁两次)
        
        Args:
            count (int): 双闪次数
        """
        try:
            if count is None:
                while True:
                    self._double_blink_once()
                    time.sleep(1.0)
            else:
                for i in range(count):
                    self._double_blink_once()
                    if i < count - 1:
                        time.sleep(1.0)
                        
            if DEBUG:
                print(f"双闪完成，次数: {count if count else '无限'}")
        except KeyboardInterrupt:
            if DEBUG:
                print("双闪被中断")
        except Exception as e:
            if DEBUG:
                print(f"双闪时出错: {e}")
    
    def _double_blink_once(self):
        """执行一次双闪"""
        self.blink_once(0.1)
        time.sleep(0.1)
        self.blink_once(0.1)
    
    def get_status(self):
        """获取LED状态"""
        return {
            'pin': self.pin,
            'is_on': self.is_on,
            'value': self.led.value()
        }
    
    def cleanup(self):
        """清理资源"""
        try:
            self.off()
            if DEBUG:
                print("LED控制器已清理")
        except Exception as e:
            if DEBUG:
                print(f"清理LED控制器时出错: {e}")

# 创建全局LED控制器实例
led = LEDController() 