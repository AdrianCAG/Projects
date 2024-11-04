/*
 * This program controls an LED using a push button.
 * When the button connected to pin 2 is pressed, the LED on pin 9 turns on.
 * When the button is not pressed, the LED remains off.
 */

const int buttonPin = 2;    // Pin connected to the button
const int ledPin = 9;       // Pin connected to the LED

int buttonState = 0;        // Variable to store the state of the button

void setup() {
  // Initialize the LED pin as an output
  pinMode(ledPin, OUTPUT);

  // Initialize the button pin as an input
  pinMode(buttonPin, INPUT);

  // Begin serial communication for debugging purposes
  Serial.begin(9600);
  Serial.println("Button-controlled LED initialized...");
}

void loop() {
  // Read the button state (HIGH when pressed, LOW when not pressed)
  buttonState = digitalRead(buttonPin);

  // Print the button state to the serial monitor
  Serial.print("Button State: ");
  Serial.println(buttonState == HIGH ? "Pressed" : "Not Pressed");

  // If the button is pressed, turn on the LED
  if (buttonState == HIGH) {
    digitalWrite(ledPin, HIGH);
    Serial.println("LED ON");
  } 
  // If the button is not pressed, turn off the LED
  else {
    digitalWrite(ledPin, LOW);
    Serial.println("LED OFF");
  }

  // Small delay to avoid bouncing effect on button press
  delay(200);
}