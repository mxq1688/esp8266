#ifndef LEDCONTROLLER_H
#define LEDCONTROLLER_H

#include <Arduino.h>

class LEDController {
private:
    int pin;
    bool state;
    unsigned long lastBlinkTime;
    int blinkCount;
    int maxBlinks;
    int blinkDelay;
    bool isBlinking;

public:
    LEDController(int ledPin);
    void begin();
    void on();
    void off();
    void toggle();
    void blink(int times, int delayMs);
    bool isOn();
    void update(); // 在主循环中调用以处理闪烁
};

#endif
