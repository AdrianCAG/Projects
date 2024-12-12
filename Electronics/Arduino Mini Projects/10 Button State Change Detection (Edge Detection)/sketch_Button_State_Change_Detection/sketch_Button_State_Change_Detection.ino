// Button State Toggle and Serial Output Program
// This program toggles a detection state variable between 0 and 1 when a button is pressed.
// The current state is printed to the Serial Monitor only when the button is pressed.

const int buttonPin = 2;   // Pin connected to the button
int detectionState = 0;    // Variable to store the current detection state (0 or 1)
int buttonState = 0;       // Variable to store the current button state
int lastButtonState = 0;   // Variable to store the previous button state
unsigned long pressTime = 0; // Stores the time the button is pressed
unsigned long releaseTime = 0; // Stores the time the button is released

void setup() {
  // Set up the button pin as an input
  pinMode(buttonPin, INPUT);

  // Initialize the Serial Monitor
  Serial.begin(9600);

  // Print an introductory message to the Serial Monitor
  Serial.println("Button State Toggle Program");
  Serial.println("-----------------------------------");
  Serial.println("Press the button to toggle the state.");
}

void loop() {
  // Read the current state of the button
  buttonState = digitalRead(buttonPin);

  // Detect changes in the button state
  if (buttonState != lastButtonState) {
    // If the button is pressed (state is HIGH)
    if (buttonState == HIGH) {
      // Capture the time of the press
      pressTime = millis();

      // Toggle the detection state (0 to 1, or 1 to 0)
      detectionState = (detectionState + 1) % 2;

      // Print the detection state to the Serial Monitor
      Serial.print("The detection state is now: ");
      Serial.println(detectionState);
    } else {
      // Capture the time of the release
      releaseTime = millis();

      // Calculate and display the duration the button was held
      Serial.print("Button held for (ms): ");
      Serial.println(releaseTime - pressTime);
    }

    // Add a delay to debounce the button
    delay(50);
  }

  // Update the last button state for the next loop iteration
  lastButtonState = buttonState;
}
