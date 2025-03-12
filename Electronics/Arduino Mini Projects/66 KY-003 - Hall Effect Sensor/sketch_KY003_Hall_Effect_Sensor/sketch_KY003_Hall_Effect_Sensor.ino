// KY-003 Hall Effect Sensor Example (Serial Monitor Output Only)
// This program reads the KY-003 Hall effect sensor and displays the values on the Serial Monitor.

int hallSensorPin = 10;   // Pin connected to the KY-003 signal output
int hallSensorValue = 0;  // Variable to store sensor readings

void setup() {
  Serial.begin(9600); // Initialize Serial Monitor for debugging
  pinMode(hallSensorPin, INPUT); // Set the Hall sensor pin as input
}

void loop() {
  // Read the Hall sensor's digital output
  hallSensorValue = digitalRead(hallSensorPin);

  // Print the sensor value to the Serial Monitor
  Serial.print("Hall Sensor Value: ");
  Serial.println(hallSensorValue);

  // Display a clear message based on the sensor's reading
  if (hallSensorValue == LOW) { // When a magnetic field is detected, the output is LOW
    Serial.println("Magnetic field detected!");
  } else {
    Serial.println("No magnetic field detected.");
  }

  delay(500); // Small delay to make the output readable
}
