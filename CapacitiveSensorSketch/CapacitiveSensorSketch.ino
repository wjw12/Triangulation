#include <CapacitiveSensor.h>

/*
 * CapitiveSense Library Demo Sketch
 * Paul Badger 2008
 * Uses a high value resistor e.g. 10M between send pin and receive pin
 * Resistor effects sensitivity, experiment with values, 50K - 50M. Larger resistor values yield larger sensor values.
 * Receive pin is the sensor pin - try different amounts of foil/metal on this pin
 */


CapacitiveSensor   cs_4_2 = CapacitiveSensor(4,2);        // 10M resistor between pins 4 & 2, pin 2 is sensor pin, add a wire and or foil if desired
//CapacitiveSensor   cs_4_6 = CapacitiveSensor(4,6);        // 10M resistor between pins 4 & 6, pin 6 is sensor pin, add a wire and or foil
//CapacitiveSensor   cs_4_8 = CapacitiveSensor(4,8);        // 10M resistor between pins 4 & 8, pin 8 is sensor pin, add a wire and or foil
int analogPin = A0;
int val = 0; 

int pin2 = A5;
int val2 = 0;
void setup()                    
{
   //cs_4_2.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example
   //cs_4_6.set_CS_AutocaL_Millis(0xFFFFFFFF);
   Serial.begin(9600);
}

int mic_max = 0;
int cap_max = 0;
int interval = 16;
unsigned long previousMillis = 0;

void loop()                    
{
  unsigned long currentMillis = millis();

    long cap =  cs_4_2.capacitiveSensor(30);
    val = analogRead(analogPin);

    if (val > mic_max) mic_max = val;
    if (cap > cap_max) cap_max = cap;

    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;
      Serial.print(cap_max); 
      Serial.print('\t');
      Serial.println(mic_max);
      mic_max = 0;
      cap_max = 0;
      
    }
    

//    Serial.print(total1);                  // print sensor output 1
//    
//    Serial.print('\t');
//  
//    val = analogRead(analogPin);
//    Serial.println(val);
//
//    delay(16);                             // arbitrary delay to limit data to serial port 
}
