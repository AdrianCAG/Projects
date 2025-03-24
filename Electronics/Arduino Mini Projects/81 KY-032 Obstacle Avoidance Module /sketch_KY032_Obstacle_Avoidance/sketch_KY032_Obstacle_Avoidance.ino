// KY-032 Obstacle Detection Sensor with Arduino
// This program detects obstacles using the KY-032 sensor and prints messages to the Serial Monitor.
// Optionally, an LED can be connected to indicate an obstacle visually.

const int sensorPin = 8;  // KY-032 sensor OUT pin connected to digital pin D3
const int ledPin = 13;    // Built-in LED pin (optional for visual feedback)

void setup() {
  Serial.begin(9600);       // Initialize serial communication for debugging
  pinMode(sensorPin, INPUT);// Set the sensor pin as an input
  pinMode(ledPin, OUTPUT);  // Set the LED pin as an output
}

void loop() {
  int sensorValue = digitalRead(sensorPin);  // Read the digital value from the sensor

  if (sensorValue == HIGH) {
    Serial.println("🚨 Obstacle detected!"); // Print a message when an obstacle is detected
    digitalWrite(ledPin, HIGH);  // Turn ON LED (if using one)
  } else {
    Serial.println("✅ No obstacle detected.");
    digitalWrite(ledPin, LOW);   // Turn OFF LED
  }

  delay(500); // Delay to avoid rapid multiple readings (adjustable)
}
