import processing.serial.*;
import java.awt.event.KeyEvent;
import java.io.IOException;

Serial myPort;
PFont orcFont;
int iAngle;
int iDistance;

void setup(){
  size(1300, 800);
  smooth();
  
  // Listens to serial port COM5
  myPort = new Serial(this, "COM5", 9600);
  myPort.clear();
  myPort.bufferUntil('\n');
  orcFont = loadFont("OCRAExtended-30.vlw");
}
void draw(){
  fill(98, 245, 31);
  textFont(orcFont);
  noStroke();
  // Creates the line fading effect for the sweeping lines
  fill(0, 4);
  rect(0, 0, width, 0.935 * height);
  fill(98, 245, 31);
  
  DrawRadar();
  DrawLine();
  DrawObject();
  DrawText();
}
void serialEvent(Serial myPort){
  try{
    // Extracts the angle and distance from serial port output
    String data = myPort.readStringUntil('\n');
     if(data == null){
       return;
     }
   int commaIndex = data.indexOf(",");
   String angle = data.substring(commaIndex + 9).trim();
   String distance = data.substring(10, commaIndex);
   iAngle = int(angle);
   iDistance = int(distance);
  }catch(RuntimeException e){}
}
void DrawRadar(){
  pushMatrix();
  translate(width/2, 0.926 * height);
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  
  DrawRadarArcLine(0.9375);
  DrawRadarArcLine(0.7300);
  DrawRadarArcLine(0.5210);
  DrawRadarArcLine(0.3130);
  
  final int halfWidth = width/2;
  line(-halfWidth, 0, halfWidth, 0);
  for(int angle = 0; angle <= 180; angle += 30){
    DrawRadarAngledLine(angle);
  }
  line(-halfWidth * cos(radians(30)), 0, halfWidth, 0);
  popMatrix();
}
void DrawRadarArcLine(final float coefficient){
  arc(0, 0, coefficient * width, coefficient * width, PI, TWO_PI);
}
void DrawRadarAngledLine(final int angle){
  line(0, 0, (width/2) * cos(radians(angle)), (-width/2) * sin(radians(angle)));
}
//Draws red lines when object is detected
void DrawObject(){
  pushMatrix();
  translate(width/2, 0.926 * height);
  strokeWeight(9);
  stroke(255, 10, 10);
  int pixDistance = int(iDistance * 0.020835 * height);
  if(iDistance < 40 && iDistance != 0){
    float c = cos(2 * radians(iAngle));
    float s = sin(2 * radians(iAngle));
    int x1 = +int(pixDistance * c);
    int y1 = -int(pixDistance * s);
    int x2 = +int(0.495 * width * c);
    int y2 = -int(0.495 * width * s);
    
    line(x1, y1, x2, y2);
  }
  popMatrix();
}
// Draws the sweeping sonar line
void DrawLine(){
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60);
  translate(width/2, 0.926 * height);
  
  float angle = radians(iAngle);
  int x = int(+0.88 * height * cos(2 * angle));
  int y = int(-0.88 * height * sin(2 * angle));
  line(0, 0, x, y);
  popMatrix();
}
void DrawText(){
  pushMatrix();
  fill(0, 0, 0);
  noStroke();
  rect(0, 0.9352 * height, width, height);
  fill(98, 245, 31);
  textSize(25);
  text("10cm", 0.6146 * width, 0.9167 * height);
  text("20cm", 0.7190 * width, 0.9167 * height);
  text("30cm", 0.8230 * width, 0.9167 * height);
  text("40cm", 0.9271 * width, 0.9167 * height);
  
  textSize(40);
  text("Object: " + (iDistance > 40 ? "Out of Range" : "In Range"), 0.05 * width, 0.9723 * height);
  text("Angle: " + iAngle + " deg", 0.45 * width, 0.9723 * height);
  text("Distance: ", 0.72 * width, 0.9723 * height);
  if(iDistance < 40){
    text("          " + iDistance + " cm", 0.72 * width, 0.9723 * height);
  }
  textSize(25);
  fill(98, 245, 60);
  translate(0.5006 * width + width/2 * cos(radians(30)), 0.9093 * height - width/2 * sin(radians(30)));
  rotate(-radians(-60));
  text("15 deg", 0, 0);
  
  resetMatrix();
  
  // Displays the correctly rotated text at each angled line
  translate(0.497 * width + width/2 * cos(radians(60)), 0.9112 * height - width/2 * sin(radians(60)));
  rotate(-radians(-30));
  text("30 deg", 0, 0);
  resetMatrix();
  
  translate(0.493 * width + width/2 * cos(radians(90)), 0.9167 * height - width/2 * sin(radians(90)));
  rotate(radians(0));
  text("45", 0, 0);
  resetMatrix();
  
  translate(0.487 * width + width/2 * cos(radians(120)), 0.92871 * height - width/2 * sin(radians(120)));
  rotate(radians(-30));
  text("60 deg", 0, 0);
  resetMatrix();
  
  translate(0.4896 * width + width/2 * cos(radians(150)), 0.9426 * height - width/2 * sin(radians(150)));
  rotate(radians(-60));
  text("75 deg", 0, 0);
  popMatrix();
}
