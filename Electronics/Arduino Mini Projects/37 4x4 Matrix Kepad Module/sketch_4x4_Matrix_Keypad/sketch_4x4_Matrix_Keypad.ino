#include <Keypad.h>

// Constants for the keypad dimensions
const byte ROWS = 4; // Number of rows
const byte COLS = 4; // Number of columns

// Define the symbols on the keypad buttons
char hexaKeys[ROWS][COLS] = {
  { '1', '2', '3', 'A' },
  { '4', '5', '6', 'B' },
  { '7', '8', '9', 'C' },
  { '*', '0', '#', 'D' }
};

// Define the row and column pins connected to the keypad
byte rowPins[ROWS] = {2, 3, 4, 5};  // Row pin connections
byte colPins[COLS] = {6, 7, 8, 9};  // Column pin connections

// Initialize an instance of the Keypad class
Keypad customKeypad = Keypad(makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS);

// Variables to store password and input
String setPassword = "";       // Password to be set
String enteredPassword = "";   // Password entered for verification
bool isPasswordSet = false;    // Flag to check if password has been set
bool isAccessGranted = false;  // Flag to disable inputs after successful login

void setup() {
  Serial.begin(9600); // Initialize serial communication

  // Prompt the user to set a password
  Serial.println("Set your password:");
  Serial.println("Enter characters using the keypad and press '#' to finish.");
}

void loop() {
  // Stop accepting inputs if access is already granted
  if (isAccessGranted) {
    return;
  }

  char customKey = customKeypad.getKey(); // Get a key press from the keypad

  // Check if a key has been pressed
  if (customKey) {
    // Handle the password-setting process
    if (!isPasswordSet) {
      if (customKey == '#') {
        if (setPassword.length() > 0) {
          isPasswordSet = true; // Mark password as set
          Serial.println("\nPassword set successfully!");
          Serial.println("Enter your password to verify:");
        } else {
          Serial.println("\nPassword cannot be empty. Try again.");
        }
      } else {
        setPassword += customKey; // Append the character to the password
        Serial.print('*');        // Display '*' for security
      }
    }
    // Handle the password verification process
    else {
      if (customKey == '#') {
        // Check if the entered password matches the set password
        if (enteredPassword == setPassword) {
          Serial.println("\nAccess Granted!");
          isAccessGranted = true; // Lock the system from further inputs
        } else {
          Serial.println("\nAccess Denied! Incorrect Password.");
        }
        enteredPassword = ""; // Clear the input for the next attempt
        delay(2000);          // Wait for 2 seconds before resetting
        if (!isAccessGranted) {
          Serial.println("Enter your password:");
        }
      } else {
        enteredPassword += customKey; // Append the character to the input
        Serial.print('*');            // Display '*' for security
      }
    }
  }
}
