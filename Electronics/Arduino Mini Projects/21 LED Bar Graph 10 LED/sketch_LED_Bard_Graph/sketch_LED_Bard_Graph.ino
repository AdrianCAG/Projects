/*
 * Enhanced Sequential LED Blinker
 * 
 * This program controls LEDs connected to pins 2 through 11 on an Arduino.
 * Features:
 * 1. LEDs blink twice sequentially from left to right.
 * 2. After each LED blinks, all LEDs blink in a "wave" from left to right.
 */

const int startPin = 2; // First pin connected to LEDs
const int endPin = 11;  // Last pin connected to LEDs
const int blinkDelay = 500; // Delay in milliseconds between LED actions

void setup() {
  // Initialize all pins from startPin to endPin as outputs
  for (int i = startPin; i <= endPin; i++) {
    pinMode(i, OUTPUT);
  }
}

void loop() {
  // Loop through each pin and control the LEDs sequentially
  for (int i = startPin; i <= endPin; i++) {
    blinkLED(i, 2);       // Blink each LED twice
    waveBlink();          // Perform a full left-to-right blink of all LEDs
  }
}

/*
 * Blinks an LED connected to a specific pin a given number of times.
 * 
 * Parameters:
 * - pin: The pin number where the LED is connected.
 * - count: The number of times the LED should blink.
 */
void blinkLED(int pin, int count) {
  for (int j = 0; j < count; j++) {
    digitalWrite(pin, HIGH); // Turn the LED on
    delay(blinkDelay);       // Wait for the specified delay
    digitalWrite(pin, LOW);  // Turn the LED off
    delay(blinkDelay);       // Wait for the specified delay
  }
}

/*
 * Performs a full left-to-right blinking sequence of all LEDs.
 */
void waveBlink() {
  for (int i = startPin; i <= endPin; i++) {
    digitalWrite(i, HIGH); // Turn the current LED on
    delay(200);            // Shorter delay for faster wave effect
    digitalWrite(i, LOW);  // Turn the current LED off
  }
}
