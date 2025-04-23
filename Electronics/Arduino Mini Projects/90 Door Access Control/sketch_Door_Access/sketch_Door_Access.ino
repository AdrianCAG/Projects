#include <rfid1.h>
#include <Stepper.h>
#include <Keypad.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Constants
#define PASSWORD_LEN 6
#define ID_LEN 4

// Stepper motor setup
const int stepsPerRevolution = 2048;
const int rolePerMinute = 16;
const int IN1 = 11;
const int IN2 = 10;
const int IN3 = 9;
const int IN4 = 8;

// Buzzer
const int buzPin = 12;

// Password & RFID
int index = 0;
uchar password[PASSWORD_LEN] = {'1', '2', '3', '4', '5', '6'};
uchar passwordInput[PASSWORD_LEN] = {""};
uchar userIdRead[ID_LEN] = {""};
uchar userId[ID_LEN] = {0xE7, 0x36, 0x25, 0xB5};

int approved = 0;

// Keypad setup
const byte ROWS = 4;
const byte COLS = 4;
char hexaKeys[ROWS][COLS] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};
byte rowPins[ROWS] = {31, 33, 35, 37};
byte colPins[COLS] = {39, 41, 43, 45};

RFID1 rfid;
Keypad customKeypad = Keypad(makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS);
Stepper stepper(stepsPerRevolution, IN1, IN3, IN2, IN4);
LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup() {
  stepper.setSpeed(rolePerMinute);
  pinMode(buzPin, OUTPUT);

  rfid.begin(7, 5, 4, 3, 6, 2);
  rfid.init();
  lcd.init();
  lcd.backlight();

  lcd.setCursor(0, 0);
  lcd.print("   Welcome to   ");
  lcd.setCursor(0, 1);
  lcd.print(" Secure Access ");
  delay(2000);
  lcd.clear();
}

void loop() {
  if (approved == 0) {
    approved = rfidRead();
    for (int i = 0; i < ID_LEN; i++) {
      userIdRead[i] = NULL;
    }
  }
  if (approved == 0) {
    approved = keypadInput();
    index = 0;
    for (int i = 0; i < PASSWORD_LEN; i++) {
      passwordInput[i] = NULL;
    }
  }
  if (approved == 1) {
    openDoor();
    approved = 0;
  }
}

// ---------- Helper Functions ----------

void beep(int duration, int frequency) {
  for (int i = 0; i < frequency; i++) {
    digitalWrite(buzPin, HIGH);
    delay(duration);
    digitalWrite(buzPin, LOW);
    delay(100);
  }
}

void verifyPrint(bool result) {
  lcd.clear();
  lcd.setCursor(0, 0);
  if (result) {
    lcd.print(" ACCESS GRANTED ");
    beep(100, 3);
  } else {
    lcd.print(" ACCESS DENIED  ");
    beep(500, 1);
  }
  delay(1500);
  lcd.clear();
}

void openDoor() {
  int doorStep = 512;
  stepper.step(doorStep);
  lcd.setCursor(0, 0);
  lcd.print("  DOOR OPENING  ");
  delay(2000);
  stepper.step(-doorStep);
  lcd.setCursor(0, 0);
  lcd.print("  DOOR CLOSED   ");
  delay(1000);
  lcd.clear();
}

bool rfidRead() {
  getId();
  if (userIdRead[0] != NULL) {
    return idVerify();
  }
  return false;
}

void getId() {
  uchar status;
  uchar str[MAX_LEN];
  status = rfid.request(PICC_REQIDL, str);
  if (status != MI_OK) return;

  status = rfid.anticoll(str);
  if (status == MI_OK) {
    for (int i = 0; i < ID_LEN; i++) {
      userIdRead[i] = str[i];
    }
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("RFID Detected");
    beep(150, 1);
  }
  delay(500);
  rfid.halt();
}

bool idVerify() {
  for (int i = 0; i < ID_LEN; i++) {
    if (userIdRead[i] != userId[i]) {
      verifyPrint(false);
      return false;
    }
  }
  verifyPrint(true);
  return true;
}

bool keypadInput() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Enter Password:");
  lcd.setCursor(0, 1);

  while (true) {
    getCode();
    if (index == 0 || index >= PASSWORD_LEN) break;
  }

  if (index >= PASSWORD_LEN) {
    return codeVerify();
  }
  return false;
}

void getCode() {
  char customKey = customKeypad.getKey();
  if (customKey) {
    passwordInput[index] = customKey;
    lcd.print('*');
    index++;
    beep(100, 1);
  }
}

bool codeVerify() {
  for (int i = 0; i < PASSWORD_LEN; i++) {
    if (passwordInput[i] != password[i]) {
      verifyPrint(false);
      return false;
    }
  }
  verifyPrint(true);
  return true;
}
