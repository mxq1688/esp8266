# LED闪烁项目

## 项目概述
使用MicroPython控制ESP8266开发板上的LED，实现LED的闪烁效果。

## 硬件要求
- ESP8266开发板 (NodeMCU、Wemos D1 Mini等)
- 内置LED (GPIO2) 或外接LED模块
- USB数据线

## 硬件连接
### 内置LED (推荐)
- NodeMCU: GPIO2 (D4)
- Wemos D1 Mini: GPIO2 (D4)
- 无需额外连接

### 外接LED
```
ESP8266    LED
GPIO2 ---- 阳极(+)
GND   ---- 阴极(-)
```

## 项目结构
```
led_blink/
├── README.md              # 项目说明
└── src/                   # 源代码
    ├── main.py           # 主程序
    ├── led_control.py    # LED控制模块
    ├── config.py         # 配置文件
    └── simple_led.py     # 简单示例
```

## 快速开始

### 1. 上传代码
将`src`目录下的文件上传到ESP8266开发板。

### 2. 运行程序
```python
# 运行完整演示
exec(open('main.py').read())

# 或运行简单示例
exec(open('simple_led.py').read())
```

### 3. 基本使用
```python
from led_control import led

# 点亮LED
led.on()

# 闪烁5次
led.blink(count=5)

# 使用预设模式
led.blink_mode('fast', count=10)
```

## 功能特性
- LED基本控制 (点亮/熄灭/切换)
- 多种闪烁模式 (单次/连续/预设模式/双闪)
- 可调节闪烁频率和持续时间
- 状态查询和错误处理

## 使用说明
1. 连接ESP8266到电脑
2. 使用Thonny IDE或其他工具上传代码
3. 运行程序观察LED闪烁效果
4. 修改配置文件调整闪烁参数 