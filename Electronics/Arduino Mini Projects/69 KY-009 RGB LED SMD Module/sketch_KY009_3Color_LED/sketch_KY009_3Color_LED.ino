// Pin definitions for KY-009 RGB LED module
const int redPin = 11;
const int greenPin = 9;
const int bluePin = 10;

// Function to set RGB LED color
void setColor(int r, int g, int b) {
  analogWrite(redPin, r);
  analogWrite(greenPin, g);
  analogWrite(bluePin, b);
}

// White flash transition between effects
void whiteFlash() {
  setColor(255, 255, 255);
  delay(200);
  setColor(0, 0, 0);
  delay(200);
  setColor(255, 255, 255);
  delay(200);
  setColor(0, 0, 0);
  delay(200);
}

// Fade between two colors
void fadeEffect(int r1, int g1, int b1, int r2, int g2, int b2, int steps, int delayTime) {
  for (int i = 0; i <= steps; i++) {
    int r = map(i, 0, steps, r1, r2);
    int g = map(i, 0, steps, g1, g2);
    int b = map(i, 0, steps, b1, b2);
    setColor(r, g, b);
    delay(delayTime);
  }
}

// Rainbow effect (smooth transition across colors)
void rainbowEffect(int delayTime) {
  for (int i = 0; i < 256; i++) {
    setColor(i, 255 - i, 128);
    delay(delayTime);
  }
  for (int i = 255; i >= 0; i--) {
    setColor(i, 255 - i, 128);
    delay(delayTime);
  }
}

// Strobe effect (flashes RGB colors)
void strobeEffect(int times, int delayTime) {
  for (int i = 0; i < times; i++) {
    setColor(255, 0, 0); // Red
    delay(delayTime);
    setColor(0, 255, 0); // Green
    delay(delayTime);
    setColor(0, 0, 255); // Blue
    delay(delayTime);
    setColor(0, 0, 0); // Off
    delay(delayTime);
  }
}

// Random color display
void randomColors(int times, int delayTime) {
  for (int i = 0; i < times; i++) {
    setColor(random(0, 256), random(0, 256), random(0, 256));
    delay(delayTime);
  }
}

// Breathing effect
void breathingEffect(int delayTime) {
  for (int i = 0; i <= 255; i++) {
    setColor(i, i / 2, 255 - i);
    delay(delayTime);
  }
  for (int i = 255; i >= 0; i--) {
    setColor(i, i / 2, 255 - i);
    delay(delayTime);
  }
}

// Color cycle
void colorCycle(int delayTime) {
  fadeEffect(255, 0, 0, 0, 255, 0, 100, delayTime); // Red to Green
  fadeEffect(0, 255, 0, 0, 0, 255, 100, delayTime); // Green to Blue
  fadeEffect(0, 0, 255, 255, 0, 0, 100, delayTime); // Blue to Red
}

// Smooth transition across thousands of colors
void smoothTransition(int delayTime) {
  for (int i = 0; i < 256; i++) {
    setColor(i, 255 - i, i / 2);
    delay(delayTime);
  }
}

// Startup setup
void setup() {
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  Serial.begin(9600);
}

// Main loop: Run different effects with white flashes in between
void loop() {
  Serial.println("Running Color Effects...");
  
  rainbowEffect(5);
  whiteFlash();
  
  strobeEffect(5, 100);
  whiteFlash();
  
  randomColors(10, 500);
  whiteFlash();
  
  breathingEffect(5);
  whiteFlash();
  
  colorCycle(5);
  whiteFlash();
  
  smoothTransition(5);
  whiteFlash();
}
