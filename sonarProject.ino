#include <Servo.h>

int duration;
int distance;
const int trigPin = 10;
const int echoPin = 11;
Servo radarServo;

// Gets distance in centimeters
int calculateDistance(){
  // Sends out ultrasonic waves
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delay(60);
  digitalWrite(trigPin, LOW);

  // Recieves the duration of ultrasonic wave in microseconds
  duration = pulseIn(echoPin, HIGH);

  // Gets distance in CM from the speed of sound
  // Divided by 2 due to the distance being doubled from send and recieve distance
  distance = duration * 0.034 / 2;

  return(distance);
}
void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  radarServo.attach(12);
  Serial.begin(115200);
}
void loop() {
  // For loops move servo motor to gather distance data every 2 degrees
  // Motor range is from 0 <= theta <= 90
  for(int angle = 0; angle <= 88; angle += 2){
    radarServo.write(angle);
    delay(10);
    Serial.print("Distance: ");
    Serial.print(calculateDistance());
    Serial.print(", Angle: ");
    Serial.println(angle);
  }
  for(int angle = 90; angle >= 2; angle -= 2){
    radarServo.write(angle);
    delay(10);
    Serial.print("Distance: ");
    Serial.print(calculateDistance());
    Serial.print(", Angle: ");
    Serial.println(angle);
  }
}
