#include <Servo.h>

// Create a servo object to control a servo
Servo myservo;

// Define the pin to which the servo is attached
const int servoPin = 9;

// Define the default speed (delay time between steps in milliseconds)
int servoSpeed = 15;

void setup() {
  // Attach the servo on the specified pin to the servo object
  myservo.attach(servoPin);

  // Move the servo to the initial position (0 degrees)
  myservo.write(0);

  // Wait for the servo to stabilize at the initial position
  delay(1000);

  // Initialize Serial communication for debugging and speed adjustment
  Serial.begin(9600);
  Serial.println("Servo initialized. Ready to move!");
  Serial.println("Enter a speed between 1 and 50 to adjust the servo speed.");
}

void loop() {
  // Sweep the servo from 0 to 180 degrees
  sweepServo(0, 180);

  // Sweep the servo back from 180 to 0 degrees
  sweepServo(180, 0);

  // Adjust the speed dynamically by reading input from the Serial Monitor
  adjustSpeed();
}

// Function to sweep the servo between two angles
void sweepServo(int startAngle, int endAngle) {
  // Determine the direction of the sweep
  int step = (startAngle < endAngle) ? 1 : -1;

  // Move the servo in small steps
  for (int angle = startAngle; angle != endAngle + step; angle += step) {
    myservo.write(angle); // Write the current angle to the servo
    delay(servoSpeed);    // Wait for the specified delay
  }
}

// Function to dynamically adjust the speed via the Serial Monitor
void adjustSpeed() {
  // Check if Serial data is available
  if (Serial.available()) {
    // Read the input as a String
    String input = Serial.readStringUntil('\n'); // Read until newline character
    input.trim(); // Remove any leading/trailing whitespace

    // Validate if the input is a valid number
    if (isValidNumber(input)) {
      int newSpeed = input.toInt();

      // Validate the speed range
      if (newSpeed >= 1 && newSpeed <= 50) {
        servoSpeed = newSpeed;
        Serial.print("Servo speed updated to: ");
        Serial.println(servoSpeed);
      } else {
        Serial.println("Invalid speed. Enter a value between 1 and 50.");
      }
    } else {
      Serial.println("Invalid input. Enter a valid numeric value.");
    }
  }
}

// Function to check if a string contains only numeric characters
bool isValidNumber(String str) {
  for (unsigned int i = 0; i < str.length(); i++) {
    if (!isDigit(str[i])) {
      return false; // Return false if a non-digit character is found
    }
  }
  return true; // Return true if all characters are digits
}
