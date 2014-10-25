// Beginning with standard camera test face detection sketch for Processin / opencv

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

int w  = 640;
int h  = 480;

int alarmTimer,
    setY,
    limY,
    setH,
    limH;

// Button things
int dL = 10;
int bW = (w/3)-dL;
int bH = 30;
int bX = dL;
int bY = h-bH-dL;

int alarm = 0;
color[] alarmCols = {#339900,#339900,#EEC73E,#EEC73E,#FB8B00,#FB8B00,#FD3301,#FD3301};
boolean active;

Button distButton;
Button htButton;
Button pauseButton;

void setup() {
  size(w, h);
  video = new Capture(this, w/2, h/2);
  opencv = new OpenCV(this, w/2, h/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  video.start();

  distButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Set Distance");
  bX = bX+bW+(dL/2);
  htButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Set Height");
  bX = bX+bW+(dL/2);
  pauseButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Pause Tracking");
}

void draw() {
  getPosition();

  distButton.display();
  htButton.display();
  pauseButton.display();

  if(distButton.pressed) {
    limY = setY+3;
  }
  if(htButton.pressed) {
    limH = setH+3;
  }
  if(pauseButton.pressed) {
    if (active) {
      active = false;
    } else {
      active = true;
    }
  }
}

void getPosition() {
  int dist,
      delta;

  // push/pop matrix protects the buttons
  pushMatrix();
    // openCV video rendering
    scale(2);
    opencv.loadImage(video);
    image(video, 0, 0);

    noFill();

    if (alarm > 0) stroke(255, 0, 0); //draw all lines red if alarm is active
    else stroke(0, 255, 0);
    strokeWeight(2);

    Rectangle[] faces = opencv.detect();

    dist = 0;

    for (int i = 0; i < faces.length; i++) {

      setH  = faces[i].height;
      setY  = faces[i].y;

      // how far are we from the height limit
      delta = limH - setH;

      // println(faces[i].x + "," + setY);
      rect(faces[i].x, setY, faces[i].width, setH);

      // If we set a limit, draw another box with the limit distance
      if (limH != 0) {
        rect(faces[i].x-delta/2, setY-delta/2, faces[i].width+delta, limH);
      }
    }

    //Draw a line at the limit height:
    if (limH != 0) line(0, limH, width, limH);

  popMatrix();
}

int setAlarm() {
  //checking for initialization of limits, and that were actively limiting
  if (limY != 0 && limH != 0 && active) {
    if (setH > limH || setY > limY) { //compare values to limits
      for(int i=0; i*5 <= limH; i++) {
        alarm = i;
      }
    }
    else {
      alarm = 0;
    }
  }

  //reset alarm timer if alarm is off
  if (alarm == 0) {
    alarmTimer = millis() + 2000;
  } else if (millis() > alarmTimer) {
    //check if alarm timer has expired

    if (millis()-2000 < alarmTimer) {
      //do this for additional 2 seconds
      Toolkit.getDefaultToolkit().beep(); //call the windows alarm sound
      delay(150);
    }
  }
  if (alarm>0) println(alarm);
  return alarm;
}

int getAlarm(int ht, int dis, int lht, int ldis, boolean act) {
  // checking for initialization of limits
  if (ht != 0 && dis != 0 && act) {

  }
  return alarm;
}

void captureEvent(Capture c) {
  c.read();
}

boolean mouseOver(int xpos, int ypos, int rwidth, int rheight){
  //return true if mouse is over a given rectangle
  if(mouseX > xpos && mouseX < xpos+rwidth &&
      mouseY > ypos && mouseY < ypos+rheight) return true;
  else return false;
}

class Button {
  color cB;
  int xB;
  int yB;
  int wB;
  int hB;
  String txB;
  boolean pressed;

  Button(color tempcB, int tempxB, int tempyB, int tempwB, int temphB, String temptxB) {
    cB = tempcB;
    xB = tempxB;
    yB = tempyB;
    wB = tempwB;
    hB = temphB;
    txB = temptxB;
    pressed = false;
  }

  void display() {
    textSize(14);
    fill(cB);
    text(txB, (wB/2)+xB-((wB/2)/2), (hB/2)+yB+((hB/2)/2));

    stroke(cB);
    noFill();
    pressed = false;

    if(mousePressed && mouseOver(xB, yB, wB, hB)) {
      fill(cB);
      pressed = true;
    }
    rect(xB, yB, wB, hB);
  }
}