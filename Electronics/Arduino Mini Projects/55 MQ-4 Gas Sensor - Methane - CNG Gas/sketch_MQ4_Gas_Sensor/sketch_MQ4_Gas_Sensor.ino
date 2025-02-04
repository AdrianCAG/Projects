/*
  MQ-4 Gas Sensor Module with Arduino
  ------------------------------------
  This program reads the analog output value (0-1023) from the MQ-4 gas sensor 
  and prints it to the serial monitor.

  Notes:
  - The MQ-4 sensor detects methane (CH₄), natural gas (CNG), and low levels of other gases.
  - After powering on, the sensor requires a warm-up time of at least 20 seconds 
    for basic readings and a longer period (24-48 hours) for precise calibration.
  - The sensor has an internal heating element, so it is normal for it to generate heat.

  Sensor:      MQ-4 Gas Sensor
  Connection:  VCC -> 5V, GND -> GND, A0 -> Analog Pin A0
*/

// Define the analog pin connected to the MQ-4 gas sensor
const int sensorPin = A0;  

// Define a threshold value for gas detection (adjust based on sensitivity)
const int threshold = 350;  

void setup() {
  Serial.begin(9600);  // Initialize serial communication at 9600 baud
  Serial.println("MQ-4 Gas Sensor Initialization...");
  delay(20000);        // Allow sensor to stabilize for initial readings
}

void loop() {
  // Read the sensor's analog output value (ranges from 0 to 1023)
  int sensorValue = analogRead(sensorPin);

  // Display the sensor reading on the serial monitor
  Serial.print("Analog Output: ");
  Serial.println(sensorValue);  

  // Check if the gas concentration exceeds the threshold
  if (sensorValue > threshold) {
    Serial.println("Warning! Methane/Natural Gas Detected!");
  } else {
    Serial.println("Safe levels of Methane detected.");
  }

  // Small delay before the next reading
  delay(1000);  // Wait 1 second between readings
}
