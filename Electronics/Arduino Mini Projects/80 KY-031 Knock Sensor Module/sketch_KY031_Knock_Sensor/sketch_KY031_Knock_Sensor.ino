int knockPin = 2;  // Pin connected to the KY-031 knock sensor
int ledPin = 13;   // Built-in LED to indicate knock detection
int value = 0;     // Temporary variable to store sensor state

void setup() {
  pinMode(knockPin, INPUT);  // Set knock sensor pin as input
  pinMode(ledPin, OUTPUT);   // Set LED pin as output
  Serial.begin(9600);        // Initialize serial communication
  Serial.println("KY-031 Knock Sensor Test");
}

void loop() {
  value = digitalRead(knockPin);  // Read sensor value

  if (value == LOW) {  // Knock detected
    Serial.println("Knock Detected!");
    digitalWrite(ledPin, HIGH); // Turn on LED
    delay(200); // Debounce delay
  } else {
    digitalWrite(ledPin, LOW); // Turn off LED when no knock is detected
  }
}
