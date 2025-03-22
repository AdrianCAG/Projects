#include <math.h> // Include the math library for logarithmic calculations

// KY-028 Temperature Sensor Module (Analog & Digital)

// Pin Definitions
#define LED_PIN 13         // Built-in LED pin
#define DIGITAL_INPUT 2    // Digital output from the sensor
#define ANALOG_INPUT A0    // Analog output from the sensor

// Variables for sensor readings
int digitalValue;          // Stores digital output value (0 or 1)
int analogValue;           // Stores raw analog output value (0 - 1023)
int correctedAnalog;       // Stores corrected analog value for temperature calculation
float temperatureC;        // Stores temperature in Celsius
float temperatureF;        // Stores temperature in Fahrenheit

void setup() {
  pinMode(LED_PIN, OUTPUT);           // Set LED pin as output
  pinMode(DIGITAL_INPUT, INPUT);       // Set digital input pin
  pinMode(ANALOG_INPUT, INPUT);        // Set analog input pin
  Serial.begin(9600);                  // Initialize serial communication at 9600 baud
}

void loop() {
  // Read analog temperature value
  analogValue = analogRead(ANALOG_INPUT);
  Serial.print("Analog value of the module: ");
  Serial.println(analogValue);

  // Convert the analog reading to match thermistor properties
  correctedAnalog = map(analogValue, 0, 1023, 1023, 0);
  
  // Convert corrected analog value to temperature (Celsius)
  temperatureC = calculateTemperature(correctedAnalog);
  // Convert Celsius to Fahrenheit
  temperatureF = (temperatureC * 9.0) / 5.0 + 32.0;

  // Read digital output (HIGH = threshold exceeded, LOW = below threshold)
  digitalValue = digitalRead(DIGITAL_INPUT);
  Serial.print("Digital value of the module: ");
  Serial.println(digitalValue);

  // LED Control based on digital sensor output
  Serial.print("LED is: ");
  if (digitalValue == HIGH) {
    digitalWrite(LED_PIN, HIGH); // Turn LED ON if temperature threshold exceeded
    Serial.println("ON");
  } else {
    digitalWrite(LED_PIN, LOW);  // Turn LED OFF otherwise
    Serial.println("OFF");
  }

  // Display measured temperature
  Serial.print("Measured Temperature: ");
  Serial.print(temperatureF, 1);
  Serial.print(" °F  ");
  Serial.print(temperatureC, 1);
  Serial.println(" °C");

  Serial.println(); // Print an empty line for readability
  delay(1000); // Wait 1 second before next reading
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
