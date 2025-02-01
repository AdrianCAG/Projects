/*
  MQ-2 Gas Sensor Module with Arduino
  ------------------------------------
  This program reads the analog output value (0-1023) from the MQ-2 gas sensor 
  and prints it to the serial monitor.

  Notes:
  - The MQ-2 sensor detects gases like LPG, smoke, alcohol, propane, hydrogen, 
    methane, and carbon monoxide.
  - After powering on, the sensor requires a warm-up time of at least 3 minutes 
    for stable readings.
  - The sensor has an internal heating element, so it is normal for it to generate heat.

  Board:       Arduino Uno R3 (or R4)
  Sensor:      MQ-2 Gas Sensor
  Connection:  VCC -> 5V, GND -> GND, A0 -> Analog Pin A0
*/

// Define the analog pin connected to the MQ-2 gas sensor
const int sensorPin = A0;  

// Define a threshold value for gas detection (adjustable based on sensitivity)
const int threshold = 400;  

void setup() {
  Serial.begin(9600);  // Initialize serial communication at 9600 baud
  Serial.println("MQ-2 Gas Sensor Initialization...");
  delay(30000);         // Allow sensor to stabilize (minimum recommended warm-up time)
}

void loop() {
  // Read the sensor's analog output value (ranges from 0 to 1023)
  int sensorValue = analogRead(sensorPin);

  // Display the sensor reading on the serial monitor
  Serial.print("Analog Output: ");
  Serial.println(sensorValue);  

  // Check if the gas concentration exceeds the threshold
  if (sensorValue > threshold) {
    Serial.println("Warning! Gas Detected!");
  }

  // Small delay before the next reading
  delay(100);  // Wait 100ms to reduce noise in readings
}
