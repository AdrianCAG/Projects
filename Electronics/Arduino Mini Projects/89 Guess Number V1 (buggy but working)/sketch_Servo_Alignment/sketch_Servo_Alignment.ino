#include <Servo.h>

Servo myservo;//create servo object to control a servo

void setup()
{
  myservo.attach(9);//attachs the servo on pin 9 to servo object
  myservo.write(0);//back to 0 degrees
  delay(1000);//wait for a second
}

void loop()
{
  myservo.write(180);
  delay(8000);
  myservo.write(90);
  delay(8000);
  myservo.write(0);
  delay(8000);
}
