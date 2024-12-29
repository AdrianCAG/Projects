#include <TimerOne.h>

/*
animatingDots: Tracks if we're in dot animation mode
dotAnimationStart: Timestamp when animation started
dotsOn: Current state of dots during animation
lastDotToggle: Timestamp of last dot state change

- updateCounter():
Start dot animation when reaching 9999 or 0
Pause counting during animation
Toggle dots every 250ms (4 times per second)
Resume counting after 1 second of animation

- loop():
Control dot display during animation
Toggle decimal points based on animation state


When the counter reaches either 9999 or 0000:
  - The count pauses
  - All decimal points flash twice over one second (250ms on, 250ms off)
  - The counter resumes in the opposite direction
  - The timing interval changes if necessary
*/



// Pin definitions for 7-segment display segments and digits
const int a = 2, b = 3, c = 4, d = 5, e = 6, f = 7, g = 8, p = 9;  // Segment pins
const int d4 = 10, d3 = 11, d2 = 12, d1 = 13;                      // Digit pins

// Counter and control variables
long n = 0;          // Current display value (0-9999)
const int del = 5;   // Delay between refreshing each digit (ms)
int count = 0;       // Timer counter for update intervals

// Pattern and interval control
bool countingUp = true;      // Direction of counting: true for up, false for down
int currentInterval = 30;    // Initial interval in seconds for a full cycle
bool firstCycle = true;      // Tracks if the first counting cycle is in progress
unsigned long steps;         // Number of steps for the current interval
float incrementValue;        // Value to increment/decrement per timer tick

// Dot animation control
bool animatingDots = false;  // Whether we're currently in dot animation mode
unsigned long dotAnimationStart = 0;  // When the dot animation started
bool dotsOn = false;        // Current state of dots during animation
unsigned long lastDotToggle = 0;  // Last time dots were toggled

void setup() {
    // Set all pins as outputs for controlling the display
    for (int pin = 2; pin <= 13; pin++) {
        pinMode(pin, OUTPUT);
    }
    
    Timer1.initialize(100000); // 0.1-second interval
    Timer1.attachInterrupt(updateCounter);
    calculateSteps();
}

void calculateSteps() {
    steps = 10 * currentInterval;
    incrementValue = 9999.0 / steps;
}

void updateCounter() {
    if (animatingDots) {
        // During dot animation, handle dot flashing
        unsigned long currentMillis = millis();
        if (currentMillis - lastDotToggle >= 250) {  // Toggle every 250ms (4 times per second)
            dotsOn = !dotsOn;
            lastDotToggle = currentMillis;
        }
        
        // Check if animation should end (1 second duration)
        if (currentMillis - dotAnimationStart >= 1000) {
            animatingDots = false;
            dotsOn = false;
            // Resume counting
            if (n >= 9999) {
                countingUp = false;
            } else if (n <= 0) {
                countingUp = true;
                if (firstCycle) {
                    currentInterval = 60;
                    firstCycle = false;
                    calculateSteps();
                }
            }
        }
        return;
    }

    count++;
    if (count >= 1) {
        count = 0;
        
        if (countingUp) {
            n += incrementValue;
            if (n >= 9999) {
                n = 9999;
                // Start dot animation
                animatingDots = true;
                dotAnimationStart = millis();
                lastDotToggle = dotAnimationStart;
                dotsOn = true;
            }
        } else {
            n -= incrementValue;
            if (n <= 0) {
                n = 0;
                // Start dot animation
                animatingDots = true;
                dotAnimationStart = millis();
                lastDotToggle = dotAnimationStart;
                dotsOn = true;
            }
        }
    }
}

void loop() {
    for (int digit = 0; digit < 4; digit++) {
        clearLEDs();
        pickDigit(digit);
        
        switch (digit) {
            case 0: pickNumber(n / 1000); break;
            case 1: pickNumber((n % 1000) / 100); break;
            case 2: pickNumber((n % 100) / 10); break;
            case 3: pickNumber(n % 10); break;
        }
        
        // Handle dot display during animation
        if (animatingDots && dotsOn) {
            digitalWrite(p, HIGH);  // Turn on decimal points
        }
        
        delay(del);
    }
}

