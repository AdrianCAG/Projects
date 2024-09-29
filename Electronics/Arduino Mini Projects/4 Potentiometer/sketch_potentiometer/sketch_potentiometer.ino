/*
 * This program reads an analog sensor value from pin A0 and prints it to the serial monitor.
 * It also maps the sensor value to a voltage range (0 - 5V) for better readability.
 */

void setup() {
  // Initialize serial communication at 9600 baud rate for printing sensor values
  Serial.begin(9600);

  // Give a startup message to signal that the program has started
  Serial.println("Analog sensor reading initialized...");
}

void loop() {
  // Read the sensor value from analog pin A0 (range: 0 - 1023)
  int sensorValue = analogRead(A0);

  // Convert the raw sensor value to a voltage (0 - 5V)
  float voltage = sensorValue * (5.0 / 1023.0);

  // Print the raw sensor value to the serial monitor
  Serial.print("Raw Sensor Value: ");
  Serial.println(sensorValue);

  // Print the corresponding voltage value to the serial monitor
  Serial.print("Voltage: ");
  Serial.print(voltage);
  Serial.println(" V");

  // Add a small delay for readability in the serial monitor
  delay(500);
}