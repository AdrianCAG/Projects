#include <Servo.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <IRremote.h>

LiquidCrystal_I2C lcd(0x27, 16, 2);
Servo myServo;

const int buttonPin = 10;
const int recvPin = 5;

IRrecv irrecv(recvPin);
decode_results results;

int maxRounds = 3;
int roundNum = 1;
int targetNumber = -1;
int currentInput = 0;
bool targetSet = false;
bool roundsSet = false;

int player1Guess = -1;
int player2Guess = -1;

void setup() {
  Serial.begin(9600);
  irrecv.enableIRIn();
  lcd.init();
  lcd.backlight();
  myServo.attach(9);
  pinMode(buttonPin, INPUT);
  myServo.write(0);

  lcd.setCursor(0, 0);
  lcd.print("Set Rounds:");
  lcd.setCursor(0, 1);
}

void loop() {
  if (!roundsSet) {
    handleRoundInput();
    return;
  }

  if (!targetSet) {
    handleTargetInput();
    return;
  }

  playGame();
}

void handleRoundInput() {
  if (irrecv.decode(&results)) {
    String num = decodeKeyValue(results.value);
    if (num == "POWER") {
      currentInput = 0;
      lcd.clear();
      lcd.print("Set Rounds:");
      lcd.setCursor(0, 1);
    } else if (num == "CYCLE") {
      maxRounds = currentInput;
      if (maxRounds < 1) maxRounds = 1;
      if (maxRounds > 10) maxRounds = 10;
      lcd.clear();
      lcd.print("Rounds: ");
      lcd.print(maxRounds);
      lcd.print(" +Extra");
      
      delay(2000);
      lcd.clear();
      lcd.print("Enter Number:");
      lcd.setCursor(0, 1);
      currentInput = 0;
      roundsSet = true;
    } else if (num >= "0" && num <= "9") {
      currentInput = currentInput * 10 + num.toInt();
      if (currentInput > 99) currentInput = 99;
      lcd.setCursor(0, 1);
      lcd.print(currentInput);
      lcd.print("     ");
    }
    irrecv.resume();
  }
}

void handleTargetInput() {
  if (irrecv.decode(&results)) {
    String num = decodeKeyValue(results.value);
    if (num == "POWER") {
      currentInput = 0;
      lcd.clear();
      lcd.print("Enter Number:");
      lcd.setCursor(0, 1);
    } else if (num == "CYCLE") {
      targetNumber = currentInput;
      Serial.print("Target number set to: ");
      Serial.println(targetNumber);
      lcd.clear();
      lcd.print("Number is set!");
      delay(1000);
      lcd.clear();
      targetSet = true;
      randomSeed(analogRead(A0));
    } else if (num >= "0" && num <= "9") {
      currentInput = currentInput * 10 + num.toInt();
      if (currentInput > 100) currentInput = 100;
      lcd.setCursor(0, 1);
      lcd.print(currentInput);
      lcd.print("     ");
    }
    irrecv.resume();
  }
}

