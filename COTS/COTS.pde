//serial
import processing.serial.*;

Serial serial;  // Create object from Serial class
String val;     // Data received from the serial port
int R = 0;
int G = 0;
//

float valC_F;
float valM_F;

float valC_FM;
float valM_FM;


import java.awt.Toolkit;
import java.awt.datatransfer.*;
import com.jogamp.opengl.GL4;
//**************************** global variables ****************************
pts P = new pts(); // class containing array of points, used to standardize GUI
COTSMap CM;

pt CenterPoint = P(), RadiusPoint = P(); // to control editing the disk
int ne=8; // current cell-count in each direction
float r=2.8; // initial radius of disk
PFont bigFont; // for showing large labels at corner

pt center = P();

pt[][] p0 = {{P(-800, -850), P(190, -850), P(1000, -850), P(1450, -850)}, 
  {P(-800, 330), P(200, 200), P(850, 250), P(1450, 150)}, 
  {P(-800, 638), P(205, 715), P(890, 750), P(1450, 650)}, 
  {P(-800, 1215), P(210, 1250), P(1010, 1285), P(1450, 1250)}, 
};

pt[][] gridPoints = {{P(0, 0), P(300, 50), P(620, 25), P(1050, -50)}, 
  {P(-25, 330), P(330, 360), P(610, 325), P(1050, 350)}, 
  {P(23, 638), P(300, 650), P(620, 625), P(1050, 650)}, 
  {P(5, 915), P(320, 950), P(620, 985), P(1050, 950)}, 
};


int divs=5;
COTSMap_GPU[][] maps = new COTSMap_GPU[3][3];

PImage[] imgs = new PImage[9];
color backgroundColor = #1310FF;

float mapClamp(float value, float x1, float x2, float y1, float y2) {
  if (value < x1) return y1;
  if (value > x2) return y2;
  return map(value, x1, x2, y1, y2);
}

//**************************** initialization ****************************
void setup()               // executed once at the begining LatticeImage
{
  //
  printArray(Serial.list());

  String portName = Serial.list()[3]; //change the right number based on your arduino
  serial = new Serial(this, portName, 9600);
  //
  frameRate(60);
  size(1000, 1000, P3D);            // window size
  center.x = 0.5*width; 
  center.y = 0.5*height;
  PJOGL.profile = 4;
  smooth();                  // turn on antialiasing
  P.declare(); // declares all points in P. MUST BE DONE BEFORE ADDING POINTS 
  P.loadPts("data/pts");  // loads points form file saved with this program
  textSize(50);
  textAlign(CENTER, CENTER);
  CM = new COTSMap(P.G[0], P.G[1], P.G[2], P.G[3], 8);
  //CM.au+=TWO_PI; // to force particular branching for the demo file
  CenterPoint=P(P.G[4]); 
  RadiusPoint=P(P.G[5]);
  CM.setCircle(CenterPoint, RadiusPoint); // adjust the green disks as the control handle is dragged

  maps[0][0] = new COTSMap_GPU(this, gridPoints[0][0], gridPoints[1][0], gridPoints[1][1], gridPoints[0][1], divs, true);
  maps[0][1] = new COTSMap_GPU(this, gridPoints[1][0], gridPoints[2][0], gridPoints[2][1], gridPoints[1][1], divs, true);
  maps[0][2] = new COTSMap_GPU(this, gridPoints[2][0], gridPoints[3][0], gridPoints[3][1], gridPoints[2][1], divs, true);

  maps[1][0] = new COTSMap_GPU(this, gridPoints[0][1], gridPoints[1][1], gridPoints[1][2], gridPoints[0][2], divs, true);
  maps[1][1] = new COTSMap_GPU(this, gridPoints[1][1], gridPoints[2][1], gridPoints[2][2], gridPoints[1][2], divs, true); 
  maps[1][2] = new COTSMap_GPU(this, gridPoints[2][1], gridPoints[3][1], gridPoints[3][2], gridPoints[2][2], divs, true);

  maps[2][0] = new COTSMap_GPU(this, gridPoints[0][2], gridPoints[1][2], gridPoints[1][3], gridPoints[0][3], divs, true);
  maps[2][1] = new COTSMap_GPU(this, gridPoints[1][2], gridPoints[2][2], gridPoints[2][3], gridPoints[1][3], divs, true);
  maps[2][2] = new COTSMap_GPU(this, gridPoints[2][2], gridPoints[3][2], gridPoints[3][3], gridPoints[2][3], divs, true);


  myFace = loadImage("data/myface.jpg"); 

  for (int i = 0; i < 9; i++) {
    imgs[i] = loadImage("data/" + str(i+1) + ".png");
  }

  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++)
    {
      maps[i][j].CreateTris();
      maps[i][j].myShader.set("tex", imgs[(2-j)*3 + i]);
    }

  textureMode(NORMAL);
} // end of setup



//**************************** display current frame ****************************
void draw()      
{
  //
  if ( serial.available() > 0) 
  {  // If data is available,
    val = serial.readStringUntil('\n');   // read it and store it in val

    if (val != null) {
      //println(val);
      val = val.trim();
      String[] listVal = split(val, " ");

      if (listVal.length > 1) {
        //print(val); //print it out in the console
        //print(" -> ");
        //printArray(listVal);
        
        //R = Integer.parseInt(listVal[0]) / 4; // 0-1023 to 0-255
        //G = Integer.parseInt(listVal[1]) / 4; // 0-1023 to 0-255

        valC_F = float(listVal[0]);
        valM_F = float(listVal[1]);

        //valC_FM = map(valC_F, 0, 30000, 0, 1000);
        valC_FM = mapClamp(valC_F, 800, 0, 0, 1000);
        valM_FM = mapClamp(valM_F, 0, 1024, 0, 1000);


      }
    }
    serial.clear();
  } 
  //
  background(backgroundColor);

  translate(width/2, height/2);
  //printMatrix();
  //line(0, 0, width, height);
  //println(frameRate);

  float t = millis() * 0.002;

  for (int i = 0; i < 4; i++)
    for (int j = 0; j < 4; j++) {

      gridPoints[i][j].x = p0[i][j].x + 350 * noise(t + i, t + j);
      gridPoints[i][j].y = p0[i][j].y + 400 * noise(t*2 + j, t*1.5 + i);
    }



  pen(red, 2);
  noFill();
  for (int i = 0; i < 3; i++)
    for (int j = 0; j < 3; j++) {
      maps[i][j].UpdateMapReference(divs);
      maps[i][j].myShader.set("time", t);
      maps[i][j].myShader.set("noiseX", valC_FM / width);
      //println(mouseX);
      maps[i][j].myShader.set("noiseY", (float)(valM_FM - 0.5*height) / height);
      maps[i][j].myShader.set("variance", 0.1);
      maps[i][j].myShader.set("backgroundColor", red(backgroundColor) / 255.0, green(backgroundColor) / 255.0, blue(backgroundColor) / 255.0);
      maps[i][j].ShowTris();
    }
    
  resetShader();
  fill(100);
  stroke(100);
  text(str(valM_FM), 500,500, 10);

}  // end of draw

//==============================
