// Arduino Sound Trigger with Manual Stop Button - EVENT DRIVEN VERSION
// Only sends data to Swift app when state changes occur

const int analogSoundPin = A0;
const int digitalSoundPin = 2;
const int stopButtonPin = 3;
const int statusLED = 13;         // Recording status indicator (RED)
const int triggerLED = 12;        // Trigger detection indicator (GREEN)
const int buttonLED = 11;         // Button press indicator (BLUE)

// Configurable parameters
int analogThreshold = 300;
unsigned long triggerCooldown = 1000;
unsigned long buttonDebounce = 50;

// State variables
unsigned long recordStartTime = 0;
unsigned long lastTriggerTime = 0;
bool isRecording = false;

// Button handling variables
bool lastButtonState = HIGH;
bool buttonState = HIGH;
unsigned long lastButtonDebounce = 0;

// Previous state tracking for change detection
bool prevSoundDetected = false;
bool prevRecording = false;
int prevAnalogLevel = 0;
bool prevDigitalState = false;

void setup() {
  pinMode(digitalSoundPin, INPUT);
  pinMode(stopButtonPin, INPUT_PULLUP);
  pinMode(statusLED, OUTPUT);
  pinMode(triggerLED, OUTPUT);
  pinMode(buttonLED, OUTPUT);
  
  Serial.begin(9600);
  
  digitalWrite(statusLED, LOW);
  digitalWrite(triggerLED, LOW);
  digitalWrite(buttonLED, LOW);
  
  Serial.println("{\"status\":\"ready\",\"message\":\"Arduino Sound Trigger Ready\"}");
  
  startupSequence();
}

void loop() {
  unsigned long currentTime = millis();
  
  // Handle button input with debouncing
  handleStopButton(currentTime);
  
  // Read sensor values
  int analogLevel = analogRead(analogSoundPin);
  bool digitalTriggered = digitalRead(digitalSoundPin) == HIGH;
  
  // Determine if sound is detected
  bool soundDetected = (analogLevel > analogThreshold) || digitalTriggered;
  
  // Update trigger LED (green) - shows sound detection
  digitalWrite(triggerLED, soundDetected ? HIGH : LOW);
  
  // ONLY send update if sound detection state changed
  if (soundDetected != prevSoundDetected) {
    sendSoundDetectionChange(soundDetected, analogLevel, digitalTriggered);
    prevSoundDetected = soundDetected;
  }
  
  // Handle recording state
  if (!isRecording && soundDetected && 
      (currentTime - lastTriggerTime > triggerCooldown)) {
    
    startRecording(currentTime, analogLevel);
    lastTriggerTime = currentTime;
  }
  
  delay(100);
}

void handleStopButton(unsigned long currentTime) {
  int reading = digitalRead(stopButtonPin);
  
  if (reading != lastButtonState) {
    lastButtonDebounce = currentTime;
  }
  
  if ((currentTime - lastButtonDebounce) > buttonDebounce) {
    if (reading != buttonState) {
      buttonState = reading;
      
      if (buttonState == LOW) {
        digitalWrite(buttonLED, HIGH);
        
        if (isRecording) {
          stopRecording(currentTime, currentTime - recordStartTime);
        } else {
          Serial.println("{\"event\":\"button_pressed\",\"recording\":false}");
        }
      } else {
        digitalWrite(buttonLED, LOW);
      }
    }
  }
  
  lastButtonState = reading;
}

void startRecording(unsigned long timestamp, int triggerLevel) {
  isRecording = true;
  recordStartTime = timestamp;
  
  digitalWrite(statusLED, HIGH);
  
  Serial.print("{\"event\":\"recording_started\",\"mode\":\"indefinite\",\"timestamp\":");
  Serial.print(timestamp);
  Serial.print(",\"trigger_level\":");
  Serial.print(triggerLevel);
  Serial.println("}");
}

void stopRecording(unsigned long timestamp, unsigned long duration) {
  isRecording = false;
  
  digitalWrite(statusLED, LOW);
  
  Serial.print("{\"event\":\"recording_stopped\",\"reason\":\"button_pressed\",\"timestamp\":");
  Serial.print(timestamp);
  Serial.print(",\"duration\":");
  Serial.print(duration);
  Serial.println("}");
}

void sendSoundDetectionChange(bool detected, int analogLevel, bool digitalState) {
  // Only send when sound detection state changes
  Serial.print("{\"event\":\"sound_detection_changed\",\"detected\":");
  Serial.print(detected ? "true" : "false");
  Serial.print(",\"analog_level\":");
  Serial.print(analogLevel);
  Serial.print(",\"digital_triggered\":");
  Serial.print(digitalState ? "true" : "false");
  Serial.print(",\"timestamp\":");
  Serial.print(millis());
  Serial.println("}");
}

