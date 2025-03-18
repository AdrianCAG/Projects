// KY-016 RGB LED Module - Enhanced Code
// This program smoothly transitions colors and adds random color effects.

const int redPin = 11;   // Pin for Red LED
const int greenPin = 9;  // Pin for Green LED
const int bluePin = 10;  // Pin for Blue LED

void setup() {
  pinMode(redPin, OUTPUT);   // Set red pin as output
  pinMode(greenPin, OUTPUT); // Set green pin as output
  pinMode(bluePin, OUTPUT);  // Set blue pin as output
  Serial.begin(9600);        // Initialize serial monitor
}

// Function to set RGB color
void setColor(int red, int green, int blue) {
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);
}

// Function to fade between colors
void fadeColors() {
  for (int val = 255; val >= 0; val--) {
    setColor(val, 255 - val, 128 - val);  // Gradient effect
    Serial.println(val);  
    delay(5); 
  }
  for (int val = 0; val <= 255; val++) {
    setColor(val, 255 - val, 128 - val); 
    Serial.println(val);
    delay(5);
  }
}

// Function to generate random colors
void randomColors(int delayTime) {
  int red = random(0, 256);
  int green = random(0, 256);
  int blue = random(0, 256);
  setColor(red, green, blue);
  Serial.print("Random Color - R: ");
  Serial.print(red);
  Serial.print(" G: ");
  Serial.print(green);
  Serial.print(" B: ");
  Serial.println(blue);
  delay(delayTime);
}

void loop() {
  fadeColors();        // Smooth color transition effect
  randomColors(1000);  // Random color effect with 1 sec delay
}
