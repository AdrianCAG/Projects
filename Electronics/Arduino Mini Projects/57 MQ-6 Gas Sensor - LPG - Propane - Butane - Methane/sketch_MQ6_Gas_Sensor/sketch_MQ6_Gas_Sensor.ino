/*
  MQ-6 Gas Sensor Module with Arduino
  ------------------------------------
  This program reads the analog output value (0-1023) from the MQ-6 gas sensor 
  and prints it to the serial monitor.

  Notes:
  - The MQ-6 sensor detects gases like LPG, propane, butane, and methane.
  - After powering on, the sensor requires a warm-up time of at least 20 seconds 
    for stable readings.
  - The sensor has an internal heating element, so it is normal for it to generate heat.

  Sensor:      MQ-6 Gas Sensor
  Connection:  VCC -> 5V, GND -> GND, A0 -> Analog Pin A0
*/

// Define the analog pin connected to the MQ-6 gas sensor
const int sensorPin = A0;  

// Define a threshold value for gas detection (adjust based on sensitivity)
const int threshold = 300;  

void setup() {
  Serial.begin(9600);  // Initialize serial communication at 9600 baud
  Serial.println("MQ-6 Gas Sensor Initialization...");
  delay(20000);         // Allow sensor to stabilize (minimum recommended warm-up time)
}

void loop() {
  // Read the sensor's analog output value (ranges from 0 to 1023)
  int sensorValue = analogRead(sensorPin);

  // Display the sensor reading on the serial monitor
  Serial.print("Analog Output: ");
  Serial.println(sensorValue);  

  // Check if the gas concentration exceeds the threshold
  if (sensorValue > threshold) {
    Serial.println("Warning! Flammable Gas Detected!");
  }

  // Small delay before the next reading
  delay(100);  // Wait 100ms to reduce noise in readings
}
