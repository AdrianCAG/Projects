/**
 * Rotary Encoder Interface
 * 
 * This program reads values from a rotary encoder with push button functionality.
 * It tracks both rotation direction and button presses, outputting the cumulative
 * value via serial communication.
 * 
 * Hardware Connections:
 * - CLK pin -> Arduino Pin 2
 * - DT pin  -> Arduino Pin 3
 * - SW pin  -> Arduino Pin 4
 * 
 * The encoder counts up or down based on rotation direction and
 * resets to zero when the button is pressed.
 */

// Pin Definitions
const int ENCODER_CLK_PIN = 2;    // Clock pin from encoder
const int ENCODER_DT_PIN = 3;     // Data pin from encoder
const int ENCODER_BUTTON_PIN = 4; // Push button pin from encoder

// Global Variables
int encoderValue = 0;  // Tracks cumulative rotation value

void setup() {
    // Configure encoder pins as inputs
    pinMode(ENCODER_CLK_PIN, INPUT);
    pinMode(ENCODER_DT_PIN, INPUT);
    pinMode(ENCODER_BUTTON_PIN, INPUT);
    
    // Enable internal pullup for button
    digitalWrite(ENCODER_BUTTON_PIN, HIGH);
    
    // Initialize serial communication
    Serial.begin(9600);
}

void loop() {
    // Read encoder rotation and update value
    int rotationChange = getEncoderRotation();
    encoderValue += rotationChange;
    
    // Check for button press and reset if pressed
    if (isButtonPressed()) {
        encoderValue = 0;
        Serial.println("Counter reset!");
    }
    
    // Output current value
    Serial.println(encoderValue);
}

/**
 * Detects rotation of the encoder and returns direction
 * 
 * Returns:
 *  1  -> Clockwise rotation
 * -1  -> Counter-clockwise rotation
 *  0  -> No rotation
 */
int getEncoderRotation() {
    // Store previous pin states
    static int previousDT = HIGH;
    static int previousCLK = HIGH;
    
    // Read current pin states
    int currentDT = digitalRead(ENCODER_DT_PIN);
    int currentCLK = digitalRead(ENCODER_CLK_PIN);
    
    // Variables for tracking rotation
    int rotationValue = 0;
    
    // Check if either pin has changed state
    if (currentDT != previousDT || currentCLK != previousCLK) {
        // Determine rotation direction based on DT pin transition
        if (previousDT == HIGH && currentDT == LOW) {
            // Use CLK state to determine direction
            // previousCLK == HIGH -> Counter-clockwise (-1)
            // previousCLK == LOW  -> Clockwise (1)
            rotationValue = (previousCLK * 2 - 1);
        }
    }
    
    // Store current states for next comparison
    previousDT = currentDT;
    previousCLK = currentCLK;
    
    return rotationValue;
}

/**
 * Checks if the encoder button is currently pressed
 * 
 * Returns:
 *  true  -> Button is pressed
 *  false -> Button is not pressed
 */
bool isButtonPressed() {
    return digitalRead(ENCODER_BUTTON_PIN) == LOW;
}