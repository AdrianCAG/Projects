int vib = 3; // Declaration of the sensor input pin
int value;   // Temporary variable
  
void setup ()
{
  pinMode(vib, INPUT); // Initialization sensor pin
  digitalWrite(vib, HIGH); // Activation of internal pull-up resistor
  Serial.begin(9600); // Initialization of the serial monitor
  Serial.print("KY-002 Vibration detection");
}
  
void loop ()
{
  // The current signal at the sensor is read out.
  value = digitalRead(vib); 
  // If a signal could be detected, this is displayed on the serial monitor.
  if (value == LOW) {
    Serial.println("Signal detected");
    delay(100); // 100 ms break
    }
}