void playGame() {
  while (roundNum <= maxRounds) {
    lcd.clear();
    lcd.print("Round ");
    lcd.print(roundNum);
    delay(1000);

    bool player1First = random(0, 2) == 0;
    int firstPlayer = player1First ? 1 : 2;
    int secondPlayer = player1First ? 2 : 1;

    getPlayerGuess(firstPlayer);
    getPlayerGuess(secondPlayer);

    bool firstCorrect = isGuessCorrect(firstPlayer == 1 ? player1Guess : player2Guess);
    bool secondCorrect = isGuessCorrect(secondPlayer == 1 ? player1Guess : player2Guess);

    if (firstCorrect || secondCorrect) {
      lcd.clear();
      if (firstCorrect) {
        lcd.print("P");
        lcd.print(firstPlayer);
        lcd.print(" Wins!");
      }
      if (secondCorrect) {
        lcd.setCursor(0, firstCorrect ? 1 : 0);
        lcd.print("P");
        lcd.print(secondPlayer);
        lcd.print(" Wins!");
      }
      delay(3000);
      waitForRestart();
      return;
    }

    lcd.clear();
    lcd.print("P1 Wrong");
    lcd.setCursor(0, 1);
    lcd.print("P2 Wrong");
    delay(1500);

    roundNum++;
  }

  // Final chance with servo help
  bool buttonPressed = false;
  for (int i = 5; i >= 0; i--) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Press btn to");
    lcd.setCursor(0, 1);
    lcd.print("help guess ");
    lcd.print(i);

    unsigned long start = millis();
    while (millis() - start < 1000) {
      if (digitalRead(buttonPin) == LOW) {
        buttonPressed = true;
        break;
      }
    }

    if (buttonPressed) break;
  }

  if (buttonPressed) {
    int angle = map(targetNumber, 0, 100, 0, 180);
    myServo.write(angle);
    lcd.clear();
    lcd.print("Servo shows num");
    delay(3000);
  }

  lcd.clear();
  lcd.print("Final guess time");
  delay(1500);

  getPlayerGuess(1);
  if (isGuessCorrect(player1Guess)) {
    lcd.clear();
    lcd.print("P1 Wins!");
    delay(3000);
    waitForRestart();
    return;
  }

  getPlayerGuess(2);
  if (isGuessCorrect(player2Guess)) {
    lcd.clear();
    lcd.print("P2 Wins!");
    delay(3000);
    waitForRestart();
    return;
  }

  lcd.clear();
  lcd.print("Game Over");
  lcd.setCursor(0, 1);
  lcd.print("Num: ");
  lcd.print(targetNumber);
  Serial.print("Game Over! Number was: ");
  Serial.println(targetNumber);
  delay(3000);
  waitForRestart();
}

void getPlayerGuess(int player) {
  lcd.clear();
  lcd.print("P");
  lcd.print(player);
  lcd.print(" guess:");
  int guess = waitForIRNumber();
  if (player == 1) player1Guess = guess;
  else player2Guess = guess;
}

int waitForIRNumber() {
  int guess = 0;
  while (true) {
    if (irrecv.decode(&results)) {
      String num = decodeKeyValue(results.value);
      if (num == "POWER") {
        guess = 0;
        lcd.setCursor(0, 1);
        lcd.print("Cleared     ");
      } else if (num == "CYCLE") {
        lcd.setCursor(0, 1);
        lcd.print("Submitted");
        delay(1000);
        irrecv.resume();
        return guess;
      } else if (num >= "0" && num <= "9") {
        guess = guess * 10 + num.toInt();
        if (guess > 100) guess = 100;
        lcd.setCursor(0, 1);
        lcd.print(guess);
        lcd.print("     ");
      }
      irrecv.resume();
    }
  }
}

bool isGuessCorrect(int guess) {
  return guess == targetNumber;
}

void waitForRestart() {
  lcd.clear();
  lcd.print("Press btn again");
  lcd.setCursor(0, 1);
  lcd.print("to restart");
  while (digitalRead(buttonPin) == LOW) {
    // wait
  }

  roundNum = 1;
  currentInput = 0;
  targetSet = false;
  roundsSet = false;
  player1Guess = -1;
  player2Guess = -1;
  myServo.write(0);
  lcd.clear();
  lcd.print("Set Rounds:");
  lcd.setCursor(0, 1);
}

String decodeKeyValue(long result) {
  switch (result) {
    case 0xFF6897: return "0";
    case 0xFF30CF: return "1"; 
    case 0xFF18E7: return "2"; 
    case 0xFF7A85: return "3"; 
    case 0xFF10EF: return "4"; 
    case 0xFF38C7: return "5"; 
    case 0xFF5AA5: return "6"; 
    case 0xFF42BD: return "7"; 
    case 0xFF4AB5: return "8"; 
    case 0xFF52AD: return "9"; 
    case 0xFF9867: return "CYCLE";
    case 0xFFA25D: return "POWER";
    default: return "ERROR";
  }
}


// Convert servo angle back to percentage
// int percent = (angle * 100) / 180;