// ***************************************
// PIR Motion Sensor Example Code
// Description: This program reads input from a PIR motion sensor connected to pin 2 
//              and prints the detected state (HIGH or LOW) to the serial console.
// ***************************************

void setup() {
  // Initialize serial communication at 9600 baud rate
  // This is used to display the output in the serial monitor
  Serial.begin(9600);

  // Set pin 2 (connected to the PIR sensor output) as an input pin
  pinMode(2, INPUT);
}

void loop() {
  // Read the digital state of pin 2
  // The PIR sensor outputs HIGH (1) when motion is detected and LOW (0) otherwise
  int motionStatus = digitalRead(2);

  // Print the current motion status to the serial console
  Serial.println(motionStatus);

  // Small delay to stabilize readings and prevent flooding the serial monitor
  delay(1);
}
