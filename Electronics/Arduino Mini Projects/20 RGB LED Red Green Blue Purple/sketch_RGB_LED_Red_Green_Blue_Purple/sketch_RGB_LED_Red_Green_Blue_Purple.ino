/*
 * RGB LED Color Cycling
 * 
 * This program controls an RGB LED connected to the Arduino. It cycles through
 * red, green, and blue colors with a 1-second delay between each color.
 * 
 * Additional Features:
 * - Fades between colors for a smoother transition.
 * - Includes a custom purple color demonstration.
 * - Modular function to set RGB values for better scalability.
 */

class RGBLed {
private:
    const uint8_t redPin;
    const uint8_t greenPin;
    const uint8_t bluePin;
    
    struct Color {
        uint8_t red;
        uint8_t green;
        uint8_t blue;
    };

    void setColor(const Color& color) {
        analogWrite(redPin, color.red);
        analogWrite(greenPin, color.green);
        analogWrite(bluePin, color.blue);
    }

public:
    RGBLed(uint8_t red, uint8_t green, uint8_t blue)
        : redPin(red), greenPin(green), bluePin(blue) {}

    void begin() {
        pinMode(redPin, OUTPUT);
        pinMode(greenPin, OUTPUT);
        pinMode(bluePin, OUTPUT);
    }

    void setColor(uint8_t red, uint8_t green, uint8_t blue) {
        setColor({red, green, blue});
    }

    void fadeTo(uint8_t endRed, uint8_t endGreen, uint8_t endBlue, 
                uint16_t steps = 100, uint16_t stepDelay = 10) {
        Color start = {
            static_cast<uint8_t>(analogRead(redPin) / 4),
            static_cast<uint8_t>(analogRead(greenPin) / 4),
            static_cast<uint8_t>(analogRead(bluePin) / 4)
        };
        
        for (uint16_t step = 0; step <= steps; step++) {
            Color current = {
                static_cast<uint8_t>(map(step, 0, steps, start.red, endRed)),
                static_cast<uint8_t>(map(step, 0, steps, start.green, endGreen)),
                static_cast<uint8_t>(map(step, 0, steps, start.blue, endBlue))
            };
            setColor(current);
            delay(stepDelay);
        }
    }
};

// Pin definitions
const uint8_t RED_PIN = 11;
const uint8_t GREEN_PIN = 10;
const uint8_t BLUE_PIN = 9;

RGBLed led(RED_PIN, GREEN_PIN, BLUE_PIN);

void setup() {
    led.begin();
}

void loop() {
    // Solid colors
    led.setColor(255, 0, 0);    // Red
    delay(1000);
    led.setColor(0, 255, 0);    // Green
    delay(1000);
    led.setColor(0, 0, 255);    // Blue
    delay(1000);

    // Color transitions
    led.fadeTo(0, 255, 0);      // Red to Green
    led.fadeTo(0, 0, 255);      // Green to Blue
    led.fadeTo(255, 0, 0);      // Blue to Red

    // Custom color
    led.setColor(128, 0, 128);  // Purple
    delay(1000);
}