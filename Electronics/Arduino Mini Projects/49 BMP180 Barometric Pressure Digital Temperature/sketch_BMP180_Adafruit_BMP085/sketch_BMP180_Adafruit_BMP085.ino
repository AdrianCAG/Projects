// Include the necessary libraries
#include <Wire.h>                // For I2C communication
#include <Adafruit_BMP085.h>     // Library for BMP180/BMP085 sensor

// Define the sea-level pressure in hPa (standard value)
#define seaLevelPressure_hPa 1013.25

// Create an instance of the BMP085 sensor
Adafruit_BMP085 bmp;

void setup() {
  // Initialize serial communication for debugging
  Serial.begin(9600);
  
  // Attempt to initialize the BMP085 sensor
  if (!bmp.begin()) {
    Serial.println("Could not find a valid BMP085 sensor, check wiring!");
    while (1) {
      // Stay in an infinite loop if the sensor isn't detected
    }
  }

  // Display a setup message once the sensor is initialized
  Serial.println("BMP180/BMP085 Sensor Initialized Successfully");
  Serial.println("---------------------------------------------");
}

void loop() {
  // Read and display temperature in Celsius
  Serial.print("Temperature: ");
  Serial.print(bmp.readTemperature());
  Serial.println(" °C");
  
  // Read and display atmospheric pressure in Pascals
  Serial.print("Pressure: ");
  Serial.print(bmp.readPressure());
  Serial.println(" Pa");

  // Calculate and display altitude based on pressure
  Serial.print("Calculated Altitude: ");
  Serial.print(bmp.readAltitude());
  Serial.println(" meters");

  // Calculate and display sea-level pressure
  Serial.print("Sea-Level Pressure (calculated): ");
  Serial.print(bmp.readSealevelPressure());
  Serial.println(" Pa");

  // Calculate and display real altitude based on sea-level pressure
  Serial.print("Real Altitude: ");
  Serial.print(bmp.readAltitude(seaLevelPressure_hPa * 100));
  Serial.println(" meters");

  // Add a line break for readability
  Serial.println("---------------------------------------------");
  
  // Wait for half a second before updating readings
  delay(500);
}
