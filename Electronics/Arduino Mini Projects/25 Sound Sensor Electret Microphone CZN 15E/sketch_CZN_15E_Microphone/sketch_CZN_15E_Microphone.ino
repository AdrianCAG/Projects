// Define the pin connected to the sound sensor
const int OUT_PIN = 8;

// Define the sampling interval in milliseconds
const int SAMPLE_TIME = 10;

// Variables for tracking time
unsigned long millisCurrent;  // Stores the current time in milliseconds
unsigned long millisLast = 0; // Stores the time of the last sample
unsigned long millisElapsed = 0; // Stores the elapsed time since the last sample

// Variable to count sound events detected during the sampling interval
int sampleBufferValue = 0;

void setup() {
  // Initialize the Serial Monitor for debugging
  Serial.begin(9600);
}

void loop() {
  // Get the current time in milliseconds
  millisCurrent = millis();

  // Calculate the time elapsed since the last sample
  millisElapsed = millisCurrent - millisLast;

  // Check if the sound sensor detects a signal (LOW indicates detection)
  if (digitalRead(OUT_PIN) == LOW) {
    sampleBufferValue++;  // Increment the sound event counter
  }

  // If the elapsed time exceeds the defined sampling interval
  if (millisElapsed > SAMPLE_TIME) {
    // Print the number of sound events detected during the interval
    Serial.println(sampleBufferValue);

    // Reset the counter for the next interval
    sampleBufferValue = 0;

    // Update the last sample time
    millisLast = millisCurrent;
  }
}
