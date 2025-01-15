/*
 * Enhanced MPR121 Capacitive Touch Sensor Example
 * This program interfaces with the MPR121 capacitive touch sensor
 * to detect touch inputs and display their status in real-time.
 * 
 * Features:
 * - Reads and displays touch states of 12 electrodes.
 * - Provides a user-friendly output in the Serial Monitor.
 * - Includes debounce functionality for smoother touch detection.
 */

#include <MPR121_JM.h> // Include the MPR121 library for capacitive touch sensing

// MPR121 initialization: IRQ pin, I2C address, interrupt source
MPR121 mpr121(2, 0x2A, 0x1F); 

// Array to hold the touch states of the 12 electrodes
boolean touchStates[12];

// Debounce delay in milliseconds
const unsigned long debounceDelay = 50;
unsigned long lastDebounceTime[12] = {0}; // Tracks last touch event per electrode

void setup() {
  // Initialize the MPR121 capacitive touch sensor
  mpr121.mpr121_setup();

  // Initialize Serial Monitor for debugging
  Serial.begin(9600);
  Serial.println("MPR121 Capacitive Touch Sensor Initialized");
  Serial.println("Touch a pad to see the status updates...");
}

void loop() {
  // Check if an interrupt has been triggered
  if (!mpr121.checkInterrupt()) {
    // Read the touch input states
    int touched = mpr121.readTouchInputs();

    // Update touch states with debounce handling
    for (int i = 0; i < 12; i++) {
      if ((touched & (1 << i)) && !touchStates[i]) {
        // If the pad is touched and was not previously touched
        if (millis() - lastDebounceTime[i] > debounceDelay) {
          touchStates[i] = true;
          lastDebounceTime[i] = millis();
          Serial.print("Pad ");
          Serial.print(i);
          Serial.println(": Touched");
        }
      } else if (!(touched & (1 << i)) && touchStates[i]) {
        // If the pad is released and was previously touched
        if (millis() - lastDebounceTime[i] > debounceDelay) {
          touchStates[i] = false;
          lastDebounceTime[i] = millis();
          Serial.print("Pad ");
          Serial.print(i);
          Serial.println(": Released");
        }
      }
    }

    // Debug: Print all touch states in a single line
    Serial.print("Touch States: ");
    for (int i = 0; i < 12; i++) {
      Serial.print(touchStates[i] ? "1" : "0");
      Serial.print(" ");
    }
    Serial.println();
  }
}
