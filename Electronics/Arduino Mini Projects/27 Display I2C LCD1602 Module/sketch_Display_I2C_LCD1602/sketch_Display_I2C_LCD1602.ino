#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Initialize the LCD with I2C address 0x27, 16 characters, and 2 lines
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Array of mathematical theorems to display
const char* theorems[] = {
  "Pythag: a^2+b^2=c^2",
  "Euler: e^(i*pi)+1=0",
  "Area: A=pi*r^2",
  "Fermat: No sols x^n+y^n=z^n (n>2)"
};

const int numTheorems = sizeof(theorems) / sizeof(theorems[0]);
int currentTheoremIndex = 0;
unsigned long lastSwitchTime = 0;
const unsigned long switchInterval = 5000; // Switch every 5 seconds

bool countdownActive = false;
unsigned long countdownStartTime = 0;
const unsigned long countdownDuration = 20000; // 10 seconds countdown

void setup() {
  lcd.init();                      // Initialize the LCD
  lcd.backlight();                 // Turn on the backlight
  Serial.begin(9600);              // Initialize Serial communication
}

void loop() {
  // Handle displaying theorems or countdown
  if (!countdownActive) {
    displayTheorems();
  } else {
    handleCountdown();
  }

  // Handle custom input during the countdown
  if (countdownActive && Serial.available()) {
    delay(100); // Small delay for full message
    lcd.clear();
    lcd.print("Custom input:");
    lcd.setCursor(0, 1);
    while (Serial.available() > 0) {
      char incomingByte = Serial.read();
      lcd.print(incomingByte); // Display user input
    }
    delay(2000); // Show the custom input for 2 seconds
    lcd.clear();
  }
}

// Function to display theorems on the LCD
void displayTheorems() {
  unsigned long currentTime = millis();

  // If it's time to switch theorems
  if (currentTime - lastSwitchTime > switchInterval) {
    lcd.clear(); // Clear the screen

    const char* theorem = theorems[currentTheoremIndex];
    int length = strlen(theorem);

    // Split the theorem across two rows if needed
    if (length > 16) {
      char row1[17];
      char row2[17];
      strncpy(row1, theorem, 16); // Copy first 16 characters to row1
      row1[16] = '\0';           // Null-terminate row1
      strncpy(row2, theorem + 16, 16); // Copy next 16 characters to row2
      row2[16] = '\0';           // Null-terminate row2

      lcd.setCursor(0, 0);
      lcd.print(row1);
      lcd.setCursor(0, 1);
      lcd.print(row2);
    } else {
      lcd.setCursor(0, 0);
      lcd.print(theorem); // Print the theorem if it fits in one row
    }

    currentTheoremIndex++; // Move to the next theorem
    lastSwitchTime = currentTime; // Reset switch timer

    // If we reached the last theorem, start the countdown
    if (currentTheoremIndex == numTheorems) {
      countdownActive = true;
      countdownStartTime = millis();
      currentTheoremIndex = 0; // Reset index for theorems
    }
  }
}

// Function to handle the countdown
void handleCountdown() {
  unsigned long currentTime = millis();
  unsigned long elapsed = currentTime - countdownStartTime;

  if (elapsed < countdownDuration) {
    int remainingSeconds = (countdownDuration - elapsed) / 1000;
    lcd.clear();
    lcd.print("Enter custom:");
    lcd.setCursor(0, 1);
    lcd.print("Time left: ");
    lcd.print(remainingSeconds);
    delay(500); // Reduce flicker
  } else {
    // Countdown ended, resume showing theorems
    countdownActive = false;
    lcd.clear();
    lcd.print("Resuming...");
    delay(2000);
    lcd.clear();
  }
}
