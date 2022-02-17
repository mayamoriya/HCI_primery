import processing.serial.*;

Serial myPort;  // Create object from Serial class
static String val;    // Data received from the serial port
int sensorVal1 = 0;
int sensorVal2 = 0;

void setup()
{
   size(720, 480);
   noStroke();
   noFill();
   String portName = "COM4";// Change the number (in this case ) to match the corresponding port number connected to your Arduino. 
   myPort = new Serial(this, portName, 9600);
}

void draw()
{
  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n'); 
    if(val != null){
      //print("@ ");
      //println(val);
      try {
        String[] val_array = val.split(",");
        sensorVal1 = Integer.valueOf(val_array[0].trim());
        sensorVal2 = Integer.valueOf(val_array[1].trim());
      }
      catch(Exception e) {
        ;
      }
        print("x: ");
        println(sensorVal1); // read it and store it in vals!
        print("Y: ");
        println(sensorVal2); // read it and store it in vals!
    }
   
  }  
  background(0);
  // Scale the mouseX value from 0 to 640 to a range between 0 and 175
  float c = map(sensorVal1, 0, width, 0, 400);
  // Scale the mouseX value from 0 to 640 to a range between 40 and 300
  float d = map(sensorVal2, 0, width, 40,500);
  fill(255, c, 0);
  ellipse(width/2, height/2, d, d);   

}
