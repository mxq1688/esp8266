#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "esp_log.h"

static const char *TAG = "gpio_example";

#define LED_PIN GPIO_NUM_2
#define BUTTON_PIN GPIO_NUM_0

void gpio_init(void)
{
    // 配置LED引脚为输出
    gpio_config_t io_conf = {};
    io_conf.intr_type = GPIO_INTR_DISABLE;
    io_conf.mode = GPIO_MODE_OUTPUT;
    io_conf.pin_bit_mask = (1ULL << LED_PIN);
    io_conf.pull_down_en = 0;
    io_conf.pull_up_en = 0;
    gpio_config(&io_conf);

    // 配置按钮引脚为输入
    io_conf.intr_type = GPIO_INTR_DISABLE;
    io_conf.mode = GPIO_MODE_INPUT;
    io_conf.pin_bit_mask = (1ULL << BUTTON_PIN);
    io_conf.pull_down_en = 0;
    io_conf.pull_up_en = 1;  // 启用上拉电阻
    gpio_config(&io_conf);
}

void led_task(void *pvParameter)
{
    while (1) {
        // 读取按钮状态
        int button_state = gpio_get_level(BUTTON_PIN);
        
        if (button_state == 0) {  // 按钮按下（低电平）
            gpio_set_level(LED_PIN, 1);  // 点亮LED
            ESP_LOGI(TAG, "LED ON");
        } else {
            gpio_set_level(LED_PIN, 0);  // 熄灭LED
            ESP_LOGI(TAG, "LED OFF");
        }
        
        vTaskDelay(100 / portTICK_PERIOD_MS);
    }
}

void app_main(void)
{
    ESP_LOGI(TAG, "ESP8266 GPIO Control Example");
    
    gpio_init();
    
    // 创建LED控制任务
    xTaskCreate(led_task, "led_task", 2048, NULL, 5, NULL);
}
