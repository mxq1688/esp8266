# NodeMCU 开发环境搭建指南

## 📋 完整安装清单

### ☐ 1. 安装 Python 和 esptool

**安装 Python**
- 下载地址: https://www.python.org/downloads/
- 选择 Python 3.7+ 版本
- 安装时勾选 "Add Python to PATH"

**安装 esptool**
```bash
pip install esptool
```

**验证安装**
```bash
esptool.py version
```

### ☐ 2. 下载并安装串口驱动

**CH340/CH341 驱动 (常见)**
- Windows: http://www.wch.cn/downloads/CH341SER_EXE.html
- macOS: `brew install --cask wch-ch34x-usb-serial-driver`
- Linux: 通常已内置，无需安装

**CP2102 驱动**
- 官方下载: https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers
- macOS: `brew install --cask silicon-labs-vcp-driver`

**验证驱动**
- Windows: 设备管理器查看端口
- macOS/Linux: `ls /dev/tty*` 查看设备

### ☐ 3. 下载 ESPlorer IDE

**下载地址**
- 官方: https://github.com/4refr0nt/ESPlorer/releases
- 下载 `ESPlorer.zip` 最新版本

**安装 Java (ESPlorer 依赖)**
- 下载: https://www.java.com/download/
- 或使用包管理器: `brew install java` (macOS)

**启动 ESPlorer**
```bash
java -jar ESPlorer.jar
```

### ☐ 4. 获取 NodeMCU 固件文件

**方式一: 官方预编译固件**
- 下载地址: https://nodemcu.readthedocs.io/en/release/
- 选择对应版本下载

**方式二: 自定义编译固件 (推荐)**
- 在线编译: https://nodemcu-build.com/
- 选择需要的模块
- 选择 Float 版本 (支持浮点数)
- 等待编译完成并下载

**推荐模块选择**
- file, gpio, net, node, timer, uart, wifi
- adc, dht, ds18b20 (传感器相关)
- http, mqtt (网络通信)

### ☐ 5. 连接设备并烧录固件

**连接设备**
1. 使用 USB 数据线连接 NodeMCU 到电脑
2. 确认设备被识别 (设备管理器/终端)

**烧录步骤**
```bash
# 1. 擦除现有固件
esptool.py --port COM3 erase_flash
# Linux/macOS 使用: --port /dev/ttyUSB0

# 2. 烧录新固件
esptool.py --port COM3 write_flash 0x00000 nodemcu-firmware.bin

# 3. 验证烧录
esptool.py --port COM3 flash_id
```

**常见端口**
- Windows: `COM3`, `COM4`, `COM5`...
- macOS: `/dev/tty.usbserial-*`, `/dev/tty.wchusbserial*`
- Linux: `/dev/ttyUSB0`, `/dev/ttyACM0`

### ☐ 6. 配置 ESPlorer 连接设备

**启动 ESPlorer**
```bash
java -jar ESPlorer.jar
```

**连接配置**
1. 选择正确的串口 (COM3 或 /dev/ttyUSB0)
2. 设置波特率: `115200`
3. 点击 "Open" 连接设备
4. 按下 NodeMCU 上的 RST 按钮
5. 应该看到启动信息

**测试连接**
在命令行输入:
```lua
print("Hello NodeMCU!")
```

**常用 ESPlorer 功能**
- 左侧: 文件管理器 (上传/下载 Lua 脚本)
- 右上: 代码编辑器
- 右下: 串口终端
- 工具栏: 上传、运行、重启等按钮