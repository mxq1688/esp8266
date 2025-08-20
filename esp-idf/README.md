# ESP-IDF 开发

## 概述
使用ESP-IDF (Espressif IoT Development Framework) 进行ESP8266开发，这是官方推荐的开发框架，使用C/C++语言，性能最优。

## 优势
- 官方开发框架，功能最完整
- 性能最优，资源利用率高
- 支持FreeRTOS实时操作系统
- 完整的开发工具链
- 适合商业项目开发

## 环境搭建

### 1. 安装ESP-IDF
```bash
# 克隆ESP-IDF仓库
git clone --recursive https://github.com/espressif/ESP8266_RTOS_SDK.git
cd ESP8266_RTOS_SDK

# 安装依赖
./install.sh

# 设置环境变量
source export.sh
```

### 2. 安装工具链
- 自动安装 (推荐): 使用install.sh脚本
- 手动安装: 下载ESP8266工具链

### 3. 配置开发环境
```bash
# 设置环境变量
export IDF_PATH=/path/to/ESP8266_RTOS_SDK
export PATH=$IDF_PATH/tools:$PATH
```

## 项目结构
```
esp-idf/
├── README.md              # 说明文档
├── examples/              # 示例项目
│   ├── wifi_station/     # WiFi Station示例
│   ├── wifi_softap/      # WiFi AP示例
│   ├── http_server/      # HTTP服务器示例
│   ├── mqtt_client/      # MQTT客户端示例
│   └── gpio_control/     # GPIO控制示例
├── components/           # 自定义组件
│   ├── my_sensor/       # 传感器组件
│   └── my_display/      # 显示组件
├── projects/            # 项目代码
├── docs/               # 文档资料
└── tools/              # 工具脚本
```

## 核心组件
- FreeRTOS: 实时操作系统
- lwIP: TCP/IP协议栈
- mbedTLS: 加密库
- JSON: JSON解析库
- HTTP: HTTP客户端/服务器

## 快速开始
1. 创建新项目
```bash
idf.py create-project my_project
cd my_project
```

2. 配置项目
```bash
idf.py menuconfig
```

3. 编译项目
```bash
idf.py build
```

4. 烧录固件
```bash
idf.py flash
```

5. 监控输出
```bash
idf.py monitor
```

## 示例代码
```c
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "esp_event.h"
#include "esp_log.h"
#include "nvs_flash.h"

static const char *TAG = "wifi_example";

void wifi_init_sta(void)
{
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    wifi_config_t wifi_config = {
        .sta = {
            .ssid = "your_wifi_ssid",
            .password = "your_wifi_password",
        },
    };
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(ESP_IF_WIFI_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());

    ESP_LOGI(TAG, "wifi_init_sta finished.");
}

void app_main(void)
{
    ESP_LOGI(TAG, "ESP8266 WiFi Example");
    
    // 初始化NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    wifi_init_sta();
}
```

## 常用命令
```bash
# 清理编译
idf.py clean

# 全量编译
idf.py fullclean

# 设置目标芯片
idf.py set-target esp8266

# 查看分区表
idf.py partition-table

# 查看帮助
idf.py --help
```

## 调试工具
- GDB调试器
- OpenOCD
- ESP-IDF Monitor
- JTAG调试 