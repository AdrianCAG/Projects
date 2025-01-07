#include <Stepper.h>   

// Constants
const int stepsPerRevolution = 2048; // Number of steps for a full revolution (specific to 28BYJ-48)
const int rolePerMinute = 16;        // Stepper motor speed in RPM (adjustable from 0 to 17)

// Stepper motor pin connections (to Arduino pins)
const int pin1 = 2;
const int pin2 = 3;
const int pin3 = 4;
const int pin4 = 5;

// Initialize the stepper motor with steps per revolution and connected pins
Stepper stepper(stepsPerRevolution, pin1, pin2, pin3, pin4);

void setup() {
  // Set the stepper motor speed
  stepper.setSpeed(rolePerMinute);

  // Optional: Start Serial communication for debugging or user feedback
  Serial.begin(9600);
  Serial.println("Stepper motor initialized. Starting loop...");
}

void loop() {
  // Define the number of steps for one complete rotation
  int forwardSteps = stepsPerRevolution;  // Forward (1 revolution)
  int reverseSteps = -stepsPerRevolution; // Reverse (1 revolution)

  // Move the motor forward
  Serial.println("Motor moving forward...");
  stepper.step(forwardSteps);
  delay(1000); // Wait for a second before reversing direction

  // Move the motor backward
  Serial.println("Motor moving backward...");
  stepper.step(reverseSteps);
  delay(1000); // Wait for a second before looping again
}
