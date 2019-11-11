import java.util.Queue;
import java.util.ArrayDeque;

class CapacityFilter
{
  boolean triggered = false;
  boolean sendTrigger = false;
  boolean sendRelease = false;
  float peak = 0.0;
  float lastVal = 0.0;
  float thres = 0.1;
  int maxn = 30;
  float ave = 1000.0;
  float variance = 0.0;
  
  Queue recent = new ArrayDeque(maxn);
  
   CapacityFilter() {}
   
   // usage:
   // 
 
   void update(float val) {
     if (!triggered) {
      if (!sendTrigger) {
        if (val < 10) {
         sendTrigger = true; 
         peak = ave - val;
        }
        if (lastVal - val > ave * thres) {
         sendTrigger = true; // need to send trigger, but value is still decreasing, wait till value stops decreasing
        }
        
        if (sendTrigger) {
          recent.clear();
        }
        else {
          // process average background
           int size = recent.size();
           if (size > maxn) {
             float oldVal = (Float)recent.remove(); 
             ave -= oldVal / maxn;
             ave += val / maxn;
           }
           else {
            recent.add(val);
            ave = (ave * size + val) / (size + 1);
           }
        }
      }
      else { // sendTrigger == true, need to determine peak value
        if (val < 10) {
         peak = ave - val; // will be sent
        }
        if (val >= lastVal) {
         peak = ave - lastVal; // use last value as the local minima 
        }
      }
      
      
     }
     
     if (triggered) {
       if (val > ave * 0.8 || val > 2000) {
        sendRelease = true; 
       }
       
       if (!sendRelease) {
         // calculate variance
           int size = recent.size();
           if (size > maxn) {
             recent.remove(); 
             size--;
           }
           recent.add(val);
           size++;
           float sum = 0.0;
           for (Object o : recent) {
            float x = (Float)o; 
            sum += x;
           }
           float mean = sum / size;
           float var = 0.0;
           for (Object o : recent) {
            float x = (Float)o; 
            var += (x - mean) * (x - mean);
           }
           var /= size;
           variance = var;
       }
     }
     
     lastVal = val;
     
   }
   
   float getTrigger() {
    if (sendTrigger) {
       if (peak > 1) {
          float returnVal = peak;
          peak = -1; // clear peak
          sendTrigger = false;
          triggered = true;
          return returnVal;
       }
       else {
        // wait for accurate peak value
       }
    }
    return -1;
   }
   
   float getRelease() {
    if (sendRelease) {
     sendRelease = false;
     triggered = false;
     return 1; 
    }
    return -1;
   }
   
   float getVariance() {
     if (triggered) {
       return variance;
     }
     return -1;
   }
}
