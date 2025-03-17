// KY-011 2-Color LED 5mm Effects Code
// This program controls a bi-color LED using PWM for smooth transitions and effects.

int redPin = 11;   // Pin connected to the red LED
int greenPin = 10; // Pin connected to the green LED

void setup() {
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
}

// Function to smoothly transition between two colors
void fadeEffect(int fromRed, int fromGreen, int toRed, int toGreen, int steps, int delayTime) {
  for (int i = 0; i <= steps; i++) {
    int redValue = map(i, 0, steps, fromRed, toRed);
    int greenValue = map(i, 0, steps, fromGreen, toGreen);
    analogWrite(redPin, redValue);
    analogWrite(greenPin, greenValue);
    delay(delayTime);
  }
}

// Function to flash both colors on and off
void flashEffect(int times, int delayTime) {
  for (int i = 0; i < times; i++) {
    analogWrite(redPin, 255);
    analogWrite(greenPin, 255);
    delay(delayTime);
    analogWrite(redPin, 0);
    analogWrite(greenPin, 0);
    delay(delayTime);
  }
}

// Function to pulse red and green alternately
void pulseEffect(int delayTime) {
  for (int i = 0; i < 256; i++) {
    analogWrite(redPin, i);
    analogWrite(greenPin, 255 - i);
    delay(delayTime);
  }
  for (int i = 255; i >= 0; i--) {
    analogWrite(redPin, i);
    analogWrite(greenPin, 255 - i);
    delay(delayTime);
  }
}

// Function to alternate between red and green
void alternateEffect(int delayTime) {
  analogWrite(redPin, 255);
  analogWrite(greenPin, 0);
  delay(delayTime);
  analogWrite(redPin, 0);
  analogWrite(greenPin, 255);
  delay(delayTime);
}

void loop() {
  // Effect 1: Smooth transition from red to green
  fadeEffect(255, 0, 0, 255, 100, 10);

  // Effect 2: Smooth transition from green to red
  fadeEffect(0, 255, 255, 0, 100, 10);

  // Effect 3: Flashing both colors
  flashEffect(5, 200);

  // Effect 4: Pulsing red and green alternately
  pulseEffect(10);

  // Effect 5: Alternate between red and green
  alternateEffect(500);

  // Effect 6: Quick blinking red
  flashEffect(3, 100);

  // Effect 7: Quick blinking green
  analogWrite(redPin, 0);
  analogWrite(greenPin, 255);
  delay(100);
  analogWrite(greenPin, 0);
  delay(100);
  analogWrite(greenPin, 255);
  delay(100);
  analogWrite(greenPin, 0);
  delay(100);

  // Effect 8: Slow fade from off to red to off
  fadeEffect(0, 0, 255, 0, 50, 15);
  fadeEffect(255, 0, 0, 0, 50, 15);

  // Effect 9: Slow fade from off to green to off
  fadeEffect(0, 0, 0, 255, 50, 15);
  fadeEffect(0, 255, 0, 0, 50, 15);

  // Effect 10: Mix red and green (yellowish effect)
  analogWrite(redPin, 255);
  analogWrite(greenPin, 128);
  delay(1000);
}
