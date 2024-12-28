/* 
 * 74HC595 Shift Register Control
 * This program demonstrates how to control a 74HC595 shift register
 * to light up LEDs or manage outputs in a sequential pattern.
 */

// Define pin connections
const int STcp = 12; // Pin connected to ST_CP (Storage Register Clock Pin) of 74HC595
const int SHcp = 8;  // Pin connected to SH_CP (Shift Register Clock Pin) of 74HC595
const int DS = 11;   // Pin connected to DS (Data Pin) of 74HC595

// Define data pattern array for LEDs or other outputs
int datArray[] = {
  B00000000, // All LEDs off
  B00000001, // First LED on
  B00000011, // First two LEDs on
  B00000111, // First three LEDs on
  B00001111, // And so on...
  B00011111, 
  B00111111, 
  B01111111, 
  B11111111  // All LEDs on
};

// Global variables
int delayTime = 500; // Delay time between pattern updates (in milliseconds)

void setup() {
  // Initialize pins as outputs
  pinMode(STcp, OUTPUT);
  pinMode(SHcp, OUTPUT);
  pinMode(DS, OUTPUT);
  
  // Initial state
  resetShiftRegister();
}

void loop() {
  // Cycle through the data patterns
  for (int num = 0; num < 9; num++) {
    digitalWrite(STcp, LOW); // Hold ST_CP low during transmission
    shiftOut(DS, SHcp, MSBFIRST, datArray[num]); // Send the data to the shift register
    digitalWrite(STcp, HIGH); // Latch the data into the storage register

    // Wait for the defined delay
    delay(delayTime);
  }

  // Optional: Reverse the pattern
  reversePattern();
}

/*
 * Function to reset the shift register by sending all zeros
 */
void resetShiftRegister() {
  digitalWrite(STcp, LOW);
  shiftOut(DS, SHcp, MSBFIRST, B00000000); // Clear the shift register
  digitalWrite(STcp, HIGH);
}

/*
 * Function to reverse the pattern for a "back and forth" effect
 */
void reversePattern() {
  for (int num = 8; num >= 0; num--) {
    digitalWrite(STcp, LOW);
    shiftOut(DS, SHcp, MSBFIRST, datArray[num]);
    digitalWrite(STcp, HIGH);
    delay(delayTime);
  }
}
