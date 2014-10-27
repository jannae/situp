// Beginning with standard camera test face detection sketch for Processin / opencv

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

int w  = 640;
int h  = 480;

int setY;     // Y position (you are here)
int setH;     // Distance from screen (you are here)
int limY = 0; // Y position limit from calibration
int limH = 0; // Distance limit from calibration

// Button things
int dL = 20;
int bW = (w/2)-dL;
int bH = 30;
int bX = dL;
int bY = h-bH-dL;

String[] alarmImgs = {
  "big-green.png",
  "big-yellow.png",
  "big-orange.png",
  "big-red.png",
  "big-gray-hello.png",
  "big-gray-pause.png"
};
PImage[] alarms = new PImage[alarmImgs.length];

boolean alarm = false;
boolean active = true;
int alarmTimer;
int secs = 1500; // How long will we tolerate bad posture

Button setButton;
Button pauseButton;

void setup() {
  size(w, h);
  video = new Capture(this, w/2, h/2);
  opencv = new OpenCV(this, w/2, h/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  video.start();

  setButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Set Posture");
  bX = bX+bW+(dL/2);
  pauseButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Pause Tracking");

  for (int i=0; i < alarmImgs.length; i++){
      alarms[i] = loadImage(alarmImgs[i]);
  }
}

void draw() {
  getPosition();
  handleAlarm();

  setButton.display();
  pauseButton.display();

  if(setButton.pressed) {
    limH = setH+10;
    delay(150);
    limY = setY+10;
  }
  if(pauseButton.pressed) {
    if (active) {
      active = false;
      pauseButton.txB = "Resume Tracking";
      noStroke();
    } else {
      active = true;
      pauseButton.txB = "Pause Tracking";
      strokeWeight(2);
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

    Rectangle[] faces = opencv.detect();

    dist = 0;

    for (int i = 0; i < faces.length; i++) {
      setH  = faces[i].height;
      setY  = faces[i].y;

      // how far are we from the height limit
      delta = limH - setH;

      // println(faces[i].x + "," + setY);
      rect(faces[i].x, setY, faces[i].width, setH);

      // If limit is set, draw another box with the limit distance
      if (limH != 0) {
        rect(faces[i].x-delta/2, setY-delta/2, faces[i].width+delta, limH);
      }
    }

    //Draw a line at the limit height:
    if (limH != 0) line(0, limH, width, limH);

  popMatrix();
}

void handleAlarm() {
  //checking for initialization of limits, and that were actively limiting
  if (limY != 0 && limH != 0 && active) {
    if (setH > limH || setY > limY) { //compare values to limits
      alarm = true;
    }
    else {
      alarm = false;
    }
  }

  println(alarmTimer + ", " + millis());

  //reset alarm timer if alarm is off
  if (alarm == false) {
    // set the alarm for x seconds from now
    alarmTimer = millis() + secs*3;
    // display safe image
    image(alarms[0],0,0);
  } else if (millis()-secs < alarmTimer) {
    image(alarms[1],0,0);
  } else if (millis()-secs*2 < alarmTimer) {
    image(alarms[2],0,0);
  } else {
    image(alarms[3],0,0);
  }
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
