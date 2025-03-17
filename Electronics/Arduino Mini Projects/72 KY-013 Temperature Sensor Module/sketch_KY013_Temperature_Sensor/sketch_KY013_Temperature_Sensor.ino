// KY-013 Temperature Sensor with Extended Features

// Pin assignment
const int ThermistorPin = A0;  // Analog input pin for thermistor
const float R1 = 10000.0;      // Value of the fixed resistor (10kΩ)

// Steinhart-Hart coefficients for the thermistor
const float c1 = 0.001129148, c2 = 0.000234125, c3 = 0.0000000876741;

// Variables for temperature calculations
float logR2, R2, T_C, T_F;
float minTemp = 1000;  // Initialize with a high value
float maxTemp = -1000; // Initialize with a low value

void setup() {
  Serial.begin(9600); // Initialize serial communication
  Serial.println("KY-013 Temperature Sensor Test");
}

void loop() {
  // Read the analog voltage from the thermistor
  int Vo = analogRead(ThermistorPin);

  // Calculate the thermistor resistance
  R2 = R1 * (1023.0 / (float)Vo - 1.0);
  logR2 = log(R2);

  // Calculate temperature in Kelvin using Steinhart-Hart equation
  float T_K = 1.0 / (c1 + c2 * logR2 + c3 * logR2 * logR2 * logR2);

  // Convert Kelvin to Celsius
  T_C = T_K - 273.15;

  // Convert Celsius to Fahrenheit
  T_F = (T_C * 9.0) / 5.0 + 32.0;

  // Update min and max temperature readings
  if (T_C < minTemp) minTemp = T_C;
  if (T_C > maxTemp) maxTemp = T_C;

  // Print temperature readings
  Serial.print("Temperature: ");
  Serial.print(T_C);
  Serial.print(" °C / ");
  Serial.print(T_F);
  Serial.println(" °F");

  // Display min and max temperature recorded
  Serial.print("Min: ");
  Serial.print(minTemp);
  Serial.print(" °C, Max: ");
  Serial.print(maxTemp);
  Serial.println(" °C");

  // Simple temperature warning system
  if (T_C > 40) {
    Serial.println("WARNING: High Temperature Detected! 🔥");
  } else if (T_C < 5) {
    Serial.println("WARNING: Low Temperature Detected! ❄️");
  }

  Serial.println("-----------------------------"); // Separator for readability
  delay(1000); // Delay before next reading
}
