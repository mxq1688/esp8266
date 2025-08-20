# MicroPython ESP8266 LED项目

## 快速开始

### 1. 环境准备
- ✅ ESP8266设备已连接 (`/dev/tty.usbserial-110`)
- ✅ MicroPython固件已烧写
- ✅ LED项目代码已准备就绪

### 2. 硬件连接
```
ESP8266 NodeMCU
┌─────────────┐
│             │
│  GPIO2 (D4) ├───[220Ω]───[LED+]───[LED-]───GND
│             │
└─────────────┘
```

### 3. 运行项目

#### 方法1: 使用Thonny IDE (推荐)
1. 下载Thonny IDE: https://thonny.org/
2. 连接ESP8266: 选择MicroPython (ESP8266)，端口 `/dev/tty.usbserial-110`
3. 上传文件到设备:
   - `led_blink/src/config.py`
   - `led_blink/src/led_control.py`
   - `led_blink/src/simple_led.py`
   - `led_blink/src/main.py`
4. 运行: `exec(open('main.py').read())`

#### 方法2: 命令行工具
```bash
# 安装ampy
pip install adafruit-ampy

# 上传文件
ampy --port /dev/tty.usbserial-110 put led_blink/src/config.py
ampy --port /dev/tty.usbserial-110 put led_blink/src/led_control.py
ampy --port /dev/tty.usbserial-110 put led_blink/src/simple_led.py
ampy --port /dev/tty.usbserial-110 put led_blink/src/main.py

# 运行程序
ampy --port /dev/tty.usbserial-110 run led_blink/src/main.py
```

## 项目结构
```
microPython/
├── README.md              # 说明文档
├── 操作指南.md            # 详细操作指南
├── 烧写脚本.sh            # 固件烧写脚本
├── esp8266-firmware.bin   # 固件文件
└── led_blink/            # LED项目
    ├── README.md         # 项目说明
    └── src/              # 源代码
        ├── main.py       # 主程序
        ├── led_control.py # LED控制模块
        ├── config.py     # 配置文件
        └── simple_led.py # 简单示例
```

## 程序功能
- 基本开关控制
- 状态切换
- 单次闪烁
- 连续闪烁
- 预设模式 (正常/快速/慢速/双闪)
- 双闪模式
- 状态查询
- 无限闪烁

## 常用命令
```python
# 基本控制
led.on()      # 点亮LED
led.off()     # 熄灭LED
led.toggle()  # 切换状态

# 闪烁控制
led.blink_once(0.5)           # 闪烁一次
led.blink(count=5)            # 闪烁5次
led.blink_mode('fast', 3)     # 快速闪烁3次
```

## 故障排除
- **LED不亮**: 检查硬件连接和LED极性
- **连接失败**: 检查USB连接和设备端口
- **程序错误**: 确认文件完整上传

## 下一步
1. 运行LED闪烁程序
2. 修改闪烁参数
3. 添加更多功能 