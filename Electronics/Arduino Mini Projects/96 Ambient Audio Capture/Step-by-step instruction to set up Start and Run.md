⚠️ IMPORTANT: Before starting, you must select/create a folder where your audio recordings will be saved!**

### Required Components:
- Arduino board with uploaded sketch
- KY-037 and KY-038 sound sensors
- Button and resistors (220Ω or 10kΩ for LED, 10kΩ for button)
- Jump wires and breadboard
- USB microphone
- Mac with Xcode installed

## Step-by-Step Instructions

### Phase 1: Arduino Setup

1. **Hardware Assembly**
   - Connect your Arduino board to the breadboard
   - Wire the KY-037 and KY-038 sound sensors to the Arduino
   - Connect the button with a 10kΩ pull-up resistor
   - Add LEDs with 220Ω or 10kΩ resistors
   - Use jump wires to complete all connections

2. **Arduino Code Upload**
   - Connect your Arduino board to your Mac via USB
   - Open Arduino IDE
   - Load the sketch from:
     ```96 Ambient Audio Capture copy/Ambient_Audio_Capture_Project/Ambient_Audio_Capture_Project.ino```
   - Select the correct board type and port in Arduino IDE
   - Compile and upload the sketch to your Arduino
   - **Verify the Arduino outputs correct JSON lines in the Serial Monitor (baud rate: 9600)**
   - **⚠️ IMPORTANT: Close the Arduino Serial Monitor after verification - keep it closed during normal operation!**

### Phase 2: Swift App Setup

3. **Audio Hardware Configuration**
   - Connect your USB microphone to your Mac
   - Go to **System Preferences > Sound > Input**
   - **Select your USB microphone as the input device**
   - Test that the microphone is working and receiving audio

4. **Swift App Preparation**
   - Open the Xcode project:
     ```96 Ambient Audio Capture App/Ambient Audio Capture App.xcodeproj```
   - **⚠️ CRITICAL: In the app, you MUST select a destination folder where audio recordings will be saved**
   - Build the Swift macOS app in Xcode
   - Ensure the app compiles without errors

### Phase 3: Running the System

5. **Start the Arduino First**
   - Power on your Arduino (it should already have the uploaded sketch)
   - The Arduino should start outputting JSON events like:
     - `{"event":"startup",...}`
     - `{"event":"recording_started",...}`
     - `{"event":"button_pressed",...}`

6. **Launch the Swift App**
   - Run the Swift app from Xcode or launch the built application
   - The app will automatically:
     - Scan for and connect to the Arduino serial port (usually `/dev/cu.usbserial-XXXX` or `/dev/cu.usbmodemXXXX`)
     - Start listening for Arduino event messages
     - Ensure the USB microphone is set as the current input
     - Initialize the audio engine for recording

7. **System Operation**
   - When Arduino detects sound/button press → sends `recording_started` → Swift app begins recording
   - When Arduino signals stop → sends `recording_stopped` → Swift app stops recording and saves file
   - **All audio files will be saved to the folder you selected in the Swift app**

### Phase 4: Stopping and Saving

8. **Proper Shutdown**
   - Use the Arduino button or app interface to stop recording
   - The Swift app will finalize and save the audio file to your selected folder
   - Close the Swift app
   - Disconnect the Arduino if needed

## Debugging Tips

- **List serial ports in Terminal**: `ls /dev/cu.*`
- **Test Arduino independently**: Use Arduino Serial Monitor (but close it before running the Swift app)
- **Test audio recording**: Verify USB mic works in macOS Sound preferences
- **Use serial terminal apps**: Try CoolTerm for manual serial monitoring
- **Add debug statements**: Both Arduino and Swift sides for tracing data flow

## Key Reminders

1. **YOU MUST SELECT A DESTINATION FOLDER** in the Swift app for saving recordings
2. **Arduino Serial Monitor must be CLOSED** during normal operation (open only for debugging)
3. **USB microphone must be selected** as input in macOS Sound preferences
4. **Start Arduino FIRST**, then launch the Swift app

The system creates an integrated workflow where Arduino sensors trigger audio recording on your Mac, with all files saved to your chosen directory.