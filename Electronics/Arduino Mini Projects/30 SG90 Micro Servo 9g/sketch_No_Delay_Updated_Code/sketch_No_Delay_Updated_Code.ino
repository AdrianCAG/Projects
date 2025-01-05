#include <Servo.h>

// Create a servo object to control a servo
Servo myservo;

// Define the pin to which the servo is attached
const int servoPin = 9;

// Servo parameters
int currentAngle = 0;         // Current angle of the servo
int targetAngle = 0;          // Target angle for the servo
unsigned long lastMoveTime = 0; // Time of the last servo movement
const int stepDelay = 20;     // Delay between steps (ms)
bool once = true;

// Define the default speed (delay time between steps in milliseconds)
int servoSpeed = 15;          // Servo speed: lower value = faster movement

void setup() {
  // Attach the servo on the specified pin to the servo object
  myservo.attach(servoPin);

  // Move the servo to the initial position (0 degrees)
  myservo.write(currentAngle);

  // Initialize Serial communication for debugging and speed adjustment
  Serial.begin(9600);
  Serial.println("----------------------------------------------------");
  Serial.println("Servo initialized. Ready to move!");
  Serial.println("Enter a speed between 1 and 50 to adjust the servo speed.");
  Serial.println("Enter a target angle (0-180) to move the servo.");
  Serial.println("Reset in order to change speed.");
  Serial.println("----------------------------------------------------");
}

void loop() {
  // Non-blocking servo movement
  moveServo();

  // Handle user input to adjust speed or set a new target angle
  handleInput();
}

// Function to move the servo to the target angle non-blockingly
void moveServo() {
  // Check if it's time to move the servo
  if (millis() - lastMoveTime >= servoSpeed) {
    lastMoveTime = millis();

    // Move the servo one step closer to the target angle
    if (currentAngle < targetAngle) {
      currentAngle++;
      myservo.write(currentAngle);
    } else if (currentAngle > targetAngle) {
      currentAngle--;
      myservo.write(currentAngle);
    }
  }
}

// Function to handle user input
void handleInput() {
  // Check if Serial data is available
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n'); // Read input until newline character
    input.trim(); // Remove any leading/trailing whitespace

    if (isValidNumber(input)) {
      int value = input.toInt();

      // Check if the input is within valid servo speed range
      if (value >= 1 && value <= 50 && once) {
        servoSpeed = value;
        Serial.print("Servo speed updated to: ");
        Serial.println(servoSpeed);
        once = false;
      }
      // Check if the input is within valid angle range
      else if (value >= 0 && value <= 180) {
        targetAngle = value;
        Serial.print("Target angle updated to: ");
        Serial.println(targetAngle);
      } else {
        Serial.println("Invalid input. Enter a speed (1-50) or angle (0-180).");
      }
    } else {
      Serial.println("Invalid input. Enter a numeric value.");
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
