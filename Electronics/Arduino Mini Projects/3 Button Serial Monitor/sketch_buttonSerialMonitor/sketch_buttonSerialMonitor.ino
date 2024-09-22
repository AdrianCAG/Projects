/*
 * This program reads the state of a button connected to pin 2
 * and prints the button state to the serial monitor. 
 * The button state is either HIGH (not pressed) or LOW (pressed).
 */

void setup() {
  // Initialize serial communication at a baud rate of 9600 bits per second
  Serial.begin(9600);

  // Set pin 2 as an input to read the button state
  pinMode(2, INPUT);
}

void loop() {
  // Read the current state of the button (HIGH or LOW)
  int buttonState = digitalRead(2);

  // Print the button state to the serial monitor (either 1 or 0)
  Serial.println(buttonState);

  // Small delay to avoid flooding the serial monitor with data
  delay(1);
}