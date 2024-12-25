/*
 * This program gradually increases the brightness of an LED 
 * connected to pin 9 using Pulse Width Modulation (PWM).
 * The LED's brightness increases in steps from 0 to 255.
 */

int ledPin = 9;  // Pin connected to the LED

void setup() {
  // No setup required for this sketch
}

void loop() {
  /*
   * This loop gradually increases the LED brightness.
   * 'value' represents the PWM value, ranging from 0 (off) to 255 (full brightness).
   * The brightness increases by 5 units in each iteration.
   */
  
  for (int value = 0; value <= 255; value += 5) {
    // Write the PWM value to the LED pin to adjust brightness
    analogWrite(ledPin, value);

    // Small delay to create a smooth fade effect
    delay(30);
  }
}