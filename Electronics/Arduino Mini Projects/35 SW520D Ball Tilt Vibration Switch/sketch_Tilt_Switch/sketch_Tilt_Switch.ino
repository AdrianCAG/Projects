/*
  Project: Tilt Switch State Logger
  Description: This program reads the state of a tilt switch connected to pin 2,
               displays its state (HIGH/LOW) on the Serial Monitor, and counts 
               the number of tilts detected.
  Components:
    - Tilt switch (connected to pin 2)
    - 10kΩ pull-down resistor
    - Optional 104 capacitor for debounce
  Additional Features:
    - Count and log the number of tilts detected
    - Enhanced feedback with state change detection
*/

const int tiltPin = 2;       // Pin where the tilt switch is connected
int tiltState = LOW;         // Current state of the tilt switch
int lastTiltState = LOW;     // Last recorded state of the tilt switch
int tiltCount = 0;           // Counter to keep track of tilt events

void setup() {
  // Initialize Serial Monitor
  Serial.begin(9600);
  Serial.println("Tilt Switch Logger Initialized");

  // Set tilt switch pin as input
  pinMode(tiltPin, INPUT);

  // Initial status message
  Serial.println("Ready to detect tilt events.");
}

void loop() {
  // Read the current state of the tilt switch
  tiltState = digitalRead(tiltPin);

  // Check if the state has changed
  if (tiltState != lastTiltState) {
    if (tiltState == HIGH) {
      // State changed to HIGH
      tiltCount++; // Increment the tilt counter
      Serial.println("Tilt detected! State: HIGH");
      Serial.print("Tilt Count: ");
      Serial.println(tiltCount);
    } else {
      // State changed to LOW
      Serial.println("Tilt stopped. State: LOW");
    }
  }

  // Update the last recorded state
  lastTiltState = tiltState;

  // Delay for debounce and readability
  delay(200);
}
