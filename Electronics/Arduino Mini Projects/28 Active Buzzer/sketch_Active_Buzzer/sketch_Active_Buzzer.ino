// *************************************
// Active Buzzer Melody Example
// *************************************
// This program plays a rhythmic melody on an active buzzer using
// simple HIGH and LOW signals. The buzzer alternates between ON (HIGH)
// and OFF (LOW) states to create sounds. The melody is based on 
// durations to simulate a simple tune.
// *************************************

// Define the buzzer pin
const int buzzerPin = 9; // Active buzzer connected to pin 9

// Define note durations (in milliseconds)
const int WHOLE = 1000;   // Whole note
const int HALF = 500;     // Half note
const int QUARTER = 250;  // Quarter note
const int EIGHTH = 125;   // Eighth note
const int REST = 100;     // Pause between notes

void setup() {
  // *************************************
  // Setup Section: Initialize the buzzer pin
  // *************************************
  pinMode(buzzerPin, OUTPUT); // Set the buzzer pin as output
}

void loop() {
  // *************************************
  // Main Loop: Play the melody continuously
  // *************************************
  playMelody(); // Call the function to play a melody
  
  // Delay before the melody restarts
  delay(2000);
}

// *************************************
// Function to Play a Melody
// *************************************
void playMelody() {
  // "Melody" using HIGH/LOW signals with different durations
  
  // First phrase
  buzz(QUARTER); delay(REST);
  buzz(QUARTER); delay(REST);
  buzz(HALF); delay(REST);
  
  // Second phrase
  buzz(QUARTER); delay(REST);
  buzz(QUARTER); delay(REST);
  buzz(HALF); delay(REST);
  
  // Third phrase (faster rhythm)
  buzz(EIGHTH); delay(REST);
  buzz(EIGHTH); delay(REST);
  buzz(QUARTER); delay(REST);
  buzz(QUARTER); delay(REST);
  
  // Add a longer pause to separate phrases
  delay(1000);
}

// *************************************
// Function to Activate the Buzzer
// *************************************
void buzz(int duration) {
  // Turn the buzzer ON
  digitalWrite(buzzerPin, HIGH);
  delay(duration);
  
  // Turn the buzzer OFF
  digitalWrite(buzzerPin, LOW);
}
