#include "LedControl.h"

LedControl lc = LedControl(12, 11, 10, 1);

void setup() {
  lc.shutdown(0, false);     // Wake up the MAX7219
  lc.setIntensity(0, 5);     // Set brightness level (0-15)
  lc.clearDisplay(0);        // Clear the display
}

void loop() {
  displayColumns();  // Draw each column
  displayRows();     // Draw each row
  displayBorder();   // Draw the border
  displayX();        // Draw an X
}

// Draw each column one by one
void displayColumns() {
  lc.clearDisplay(0);
  delay(100);
  for (int col = 0; col < 8; col++) {
    for (int row = 0; row < 8; row++) {
      lc.setLed(0, row, col, true);
    }
    delay(200);
    lc.clearDisplay(0);
  }
}

// Draw each row one by one
void displayRows() {
  lc.clearDisplay(0);
  delay(100);
  for (int row = 0; row < 8; row++) {
    for (int col = 0; col < 8; col++) {
      lc.setLed(0, row, col, true);
    }
    delay(200);
    lc.clearDisplay(0);
  }
}

// Draw the border around the display
void displayBorder() {
  lc.clearDisplay(0);
  delay(100);

  // Top and bottom rows
  for (int col = 0; col < 8; col++) {
    lc.setLed(0, 0, col, true);   // Top row
    lc.setLed(0, 7, col, true);   // Bottom row
  }

  // Left and right columns
  for (int row = 1; row < 7; row++) { // Skip corners already lit
    lc.setLed(0, row, 0, true);   // Left column
    lc.setLed(0, row, 7, true);   // Right column
  }

  delay(2000); // Keep the border visible
}

// Draw an X pattern
void displayX() {
  lc.clearDisplay(0);
  delay(100);

  for (int i = 0; i < 8; i++) {
    lc.setLed(0, i, i, true);        // Top-left to bottom-right diagonal
    lc.setLed(0, i, 7 - i, true);   // Top-right to bottom-left diagonal
  }

  delay(2000); // Keep the X visible
}
