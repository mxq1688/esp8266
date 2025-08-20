"""
LED闪烁项目主程序
演示LED的各种控制功能
"""

import time
from led_control import led
from config import *

def main():
    """主函数"""
    print("=== LED闪烁项目启动 ===")
    print(f"LED引脚: GPIO{LED_PIN}")
    print(f"默认模式: {DEFAULT_MODE}")
    print("按Ctrl+C停止程序")
    print()
    
    try:
        # 演示1: 基本开关控制
        print("1. 基本开关控制演示")
        led.on()
        time.sleep(1)
        led.off()
        time.sleep(1)
        print("基本开关控制完成")
        print()
        
        # 演示2: 切换状态
        print("2. LED状态切换演示")
        for i in range(5):
            led.toggle()
            time.sleep(0.5)
        print("状态切换演示完成")
        print()
        
        # 演示3: 单次闪烁
        print("3. 单次闪烁演示")
        led.blink_once(0.5)
        time.sleep(1)
        print("单次闪烁演示完成")
        print()
        
        # 演示4: 连续闪烁 (5次)
        print("4. 连续闪烁演示 (5次)")
        led.blink(interval=0.8, duration=0.3, count=5)
        print("连续闪烁演示完成")
        print()
        
        # 演示5: 预设模式闪烁
        print("5. 预设模式闪烁演示")
        modes = ['normal', 'fast', 'slow', 'double']
        for mode in modes:
            print(f"  模式: {mode}")
            led.blink_mode(mode, count=3)
            time.sleep(1)
        print("预设模式演示完成")
        print()
        
        # 演示6: 双闪模式
        print("6. 双闪模式演示 (3次)")
        led.double_blink(count=3)
        print("双闪模式演示完成")
        print()
        
        # 演示7: 状态查询
        print("7. LED状态查询")
        status = led.get_status()
        print(f"  引脚: GPIO{status['pin']}")
        print(f"  状态: {'点亮' if status['is_on'] else '熄灭'}")
        print(f"  电平: {status['value']}")
        print("状态查询完成")
        print()
        
        # 演示8: 无限闪烁 (可中断)
        print("8. 无限闪烁演示 (按Ctrl+C停止)")
        print("开始无限闪烁...")
        led.blink()  # 无限闪烁
        
    except KeyboardInterrupt:
        print("\n程序被用户中断")
    except Exception as e:
        print(f"程序运行出错: {e}")
    finally:
        # 清理资源
        print("清理资源...")
        led.cleanup()
        print("=== 程序结束 ===")

def demo_simple():
    """简单演示函数 - 适合初学者"""
    print("简单LED闪烁演示")
    print("LED将闪烁10次")
    
    for i in range(10):
        print(f"闪烁 {i+1}/10")
        led.on()
        time.sleep(0.5)
        led.off()
        time.sleep(0.5)
    
    print("演示完成")

def demo_interactive():
    """交互式演示函数"""
    print("交互式LED控制")
    print("输入命令控制LED:")
    print("  on    - 点亮LED")
    print("  off   - 熄灭LED")
    print("  blink - 闪烁一次")
    print("  quit  - 退出")
    
    while True:
        try:
            command = input("请输入命令: ").strip().lower()
            
            if command == 'on':
                led.on()
                print("LED已点亮")
            elif command == 'off':
                led.off()
                print("LED已熄灭")
            elif command == 'blink':
                led.blink_once()
            elif command == 'quit':
                break
            else:
                print("未知命令，请重试")
                
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"错误: {e}")
    
    print("交互式演示结束")

if __name__ == "__main__":
    # 运行主演示
    main()
    
    # 如果需要简单演示，取消下面的注释
    # demo_simple()
    
    # 如果需要交互式演示，取消下面的注释
    # demo_interactive() 