// Beginning with standard camera test face detection sketch for Processin / opencv

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

int w  = 640;
int h  = 480;

int alarm,
    alarmTimer,
    setY,
    limY,
    setH,
    limH;

// Button things
int dL = 10;
int bW = (w/3)-10;
int bH = 30;
int bX = 10;
int bY = h-bH-dL;

boolean active;

Button distButton;
Button htButton;
Button pauseButton;

void setup() {
  size(w, h);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  video.start();

  distButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Set Distance");
  bX = bX+bW+(dL/2);
  htButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Set Height");
  bX = bX+bW+(dL/2);
  pauseButton = new Button(color(#FFFB7E), bX, bY, bW, bH, "Pause Tracking");
}

void draw() {
  getPosition(0);

  distButton.display();
  htButton.display();
  pauseButton.display();

  if(distButton.pressed) {
    println("yay");
  }

}

void getPosition(int interval) {
  int dist,
      delta;

  // Run all the openCV things here
  //
  // push/pop matrix protects the calibration buttons
  //
  pushMatrix();
    scale(2); // scales the video to the window size
    opencv.loadImage(video);

    image(video, 0, 0); // this draws the webcam image

    noFill();

    if (alarm > 5) stroke(255, 0, 0); //draw all lines red if alarm is active
    else stroke(0, 255, 0);
    strokeWeight(2);

    Rectangle[] faces = opencv.detect();

    dist = 0;

    for (int i = 0; i < faces.length; i++) {

      setH  = faces[i].height;
      setY  = faces[i].y;
      delta = limH - setH;

      // println(faces[i].x + "," + setY);

      rect(faces[i].x, setY, faces[i].width, setH);

      //the following line draws a second box with the limit distance
      if (limH!=0) {
        rect(faces[i].x-delta/2, setY-delta/2, faces[i].width+delta, limH);
      }
    }
    //This draws a line at the limit height:
    if (limH != 0) line(0, limH, width, limH);
  popMatrix();
}

int setAlarm(int ht, int dis, boolean act) {
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
  boolean over;

  Button(color tempcB, int tempxB, int tempyB, int tempwB, int temphB, String temptxB) {
    cB = tempcB;
    xB = tempxB;
    yB = tempyB;
    wB = tempwB;
    hB = temphB;
    txB = temptxB;
    pressed = false;
    over = false;
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