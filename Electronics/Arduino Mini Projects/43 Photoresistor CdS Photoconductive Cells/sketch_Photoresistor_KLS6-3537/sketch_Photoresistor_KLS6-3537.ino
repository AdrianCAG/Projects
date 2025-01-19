/**
 * Analog Sensor Reading Example
 * 
 * This program reads data from an analog sensor connected to pin A0
 * and outputs the value to the Serial Monitor.
 * 
 * Features:
 * - Real-time reading of sensor values
 * - Displays normalized percentage (0-100%) for better interpretation
 * - Adjustable delay between readings for smoother monitoring
 * 
 * Hardware Connections:
 * - Sensor signal pin -> A0
 * - Power (VCC) -> 5V or 3.3V
 * - Ground (GND) -> GND
 */

// Pin Definitions
const int SENSOR_PIN = A0; // Analog pin for sensor input

// Constants
const int SENSOR_MIN = 0;     // Minimum expected analog value
const int SENSOR_MAX = 1023;  // Maximum expected analog value

void setup() {
    // Initialize serial communication at 9600 bps
    Serial.begin(9600);

    // Print a startup message
    Serial.println("Analog Sensor Reading Started!");
    Serial.println("Reading values from sensor on pin A0...\n");
}

void loop() {
    // Read the raw analog value from the sensor
    int rawValue = analogRead(SENSOR_PIN);

    // Normalize the value to a percentage (0-100%)
    float normalizedValue = map(rawValue, SENSOR_MIN, SENSOR_MAX, 0, 100);

    // Print the raw value and normalized percentage to Serial Monitor
    Serial.print("Raw Value: ");
    Serial.print(rawValue);
    Serial.print(" | Normalized: ");
    Serial.print(normalizedValue, 1); // One decimal precision
    Serial.println(" %");

    // Add a small delay for readability
    delay(100); // Delay in milliseconds (adjust as needed)
}
