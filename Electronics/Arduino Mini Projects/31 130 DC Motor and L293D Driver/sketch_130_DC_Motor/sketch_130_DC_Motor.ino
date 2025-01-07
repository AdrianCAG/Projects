// Constants for motor control pins
const int motor1A = 10; // Motor control pin 1
const int motor2A = 9;  // Motor control pin 2

// Global variable to track the last command time
unsigned long lastCommandTime = 0;

void setup() {
  // Configure motor control pins as outputs
  pinMode(motor1A, OUTPUT);
  pinMode(motor2A, OUTPUT);

  // Begin serial communication for user input and feedback
  Serial.begin(9600);
  Serial.println("Motor Controller Initialized!");
  Serial.println("Commands:");
  Serial.println("  'A' - Rotate motor clockwise");
  Serial.println("  'B' - Rotate motor anticlockwise");
  Serial.println("  'S' - Stop the motor manually");
  Serial.println("Commands will stop automatically after 3 seconds of inactivity.");

  // Ensure the motor is stopped at startup
  stopMotor();
}

void loop() {
  // Check if there is any input from the Serial Monitor
  if (Serial.available() > 0) {
    // Read the incoming byte as a character
    char incomingByte = Serial.read();

    // Act based on the received command
    switch (incomingByte) {
      case 'A': // Command to rotate motor clockwise
        clockwise(255); // Rotate motor at full speed
        Serial.println("Motor is rotating clockwise.");
        lastCommandTime = millis(); // Record the time of the command
        break;

      case 'B': // Command to rotate motor anticlockwise
        anticlockwise(255); // Rotate motor at full speed
        Serial.println("Motor is rotating anticlockwise.");
        lastCommandTime = millis(); // Record the time of the command
        break;

      case 'S': // Command to stop the motor
        stopMotor(); // Immediately stop the motor
        Serial.println("Motor stopped by user.");
        break;

      default: // Handle invalid input
        Serial.println("Invalid command! Please enter 'A', 'B', or 'S'.");
        break;
    }
  }

  // Stop the motor automatically if no command is received for 3 seconds
  if (millis() - lastCommandTime >= 3000) {
    stopMotor(); // Stop the motor
  }
}

// Function to rotate the motor clockwise
void clockwise(int Speed) {
  analogWrite(motor1A, 0);    // Set motor pin 1 to LOW
  analogWrite(motor2A, Speed); // Set motor pin 2 to the desired speed
}

// Function to rotate the motor anticlockwise
void anticlockwise(int Speed) {
  analogWrite(motor1A, Speed); // Set motor pin 1 to the desired speed
  analogWrite(motor2A, 0);    // Set motor pin 2 to LOW
}

// Function to stop the motor
void stopMotor() {
  analogWrite(motor1A, 0);    // Set motor pin 1 to LOW
  analogWrite(motor2A, 0);    // Set motor pin 2 to LOW
  Serial.println("Motor has stopped."); // Provide feedback to the user
}
