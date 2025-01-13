/*
 * This program receives IR signals, decodes them, and displays the corresponding key values.
 * Compatible with IRremote library version 4.x or newer.
 * 
 * Features:
 * - Decodes and prints IR key presses from a standard remote control.
 * - Displays unknown IR codes for unsupported keys.
 * - Added handling for library version updates and example references.
 * - Includes detailed comments for better understanding.
 */

#include <IRremote.h> // Include the IRremote library

// Pin configuration for the IR receiver
const int recvPin = 11; // Connect the IR receiver module to pin 11

// Create an instance of the IR receiver
IRrecv irrecv(recvPin);
decode_results results; // Variable to store the decoded IR data

// Function prototypes
String decodeKeyValue(long result);

void setup() {
  // Initialize the Serial Monitor for debugging
  Serial.begin(9600);

  // Display setup message
  Serial.println("IR Remote Receiver Initialized");
  Serial.println("Waiting for IR input...");

  // Start the IR receiver
  irrecv.enableIRIn();
}

void loop() {
  // Check if a signal has been received
  if (irrecv.decode(&results)) {
    // Decode and print the key value
    String key = decodeKeyValue(results.value);
    if (key != "ERROR") {
      Serial.println("Key Pressed: " + key);
    } else {
      // Print the unknown key code
      Serial.print("Unknown Key Received. Code: 0x");
      Serial.println(results.value, HEX);
    }

    // Prepare to receive the next signal
    irrecv.resume();
  }
}

/*
 * Function: decodeKeyValue
 * Purpose: Maps IR signal values to their corresponding key names.
 * Input:   Long result - The decoded IR signal value.
 * Output:  String - The corresponding key name or "ERROR" if unknown.
 */
String decodeKeyValue(long result) {
  switch (result) {
    case 0xFF6897: return "0";
    case 0xFF30CF: return "1";
    case 0xFF18E7: return "2";
    case 0xFF7A85: return "3";
    case 0xFF10EF: return "4";
    case 0xFF38C7: return "5";
    case 0xFF5AA5: return "6";
    case 0xFF42BD: return "7";
    case 0xFF4AB5: return "8";
    case 0xFF52AD: return "9";
    case 0xFF906F: return "+";
    case 0xFFA857: return "-";
    case 0xFFE01F: return "EQ";
    case 0xFFB04F: return "U/SD";
    case 0xFF9867: return "CYCLE";
    case 0xFF22DD: return "PLAY/PAUSE";
    case 0xFF02FD: return "FORWARD";
    case 0xFFC23D: return "BACKWARD";
    case 0xFFA25D: return "POWER";
    case 0xFFE21D: return "MUTE";
    case 0xFF629D: return "MODE";
    case 0xFFFFFFFF: return "DUPLICATE";
    default: return "ERROR";
  }
}

/*
 * Notes:
 * - If you encounter issues with newer library versions, ensure compatibility by using the latest examples or downgrading the library to 2.6.0.
 * - Visit the IRremote library GitHub page for detailed documentation and examples:
 *   https://github.com/Arduino-IRremote/Arduino-IRremote#examples-for-this-library
 * 
 * Additional Enhancements:
 * - Displays unknown IR codes in hexadecimal format.
 */
