/**
 * Sensor Data Reading and Visualization
 * 
 * This program reads values from a digital and analog sensor connected to Arduino,
 * then prints both digital and analog readings to the Serial Monitor and Serial Plotter.
 * The values from the digital sensor (connected to pin 2) and the analog sensor 
 * (connected to pin A0) are read and printed at a regular interval.
 * 
 * Hardware Connections:
 * - Digital sensor -> Arduino Pin 2
 * - Analog sensor -> Arduino Pin A0
 *
 * The readings are displayed on both the Serial Monitor and Serial Plotter.
 */

void setup() {
  // Initialize the digital input pin (pin 2) for sensor reading
  pinMode(2, INPUT);
  
  // Initialize the analog input pin (pin A0) for sensor reading
  // No need to call pinMode for analog pins, they are input by default

  // Start serial communication at 9600 baud rate for serial monitor and plotter
  Serial.begin(9600);
  
  // Provide feedback on startup (useful for debugging)
  Serial.println("Sensor Data Reading Initialized");
}

void loop() {
  // Read the digital value from the sensor connected to pin 2 (HIGH or LOW)
  int sensorDigitalValue = digitalRead(2);
  
  // Read the analog value from the sensor connected to pin A0 (range 0-1023)
  int sensorAnalogValue = analogRead(A0);

  // Print the digital value to the Serial Monitor for visibility
  Serial.print("Digital Reading: ");
  Serial.println(sensorDigitalValue);

  // Print the analog value to the Serial Monitor for visibility
  Serial.print("Analog Reading: ");
  Serial.println(sensorAnalogValue);

  // Prepare the data for the Serial Plotter in a format suitable for visualization
  // The Serial Plotter requires data to be printed in a specific way
  Serial.print("Digital Value: ");
  Serial.print(sensorDigitalValue);   // Digital sensor reading (either 0 or 1)
  Serial.print("\t");                 // Tab separator for easy parsing
  Serial.print("Analog Value: ");
  Serial.println(sensorAnalogValue);  // Analog sensor reading (range 0-1023)

  // Provide a small delay to allow for readable updates and prevent overwhelming the serial output
  delay(100);  // Delay of 100ms to make plotting smoother and reduce data congestion
}
