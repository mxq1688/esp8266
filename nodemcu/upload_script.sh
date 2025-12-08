#!/bin/bash

# NodeMCU Lua代码上传脚本
# 使用 NodeMCU-Tool 按正确顺序上传文件

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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

# 检查NodeMCU-Tool是否安装
check_tool() {
    if ! command -v nodemcu-tool &> /dev/null; then
        print_error "NodeMCU-Tool 未安装!"
        print_info "请运行: npm install -g nodemcu-tool"
        exit 1
    fi
    print_success "NodeMCU-Tool 已安装"
}

# 检查文件是否存在
check_files() {
    local missing_files=()
    
    if [ ! -f "config.lua" ]; then
        missing_files+=("config.lua")
    fi
    
    if [ ! -f "main.lua" ]; then
        missing_files+=("main.lua")
    fi
    
    if [ ! -f "init.lua" ]; then
        missing_files+=("init.lua")
    fi
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        print_error "缺少文件: ${missing_files[*]}"
        print_info "请确保当前目录包含所有必需的 .lua 文件"
        exit 1
    fi
    
    print_success "所有必需文件都存在"
}

# 上传单个文件
upload_file() {
    local filename=$1
    local step=$2
    
    print_info "步骤 $step: 上传 $filename"
    
    if nodemcu-tool upload "$filename"; then
        print_success "$filename 上传成功"
        sleep 1  # 等待一秒确保上传完成
    else
        print_error "$filename 上传失败"
        exit 1
    fi
}

# 显示设备信息
show_device_info() {
    print_info "获取设备信息..."
    nodemcu-tool info 2>/dev/null || print_warning "无法获取设备信息，请检查连接"
}

# 列出设备上的文件
list_files() {
    print_info "设备上的文件列表:"
    nodemcu-tool fsinfo 2>/dev/null || print_warning "无法获取文件列表"
}

# 重启设备
reset_device() {
    print_info "重启设备..."
    if nodemcu-tool reset; then
        print_success "设备重启成功"
    else
        print_warning "设备重启失败，请手动重启"
    fi
}

# 主函数
main() {
    echo "========================================"
    echo "    NodeMCU Lua 代码上传脚本"
    echo "========================================"
    
    # 检查工具和文件
    check_tool
    check_files
    
    # 显示当前目录的文件
    print_info "当前目录的 .lua 文件:"
    ls -la *.lua 2>/dev/null || print_warning "当前目录没有 .lua 文件"
    
    # 询问是否继续
    echo
    read -p "是否继续上传? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "上传已取消"
        exit 0
    fi
    
    # 显示设备信息
    show_device_info
    
    echo
    print_info "开始按顺序上传文件..."
    print_warning "重要: 文件将按 config.lua → main.lua → init.lua 的顺序上传"
    
    # 按正确顺序上传文件
    upload_file "config.lua" "1/3"
    upload_file "main.lua" "2/3"
    upload_file "init.lua" "3/3"
    
    echo
    print_success "所有文件上传完成!"
    
    # 列出设备文件
    list_files
    
    # 重启设备
    echo
    reset_device
    
    echo
    print_success "上传流程完成! 设备应该开始运行你的程序了。"
    print_info "你可以使用串口监视器查看输出信息"
}

# 运行主函数
main "$@"
