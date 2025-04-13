// --- Pin Definitions ---
const int redLed = 5;
const int greenLed = 6;
const int STcp = 12;   // Storage Register Clock Pin (Latch)
const int SHcp = 8;    // Shift Register Clock Pin
const int DS = 11;     // Serial Data Input Pin
const int touchIO = 2; // Touch sensor input pin

// --- 7-Segment Display Digit Encoding (Common Cathode) ---
char datArray[] = {
  0x3f, // 0
  0x06, // 1
  0x5b, // 2
  0x4f, // 3
  0x66, // 4
  0x6d, // 5
  0x7d, // 6
  0x07, // 7
  0x7f, // 8
  0x6f  // 9
};

void setup() {
  // --- Initialize all I/O pins ---
  pinMode(touchIO, INPUT);
  pinMode(STcp, OUTPUT); 
  pinMode(SHcp, OUTPUT);
  pinMode(DS, OUTPUT);
  pinMode(redLed, OUTPUT);
  pinMode(greenLed, OUTPUT);

  // --- Start with the idle state (red LED ON) ---
  startIdleState();
}

void loop() {
  // --- If touch sensor is pressed, begin sequence ---
  if (digitalRead(touchIO) == HIGH) {
    countdownWithBothLeds();  // Countdown 5 to 0 with both LEDs flashing
    showDash();               // Display dash between phases
    greenOnlyCountdown();     // Countdown 9 to 4 with green LED flashing
    finalCountdown();         // Countdown 3 to 0 with both LEDs flashing
    startIdleState();         // Return to idle state (red LED ON)
  }
}

// --- Display dash (mid-phase indicator) ---
void showDash() {
  digitalWrite(STcp, LOW);
  shiftOut(DS, SHcp, MSBFIRST, 0x40); // Dash segment pattern (only middle segment ON)
  digitalWrite(STcp, HIGH);
  delay(500);
}

// --- Idle state: red LED ON, display blank ---
void startIdleState() {
  digitalWrite(redLed, HIGH);
  digitalWrite(greenLed, LOW);
  displayDigit(-1); // Clear display
}

// --- Countdown with both LEDs flashing (5 to 0) ---
void countdownWithBothLeds() {
  for (int i = 5; i >= 0; i--) {
    displayDigit(i);
    flashBothLeds(1); // 500ms ON, 500ms OFF
  }
}

// --- Countdown with only green LED flashing (9 to 4) ---
void greenOnlyCountdown() {
  for (int i = 9; i > 3; i--) {
    displayDigit(i);
    digitalWrite(greenLed, HIGH);
    delay(500);
    digitalWrite(greenLed, LOW);
    delay(500);
  }
}

// --- Final countdown (3 to 0) with both LEDs flashing ---
void finalCountdown() {
  for (int i = 3; i >= 0; i--) {
    displayDigit(i);
    flashBothLeds(1);
  }
}

// --- Flash both LEDs specified number of times ---
void flashBothLeds(int flashes) {
  for (int i = 0; i < flashes; i++) {
    digitalWrite(redLed, HIGH);
    digitalWrite(greenLed, HIGH);
    delay(500);
    digitalWrite(redLed, LOW);
    digitalWrite(greenLed, LOW);
    delay(500);
  }
}

// --- Display number (0–9), or clear screen if out of range ---
void displayDigit(int num) {
  digitalWrite(STcp, LOW);
  if (num >= 0 && num <= 9) {
    shiftOut(DS, SHcp, MSBFIRST, datArray[num]);
  } else {
    shiftOut(DS, SHcp, MSBFIRST, 0x00); // Clear display
  }
  digitalWrite(STcp, HIGH);
}
