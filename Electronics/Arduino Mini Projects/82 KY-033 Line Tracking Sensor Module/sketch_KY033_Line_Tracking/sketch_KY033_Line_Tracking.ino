const int sensorPin = 7;   // Line detection sensor interface
const int ledPin = 13;     // Onboard LED to indicate detection
int val;                   // Variable to store sensor reading

void setup() {
  pinMode(sensorPin, INPUT);  // Define sensor as input
  pinMode(ledPin, OUTPUT);    // Define LED as output
  Serial.begin(9600);         // Initialize serial communication
  Serial.println("KY-032 Line Detection Initialized...");
}

void loop() {
  readSensor();   // Call function to read sensor
  delay(500);     // Delay to prevent rapid multiple readings
}

// Function to read sensor and respond
void readSensor() {
  val = digitalRead(sensorPin); // Read value from sensor

  if (val == HIGH) { 
    Serial.println("Line detected");
    digitalWrite(ledPin, HIGH);  // Turn LED ON
  } else { 
    Serial.println("Line NOT detected");
    digitalWrite(ledPin, LOW);   // Turn LED OFF
  }
}
