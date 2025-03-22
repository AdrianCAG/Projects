// KY-029 Bi-Color LED Module Example
// Controls red and green LEDs with smooth transitions

// Define LED pins
const int redPin = 11;    // Red LED pin (PWM)
const int greenPin = 10;  // Green LED pin (PWM)
const int bluePin = 9;    // Optional: Add a blue LED (if needed)

void setup() {
  // Set pins as OUTPUT
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  // Start serial communication
  Serial.begin(9600);
  Serial.println("KY-029 LED Module Initialized");
}

void loop() {
  // Transition from RED to GREEN
  Serial.println("Fading from Red to Green...");
  for (int val = 255; val >= 0; val--) {
    analogWrite(redPin, val);       // Decrease red intensity
    analogWrite(greenPin, 255 - val); // Increase green intensity
    delay(10);
  }
  Serial.println("Green Color Active");
  delay(1000);  // Hold green for 1 second

  // Transition from GREEN to RED
  Serial.println("Fading from Green to Red...");
  for (int val = 0; val <= 255; val++) {
    analogWrite(redPin, val);       // Increase red intensity
    analogWrite(greenPin, 255 - val); // Decrease green intensity
    delay(10);
  }
  Serial.println("Red Color Active");
  delay(1000);  // Hold red for 1 second

  // Optional: Blue LED Effect
  Serial.println("Flashing Blue LED...");
  for (int i = 0; i < 5; i++) {
    analogWrite(bluePin, 255);
    delay(200);
    analogWrite(bluePin, 0);
    delay(200);
  }
}
