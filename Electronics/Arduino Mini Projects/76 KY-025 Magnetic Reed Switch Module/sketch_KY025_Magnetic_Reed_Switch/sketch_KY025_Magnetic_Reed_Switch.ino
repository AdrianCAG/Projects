// KY-025 Reed Switch Sensor with Arduino

// Define pin connections
const int LED_PIN = 13;       // Built-in LED pin
const int DIGITAL_PIN = 2;    // KY-025 digital output pin
const int ANALOG_PIN = A0;    // KY-025 analog output pin

void setup() {
  pinMode(LED_PIN, OUTPUT);      // Set LED pin as output
  pinMode(DIGITAL_PIN, INPUT);   // Set KY-025 digital pin as input
  Serial.begin(9600);            // Initialize Serial Monitor
  Serial.println("KY-025 Magnetic Sensor Initialized");
}

void loop() {
  readSensor(); // Call the function to read the sensor values
  delay(100);   // Short delay to avoid spamming serial output
}

// Function to read digital and analog values from KY-025
void readSensor() {
  int digitalVal = digitalRead(DIGITAL_PIN); // Read digital state
  int analogVal = analogRead(ANALOG_PIN);    // Read analog value

  // Check if magnetic field is detected
  if (digitalVal == HIGH) {
    digitalWrite(LED_PIN, HIGH); // Turn on the LED
    Serial.print("🧲 Magnetic Field Detected | ");
  } else {
    digitalWrite(LED_PIN, LOW); // Turn off the LED
    Serial.print("❌ No Magnetic Field | ");
  }

  // Print analog reading for debugging
  Serial.print("Analog Value: ");
  Serial.println(analogVal);
}
