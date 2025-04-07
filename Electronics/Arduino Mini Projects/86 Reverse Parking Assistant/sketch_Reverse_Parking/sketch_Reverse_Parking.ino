#include "rfid1.h"
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

const int redLEDPin = 9;
const int greenLEDPin = 10;
const int echoPin = 11;
const int trigPin = 12;
const int buttonPin = 8;

const long intervalLcd = 1000;
long intervalAlert = -1;
unsigned long previousMillisL = 0;
unsigned long previousMillisA = 0;

LiquidCrystal_I2C lcd(0x27, 16, 2);
RFID1 rfid;

bool isButtonEnabled = false;
int isRFIDEnabled = 0;

// Track LCD state
String currentLcdLine0 = "";
String currentLcdLine1 = "";

void setup() {
  lcd.init();
  lcd.backlight();
  pinMode(redLEDPin, OUTPUT);
  pinMode(greenLEDPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(trigPin, OUTPUT);
  pinMode(buttonPin, INPUT);

  Serial.begin(9600);
  rfid.begin(7, 5, 4, 3, 6, 2);
  rfid.init();

  updateLcdLine(0, "Reverse is OFF");
  updateLcdLine(1, "RFID is OFF");
}

void loop() {
  if (digitalRead(buttonPin) == 1) {
    isButtonEnabled = !isButtonEnabled;
    delay(250); // Debounce
  }

  checkRFID();
  updateLcdLine(1, isRFIDEnabled ? "RFID is ON" : "RFID is OFF");
  
  digitalWrite(greenLEDPin, isRFIDEnabled ? HIGH : LOW);
  
  if (!isRFIDEnabled) {
    isButtonEnabled = false;
    updateLcdLine(0, "Reverse is OFF");
    digitalWrite(redLEDPin, LOW);
    return;
  }

  if (!isButtonEnabled) {
    updateLcdLine(0, "Reverse is OFF");
    digitalWrite(redLEDPin, LOW);
    return;
  }
  
  // Only process distance when both RFID and button are enabled
  float distance = readSensorData();
  
  unsigned long currentMillisL = millis();
  if (currentMillisL - previousMillisL >= intervalLcd) {
    previousMillisL = currentMillisL;
    updateLcdLine(0, "Distance: " + String(distance));
  }
  
  distanceJudgment(distance);
  
  if (intervalAlert != -1) {
    unsigned long currentMillisA = millis();
    if (currentMillisA - previousMillisA >= intervalAlert) {
      previousMillisA = currentMillisA;
      alertWork(distance);
    }
  }
}

void updateLcdLine(int line, String text) {
  String *currentLine = (line == 0) ? &currentLcdLine0 : &currentLcdLine1;
  if (text != *currentLine) {
    lcd.setCursor(0, line);
    lcd.print("                "); // Clear the line
    lcd.setCursor(0, line);
    lcd.print(text);
    *currentLine = text;
  }
}

void alertWork(float distance) {
  if (distance < 5) {
    digitalWrite(redLEDPin, HIGH);
  } else {
    digitalWrite(redLEDPin, HIGH);
    delay(50);
    digitalWrite(redLEDPin, LOW);
  }
}

float readSensorData() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  return pulseIn(echoPin, HIGH) / 58.00;
}

void distanceJudgment(float distance) {
  if (distance < 5) {
    intervalAlert = 50;
  } else if (distance <= 10) {
    intervalAlert = 100;
  } else if (distance <= 25) {
    intervalAlert = 300;
  } else if (distance <= 50) {
    intervalAlert = 800;
  } else {
    intervalAlert = -1;
    digitalWrite(redLEDPin, LOW);
  }
}

void checkRFID() {
  uchar status;
  uchar str[MAX_LEN];
  
  status = rfid.request(PICC_REQIDL, str);
  if (status != MI_OK) return;
  
  status = rfid.anticoll(str);
  
  if (str[0] == 0xA7 && str[1] == 0x80 && str[2] == 0xCC && str[3] == 0x93) {
    isRFIDEnabled = true;
  } else if (str[0] == 0xE7 && str[1] == 0x36 && str[2] == 0x25 && str[3] == 0xB5) {
    isRFIDEnabled = false;
  }
}