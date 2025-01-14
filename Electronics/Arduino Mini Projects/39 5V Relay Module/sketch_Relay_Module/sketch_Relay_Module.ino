/*
 * Simple Relay Control Program
 * This program toggles a relay on and off at 1-second intervals.
 * 
 * Features:
 * - Uses a digital pin to control a relay module.
 * - Provides detailed comments for better understanding.
 * - Includes setup and loop functions for Arduino.
 * 
 * Instructions:
 * - Connect the relay module's signal pin to pin 9 on the Arduino.
 * - Ensure the relay's power and ground connections are correctly set.
 * - The relay will toggle between ON and OFF states every second.
 */

// Pin configuration
const int relayPin = 9; // Define the digital pin connected to the relay module

// Initialization block
void setup() {
  // Set the relay pin as an OUTPUT
  pinMode(relayPin, OUTPUT);

  // Initial feedback to the user
  Serial.begin(9600); // Initialize the Serial Monitor for debugging
  Serial.println("Relay Control Program Initialized");
  Serial.println("Relay will toggle every 1 second.");
}

// Main program loop
void loop() {
  // Turn the relay ON
  digitalWrite(relayPin, HIGH);
  Serial.println("Relay is ON"); // Debug message
  delay(1000); // Wait for 1 second

  // Turn the relay OFF
  digitalWrite(relayPin, LOW);
  Serial.println("Relay is OFF"); // Debug message
  delay(1000); // Wait for 1 second
}

/*
 * Notes:
 * - Ensure the relay module can handle the voltage and current of your load.
 * - Adjust the `delay` values for faster or slower toggling if needed.
 * - Use the Serial Monitor (set to 9600 baud) to observe relay state changes.
 */
