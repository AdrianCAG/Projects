/*
 * Joystick Position and Button Reader with Calibration
 * This program reads and displays the X and Y axis values of a joystick,
 * applies calibration to handle non-linear ranges, and prints the button state (SW).
 * 
 * Features:
 * - Improved sensitivity and calibration for better travel range detection.
 * - Dead zone calibration to avoid "sticking" near the center.
 * - Smoothing filter to stabilize noisy analog readings.
 */

// Pin configuration
const int xPin = A0; // VRX (X-axis) pin connected to analog pin A0
const int yPin = A1; // VRY (Y-axis) pin connected to analog pin A1
const int swPin = 8; // SW (Button) pin connected to digital pin 8

// Calibration settings
const int minValue = 100;   // Minimum analog value for X and Y
const int maxValue = 900;   // Maximum analog value for X and Y
const int deadZone = 50;    // Dead zone around the center for stability
const int smoothingFactor = 5; // Number of samples for smoothing

// Variables for smoothing
int xSamples[smoothingFactor] = {0};
int ySamples[smoothingFactor] = {0};
int sampleIndex = 0;

void setup() {
  // Configure the SW pin as an input with pull-up resistor enabled
  pinMode(swPin, INPUT_PULLUP);

  // Initialize the Serial Monitor for debugging
  Serial.begin(9600);
  Serial.println("Joystick Reader Initialized");
  Serial.println("Reading joystick values...");
  Serial.println("---------------------------");
}

void loop() {
  // Read raw analog values
  int rawX = analogRead(xPin);
  int rawY = analogRead(yPin);

  // Smooth the analog readings
  int smoothX = smoothInput(rawX, xSamples);
  int smoothY = smoothInput(rawY, ySamples);

  // Apply calibration and map the values to a 0-1023 range
  int calibratedX = map(constrain(smoothX, minValue, maxValue), minValue, maxValue, 0, 1023);
  int calibratedY = map(constrain(smoothY, minValue, maxValue), minValue, maxValue, 0, 1023);

  // Apply dead zone to prevent noise near the center
  calibratedX = applyDeadZone(calibratedX);
  calibratedY = applyDeadZone(calibratedY);

  // Read the SW button state
  int zState = digitalRead(swPin);

  // Display the values
  Serial.print("X-axis: ");
  Serial.print(calibratedX);
  Serial.print(" | Y-axis: ");
  Serial.print(calibratedY);
  Serial.print(" | Button (SW): ");
  if (zState == LOW) {
    Serial.println("Pressed");
  } else {
    Serial.println("Released");
  }

  // Short delay for stable readings
  delay(50);
}

/*
 * Function: smoothInput
 * Purpose: Stabilizes noisy analog readings using a moving average filter.
 * Input:  int rawValue - The raw analog value to smooth.
 *         int samples[] - Array storing the recent samples.
 * Output: int - The smoothed analog value.
 */
int smoothInput(int rawValue, int samples[]) {
  samples[sampleIndex] = rawValue; // Store the new sample
  sampleIndex = (sampleIndex + 1) % smoothingFactor; // Update the sample index

  int sum = 0;
  for (int i = 0; i < smoothingFactor; i++) {
    sum += samples[i]; // Calculate the sum of samples
  }
  return sum / smoothingFactor; // Return the average
}

/*
 * Function: applyDeadZone
 * Purpose: Adjusts joystick values near the center to avoid noise.
 * Input:  int value - The joystick value.
 * Output: int - The adjusted value with dead zone applied.
 */
int applyDeadZone(int value) {
  int center = 512; // Center of the joystick range
  if (abs(value - center) < deadZone) {
    return center; // Snap to center if within the dead zone
  }
  return value;
}

/*
 * Notes:
 * - `map()` and `constrain()` ensure the joystick range is properly scaled.
 * - Adjust `minValue`, `maxValue`, and `deadZone` based on your joystick module.
 * - Smoothing prevents jittery readings by averaging recent samples.
 * - The button (SW) state remains responsive even with smoothing applied.
 */
