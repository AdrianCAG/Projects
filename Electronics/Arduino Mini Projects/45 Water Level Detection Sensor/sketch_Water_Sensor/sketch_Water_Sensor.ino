// ***************************************************
// Analog Sensor Reader with Serial Plotter Support
// ***************************************************
// This program reads analog values from a sensor connected to pin A0
// and displays the readings on the Serial Monitor and Serial Plotter.
// The data is updated every millisecond, providing real-time visualization.
//
// Connections:
// - Sensor signal pin -> Arduino Analog Pin A0
// - Sensor VCC -> Arduino 5V
// - Sensor GND -> Arduino GND
// ***************************************************

const int SENSOR_PIN = A0; // Define the analog pin connected to the sensor

void setup() {
  // Initialize serial communication for debugging and plotting
  Serial.begin(9600);
  
  // Print initial message to Serial Monitor
  Serial.println("Starting Analog Sensor Reading...");
}

void loop() {
  // Read the analog value from the sensor
  int sensorValue = analogRead(SENSOR_PIN);

  // Print the sensor value to Serial (for Serial Plotter visualization)
  Serial.println(sensorValue);

  // Optional: Add a slight delay for smoother visualization on Serial Plotter
  delay(10); 
}
