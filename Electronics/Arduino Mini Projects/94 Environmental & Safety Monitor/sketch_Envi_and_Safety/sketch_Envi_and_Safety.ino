/*
 * Project 2: Environmental & Safety Monitor (Arduino Mega 2560) - CSV Output Format
 * 
 * Sensors:
 * - MQ4 (Methane/Natural Gas) - Raw Values - Analog Pin A0
 * - MQ5 (LPG/Natural Gas) - Raw Values - Analog Pin A1
 * - MQ6 (LPG/Butane) - Raw Values - Analog Pin A2
 * - MQ7 (Carbon Monoxide) - Raw Values - Analog Pin A3
 * - MQ8 (Hydrogen) - Raw Values - Analog Pin A4
 * - MQ9 (LPG/CO/CH4) - Raw Values - Analog Pin A5
 * - MQ139 (Freon/other gases) - Raw Values - Analog Pin A6
 * - DHT11 (Temperature/Humidity/Heat Index) - Digital Pin 2

 * - KY-028 (Temperature) - Raw Values - Analog Pin A8
 * 
 * Output: CSV format for easy conversion to graphs and analysis
 * Sampling Rate: Every 6 seconds (optimal for multiple MQ sensors)
 * 
 * Wiring:
 * MQ4: VCC->5V, GND->GND, A0->A0
 * MQ5: VCC->5V, GND->GND, A0->A1
 * MQ6: VCC->5V, GND->GND, A0->A2
 * MQ7: VCC->5V, GND->GND, A0->A3
 * MQ8: VCC->5V, GND->GND, A0->A4
 * MQ9: VCC->5V, GND->GND, A0->A5
 * MQ139: VCC->5V, GND->GND, A0->A6
 * DHT11: VCC->5V, GND->GND, Data->Pin 2, 10k pullup resistor between VCC and Data

 * KY-028: VCC->5V, GND->GND, A0->A8
 * 
 * Notes:
 * - MQ sensors need 24-48 hour burn-in period for accurate readings
 * - 30-second warm-up time on startup for MQ sensor stability
 * - Sampling every 6 seconds for optimal sensor performance
 * - Raw values displayed for all analog sensors
 * - Calculated values for DHT11 (temperature, humidity, heat index)
 * Data can be captured using Serial Monitor and saved to CSV file
 */

// Include necessary libraries
#include <dht.h>
#include <math.h> // Include the math library for logarithmic calculations

// Pin definitions
#define DHTPIN 4        // DHT11 data pin
#define MQ4_PIN A0      // MQ4 analog pin
#define MQ5_PIN A1      // MQ5 analog pin
#define MQ6_PIN A2      // MQ6 analog pin
#define MQ7_PIN A3      // MQ7 analog pin
#define MQ8_PIN A4      // MQ8 analog pin
#define MQ9_PIN A5      // MQ9 analog pin
#define MQ139_PIN A6    // MQ139 analog pin

#define KY028_PIN A8    // KY-028 Temperature analog pin

// Initialize sensors
dht DHT;

// Configuration
const unsigned long SAMPLE_INTERVAL = 6000; // 6 seconds between readings
unsigned long previousMillis = 0;
bool headersWritten = false;

void setup() {
  // Initialize serial communication
  Serial.begin(9600);

  // Wait for serial port to connect
  while (!Serial) {
    ; // Wait for serial port to connect
  }

  // DHT11 sensor ready (no initialization needed)

  // Allow sensors to stabilize (30 seconds for MQ sensor warm-up)
  delay(30000);
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
  Serial.println("MQ4_Raw,MQ5_Raw,MQ6_Raw,MQ7_Raw,MQ8_Raw,MQ9_Raw,MQ139_Raw,DHT11_Temp_C,DHT11_Humidity_%,DHT11_HeatIndex_C,KY028_Temp_C");
}

void takeReadingsAndOutputCSV() {
  // Read MQ sensors (raw values only)
  int mq4_raw = analogRead(MQ4_PIN);
  int mq5_raw = analogRead(MQ5_PIN);
  int mq6_raw = analogRead(MQ6_PIN);
  int mq7_raw = analogRead(MQ7_PIN);
  int mq8_raw = analogRead(MQ8_PIN);
  int mq9_raw = analogRead(MQ9_PIN);
  int mq139_raw = analogRead(MQ139_PIN);

  // Read additional analog sensors
  
  // Read KY-028 and calculate temperature in Celsius
  int ky028_analog = analogRead(KY028_PIN);
  int correctedAnalog = map(ky028_analog, 0, 1023, 1023, 0);
  float ky028_temp_c = calculateTemperature(correctedAnalog);

  // Read DHT11 sensor
  int chk = DHT.read11(DHTPIN);
  float dht_temp = DHT.temperature;
  float dht_humidity = DHT.humidity;
  float dht_heat_index = NAN;

  // Calculate heat index if temperature and humidity are valid (simple approximation)
  if (chk == DHTLIB_OK && dht_temp > 0 && dht_humidity > 0) {
    dht_heat_index = dht_temp + 0.5555 * (6.11 * exp(5417.7530 * (1/273.16 - 1/(273.16 + dht_humidity/100.0 * dht_temp))) - 10.0);
  }

  // Output MQ sensor raw values
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

  // DHT11 data with error checking
  if (chk != DHTLIB_OK) {
    Serial.print("ERROR");
  } else {
    Serial.print(DHT.temperature, 1);
  }
  Serial.print(",");

  if (chk != DHTLIB_OK) {
    Serial.print("ERROR");
  } else {
    Serial.print(DHT.humidity, 1);
  }
  Serial.print(",");

  if (chk != DHTLIB_OK || isnan(dht_heat_index)) {
    Serial.print("ERROR");
  } else {
    Serial.print(dht_heat_index, 1);
  }
  Serial.print(",");

  // Additional analog sensors values
  Serial.print(ky028_temp_c, 1);

  Serial.println(); 
}

// Function to calculate temperature from raw ADC value
double calculateTemperature(int rawADC) {
  double temp;
  // Convert raw ADC value using the Steinhart-Hart equation
  temp = log((10240000 / rawADC) - 10000);
  temp = 1 / (0.001129148 + (0.000234125 * temp) + (0.0000000876741 * temp * temp * temp));
  temp -= 273.15; // Convert Kelvin to Celsius
  return temp;
}