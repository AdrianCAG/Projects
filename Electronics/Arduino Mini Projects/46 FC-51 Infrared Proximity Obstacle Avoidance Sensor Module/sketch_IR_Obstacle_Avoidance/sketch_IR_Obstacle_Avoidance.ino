// ---------------------------------------------
// IR Proximity Obstacle Avoidance Sensor Code
// ---------------------------------------------
// This code reads data from an IR proximity sensor connected to pin 2.
// The sensor outputs HIGH (1) when no obstacle is detected and LOW (0) when an obstacle is present.
// The output is displayed in the Serial Monitor in a user-friendly format.
// ---------------------------------------------

// Pin Definitions
const int sensorPin = 2; // Pin connected to the IR proximity sensor

void setup() {
  // Initialize the Serial Monitor for debugging and output
  Serial.begin(9600);
  
  // Set the sensor pin as an input
  pinMode(sensorPin, INPUT);

  // Inform the user that the setup is complete
  Serial.println("IR Proximity Sensor Initialized");
  Serial.println("Waiting for obstacle detection...");
  Serial.println("---------------------------------");
}

void loop() {
  // Read the digital signal from the sensor
  int sensorValue = digitalRead(sensorPin);

  // Print the sensor status in a user-friendly way
  if (sensorValue == HIGH) {
    Serial.println("No Obstacle Detected");
  } else {
    Serial.println("Obstacle Detected!");
  }

  // Add a separator for better readability in the Serial Monitor
  Serial.println("---------------------------------");

  // Wait for 500 milliseconds before the next reading
  delay(500);
}
