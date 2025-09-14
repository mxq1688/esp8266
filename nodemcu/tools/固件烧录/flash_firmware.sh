#!/bin/bash

# NodeMCU 固件烧录脚本
# 支持 macOS/Linux 系统

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 esptool 是否安装
check_esptool() {
    if ! command -v esptool.py &> /dev/null; then
        print_error "esptool 未安装，请先安装: pip install esptool"
        exit 1
    fi
    print_success "esptool 已安装"
}

# 检测可用的串口
detect_ports() {
    print_info "检测可用的串口..."
    
    # macOS 串口检测
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PORTS=$(ls /dev/tty.* 2>/dev/null | grep -E "(usbserial|wchusbserial|SLAB_USBtoUART)" | head -5)
    # Linux 串口检测
    else
        PORTS=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -5)
    fi
    
    if [ -z "$PORTS" ]; then
        print_error "未检测到串口设备，请检查："
        echo "  1. NodeMCU 是否已连接"
        echo "  2. 串口驱动是否已安装"
        echo "  3. USB 线是否为数据线"
        exit 1
    fi
    
    echo "检测到的串口："
    echo "$PORTS" | nl -w2 -s'. '
}

# 选择串口
select_port() {
    detect_ports
    
    echo
    read -p "请选择串口编号 (1-$(echo "$PORTS" | wc -l)): " port_num
    
    if ! [[ "$port_num" =~ ^[0-9]+$ ]] || [ "$port_num" -lt 1 ] || [ "$port_num" -gt $(echo "$PORTS" | wc -l) ]; then
        print_error "无效的选择"
        exit 1
    fi
    
    SELECTED_PORT=$(echo "$PORTS" | sed -n "${port_num}p")
    print_success "已选择串口: $SELECTED_PORT"
}

# 检测固件文件
detect_firmware() {
    print_info "检测固件文件..."
    
    # 查找当前目录下的 .bin 文件
    FIRMWARE_FILES=$(ls *.bin 2>/dev/null)
    
    if [ -z "$FIRMWARE_FILES" ]; then
        print_error "未找到固件文件 (.bin)，请确保固件文件在当前目录"
        exit 1
    fi
    
    echo "检测到的固件文件："
    echo "$FIRMWARE_FILES" | nl -w2 -s'. '
}

# 选择固件文件
select_firmware() {
    detect_firmware
    
    echo
    read -p "请选择固件文件编号 (1-$(echo "$FIRMWARE_FILES" | wc -l)): " firmware_num
    
    if ! [[ "$firmware_num" =~ ^[0-9]+$ ]] || [ "$firmware_num" -lt 1 ] || [ "$firmware_num" -gt $(echo "$FIRMWARE_FILES" | wc -l) ]; then
        print_error "无效的选择"
        exit 1
    fi
    
    SELECTED_FIRMWARE=$(echo "$FIRMWARE_FILES" | sed -n "${firmware_num}p")
    print_success "已选择固件: $SELECTED_FIRMWARE"
}

# 获取芯片信息
get_chip_info() {
    print_info "获取芯片信息..."
    
    if esptool.py --port "$SELECTED_PORT" chip_id > /dev/null 2>&1; then
        print_success "设备连接正常"
        esptool.py --port "$SELECTED_PORT" chip_id
    else
        print_error "无法连接到设备，请检查："
        echo "  1. 串口是否正确"
        echo "  2. 设备是否正常连接"
        echo "  3. 是否有其他程序占用串口"
        exit 1
    fi
}

# 擦除固件
erase_flash() {
    print_info "擦除现有固件..."
    
    if esptool.py --port "$SELECTED_PORT" erase_flash; then
        print_success "固件擦除完成"
    else
        print_error "固件擦除失败"
        exit 1
    fi
}

# 烧录固件
flash_firmware() {
    print_info "开始烧录固件: $SELECTED_FIRMWARE"
    print_warning "请勿断开连接，烧录过程需要几分钟..."
    
    if esptool.py --port "$SELECTED_PORT" --baud 460800 write_flash --flash_size=detect 0 "$SELECTED_FIRMWARE"; then
        print_success "固件烧录完成！"
    else
        print_warning "高速烧录失败，尝试低速烧录..."
        if esptool.py --port "$SELECTED_PORT" --baud 115200 write_flash --flash_size=detect 0 "$SELECTED_FIRMWARE"; then
            print_success "固件烧录完成！"
        else
            print_error "固件烧录失败"
            exit 1
        fi
    fi
}

# 验证烧录
verify_flash() {
    print_info "验证烧录结果..."
    
    if esptool.py --port "$SELECTED_PORT" flash_id > /dev/null 2>&1; then
        print_success "烧录验证成功"
        esptool.py --port "$SELECTED_PORT" flash_id
    else
        print_warning "验证失败，但固件可能已正确烧录"
    fi
}

# 主函数
main() {
    echo "========================================"
    echo "       NodeMCU 固件烧录工具"
    echo "========================================"
    echo
    
    # 检查依赖
    check_esptool
    
    # 选择串口和固件
    select_port
    select_firmware
    
    echo
    print_info "准备烧录："
    echo "  串口: $SELECTED_PORT"
    echo "  固件: $SELECTED_FIRMWARE"
    echo
    
    read -p "确认开始烧录? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "已取消烧录"
        exit 0
    fi
    
    echo
    print_info "开始烧录流程..."
    
    # 获取芯片信息
    get_chip_info
    echo
    
    # 擦除固件
    erase_flash
    echo
    
    # 烧录固件
    flash_firmware
    echo
    
    # 验证烧录
    verify_flash
    
    echo
    print_success "========== 烧录完成 =========="
    print_info "接下来可以："
    echo "  1. 使用 ESPlorer 连接设备"
    echo "  2. 波特率设置为 115200"
    echo "  3. 按下设备上的 RST 按钮重启"
    echo "  4. 在终端中输入: print('Hello NodeMCU!')"
}

# 运行主函数
main "$@"
