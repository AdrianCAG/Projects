/*
 * MQ-4 Methane Gas Sensor Monitoring Program
 * This program reads the analog and digital outputs from the MQ-4 sensor to monitor methane gas concentration.
 * An LED indicator lights up when the methane concentration crosses the threshold.
 * Sensor readings are displayed on the Serial Monitor for real-time monitoring.
 */

// Pin Definitions
const int AO_Pin = A0;      // Analog Output pin (AO) of the MQ-4 sensor connected to analog pin A0
const int DO_Pin = 8;       // Digital Output pin (DO) of the MQ-4 sensor connected to digital pin 8
const int LED_Pin = 13;     // LED indicator connected to digital pin 13

// Variables to store sensor readings
int threshold;              // Digital output from the MQ-4 sensor (HIGH or LOW)
int AO_Out;                 // Analog output from the MQ-4 sensor (0-1023)

void setup() {
  // Initialize Serial Monitor for debugging and output messages
  Serial.begin(115200);

  // Set pin modes
  pinMode(DO_Pin, INPUT);   // Configure DO_Pin as an input
  pinMode(LED_Pin, OUTPUT); // Configure LED_Pin as an output

  // Welcome message on the Serial Monitor
  Serial.println("MQ-4 Methane Gas Sensor Program Initialized");
  Serial.println("Monitoring methane concentration...");
}

void loop() {
  // Read the sensor outputs
  AO_Out = analogRead(AO_Pin);      // Get the analog value (methane concentration)
  threshold = digitalRead(DO_Pin);  // Get the digital output (threshold status)

  // Display sensor readings on the Serial Monitor
  Serial.print("Threshold Reached: "); // Label for digital output
  Serial.print(threshold == LOW ? "Yes" : "No"); // Show "No" if HIGH, otherwise "Yes"
  Serial.print(", "); // Separator for readability

  Serial.print("Methane Concentration (Analog Value): "); // Label for analog value
  Serial.println(AO_Out); // Display the methane concentration (0-1023)

  // Control LED based on threshold status
  if (!threshold == HIGH) {
    digitalWrite(LED_Pin, HIGH);   // Turn the LED ON if threshold is reached
  } else {
    digitalWrite(LED_Pin, LOW);    // Turn the LED OFF if threshold is not reached
  }

  // Add a brief delay to avoid overwhelming the Serial Monitor
  delay(1000); // Delay for 1 second before the next reading
}