void pickDigit(int x) {
    digitalWrite(d1, HIGH);
    digitalWrite(d2, HIGH);
    digitalWrite(d3, HIGH);
    digitalWrite(d4, HIGH);

    switch (x) {
        case 0: digitalWrite(d1, LOW); break;
        case 1: digitalWrite(d2, LOW); break;
        case 2: digitalWrite(d3, LOW); break;
        case 3: digitalWrite(d4, LOW); break;
    }
}

// [Rest of the display functions remain unchanged]
void pickNumber(int x) {
    switch (x) {
        case 0: zero(); break;
        case 1: one(); break;
        case 2: two(); break;
        case 3: three(); break;
        case 4: four(); break;
        case 5: five(); break;
        case 6: six(); break;
        case 7: seven(); break;
        case 8: eight(); break;
        case 9: nine(); break;
        default: zero(); break;
    }
}

void clearLEDs() {
    for (int pin = 2; pin <= 9; pin++) {
        digitalWrite(pin, LOW);
    }
}

// [Number display functions remain the same as in your original code]
void zero() {
    digitalWrite(a, HIGH);
    digitalWrite(b, HIGH);
    digitalWrite(c, HIGH);
    digitalWrite(d, HIGH);
    digitalWrite(e, HIGH);
    digitalWrite(f, HIGH);
    digitalWrite(g, LOW);
}

void one() {
    digitalWrite(a, LOW);
    digitalWrite(b, HIGH);
    digitalWrite(c, HIGH);
    digitalWrite(d, LOW);
    digitalWrite(e, LOW);
    digitalWrite(f, LOW);
    digitalWrite(g, LOW);
}

void two() {
    digitalWrite(a, HIGH);
    digitalWrite(b, HIGH);
    digitalWrite(c, LOW);
    digitalWrite(d, HIGH);
    digitalWrite(e, HIGH);
    digitalWrite(f, LOW);
    digitalWrite(g, HIGH);
}

void three() {
    digitalWrite(a, HIGH);
    digitalWrite(b, HIGH);
    digitalWrite(c, HIGH);
    digitalWrite(d, HIGH);
    digitalWrite(e, LOW);
    digitalWrite(f, LOW);
    digitalWrite(g, HIGH);
}

void four() {
    digitalWrite(a, LOW);
    digitalWrite(b, HIGH);
    digitalWrite(c, HIGH);
    digitalWrite(d, LOW);
    digitalWrite(e, LOW);
    digitalWrite(f, HIGH);
    digitalWrite(g, HIGH);
}

void five() {
    digitalWrite(a, HIGH);
    digitalWrite(b, LOW);
    digitalWrite(c, HIGH);
    digitalWrite(d, HIGH);
    digitalWrite(e, LOW);
    digitalWrite(f, HIGH);
    digitalWrite(g, HIGH);
}

void six() {
    digitalWrite(a, HIGH);
    digitalWrite(b, LOW);
    digitalWrite(c, HIGH);
    digitalWrite(d, HIGH);
    digitalWrite(e, HIGH);
    digitalWrite(f, HIGH);
    digitalWrite(g, HIGH);
}

void seven() {
    digitalWrite(a, HIGH);
    digitalWrite(b, HIGH);
    digitalWrite(c, HIGH);
    digitalWrite(d, LOW);
    digitalWrite(e, LOW);
    digitalWrite(f, LOW);
    digitalWrite(g, LOW);
}

void eight() {
    digitalWrite(a, HIGH);
    digitalWrite(b, HIGH);
    digitalWrite(c, HIGH);
    digitalWrite(d, HIGH);
    digitalWrite(e, HIGH);
    digitalWrite(f, HIGH);
    digitalWrite(g, HIGH);
}

void nine() {
    digitalWrite(a, HIGH);
    digitalWrite(b, HIGH);
    digitalWrite(c, HIGH);
    digitalWrite(d, HIGH);
    digitalWrite(e, LOW);
    digitalWrite(f, HIGH);
    digitalWrite(g, HIGH);
}