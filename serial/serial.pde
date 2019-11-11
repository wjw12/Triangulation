//serial
import processing.serial.*;

Serial serial;  // Create object from Serial class
String val;     // Data received from the serial port


float valC_F;
float valM_F;

float valC_FM;
float valM_FM;

CapacityFilter cf = new CapacityFilter();
boolean triggered = false;
float lastPeak = 0.0;
float variance = 0.0;

float mapClamp(float value, float x1, float x2, float y1, float y2) {
  if (value < x1) return y1;
  if (value > x2) return y2;
  return map(value, x1, x2, y1, y2);
}

Minim minim;
AudioOutput out;

ChikInstrument chik;// = new ChikInstrument( out );

Queue history;

void setup()               // executed once at the begining LatticeImage
{
  //
  printArray(Serial.list());

  String portName = Serial.list()[0]; //change the right number based on your arduino
  serial = new Serial(this, portName, 9600);
  //
  frameRate(60);
  size(1000, 1000, P3D);            // window size
  textSize(50);
  textAlign(CENTER, CENTER);
  
  history = new ArrayDeque(width);
  
  // init minim
  // initialize the minim and out objects
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );
  chik = new ChikInstrument( out );

} // end of setup



void draw()      
{
  //
  if ( serial.available() > 0) 
  {  // If data is available,
    val = serial.readStringUntil('\n');   // read it and store it in val

    if (val != null) {
      val = val.trim();
      String[] listVal = split(val, "\t");

      if (listVal.length > 1) {
        //print(val); //print it out in the console
        //print(" -> ");
        //printArray(listVal);
        
        //R = Integer.parseInt(listVal[0]) / 4; // 0-1023 to 0-255
        //G = Integer.parseInt(listVal[1]) / 4; // 0-1023 to 0-255

        valC_F = float(listVal[0]);
        valM_F = float(listVal[1]);
        
        if (history.size() < width) {
         history.add(valC_F); 
        }
        else {
         history.remove(); 
         history.add(valC_F); 
        }
        
        //println(valC_F);

        //valC_FM = map(valC_F, 0, 30000, 0, 1000);
        valC_FM = mapClamp(valC_F, 0, 800, 1000, 0);
        valM_FM = mapClamp(valM_F, 0, 1024, 0, 1000);

        cf.update(valC_F);
        float peak = cf.getTrigger();
        if (peak > 0) {
          triggered = true;
          lastPeak = peak;
          //out.playNote( 0.f, 0.05f, chik );
          out.playNote( 0.f, 1.0f, new WaveShaperInstrument( Frequency.ofPitch("C2").asHz(), 10.0, out ) ); 
        }
        if (cf.getRelease() > 0) triggered = false;
        if (triggered) variance = cf.getVariance();
        
      }
    }
  } 
  fill(100);
  stroke(100);
  if (triggered) {
    background(30,150,150);
    text("Variance = " + str(variance), 500, 400, 10);
    
  }
  else {
    background(10, 10, 50);
  }
  text(str(valC_FM), 500,500, 10);
  text("Last Peak = " + str(lastPeak), 500, 300, 10);
  
  
  text("Microphone = " + str(valM_F), 500,600, 10);
  
  stroke(255);
  int n = 0;
  float last = 0;
  for (Object o : history) {
    float value = (Float)o * 0.25;
    line(n, last, 0, n+1, value, 0);
    last = value;
    n++;
  }

}  // end of draw

//==============================
