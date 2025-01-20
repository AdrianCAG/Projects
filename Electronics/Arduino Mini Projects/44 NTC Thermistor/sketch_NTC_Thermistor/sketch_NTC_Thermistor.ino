/**
 * Thermistor Temperature Sensor Example
 * 
 * This program reads temperature data from a thermistor connected to A0 and
 * calculates the temperature in both Celsius and Fahrenheit. The temperature
 * is updated continuously, but the output is printed to the serial monitor
 * once per second.
 * 
 * Constants:
 * - Beta: Beta coefficient of the thermistor (3950 in this case).
 * - Resistance: Value of the pull-up resistor in kilo-ohms (10kΩ).
 * 
 * Connections:
 * - Thermistor Pin -> A0 (Analog input pin)
 * - Other thermistor leg -> GND
 * - Pull-up resistor (10kΩ) connects between 5V and the thermistor leg on A0.
 */

// Pin and Constants
#define ANALOG_PIN A0       // Analog pin connected to the thermistor
#define BETA 3950           // Beta coefficient of the thermistor
#define RESISTANCE 10       // Pull-up resistor value in kilo-ohms

// Timing variables
unsigned long previousMillis = 0; // Store the last time the temperature was printed
const unsigned long interval = 1000; // Interval for printing in milliseconds (1 second)

// Global variables for temperature
float currentTempC = 0;
float currentTempF = 0;

void setup() {
  // Initialize serial communication
  Serial.begin(9600);
  Serial.println("Thermistor Temperature Sensor Initialized");
  Serial.println("=========================================");
}

void loop() {
  // Calculate temperature in Celsius using thermistor formula
  long analogValue = analogRead(ANALOG_PIN);
  currentTempC = BETA / (log((1025.0 * RESISTANCE / analogValue - RESISTANCE) / RESISTANCE) + BETA / 298.0) - 273.0;

  // Convert Celsius to Fahrenheit
  currentTempF = (1.8 * currentTempC) + 32.0;

  // Check if one second has passed
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    // Save the last time the temperature was printed
    previousMillis = currentMillis;

    // Print the temperature readings
    Serial.print("Temperature: ");
    Serial.print(currentTempC, 2); // 2 decimal places for Celsius
    Serial.println(" °C");
    Serial.print("Temperature: ");
    Serial.print(currentTempF, 2); // 2 decimal places for Fahrenheit
    Serial.println(" °F");

    // Display status based on temperature
    Serial.print("Status: ");
    if (currentTempC < 15) {
      Serial.println("Cold");
    } else if (currentTempC < 25) {
      Serial.println("Comfortable");
    } else if (currentTempC < 35) {
      Serial.println("Warm");
    } else {
      Serial.println("Hot");
    }

    Serial.println("-----------------------------------------");
  }
}
