// *********************************************************************
// 7-Segment LED Display Controller
// Description: This program controls a 7-segment display to show digits
//              and letters (0-9, A-F) sequentially with a delay.
// Author: [Your Name]
// *********************************************************************

// Pin Definitions
const int a = 7;  // Segment 'a' attached to digital pin 7
const int b = 6;  // Segment 'b' attached to digital pin 6
const int c = 5;  // Segment 'c' attached to digital pin 5
const int d = 11; // Segment 'd' attached to digital pin 11
const int e = 10; // Segment 'e' attached to digital pin 10
const int f = 8;  // Segment 'f' attached to digital pin 8
const int g = 9;  // Segment 'g' attached to digital pin 9
const int dp = 4; // Decimal point attached to digital pin 4

// *********************************************************************
// Setup Function
// Configures all pins as outputs and initializes the display.
// *********************************************************************
void setup() {
  // Configure pins 4 to 11 as output
  for (int thisPin = 4; thisPin <= 11; thisPin++) {
    pinMode(thisPin, OUTPUT);
  }

  // Turn off the decimal point initially
  digitalWrite(dp, LOW);
}

// *********************************************************************
// Loop Function
// Cycles through digits and letters on the 7-segment display.
// *********************************************************************
void loop() {
  displayAll();  // Display all supported digits and letters
}

// *********************************************************************
// Additional Functions
// Functions to display each digit and letter on the 7-segment display.
// *********************************************************************

// Display all digits and letters sequentially
void displayAll() {
  for (int i = 1; i <= 15; i++) {
    switch (i) {
      case 1: digital_1(); break;
      case 2: digital_2(); break;
      case 3: digital_3(); break;
      case 4: digital_4(); break;
      case 5: digital_5(); break;
      case 6: digital_6(); break;
      case 7: digital_7(); break;
      case 8: digital_8(); break;
      case 9: digital_9(); break;
      case 10: digital_A(); break;
      case 11: digital_b(); break;
      case 12: digital_C(); break;
      case 13: digital_d(); break;
      case 14: digital_E(); break;
      case 15: digital_F(); break;
    }
    delay(1000);  // Wait for a second before the next character
    flickerDot(); // Flicker the decimal point twice
  }
}

// Function to turn off all segments
void clearDisplay() {
  for (int thisPin = 4; thisPin <= 11; thisPin++) {
    digitalWrite(thisPin, LOW);
  }
}

// Functions to display digits and letters (1-F)
void digital_1() {
  clearDisplay();
  digitalWrite(b, HIGH);
  digitalWrite(c, HIGH);
}

void digital_2() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(b, HIGH);
  digitalWrite(g, HIGH);
  digitalWrite(e, HIGH);
  digitalWrite(d, HIGH);
}

void digital_3() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(b, HIGH);
  digitalWrite(c, HIGH);
  digitalWrite(d, HIGH);
  digitalWrite(g, HIGH);
}

void digital_4() {
  clearDisplay();
  digitalWrite(f, HIGH);
  digitalWrite(g, HIGH);
  digitalWrite(b, HIGH);
  digitalWrite(c, HIGH);
}

void digital_5() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(f, HIGH);
  digitalWrite(g, HIGH);
  digitalWrite(c, HIGH);
  digitalWrite(d, HIGH);
}

void digital_6() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(f, HIGH);
  digitalWrite(g, HIGH);
  digitalWrite(c, HIGH);
  digitalWrite(d, HIGH);
  digitalWrite(e, HIGH);
}

void digital_7() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(b, HIGH);
  digitalWrite(c, HIGH);
}

void digital_8() {
  clearDisplay();
  for (int i = 5; i <= 11; i++) {
    digitalWrite(i, HIGH);
  }
}

void digital_9() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(b, HIGH);
  digitalWrite(c, HIGH);
  digitalWrite(d, HIGH);
  digitalWrite(f, HIGH);
  digitalWrite(g, HIGH);
}

void digital_A() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(b, HIGH);
  digitalWrite(c, HIGH);
  digitalWrite(e, HIGH);
  digitalWrite(f, HIGH);
  digitalWrite(g, HIGH);
}

void digital_b() {
  clearDisplay();
  digitalWrite(f, HIGH);
  digitalWrite(e, HIGH);
  digitalWrite(g, HIGH);
  digitalWrite(c, HIGH);
  digitalWrite(d, HIGH);
}

void digital_C() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(f, HIGH);
  digitalWrite(e, HIGH);
  digitalWrite(d, HIGH);
}

void digital_d() {
  clearDisplay();
  digitalWrite(b, HIGH);
  digitalWrite(c, HIGH);
  digitalWrite(d, HIGH);
  digitalWrite(e, HIGH);
  digitalWrite(g, HIGH);
}

void digital_E() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(f, HIGH);
  digitalWrite(g, HIGH);
  digitalWrite(e, HIGH);
  digitalWrite(d, HIGH);
}

void digital_F() {
  clearDisplay();
  digitalWrite(a, HIGH);
  digitalWrite(f, HIGH);
  digitalWrite(g, HIGH);
  digitalWrite(e, HIGH);
}

// Function to flicker the decimal point twice
void flickerDot() {
  for (int i = 0; i < 2; i++) {
    digitalWrite(dp, HIGH);
    delay(250); // On for 250ms
    digitalWrite(dp, LOW);
    delay(250); // Off for 250ms
  }
}
