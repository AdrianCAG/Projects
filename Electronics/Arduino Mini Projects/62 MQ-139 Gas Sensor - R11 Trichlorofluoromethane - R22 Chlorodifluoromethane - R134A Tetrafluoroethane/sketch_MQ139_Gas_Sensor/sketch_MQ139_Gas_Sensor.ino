/*
  MQ-139 Gas Sensor with Arduino
  ------------------------------------
  This program reads the analog output value (0-1023) from the MQ-139 gas sensor 
  and prints it to the serial monitor.

  Notes:
  - The MQ-139 sensor detects Freon gases such as R11, R22, R113, R134A, R409A, and R410A.
  - It requires a warm-up time of at least 1-2 minutes for accurate readings.
  - The sensor's analog output varies with gas concentration in the air.

  Sensor:      MQ-139 Gas Sensor
  Connection:  VCC -> 5V, GND -> GND, A0 -> Analog Pin A0
*/

// Define the analog pin connected to the MQ-139 gas sensor
const int sensorPin = A0;

// Define a threshold value for gas detection (adjustable)
const int threshold = 400;

void setup() {
  Serial.begin(9600);  // Initialize serial communication at 9600 baud
  Serial.println("MQ-139 Gas Sensor Initialization...");
  delay(30000);         // Allow sensor to stabilize (recommended warm-up time)
}

void loop() {
  // Read the sensor's analog output value (ranges from 0 to 1023)
  int sensorValue = analogRead(sensorPin);

  // Display the sensor reading on the serial monitor
  Serial.print("Analog Output: ");
  Serial.println(sensorValue);

  // Check if the gas concentration exceeds the threshold
  if (sensorValue > threshold) {
    Serial.println("Warning! High Freon Gas Level Detected!");
  }

  // Small delay before the next reading
  delay(1000);  // Wait 100ms to reduce noise in readings
}
