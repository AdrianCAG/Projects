/*
 * Mini project to control an LED connected to pin 9.
 * The LED will turn on and off with varying delays, 
 * and then blink 15 times rapidly in the loop.
 */

const int ledPin = 9;  // Define the pin number for the LED

/*
 * setup() function runs once when the microcontroller is powered on or reset.
 * It sets up the LED pin as an output.
 */
void setup() 
{
  pinMode(ledPin, OUTPUT);  // Set ledPin as an output pin
}

/*
 * loop() function runs repeatedly after setup() finishes.
 * The LED will:
 * - Turn on and off with various delays
 * - Blink 15 times with short delays in a loop
 */
void loop() 
{ 
  /*
   * Turn the LED on for 1 second, then off for 1 second.
   */
  digitalWrite(ledPin, HIGH);  // Turn LED on
  delay(1000);                 // Wait for 1000ms (1 second)
  
  digitalWrite(ledPin, LOW);   // Turn LED off
  delay(1000);                 // Wait for 1000ms (1 second)

  /*
   * Turn the LED on and off with decreasing delay times.
   * 800ms, 600ms, and 500ms intervals.
   */
  digitalWrite(ledPin, HIGH);  // Turn LED on for 800ms
  delay(800);                  // Wait for 800ms
  
  digitalWrite(ledPin, LOW);   // Turn LED off for 800ms
  delay(800);                  // Wait for 800ms

  digitalWrite(ledPin, HIGH);  // Turn LED on for 600ms
  delay(600);                  // Wait for 600ms
  
  digitalWrite(ledPin, LOW);   // Turn LED off for 600ms
  delay(600);                  // Wait for 600ms

  digitalWrite(ledPin, HIGH);  // Turn LED on for 500ms
  delay(500);                  // Wait for 500ms
  
  digitalWrite(ledPin, LOW);   // Turn LED off for 500ms
  delay(500);                  // Wait for 500ms

  /*
   * Blink the LED 15 times with 200ms on/off intervals.
   */
  for(int i = 0; i < 15; i++) 
  {
    digitalWrite(ledPin, HIGH);  // Turn LED on
    delay(200);                  // Wait for 200ms
    
    digitalWrite(ledPin, LOW);   // Turn LED off
    delay(200);                  // Wait for 200ms
  }
}
