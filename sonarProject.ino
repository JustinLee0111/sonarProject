#include <Servo.h>
#include <Arduino_FreeRTOS.h>

//void TaskCalculateDistance(void *pvParameters);
void TaskRotateServo(void *pvParameters);
void TaskOutputDistance(void *pvParameters);

namespace PinNumbers{
  constexpr int SONAR_TRIG = 10;
  constexpr int SONAR_ECHO = 11;
  constexpr int SERVO_PIN = 12;
}

struct HardwarePins{
  int trigPin;
  int echoPin;
};

QueueHandle_t dataQueue;
Servo radarServo;

// Gets distance in centimeters
int calculateDistance(int trigPin, int echoPin){
  // Sends out ultrasonic waves
  digitalWrite(trigPin, LOW);
  vTaskDelay(pdMS_TO_TICKS(35));
  digitalWrite(trigPin, HIGH);
  vTaskDelay(pdMS_TO_TICKS(35));
  digitalWrite(trigPin, LOW);

  // Recieves the duration of ultrasonic wave in microseconds
  int duration = pulseIn(echoPin, HIGH);

  // Gets distance in CM from the speed of sound
  // Divided by 2 due to the distance being doubled from send and recieve distance
  int distance = duration * 0.034 / 2;

  return(distance);
}
void setup() {
  static HardwarePins mySonarPins = {
    PinNumbers::SONAR_TRIG,
    PinNumbers::SONAR_ECHO
  };
  pinMode(mySonarPins.trigPin, OUTPUT);
  pinMode(mySonarPins.echoPin, INPUT);
  radarServo.attach(12);
  Serial.begin(115200);
  // Creates a queue enough for 5 integers, used to send the angle of the servo to TaskOutputDistance() for serial streaming
  dataQueue = xQueueCreate(5, sizeof(int));
  xTaskCreate(TaskRotateServo, "Servo Rotation", 256, (void*)12, 2, NULL);
  xTaskCreate(TaskOutputDistance, "Serial Output", 256, (void*)&mySonarPins, 1, NULL);
  vTaskStartScheduler();
}
void loop() {
}
void TaskRotateServo(void* pvParameters){
  for(;;){
    int angle = 0;
    for(angle = 0; angle <= 88; angle += 2){
      radarServo.write(angle);
      xQueueSend(dataQueue, &angle, 0);
      vTaskDelay(pdMS_TO_TICKS(150));
    }
    for(angle = 90; angle >= 2; angle -= 2){
      radarServo.write(angle);
      xQueueSend(dataQueue, &angle, 0);
      vTaskDelay(pdMS_TO_TICKS(150));
    }
  }
}
void TaskOutputDistance(void* pvParameters){
  HardwarePins* pins = (HardwarePins*) pvParameters;
  int recievedAngle;
  for(;;){
    // If the angle is recieved from the queue successfully, run the code for serial streaming
    if (xQueueReceive(dataQueue, &recievedAngle, portMAX_DELAY)) {
      Serial.print("Distance: ");
      Serial.print(calculateDistance(pins->trigPin, pins->echoPin));
      Serial.print(", Angle: ");
      Serial.println(recievedAngle);
    }
  }
}
