// KY-021 Reed Switch Sensor Example
// This program detects the presence of a magnetic field using the KY-021 module.

const int reedPin = 8;    // Pin where the KY-021 reed switch is connected
const int ledPin = 13;    // Built-in LED pin to indicate magnet detection
int sensorState;          // Variable to store sensor state
int lastState = HIGH;     // Stores the previous sensor state (for debouncing)
unsigned long lastDebounceTime = 0; // Stores last time the state changed
const int debounceDelay = 50;  // Debounce delay in milliseconds

void setup() {
  pinMode(reedPin, INPUT);  // Set the sensor pin as input
  pinMode(ledPin, OUTPUT);  // Set the LED pin as output
  Serial.begin(9600);       // Initialize the serial monitor
  Serial.println("KY-021 Magnetic Field Detection Initialized");
}

void loop() {
  // Read the current state of the reed switch
  int currentState = digitalRead(reedPin);

  // Debouncing: Only process a state change if it's stable for a certain time
  if (currentState != lastState) {
    lastDebounceTime = millis(); // Reset debounce timer
  }
  
  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (currentState == LOW) {
      // Magnet is near (switch is closed)
      Serial.println("Magnetic field detected! ⚡");
      digitalWrite(ledPin, HIGH); // Turn LED on
    } else {
      // No magnetic field detected
      digitalWrite(ledPin, LOW);  // Turn LED off
    }
  }

  lastState = currentState; // Save current state for next loop
}
