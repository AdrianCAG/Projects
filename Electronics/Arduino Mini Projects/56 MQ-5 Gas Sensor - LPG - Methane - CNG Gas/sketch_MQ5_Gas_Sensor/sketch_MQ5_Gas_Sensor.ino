/*
  MQ-5 Gas Sensor Module with Arduino
  ------------------------------------
  This program reads the analog output value (0-1023) from the MQ-5 gas sensor 
  and prints it to the serial monitor.

  Notes:
  - The MQ-5 sensor detects gases like LPG, natural gas (CNG), methane (CH₄), 
    hydrogen (H₂), and carbon monoxide (CO).
  - After powering on, the sensor requires a warm-up time of at least 1-2 minutes 
    for stable readings.
  - The sensor has an internal heating element, so it is normal for it to generate heat.

  Sensor:      MQ-5 Gas Sensor
  Connection:  VCC -> 5V, GND -> GND, A0 -> Analog Pin A0
*/

// Define the analog pin connected to the MQ-5 gas sensor
const int sensorPin = A0;  

// Define a threshold value for gas detection (adjustable based on sensitivity)
const int threshold = 350;  

void setup() {
  Serial.begin(9600);  // Initialize serial communication at 9600 baud
  Serial.println("MQ-5 Gas Sensor Initialization...");
  delay(20000);         // Allow sensor to stabilize (recommended warm-up time)
}

void loop() {
  // Read the sensor's analog output value (ranges from 0 to 1023)
  int sensorValue = analogRead(sensorPin);

  // Display the sensor reading on the serial monitor
  Serial.print("Analog Output: ");
  Serial.println(sensorValue);  

  // Check if the gas concentration exceeds the threshold
  if (sensorValue > threshold) {
    Serial.println("Warning! Gas Leak Detected!");
  } else {
    Serial.println("Gas levels normal.");
  }

  // Small delay before the next reading
  delay(200);  // Wait 200ms to reduce noise in readings
}
