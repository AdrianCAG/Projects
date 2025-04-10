/*
  MQ-7 Gas Sensor with Arduino
  ------------------------------------
  This program reads the analog output value (0-1023) from the MQ-7 gas sensor 
  and prints it to the serial monitor.

  Notes:
  - The MQ-7 sensor detects Carbon Monoxide (CO) with high sensitivity.
  - The sensor operates best with a heating voltage cycle (not used in this simple setup).
  - After powering on, the sensor requires a warm-up time of at least 1-2 minutes.
  - The sensor's analog output varies with CO concentration in the air.

  Sensor:      MQ-7 Gas Sensor
  Connection:  VCC -> 5V, GND -> GND, A0 -> Analog Pin A0
*/

// Define the analog pin connected to the MQ-7 gas sensor
const int sensorPin = A0;

// Define a threshold value for gas detection (adjustable)
const int threshold = 400;

void setup() {
  Serial.begin(9600);  // Initialize serial communication at 9600 baud
  Serial.println("MQ-7 Gas Sensor Initialization...");
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
    Serial.println("Warning! High CO Level Detected!");
  }

  // Small delay before the next reading
  delay(100);  // Wait 100ms to reduce noise in readings
}
