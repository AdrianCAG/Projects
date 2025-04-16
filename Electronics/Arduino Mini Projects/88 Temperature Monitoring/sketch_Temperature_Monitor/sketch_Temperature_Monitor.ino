#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <EEPROM.h>
#include <DHT.h>

// === Hardware Pins ===
#define relayPin 2
#define ledPin 13

#define setModePin 11    // Slide switch replaces old button
#define dhtPin 4         // DHT11 data pin

#define clkPin 5         // Rotary encoder CLK
#define dtPin 6          // Rotary encoder DT
#define swPin 7          // Encoder push button

#define buttonHundreds 8
#define buttonTens 9
#define buttonOnes 10

// === LCD ===
LiquidCrystal_I2C lcd(0x27, 16, 2);

// === DHT ===
#define DHTTYPE DHT11
DHT dht(dhtPin, DHTTYPE);

// === Encoder and Flicker State ===
int lastClkState;
int selectedDigit = 0;
bool flickerOn = true;
unsigned long lastFlickerTime = 0;
unsigned long lastEncoderTime = 0;
const int flickerInterval = 500;
const int flickerDuration = 3000;

// === Digit State ===
int hundreds = 0;
int tens = 0;
int ones = 0;
float hysteresis = 0.25;

void setup() {
  pinMode(relayPin, OUTPUT);
  pinMode(ledPin, OUTPUT);
  digitalWrite(relayPin, HIGH);
  
  pinMode(setModePin, INPUT); // Slide switch
  pinMode(clkPin, INPUT);
  pinMode(dtPin, INPUT);
  pinMode(swPin, INPUT_PULLUP);
  pinMode(buttonHundreds, INPUT_PULLUP);
  pinMode(buttonTens, INPUT_PULLUP);
  pinMode(buttonOnes, INPUT_PULLUP);

  lcd.init();
  lcd.backlight();
  lcd.setCursor(0, 0);
  lcd.print("Overheat Protect");
  lcd.setCursor(0, 1);
  lcd.print("  Initializing  ");
  delay(1000);
  lcd.clear();

  lastClkState = digitalRead(clkPin);

  dht.begin();

  int savedTemp = EEPROM.read(0);
  hundreds = savedTemp / 100;
  tens = (savedTemp / 10) % 10;
  ones = savedTemp % 10;
}

void loop() {
  if (digitalRead(setModePin) == HIGH) {
    upperTempSetting();
  } else {
    monitoringTemp();
  }
}

void upperTempSetting() {
  lcd.setCursor(0, 0);
  lcd.print("Set Temp:        ");
  startFlicker();

  while (digitalRead(setModePin) == HIGH) {
    // Handle digit select
    if (digitalRead(buttonHundreds) == LOW) {
      selectedDigit = 1;
      startFlicker();
    } else if (digitalRead(buttonTens) == LOW) {
      selectedDigit = 2;
      startFlicker();
    } else if (digitalRead(buttonOnes) == LOW) {
      selectedDigit = 3;
      startFlicker();
    }

    // Rotary encoder
    int clkState = digitalRead(clkPin);
    int dtState = digitalRead(dtPin);
    if (clkState != lastClkState && clkState == LOW) {
      if (dtState != clkState) incrementDigit();
      else decrementDigit();
      lastEncoderTime = millis(); // Reset flicker timer
    }
    lastClkState = clkState;

    // Flicker timeout
    if (selectedDigit != 0 && millis() - lastEncoderTime > flickerDuration) {
      selectedDigit = 0;
    }

    if (selectedDigit != 0 && millis() - lastFlickerTime >= flickerInterval) {
      flickerOn = !flickerOn;
      lastFlickerTime = millis();
    }

    displaySetValue();
    delay(10); // to avoid bouncing
  }

  // Save temp and exit
  int temp = hundreds * 100 + tens * 10 + ones;
  EEPROM.write(0, temp);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Saved: ");
  lcd.print(temp);
  lcd.print(char(223));
  lcd.print("C");
  delay(1000);
  lcd.clear();
}

void monitoringTemp() {
  float tempC = dht.readTemperature();
  if (isnan(tempC)) {
    lcd.setCursor(0, 0);
    lcd.print("DHT read error  ");
    lcd.setCursor(0, 1);
    lcd.print("Check sensor    ");
    delay(1000);
    return;
  }

  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(tempC);
  lcd.print(char(223));
  lcd.print("C   ");

  int upperTemp = EEPROM.read(0);
  lcd.setCursor(0, 1);
  lcd.print("Upper: ");
  lcd.print(upperTemp);
  lcd.print(char(223));
  lcd.print("C   ");

  if (tempC >= upperTemp + hysteresis) {
    digitalWrite(relayPin, HIGH);
    digitalWrite(ledPin, HIGH);
  } else if (tempC < upperTemp - hysteresis) {
    digitalWrite(relayPin, LOW);
    digitalWrite(ledPin, LOW);
  }

  delay(300);
}

void startFlicker() {
  lastEncoderTime = millis();
  lastFlickerTime = millis();
  flickerOn = true;
}

void incrementDigit() {
  switch (selectedDigit) {
    case 1: hundreds = (hundreds + 1) % 10; break;
    case 2: tens = (tens + 1) % 10; break;
    case 3: ones = (ones + 1) % 10; break;
  }
}

void decrementDigit() {
  switch (selectedDigit) {
    case 1: hundreds = (hundreds + 9) % 10; break;
    case 2: tens = (tens + 9) % 10; break;
    case 3: ones = (ones + 9) % 10; break;
  }
}

void displaySetValue() {
  lcd.setCursor(0, 1);
  lcd.print("Value: ");

  if (selectedDigit == 1 && !flickerOn) lcd.print(" ");
  else lcd.print(hundreds);

  if (selectedDigit == 2 && !flickerOn) lcd.print(" ");
  else lcd.print(tens);

  if (selectedDigit == 3 && !flickerOn) lcd.print(" ");
  else lcd.print(ones);

  lcd.print("     "); // clear leftover chars
}
