// KY-026 Flame Sensor with Arduino

// Define sensor pins
const int LED_PIN = 13;      // Built-in Arduino LED pin (for indication)
const int DIGITAL_PIN = 8;   // KY-026 Digital output (D0)
const int ANALOG_PIN = A0;   // KY-026 Analog output (A0)

void setup() {
  pinMode(LED_PIN, OUTPUT);      // Set built-in LED as output
  pinMode(DIGITAL_PIN, INPUT);   // Set digital pin as input
  Serial.begin(9600);            // Initialize Serial Monitor
  Serial.println("🔥 KY-026 Flame Sensor Ready 🔥");
}

void loop() {
  int analogVal = analogRead(ANALOG_PIN);   // Read analog sensor value
  int digitalVal = digitalRead(DIGITAL_PIN); // Read digital sensor state

  // Print sensor readings in one clean line
  Serial.print("Analog: "); Serial.print(analogVal);
  Serial.print(" | D0: "); Serial.print(digitalVal ? "🔥 Flame Detected" : "❌ No Flame");
  Serial.println();

  // If a flame is detected (digital output HIGH)
  if (digitalVal == HIGH) {
    digitalWrite(LED_PIN, HIGH); // Turn on LED
  } else {
    digitalWrite(LED_PIN, LOW);  // Turn off LED
  }

  delay(100); // Delay for stability
}