void startupSequence() {
  Serial.println("{\"event\":\"startup\",\"message\":\"LED Test Sequence\"}");
  
  digitalWrite(triggerLED, HIGH);
  delay(300);
  digitalWrite(triggerLED, LOW);
  
  digitalWrite(statusLED, HIGH);
  delay(300);
  digitalWrite(statusLED, LOW);
  
  digitalWrite(buttonLED, HIGH);
  delay(300);
  digitalWrite(buttonLED, LOW);
  
  for(int i = 0; i < 3; i++) {
    digitalWrite(statusLED, HIGH);
    digitalWrite(triggerLED, HIGH);
    digitalWrite(buttonLED, HIGH);
    delay(150);
    digitalWrite(statusLED, LOW);
    digitalWrite(triggerLED, LOW);
    digitalWrite(buttonLED, LOW);
    delay(150);
  }
  
  Serial.println("{\"event\":\"system_ready\",\"message\":\"Waiting for Sound\"}");
}

void serialEvent() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command.startsWith("{")) {
      parseJsonCommand(command);
    } else {
      handleSimpleCommand(command);
    }
  }
}

void parseJsonCommand(String jsonCommand) {
  if (jsonCommand.indexOf("\"command\":\"manual_start\"") != -1) {
    if (!isRecording) {
      startRecording(millis(), analogRead(analogSoundPin));
      lastTriggerTime = millis();
    } else {
      Serial.println("{\"response\":\"already_recording\"}");
    }
  }
  else if (jsonCommand.indexOf("\"command\":\"manual_stop\"") != -1) {
    if (isRecording) {
      stopRecording(millis(), millis() - recordStartTime);
    } else {
      Serial.println("{\"response\":\"not_recording\"}");
    }
  }
  else if (jsonCommand.indexOf("\"command\":\"set_threshold\"") != -1) {
    int valueStart = jsonCommand.indexOf("\"value\":") + 8;
    int valueEnd = jsonCommand.indexOf(",", valueStart);
    if (valueEnd == -1) valueEnd = jsonCommand.indexOf("}", valueStart);
    
    if (valueStart > 7 && valueEnd > valueStart) {
      int newThreshold = jsonCommand.substring(valueStart, valueEnd).toInt();
      if (newThreshold >= 0 && newThreshold <= 1023) {
        analogThreshold = newThreshold;
        Serial.print("{\"response\":\"threshold_set\",\"value\":");
        Serial.print(analogThreshold);
        Serial.println("}");
      }
    }
  }
  else if (jsonCommand.indexOf("\"command\":\"get_status\"") != -1) {
    sendCurrentStatus();
  }
  else if (jsonCommand.indexOf("\"command\":\"get_config\"") != -1) {
    sendConfiguration();
  }
  else if (jsonCommand.indexOf("\"command\":\"test_leds\"") != -1) {
    testLEDs();
  }
}

void handleSimpleCommand(String command) {
  if (command == "START") {
    if (!isRecording) {
      startRecording(millis(), analogRead(analogSoundPin));
      lastTriggerTime = millis();
    }
  }
  else if (command == "STOP") {
    if (isRecording) {
      stopRecording(millis(), millis() - recordStartTime);
    }
  }
  else if (command == "STATUS") {
    sendCurrentStatus();
  }
  else if (command.startsWith("THRESHOLD:")) {
    int newThreshold = command.substring(10).toInt();
    if (newThreshold >= 0 && newThreshold <= 1023) {
      analogThreshold = newThreshold;
      Serial.print("{\"response\":\"threshold_updated\",\"value\":");
      Serial.print(analogThreshold);
      Serial.println("}");
    }
  }
  else if (command == "TEST") {
    testLEDs();
  }
}

void sendCurrentStatus() {
  // Only send when explicitly requested
  int analogLevel = analogRead(analogSoundPin);
  bool digitalState = digitalRead(digitalSoundPin) == HIGH;
  bool soundDetected = (analogLevel > analogThreshold) || digitalState;
  
  Serial.print("{\"response\":\"current_status\",\"analog_level\":");
  Serial.print(analogLevel);
  Serial.print(",\"digital_triggered\":");
  Serial.print(digitalState ? "true" : "false");
  Serial.print(",\"sound_detected\":");
  Serial.print(soundDetected ? "true" : "false");
  Serial.print(",\"recording\":");
  Serial.print(isRecording ? "true" : "false");
  Serial.print(",\"button_state\":");
  Serial.print(digitalRead(stopButtonPin) == LOW ? "\"pressed\"" : "\"released\"");
  Serial.print(",\"timestamp\":");
  Serial.print(millis());
  Serial.println("}");
}

void sendConfiguration() {
  Serial.print("{\"response\":\"config\",\"analog_threshold\":");
  Serial.print(analogThreshold);
  Serial.print(",\"trigger_cooldown\":");
  Serial.print(triggerCooldown);
  Serial.print(",\"button_debounce\":");
  Serial.print(buttonDebounce);
  Serial.print(",\"recording\":");
  Serial.print(isRecording ? "true" : "false");
  Serial.println("}");
}

void testLEDs() {
  Serial.println("{\"event\":\"testing_leds\"}");
  
  for(int i = 0; i < 2; i++) {
    digitalWrite(triggerLED, HIGH);
    delay(200);
    digitalWrite(triggerLED, LOW);
    digitalWrite(statusLED, HIGH);
    delay(200);
    digitalWrite(statusLED, LOW);
    digitalWrite(buttonLED, HIGH);
    delay(200);
    digitalWrite(buttonLED, LOW);
    delay(200);
  }
  
  Serial.println("{\"event\":\"led_test_complete\"}");
}