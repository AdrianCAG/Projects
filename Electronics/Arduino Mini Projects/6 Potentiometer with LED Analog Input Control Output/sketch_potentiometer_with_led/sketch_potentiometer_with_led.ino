/*
 * This program reads an analog sensor value from pin A0 and adjusts the brightness 
 * of an LED connected to pin 9 based on the sensor input.
 * The sensor value is mapped from its range (0-1023) to the PWM range (0-255) 
 * for smooth LED dimming.
 */

const int sensorPin = A0;   // Pin connected to the analog sensor
const int ledPin = 9;       // Pin connected to the LED

void setup() {
  // Initialize the LED pin as an output
  pinMode(ledPin, OUTPUT);

  // Begin serial communication for debugging purposes
  Serial.begin(9600);
  Serial.println("Analog sensor to LED brightness control initialized...");
}

void loop() {
  // Read the analog value from the sensor (range: 0 - 1023)
  int sensorValue = analogRead(sensorPin);

  // Map the sensor value to the range of PWM output (0 - 255)
  int brightness = map(sensorValue, 0, 1023, 0, 255);

  // Set the LED brightness based on the mapped value
  analogWrite(ledPin, brightness);

  // Print the raw sensor value and the mapped brightness to the serial monitor
  Serial.print("Sensor Value: ");
  Serial.print(sensorValue);
  Serial.print(" -> LED Brightness: ");
  Serial.println(brightness);

  // Add a small delay to stabilize the readings and prevent overloading the serial monitor
  delay(250);
}
