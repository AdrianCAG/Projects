// Include necessary libraries for communication with KY-001 (DS18B20) temperature sensor
#include <OneWire.h>
#include <DallasTemperature.h>

// Define the digital pin where the KY-001 sensor's signal pin is connected
#define SENSOR_PIN 8

// Create a OneWire object to communicate with the sensor
OneWire oneWire(SENSOR_PIN);

// Create a DallasTemperature object using the OneWire bus
DallasTemperature sensors(&oneWire);

void setup(void)
{
  // Initialize the serial communication for debugging and output
  Serial.begin(9600);

  // Initialize the temperature sensor
  sensors.begin();
}

void loop(void)
{
  // Request temperature measurement from the sensor
  sensors.requestTemperatures();

  // Print temperature value in Celsius to the serial monitor
  Serial.print("Temperature from KY-001 is: ");
  Serial.println(sensors.getTempCByIndex(0)); // Get temperature and display it

  // Wait 1 second before the next reading to avoid excessive polling
  delay(1000);
}