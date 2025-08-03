/*
 * Project 1: Indoor Air Quality Monitor (Arduino Uno) - CSV Output Format
 *
 * Sensors:
 * - MQ2 (Smoke/Gas) - Raw Values - Analog Pin A0
 * - MQ3 (Alcohol) - Raw Values - Analog Pin A1
 * - MQ135 (Air Quality) - Raw Values - Analog Pin A2
 * - DHT22 (Temperature/Humidity/Heat Index) - Digital Pin 4
 * - BMP180 (Temperature/Sea Level Pressure) - I2C (SDA: A4, SCL: A5)
 *
 * Output: CSV format for easy conversion to graphs and analysis
 * Sampling Rate: Every 5 seconds (optimal for all sensors)
 *
 * Required Libraries:
 * - DHT sensor library by Adafruit
 * - Adafruit BMP085 Library (works with BMP180)
 *
 * Wiring:
 * MQ2: VCC->5V, GND->GND, A0->A0
 * MQ3: VCC->5V, GND->GND, A0->A1
 * MQ135: VCC->5V, GND->GND, A0->A2
 * DHT22: VCC->5V, GND->GND, Data->Pin 4
 * BMP180: VCC->3.3V, GND->GND, SDA->A4, SCL->A5
 *
 * Note: MQ sensors need 24-48 hour burn-in period for accurate readings
 * Data can be captured using Serial Monitor and saved to CSV file
 */

// Include necessary libraries
#include <DHT.h>
#include <Wire.h>
#include <SFE_BMP180.h>

// Pin definitions
#define DHTPIN 4        // DHT22 data pin
#define MQ2_PIN A0      // MQ2 analog pin
#define MQ3_PIN A1      // MQ3 analog pin
#define MQ135_PIN A2    // MQ135 analog pin

// Sensor type definition
#define DHTTYPE DHT22   // DHT22 (AM2302)

// Initialize sensors
DHT dht(DHTPIN, DHTTYPE);
SFE_BMP180 bmp180;

// Configuration
const unsigned long SAMPLE_INTERVAL = 5000; // 5 seconds between readings
const int ALTITUDE = 10; // Change this to your location's altitude in meters
unsigned long previousMillis = 0;
bool headersWritten = false;

void setup() {
  // Initialize serial communication
  Serial.begin(9600);

  // Wait for serial port to connect
  while (!Serial) {
    ; // Wait for serial port to connect
  }

  // Initialize DHT22
  dht.begin();

  // Initialize BMP180
  bmp180.begin();

  // Allow sensors to stabilize
  delay(2000);
}

void loop() {
  unsigned long currentMillis = millis();

  // Check if it's time to take a reading
  if (currentMillis - previousMillis >= SAMPLE_INTERVAL) {
    previousMillis = currentMillis;

    // Write headers on first run
    if (!headersWritten) {
      writeCSVHeaders();
      headersWritten = true;
    }

    // Take readings and output row
    takeReadingsAndOutputCSV();
  }
}

void writeCSVHeaders() {
  Serial.println("MQ2_Raw,MQ3_Raw,MQ135_Raw,DHT22_Temp_C,DHT22_Humidity_%,DHT22_HeatIndex_C,BMP180_Temp_C,BMP180_SeaLevel_Pressure_hPa");
}

void takeReadingsAndOutputCSV() {
  // Read MQ sensors (raw values only)
  int mq2_raw = analogRead(MQ2_PIN);
  int mq3_raw = analogRead(MQ3_PIN);
  int mq135_raw = analogRead(MQ135_PIN);

  // Read DHT22 sensor
  float dht_temp = dht.readTemperature();
  float dht_humidity = dht.readHumidity();
  float dht_heat_index = NAN;

  // Calculate heat index if temperature and humidity are valid
  if (!isnan(dht_temp) && !isnan(dht_humidity)) {
    dht_heat_index = dht.computeHeatIndex(dht_temp, dht_humidity, false);
  }

  // Read BMP180 sensor
  float bmp_temp = NAN;
  float bmp_sea_level_pressure = NAN;

  char status;
  double temp_reading, pressure_reading;

  // Attempt to read BMP180
  status = bmp180.startTemperature();
  if (status != 0) {
    delay(status);
    status = bmp180.getTemperature(temp_reading);
    if (status != 0) {
      status = bmp180.startPressure(3);
      if (status != 0) {
        delay(status);
        status = bmp180.getPressure(pressure_reading, temp_reading);
        if (status != 0) {
          bmp_temp = temp_reading;
          bmp_sea_level_pressure = bmp180.sealevel(pressure_reading, ALTITUDE);
        }
      }
    }
  }

  // Output MQ row
  Serial.print(mq2_raw);
  Serial.print(",");
  Serial.print(mq3_raw);
  Serial.print(",");
  Serial.print(mq135_raw);
  Serial.print(",");

  // DHT22 data with error checking
  if (isnan(dht_temp)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht_temp, 2);
  }
  Serial.print(",");

  if (isnan(dht_humidity)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht_humidity, 2);
  }
  Serial.print(",");

  if (isnan(dht_heat_index)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht_heat_index, 2);
  }
  Serial.print(",");

  // BMP180 data with error checking
  if (isnan(bmp_temp)) {
    Serial.print("ERROR");
  } else {
    Serial.print(bmp_temp, 2);
  }
  Serial.print(",");

  if (isnan(bmp_sea_level_pressure)) {
    Serial.print("ERROR");
  } else {
    Serial.print(bmp_sea_level_pressure, 2);
  }

  Serial.println(); 
}
