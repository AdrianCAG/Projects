/*
  Tap Counter with Silent Tapping
  Counts the number of taps on a touch sensor within 5 seconds and displays the total at the end.
  Includes a 2-second delay before starting a new countdown.
*/

// Pin definition
const int touchPin = 2;    // Pin number for the touch sensor

// Timing and state variables
int touchState = 0;        // Current state of the touch sensor
int lastTouchState = 0;    // Previous state of the touch sensor
int tapCount = 0;          // Counter for the number of taps
unsigned long startTime;   // Start time for the 5-second window
const unsigned long duration = 5000; // Countdown duration in milliseconds

void setup() {
  Serial.begin(9600);              // Initialize serial communication
  pinMode(touchPin, INPUT);        // Set the touch sensor pin as an input
  Serial.println("Tap Counter Initialized.");
  delay(2000);                     // Initial 2-second delay before starting
  startTime = millis();            // Record the start time
}

void loop() {
  // Read the current state of the touch sensor
  touchState = digitalRead(touchPin);

  // Detect a tap (transition from LOW to HIGH)
  if (touchState == HIGH && lastTouchState == LOW) {
    tapCount++;  // Increment the tap counter
  }

  // Update the previous state
  lastTouchState = touchState;

  // Check if the countdown has finished
  unsigned long elapsedTime = millis() - startTime;
  if (elapsedTime >= duration) {
    // Output the total number of taps
    Serial.print("Countdown finished! Total taps: ");
    Serial.println(tapCount);

    // Reset for a new round
    tapCount = 0;             // Reset tap counter
    delay(2000);              // Wait for 2 seconds before restarting
    startTime = millis();     // Restart the timer
    Serial.println("New countdown started!");
  }

  delay(10);  // Small delay for stability
}
