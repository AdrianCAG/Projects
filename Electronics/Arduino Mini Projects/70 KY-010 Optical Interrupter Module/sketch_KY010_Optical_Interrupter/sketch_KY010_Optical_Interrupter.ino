// KY-010 Light Barrier Sensor Test
// Improved version with clear comments and optimized structure

const int barrierPin = 7;  // Define the digital pin for the sensor
int sensorValue;           // Variable to store sensor readings

void setup() {
  pinMode(barrierPin, INPUT);      // Set the sensor pin as input
  digitalWrite(barrierPin, HIGH);  // Enable internal pull-up resistor
  Serial.begin(9600);              // Start serial communication
  Serial.println("KY-010 Light Barrier Sensor Initialized");
}

void loop() {
  sensorValue = digitalRead(barrierPin);  // Read the sensor state

  if (sensorValue == HIGH) {
    Serial.println("Signal detected!");  // Print message when barrier is broken
  } else {
    Serial.println("No signal detected"); // Print message when no obstacle
  }

  delay(200);  // Adjusted delay for better readability in serial monitor
}
