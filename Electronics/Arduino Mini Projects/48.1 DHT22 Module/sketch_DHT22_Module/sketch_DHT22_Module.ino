#include <DHT.h>

// Define the pin to which the DHT22 is connected
#define DHTPIN 4  // Pin connected to the DHT22 sensor data pin

// Define the DHT sensor type
#define DHTTYPE DHT22  // DHT22 (AM2302)

// Initialize the DHT sensor
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  // Initialize the Serial Monitor for debugging
  Serial.begin(9600);
  Serial.println("DHT22 Sensor Example");
  
  // Start the DHT sensor
  dht.begin();
}

void loop() {
  // Wait a few seconds between measurements
  delay(2000); // DHT22 can only read data every 2 seconds

  // Read the temperature in Celsius
  float temperature = dht.readTemperature();

  // Read the temperature in Fahrenheit
  float temperatureF = dht.readTemperature(true);

  // Read the humidity
  float humidity = dht.readHumidity();

  // Check if any reads failed and exit early
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // Calculate heat index in Fahrenheit
  float heatIndexF = dht.computeHeatIndex(temperatureF, humidity, true);

  // Calculate heat index in Celsius
  float heatIndexC = dht.computeHeatIndex(temperature, humidity, false);

  // Print the results to the Serial Monitor
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.print("%  ");
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.print("°C  ");
  Serial.print(temperatureF);
  Serial.print("°F  ");
  Serial.print("Heat Index: ");
  Serial.print(heatIndexC);
  Serial.print("°C  ");
  Serial.print(heatIndexF);
  Serial.println("°F");
}
