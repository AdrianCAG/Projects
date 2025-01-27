// Include the DHT sensor library
#include <dht.h>

// Create a DHT object
dht DHT;

// Define the pin where the DHT11 sensor is connected
#define DHT11_PIN 4

void setup()
{
  // Initialize the serial communication for debugging
  Serial.begin(9600);

  // Print initial information to the serial monitor
  Serial.println("DHT11 TEST PROGRAM");
  Serial.print("LIBRARY VERSION: ");
  Serial.println(DHT_LIB_VERSION); // Print the library version
  Serial.println();                // Blank line for readability
  Serial.println("Type,\tStatus,\tHumidity (%),\tTemperature (C)");
}

void loop()
{
  // Start data output for DHT11
  Serial.print("DHT11, \t");

  // Read data from the DHT11 sensor
  int chk = DHT.read11(DHT11_PIN);

  // Handle the status code returned by the read function
  switch (chk)
  {
    case DHTLIB_OK: // Data read successfully
      Serial.print("OK,\t");                     // Print status
      Serial.print(DHT.humidity, 1);             // Print humidity with 1 decimal place
      Serial.print(",\t");                       // Tab separator
      Serial.println(DHT.temperature, 1);        // Print temperature with 1 decimal place
      break;

    case DHTLIB_ERROR_CHECKSUM: // Data checksum error
      Serial.println("Checksum error,\t");       // Print error message
      break;

    case DHTLIB_ERROR_TIMEOUT: // Sensor timeout error
      Serial.println("Time out error,\t");       // Print error message
      delay(20);                                 // Short delay before retrying
      break;

    default: // Unknown error
      Serial.println("Unknown error,\t");        // Print error message
      break;
  }

  // Add a delay to prevent flooding the serial monitor
  delay(1000); // Wait 1 second before the next reading
}
