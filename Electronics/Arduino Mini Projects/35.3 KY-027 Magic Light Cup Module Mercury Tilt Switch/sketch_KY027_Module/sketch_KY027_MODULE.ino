// Pin definitions
int ledPin = 9;         // Pin number for controlling the LED (PWM pin)
int switchPin = 8;      // Pin number for the tilt switch signal (S pin)
int switchState = 0;    // Variable for reading the current tilt switch state
int brightness = 0;     // Variable for storing LED brightness (0-255)

// Setup function: runs once when the program starts
void setup() {
  pinMode(ledPin, OUTPUT);     // Set the LED pin as an output to control LED
  pinMode(switchPin, INPUT);   // Set the tilt switch pin as an input to read the switch state

  // Initialize serial communication for debugging (optional, useful for monitoring values)
  Serial.begin(9600);
  Serial.println("Tilt Switch LED Control Initialized");
}

// Main loop: runs continuously after setup
void loop() {
  // Read the current state of the tilt switch (HIGH = tilted, LOW = not tilted)
  switchState = digitalRead(switchPin);

  // If the switch is tilted (signal HIGH), increase brightness up to 255
  if (switchState == HIGH && brightness < 255) {
    brightness++;  // Increase brightness by 1
  } 
  
  // If the switch is not tilted (signal LOW), decrease brightness down to 0
  else if (switchState == LOW && brightness > 0) {
    brightness--;  // Decrease brightness by 1
  }

  // Control the LED brightness using PWM based on the tilt switch state
  analogWrite(ledPin, brightness);

  // If the brightness reaches 255, make the LED blink (ON for 500ms, OFF for 500ms)
  if (brightness == 255) {
    blinkLED();
  }

  // Print current values of brightness and switch state to the serial monitor
  Serial.print("Brightness: ");
  Serial.print(brightness);
  Serial.print(" | Switch State: ");
  Serial.println(switchState);

  // Small delay to allow for smoother operation and better readability of serial monitor output
  delay(20);  
}

// Function to make the LED blink when it reaches full brightness (255)
void blinkLED() {
  // Blink LED when full brightness is reached
  digitalWrite(ledPin, HIGH);  // Turn the LED ON
  delay(500);                  // Keep the LED ON for 500 milliseconds
  digitalWrite(ledPin, LOW);   // Turn the LED OFF
  delay(500);                  // Keep the LED OFF for 500 milliseconds
}
