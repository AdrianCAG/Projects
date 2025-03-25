int ledPin = 13;  // Pin to control KY-034 LED

void setup() {                
  pinMode(ledPin, OUTPUT);  // Define LED pin as output
}

void loop() {
  // Steady ON for 3 seconds
  digitalWrite(ledPin, HIGH);  
  delay(3000);                
  
  // Steady OFF for 1 second
  digitalWrite(ledPin, LOW);   
  delay(1000);                

  // FLASH effect: Rapid blinking 5 times
  for (int i = 0; i < 5; i++) {
    digitalWrite(ledPin, HIGH);
    delay(100);  
    digitalWrite(ledPin, LOW);
    delay(100);  
  }
  
  // Slow blinking effect: 3 times
  for (int i = 0; i < 3; i++) {
    digitalWrite(ledPin, HIGH);
    delay(500);  
    digitalWrite(ledPin, LOW);
    delay(500);  
  }

  // Alternating pattern: Two fast blinks, then one long blink
  for (int i = 0; i < 2; i++) {
    digitalWrite(ledPin, HIGH);
    delay(200);
    digitalWrite(ledPin, LOW);
    delay(200);
  }
  digitalWrite(ledPin, HIGH);
  delay(1000);
  digitalWrite(ledPin, LOW);
  delay(1000);
}
