/*
 * Combined Project: Air Quality & Environmental Safety Monitor (Arduino Mega 2560) - CSV Output Format
 *
 * This sketch combines sensors from both Air Quality and Environmental Safety monitors:
 *
 * Air Quality Sensors:
 * - MQ2 (Smoke/Gas) - Raw Values - Analog Pin A0
 * - MQ3 (Alcohol) - Raw Values - Analog Pin A1
 * - MQ135 (Air Quality) - Raw Values - Analog Pin A2
 * - DHT11 (Temperature/Humidity/Heat Index) - Digital Pin 4
 * - BMP180 (Temperature/Sea Level Pressure) - I2C (SDA: Pin 20, SCL: Pin 21)
 *
 * Environmental & Safety Sensors:
 * - MQ4 (Methane/Natural Gas) - Raw Values - Analog Pin A3
 * - MQ5 (LPG/Natural Gas) - Raw Values - Analog Pin A4
 * - MQ6 (LPG/Butane) - Raw Values - Analog Pin A5
 * - MQ7 (Carbon Monoxide) - Raw Values - Analog Pin A6
 * - MQ8 (Hydrogen) - Raw Values - Analog Pin A7
 * - MQ9 (LPG/CO/CH4) - Raw Values - Analog Pin A8
 * - MQ139 (Freon/other gases) - Raw Values - Analog Pin A9
 * - DHT11 (Temperature/Humidity/Heat Index) - Digital Pin 2
 * - KY-028 (Temperature) - Raw Values - Analog Pin A11
 *
 * Output: CSV format for easy conversion to graphs and analysis
 * Sampling Rate: Every 5 seconds (optimal balance for all sensors)
 *
 * Required Libraries:
 * - DHT sensor library by Adafruit (for DHT22 and DHT11)
 * - Adafruit BMP085 Library (works with BMP180)
 *
 * Wiring:
 * MQ2: VCC->5V, GND->GND, A0->A0
 * MQ3: VCC->5V, GND->GND, A0->A1
 * MQ135: VCC->5V, GND->GND, A0->A2
 * MQ4: VCC->5V, GND->GND, A0->A3
 * MQ5: VCC->5V, GND->GND, A0->A4
 * MQ6: VCC->5V, GND->GND, A0->A5
 * MQ7: VCC->5V, GND->GND, A0->A6
 * MQ8: VCC->5V, GND->GND, A0->A7
 * MQ9: VCC->5V, GND->GND, A0->A8
 * MQ139: VCC->5V, GND->GND, A0->A9
 * DHT11_2: VCC->5V, GND->GND, Data->Pin 4
 * DHT11_1: VCC->5V, GND->GND, Data->Pin 2
 * BMP180: VCC->3.3V, GND->GND, SDA->Pin 20, SCL->Pin 21
 * KY-028: VCC->5V, GND->GND, A0->A11
 *
 * Notes:
 * - MQ sensors need 24-48 hour burn-in period for accurate readings
 * - Allow 30-60 seconds warm-up time on startup for MQ sensor stability
 * - Data can be captured using Serial Monitor and saved to CSV file
 * - Arduino Mega 2560 required for sufficient analog pins
 */

// Include necessary libraries
#include <DHT.h>     // Using Adafruit DHT library for both DHT11 and DHT22
#include <Wire.h>
#include <SFE_BMP180.h>
#include <math.h>     // For logarithmic calculations

// Pin definitions - Air Quality Sensors
#define DHT11_2_PIN 4   // Second DHT11 data pin (replaces former DHT22)
#define MQ2_PIN A0      // MQ2 analog pin
#define MQ3_PIN A1      // MQ3 analog pin
#define MQ135_PIN A2    // MQ135 analog pin

// Pin definitions - Environmental & Safety Sensors
#define DHT11_PIN 2     // DHT11 data pin
#define MQ4_PIN A3      // MQ4 analog pin
#define MQ5_PIN A4      // MQ5 analog pin
#define MQ6_PIN A5      // MQ6 analog pin
#define MQ7_PIN A6      // MQ7 analog pin
#define MQ8_PIN A7      // MQ8 analog pin
#define MQ9_PIN A8      // MQ9 analog pin
#define MQ139_PIN A9    // MQ139 analog pin
#define KY028_PIN A11   // KY-028 Temperature analog pin

// Sensor type definitions
#define DHT11TYPE DHT11 // DHT11

// Initialize sensors
DHT dht11_1(DHT11_PIN, DHT11TYPE);  // First DHT11 sensor using Adafruit library
DHT dht11_2(DHT11_2_PIN, DHT11TYPE);  // Second DHT11 sensor using Adafruit library
SFE_BMP180 bmp180;              // BMP180 sensor

