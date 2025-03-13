#include <IRremote.h> // Include the IRremote library

const int irSendPin = 3; // Connect KY-005 signal pin to digital pin 3
IRsend irsend(irSendPin); // Create an instance of IRsend

// Array of IR hex codes to send (same as decodeKeyValue function)
const unsigned long irHexValues[] = {
  0xFF6897,  // "0"
  0xFF30CF,  // "1"
  0xFF18E7,  // "2"
  0xFF7A85,  // "3"
  0xFF10EF,  // "4"
  0xFF38C7,  // "5"
  0xFF5AA5,  // "6"
  0xFF42BD,  // "7"
  0xFF4AB5,  // "8"
  0xFF52AD,  // "9"
  0xFF906F,  // "+"
  0xFFA857,  // "-"
  0xFFE01F,  // "EQ"
  0xFFB04F,  // "U/SD"
  0xFF9867,  // "CYCLE"
  0xFF22DD,  // "PLAY/PAUSE"
  0xFF02FD,  // "FORWARD"
  0xFFC23D,  // "BACKWARD"
  0xFFA25D,  // "POWER"
  0xFFE21D,  // "MUTE"
  0xFF629D   // "MODE"
};

const char* keyNames[] = { // Names of the keys for Serial output
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
  "+", "-", "EQ", "U/SD", "CYCLE", "PLAY/PAUSE",
  "FORWARD", "BACKWARD", "POWER", "MUTE", "MODE"
};

const int numKeys = sizeof(irHexValues) / sizeof(irHexValues[0]); // Total number of keys

void setup() {
  Serial.begin(9600); // Initialize Serial Monitor
  Serial.println("KY-005 IR Transmitter Initialized");
}

void loop() {
  static int index = 0; // Index to cycle through key values

  unsigned long code = irHexValues[index]; // Get the current IR code

  Serial.print("Sending IR code: ");
  Serial.print("0x");
  Serial.print(code, HEX);
  Serial.print(" (");
  Serial.print(keyNames[index]);
  Serial.println(")");

  irsend.sendNEC(code, 32); // Send the IR signal using NEC protocol

  index = (index + 1) % numKeys; // Move to the next IR code
  delay(1000); // Wait 1 second before sending the next code
}
