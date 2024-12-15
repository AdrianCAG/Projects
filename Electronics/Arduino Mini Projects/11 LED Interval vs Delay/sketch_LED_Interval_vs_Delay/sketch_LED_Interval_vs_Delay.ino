/*
 * LED Blink Without Delay
 * 
 * This program toggles an LED connected to pin 9 on and off at regular intervals
 * using the millis() function to avoid blocking delays. It also provides feedback
 * via the Serial Monitor each time the LED state changes.
 * 
 * Additional Features:
 * - Displays the current LED state (ON/OFF) in the Serial Monitor.
 * - Allows dynamic adjustment of the blink interval via the Serial Monitor.
 */

const int ledPin = 9;                  // Pin connected to the LED
int ledState = LOW;                     // Current state of the LED (LOW = OFF, HIGH = ON)
unsigned long previousMillis = 0;       // Stores the last time the LED was updated
unsigned long interval = 1000;          // Interval at which to blink the LED (milliseconds)

// Variables for dynamic interval adjustment
bool intervalChanged = false;           // Flag to indicate if the interval has been changed
unsigned long newInterval = 0;          // Variable to store the new interval value

void setup() {
  // Initialize the LED pin as an output
  pinMode(ledPin, OUTPUT);
  
  // Initialize Serial communication at 9600 baud rate for debugging and user input
  Serial.begin(9600);
  
  // Print an introductory message to the Serial Monitor
  Serial.println("LED Blink Without Delay Initialized");
  Serial.print("Current Blink Interval: ");
  Serial.print(interval);
  Serial.println(" ms");
  Serial.println("Type a new interval in milliseconds and press Enter to change the blink rate.");
  Serial.println("---------------------------------------------");
}

void loop() {
  // Get the current time in milliseconds since the program started
  unsigned long currentMillis = millis();

  // Check if the interval has passed
  if (currentMillis - previousMillis >= interval) {
    // Save the last time the LED was toggled
    previousMillis = currentMillis;

    // Toggle the LED state
    ledState = (ledState == LOW) ? HIGH : LOW;

    // Apply the new LED state
    digitalWrite(ledPin, ledState);

    // Print the new LED state to the Serial Monitor
    Serial.print("LED is now: ");
    Serial.println((ledState == HIGH) ? "ON" : "OFF");
  }

  // Check if there is any data available on the Serial Monitor
  if (Serial.available() > 0) {
    // Read the incoming data as a string
    String inputString = Serial.readStringUntil('\n');
    inputString.trim(); // Remove any leading/trailing whitespace

    // Attempt to convert the input string to an unsigned long integer
    unsigned long parsedValue = inputString.toInt();

    // Validate the parsed value
    if (parsedValue > 0) {
      // Update the interval with the new value
      newInterval = parsedValue;
      interval = newInterval;
      intervalChanged = true;

      // Provide feedback to the user
      Serial.print("Blink interval updated to: ");
      Serial.print(interval);
      Serial.println(" ms");
    } else {
      // Inform the user of invalid input
      Serial.println("Invalid input. Please enter a positive integer for the interval in milliseconds.");
    }

    Serial.println("---------------------------------------------");
  }

  // Optional: Handle any additional tasks here
  // For example, you can add sensor readings or other controls
}