// Configuration
const unsigned long SAMPLE_INTERVAL = 1000; // 5 seconds between readings
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

  // Initialize DHT11 sensors
  dht11_1.begin();
  dht11_2.begin();

  // Initialize BMP180
  bmp180.begin();

  // Allow sensors to stabilize (important for MQ sensors)
  delay(3000);
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
  Serial.println("MQ2_Raw,MQ3_Raw,MQ135_Raw,MQ4_Raw,MQ5_Raw,MQ6_Raw,MQ7_Raw,MQ8_Raw,MQ9_Raw,MQ139_Raw,DHT11_1_Temp_C,DHT11_1_Humidity_%,DHT11_1_HeatIndex_C,DHT11_2_Temp_C,DHT11_2_Humidity_%,DHT11_2_HeatIndex_C,BMP180_Temp_C,BMP180_SeaLevel_Pressure_hPa,KY028_Temp_C");
}

void takeReadingsAndOutputCSV() {
  // Read all MQ sensors (raw values only)
  int mq2_raw = analogRead(MQ2_PIN);
  int mq3_raw = analogRead(MQ3_PIN);
  int mq135_raw = analogRead(MQ135_PIN);
  int mq4_raw = analogRead(MQ4_PIN);
  int mq5_raw = analogRead(MQ5_PIN);
  int mq6_raw = analogRead(MQ6_PIN);
  int mq7_raw = analogRead(MQ7_PIN);
  int mq8_raw = analogRead(MQ8_PIN);
  int mq9_raw = analogRead(MQ9_PIN);
  int mq139_raw = analogRead(MQ139_PIN);

  // Read DHT11 sensors
  float dht11_1_temp = dht11_1.readTemperature();
  float dht11_1_humidity = dht11_1.readHumidity();
  float dht11_1_heat_index = NAN;

  if (!isnan(dht11_1_temp) && !isnan(dht11_1_humidity)) {
    dht11_1_heat_index = dht11_1.computeHeatIndex(dht11_1_temp, dht11_1_humidity, false);
  }

  float dht11_2_temp = dht11_2.readTemperature();
  float dht11_2_humidity = dht11_2.readHumidity();
  float dht11_2_heat_index = NAN;

  if (!isnan(dht11_2_temp) && !isnan(dht11_2_humidity)) {
    dht11_2_heat_index = dht11_2.computeHeatIndex(dht11_2_temp, dht11_2_humidity, false);
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

  // Read KY-028 and calculate temperature in Celsius
  int ky028_analog = analogRead(KY028_PIN);
  int correctedAnalog = map(ky028_analog, 0, 1023, 1023, 0);
  float ky028_temp_c = calculateTemperature(correctedAnalog);

  // Output all MQ sensor raw values
  Serial.print(mq2_raw);
  Serial.print(",");
  Serial.print(mq3_raw);
  Serial.print(",");
  Serial.print(mq135_raw);
  Serial.print(",");
  Serial.print(mq4_raw);
  Serial.print(",");
  Serial.print(mq5_raw);
  Serial.print(",");
  Serial.print(mq6_raw);
  Serial.print(",");
  Serial.print(mq7_raw);
  Serial.print(",");
  Serial.print(mq8_raw);
  Serial.print(",");
  Serial.print(mq9_raw);
  Serial.print(",");
  Serial.print(mq139_raw);
  Serial.print(",");

  // DHT11_1 data with error checking
  if (isnan(dht11_1_temp)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht11_1_temp, 1);
  }
  Serial.print(",");

  if (isnan(dht11_1_humidity)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht11_1_humidity, 1);
  }
  Serial.print(",");

  if (isnan(dht11_1_heat_index)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht11_1_heat_index, 1);
  }
  Serial.print(",");

  // DHT11_2 data with error checking
  if (isnan(dht11_2_temp)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht11_2_temp, 1);
  }
  Serial.print(",");

  if (isnan(dht11_2_humidity)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht11_2_humidity, 1);
  }
  Serial.print(",");

  if (isnan(dht11_2_heat_index)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht11_2_heat_index, 1);
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
  Serial.print(",");

  // Additional analog sensors values
  Serial.print(ky028_temp_c, 1);

  Serial.println(); 
}

// Function to calculate temperature from raw ADC value for KY-028
double calculateTemperature(int rawADC) {
  double temp;
  // Convert raw ADC value using the Steinhart-Hart equation
  temp = log((10240000 / rawADC) - 10000);
  temp = 1 / (0.001129148 + (0.000234125 * temp) + (0.0000000876741 * temp * temp * temp));
  temp -= 273.15; // Convert Kelvin to Celsius
  return temp;
}