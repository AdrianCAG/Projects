// Program to measure distance using HC-SR04 Ultrasonic Sensor

// Define pins for the HC-SR04 module
const int echoPin = 4; // Pin connected to the Echo pin of the sensor
const int trigPin = 5; // Pin connected to the Trigger pin of the sensor

// Setup function - Runs once at the start
void setup() {
  Serial.begin(9600); // Initialize serial communication at 9600 baud
  pinMode(echoPin, INPUT); // Set Echo pin as input
  pinMode(trigPin, OUTPUT); // Set Trigger pin as output
  
  // Display an initial message for clarity
  Serial.println("Ultrasonic Sensor HC-SR04 Initialized");
  Serial.println("-------------------------------------");
  Serial.println("Measuring distance...");
}

// Main loop - Continuously measures and displays distance
void loop() {
  // Measure distance using the ultrasonic sensor
  float distance = readSensorData(); 

  // Display the measured distance
  Serial.print("Distance: ");
  Serial.print(distance);   
  Serial.println(" cm");

  // Wait before taking the next measurement
  delay(400); // Delay of 400ms
}

// Function to read sensor data and calculate distance
float readSensorData() {
  // Ensure the Trigger pin is LOW before starting a new measurement
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2); 

  // Send a 10-microsecond pulse to the Trigger pin
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10); 
  digitalWrite(trigPin, LOW);  

  // Measure the duration of the HIGH pulse on the Echo pin
  float duration = pulseIn(echoPin, HIGH); 

  // Calculate distance based on the duration of the pulse
  // Speed of sound = 340 m/s, equivalent to 0.034 cm/μs
  // Distance = (duration * 0.034) / 2; Simplified to duration / 58.00
  float distance = duration / 58.00;  

  // Add a safety check for out-of-range readings
  if (distance <= 0 || distance > 400) {
    Serial.println("Warning: Out of range or no object detected");
    return -1; // Return -1 to indicate an invalid reading
  }

  return distance; // Return the calculated distance
}
