// Define the pin connected to the KY-008 Laser Module
const int laserPin = 13; // Using pin 13 for laser output

void setup() {
  // Set the laserPin as an OUTPUT
  pinMode(laserPin, OUTPUT);
  
  // Initialize Serial Monitor for debugging
  Serial.begin(9600);
}

void loop() {
  // Turn ON the laser
  digitalWrite(laserPin, HIGH);
  Serial.println("Laser ON"); // Debugging message
  
  delay(100); // Laser stays on for 100ms
  
  // Turn OFF the laser (to prevent overheating)
  digitalWrite(laserPin, LOW);
  Serial.println("Laser OFF"); // Debugging message

  delay(100); // Laser stays off for 100ms
}
