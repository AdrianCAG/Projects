// Pin definitions
int tiltPin = 3;      // Pin number for the tilt switch signal
int tiltState = 0;    // Variable to store the current tilt switch state

// Setup function, runs once when the program starts
void setup() {
  // Initialize tilt switch pin as an input
  pinMode(tiltPin, INPUT);  
  
  // Print a message to the serial monitor for debugging purposes
  Serial.begin(9600);  
  Serial.println("Tilt switch is ready. Please tilt the switch to test.");
}

// Main loop function, runs continuously after setup()
void loop() {
  // Read the current state of the tilt switch
  tiltState = digitalRead(tiltPin);

  // Check if the tilt switch is tilted (signal HIGH)
  if (tiltState == HIGH) {    
    // If tilted, print tilt detected to the serial monitor
    Serial.println("Tilt detected.");
  } 
  else {
    // If not tilted, print no tilt detected to the serial monitor
    Serial.println("No tilt detected.");
  }

  // Add a short delay for better readability of serial monitor output
  delay(100);  // Delay for 100 milliseconds (can be adjusted)
}
