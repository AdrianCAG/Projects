// Include the necessary libraries for I2C communication and BMP180 sensor
#include <Wire.h>
#include <SFE_BMP180.h>

// Create an instance of the BMP180 sensor
SFE_BMP180 bmp180;

// Define the current altitude in meters (used for pressure compensation)
int altitude = 10; // Change this value to match your location

void setup() {
  // Initialize serial communication for debugging and data display
  Serial.begin(9600);
  
  // Attempt to initialize the BMP180 sensor
  bool success = bmp180.begin();

  // Check if the sensor initialization was successful
  if (success) {
    Serial.println("BMP180 initialized successfully");
  } else {
    Serial.println("BMP180 initialization failed! Check connections.");
    while (1); // Stay in an infinite loop if initialization fails
  }
}

void loop() {
  char status;       // Variable to track the status of sensor operations
  double temperature, pressure; // Variables to hold temperature and pressure values
  
  // Start temperature measurement
  status = bmp180.startTemperature();
  if (status != 0) {
    delay(1000); // Wait for temperature measurement to complete

    // Retrieve the temperature value
    status = bmp180.getTemperature(temperature);
    if (status != 0) {
      // Start pressure measurement with oversampling setting of 3 (highest accuracy)
      status = bmp180.startPressure(3);
      if (status != 0) {
        delay(status); // Wait for pressure measurement to complete

        // Retrieve the pressure value
        status = bmp180.getPressure(pressure, temperature);
        if (status != 0) {
          // Calculate the pressure at sea level
          float seaLevelPressure = bmp180.sealevel(pressure, altitude);

          // Display compensated pressure in hPa
          Serial.print("Pressure at Sea Level: ");
          Serial.print(seaLevelPressure);
          Serial.println(" hPa");

          // Display temperature in Celsius
          Serial.print("Temperature: ");
          Serial.print(temperature);
          Serial.println(" °C");

          // Add a separator for better readability in the serial monitor
          Serial.println("---------------------------------------------");
        } else {
          Serial.println("Error retrieving pressure!");
        }
      } else {
        Serial.println("Error starting pressure measurement!");
      }
    } else {
      Serial.println("Error retrieving temperature!");
    }
  } else {
    Serial.println("Error starting temperature measurement!");
  }
}
