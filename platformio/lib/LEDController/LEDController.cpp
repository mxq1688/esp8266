#include "LEDController.h"

LEDController::LEDController(int ledPin) {
    pin = ledPin;
    state = false;
    isBlinking = false;
    blinkCount = 0;
    maxBlinks = 0;
    blinkDelay = 0;
    lastBlinkTime = 0;
}

void LEDController::begin() {
    pinMode(pin, OUTPUT);
    off(); // 初始状态为关闭
}

void LEDController::on() {
    state = true;
    isBlinking = false;
    digitalWrite(pin, LOW); // ESP8266 内置LED为低电平有效
}

void LEDController::off() {
    state = false;
    isBlinking = false;
    digitalWrite(pin, HIGH); // ESP8266 内置LED为低电平有效
}

void LEDController::toggle() {
    if (state) {
        off();
    } else {
        on();
    }
}

void LEDController::blink(int times, int delayMs) {
    isBlinking = true;
    maxBlinks = times * 2; // 每次闪烁包含开和关
    blinkCount = 0;
    blinkDelay = delayMs;
    lastBlinkTime = millis();
    
    // 立即开始第一次闪烁
    digitalWrite(pin, LOW);
    state = true;
}

bool LEDController::isOn() {
    return state;
}

void LEDController::update() {
    if (!isBlinking) return;
    
    unsigned long currentTime = millis();
    if (currentTime - lastBlinkTime >= blinkDelay) {
        blinkCount++;
        
        if (blinkCount >= maxBlinks) {
            // 闪烁完成
            isBlinking = false;
            off();
            return;
        }
        
        // 切换状态
        toggle();
        lastBlinkTime = currentTime;
    }
}
