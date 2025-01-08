/*
  Program to read the state of a switch connected to pin 2 
  and print its state to the Serial Monitor.
  This code demonstrates basic digital input handling.
*/

// Define the pin for the switch
const int switchPin = 2;

// Variable to store the switch state
int switchState = 0;

void setup() {
  // Initialize the Serial Monitor
  Serial.begin(9600);
  Serial.println("Switch State Monitor Initialized");
  
  // Set the switch pin as an input
  pinMode(switchPin, INPUT);

  // Provide an initial status message
  Serial.println("Waiting for switch state changes...");
}

void loop() {
  // Read the state of the switch
  switchState = digitalRead(switchPin);
  
  // Print the switch state to the Serial Monitor
  if (switchState == HIGH) {
    Serial.println("Switch is ON");
  } else {
    Serial.println("Switch is OFF");
  }

  // Add a small delay for stability
  delay(500); // Increased delay to make output readable
}
