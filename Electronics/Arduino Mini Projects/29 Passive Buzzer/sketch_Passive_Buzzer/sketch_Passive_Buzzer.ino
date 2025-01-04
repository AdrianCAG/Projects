// Define the buzzer pin
const int buzzerPin = 9;  // Active buzzer connected to pin 9

// Define the musical notes and their frequencies in Hz (using standard notation)
#define NOTE_E4  330   // E above Middle C
#define NOTE_F4  349   // F above Middle C
#define NOTE_G4  392   // G above Middle C
#define NOTE_A4  440   // A above Middle C
#define NOTE_B4  494   // B above Middle C
#define NOTE_C5  523   // C above Middle C
#define NOTE_D5  587   // D above Middle C

// Duration of notes in milliseconds
#define WHOLE  1000
#define HALF   500
#define QUARTER 250
#define EIGHTH 125

void setup() {
  // Set the buzzer pin as an output
  pinMode(buzzerPin, OUTPUT);
}

void loop() {
  // Play the song: "Ode to Joy"
  playOdeToJoy();
  
  // Add a delay before repeating the song
  delay(2000);
}

// Function to play "Ode to Joy"
void playOdeToJoy() {
  // First phrase
  tone(buzzerPin, NOTE_E4, HALF);  // E
  delay(HALF);
  tone(buzzerPin, NOTE_E4, HALF);  // E
  delay(HALF);
  tone(buzzerPin, NOTE_F4, HALF);  // F
  delay(HALF);
  tone(buzzerPin, NOTE_G4, HALF);  // G
  delay(HALF);
  
  tone(buzzerPin, NOTE_G4, HALF);  // G
  delay(HALF);
  tone(buzzerPin, NOTE_F4, HALF);  // F
  delay(HALF);
  tone(buzzerPin, NOTE_E4, HALF);  // E
  delay(HALF);
  
  // Second phrase
  tone(buzzerPin, NOTE_E4, HALF);  // E
  delay(HALF);
  tone(buzzerPin, NOTE_D5, HALF);  // D
  delay(HALF);
  tone(buzzerPin, NOTE_D5, HALF);  // D
  delay(HALF);
  
  // Third phrase
  tone(buzzerPin, NOTE_C5, HALF);  // C
  delay(HALF);
  tone(buzzerPin, NOTE_B4, HALF);  // B
  delay(HALF);
  tone(buzzerPin, NOTE_A4, HALF);  // A
  delay(HALF);
  tone(buzzerPin, NOTE_A4, HALF);  // A
  delay(HALF);
  
  // Fourth phrase
  tone(buzzerPin, NOTE_B4, HALF);  // B
  delay(HALF);
  tone(buzzerPin, NOTE_C5, HALF);  // C
  delay(HALF);
  tone(buzzerPin, NOTE_D5, HALF);  // D
  delay(HALF);
  
  // Add a pause after finishing the song
  delay(1000);
}
