// KY-035 Hall Effect Sensor with Arduino (Analog Only)
// Detects both positive (north pole) and negative (south pole) magnetic fields

#define LED_PIN 13       // Built-in LED on Arduino
#define ANALOG_PIN A0    // Analog output from KY-035

void setup() {
  pinMode(LED_PIN, OUTPUT);  // Set built-in LED as output
  Serial.begin(9600);        // Initialize serial communication
}

void loop() {
  int analogValue = analogRead(ANALOG_PIN); // Read analog sensor value

  // Thresholds for detecting positive and negative magnetic fields
  int thresholdLow = 300;   // Adjust based on testing
  int thresholdHigh = 700;  // Adjust based on testing

  String fieldState = "⚪ No magnetic field";  // Default state
  bool ledState = LOW; // Default LED state

  if (analogValue < thresholdLow) {  
    fieldState = "🔴 SOUTH pole detected";  // Strong Negative Magnetic Field
    ledState = HIGH;
  } 
  else if (analogValue > thresholdHigh) { 
    fieldState = "🔵 NORTH pole detected";  // Strong Positive Magnetic Field
    ledState = HIGH;
  }

  digitalWrite(LED_PIN, ledState);  // Update LED state

  // Print sensor values and detected field state
  Serial.print("Analog: "); Serial.print(analogValue);
  Serial.print(" | "); Serial.println(fieldState);

  delay(200); // Delay to avoid rapid readings
}
