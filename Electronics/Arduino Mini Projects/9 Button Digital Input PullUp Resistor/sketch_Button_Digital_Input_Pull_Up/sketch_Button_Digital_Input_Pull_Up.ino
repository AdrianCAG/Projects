// Button State Monitoring Program
// This program reads the state of a button connected to pin 2, prints its state to the Serial Monitor,
// and provides visual feedback via the Serial Monitor when the button is pressed or released.

void setup() {
  // Initialize the Serial Monitor at a baud rate of 9600
  Serial.begin(9600);

  // Configure pin 2 as an input with an internal pull-up resistor
  pinMode(2, INPUT_PULLUP);

  // Print an initial message to the Serial Monitor
  Serial.println("Button State Monitoring Initialized");
  Serial.println("Press the button to see its state in the Serial Monitor");
  Serial.println("------------------------------------");
}

void loop() {
  // Read the state of the button (LOW = pressed, HIGH = not pressed)
  int buttonState = digitalRead(2);

  // Print the button state to the Serial Monitor
  if (buttonState == LOW) {
    Serial.println("Button Pressed");
  } else {
    Serial.println("Button Not-Pressed");
  }

  // Add a slight delay to stabilize the readings
  delay(200); // Adjust delay as needed
}