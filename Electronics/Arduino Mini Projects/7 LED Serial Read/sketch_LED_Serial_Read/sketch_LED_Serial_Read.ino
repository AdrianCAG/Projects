/*
 * This program controls an LED connected to pin 9 using commands received over the Serial Monitor.
 * The user can send '1' to turn the LED on and '0' to turn it off.
 * Feedback messages are sent to the Serial Monitor for user interaction.
 */

const int ledPin = 9;      // Pin connected to the LED
int incomingByte = 0;      // Variable to store incoming serial data

void setup() {
  // Set up the LED pin as an output
  pinMode(ledPin, OUTPUT);

  // Begin serial communication at 9600 baud
  Serial.begin(9600);

  // Display a welcome message on the Serial Monitor
  Serial.println("LED Control Program Initialized.");
  Serial.println("Send '1' to turn the LED ON.");
  Serial.println("Send '0' to turn the LED OFF.");
}

void loop() {
  // Check if data is available on the Serial Monitor
  if (Serial.available() > 0) {
    // Read the incoming byte from the serial buffer
    incomingByte = Serial.read();

    // Perform actions based on the received byte
    if (incomingByte == '1') {
      digitalWrite(ledPin, HIGH);  // Turn the LED on
      Serial.println("LED is ON."); // Feedback message
    } else if (incomingByte == '0') {
      digitalWrite(ledPin, LOW);   // Turn the LED off
      Serial.println("LED is OFF."); // Feedback message
    } 
  }
}