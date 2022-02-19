import processing.serial.*;

Serial myPort;  // Create object from Serial class
static String val;    // Data received from the serial port
static int MAX = 10;
static int RESET_FACTOR = 100;
static float VARIANCE = 0.2;
static float SHIFTT_FACTOR = 0.0000002;
static int SIZE = 60;
static int TOUCH_AVG_SIZE = 5;
static float THRESH = 0.005;
static float FREQ_FACTOR = 10000;
float total_avg[] = new float[2];
float current_avg[] = new float[2];
int total_count = 0;
float input[][] = new float[2][SIZE];
float coord[][] = new float[2][SIZE];
long touch[] = new long[TOUCH_AVG_SIZE];
int touch_count = 0;
float max[] = new float[2];
float sum[] = new float[2];
float push_x, push_y, push_z;
float x, map_x, max_x=MAX, avg_x=0, sum_x, cen_x, cur_var_x;
float y, map_y, max_y=MAX, avg_y=0, sum_y, cen_y, cut_var_y;
int freq;
long max_diff = 0;
long time = 0;
void setup()
{
   time = System.currentTimeMillis();
   size(640, 360);
   noStroke();
   fill(255, 153); 
   String portName = "COM4";// Change the number (in this case ) to match the corresponding port number connected to your Arduino. 
   myPort = new Serial(this, portName, 9600);
}

void update_avg(){
  total_avg[0] = ((total_avg[0] * total_count) + x) / (total_count + 1);
  total_avg[1] = ((total_avg[1] * total_count) + x) / (total_count + 1);
  total_count += 1;
}

float frequency(){
  return 0.0;
}

void touch(){
  float n = 0;
  if(freq > 0){
    n = float(1/freq);
  }
  int green_= int(map(freq, 16, 800, 0, 255));
  if (push_x > THRESH && push_y > THRESH || push_z > THRESH){
      fill(green_, 0, 0);
      ellipse(width/2, height/2, 40, 40);
      long current_time = System.currentTimeMillis();
      long diff = current_time - time;
      touch[touch_count % TOUCH_AVG_SIZE] = diff;
      if (max_diff < diff){
        max_diff = diff;
      }
      print("time: ");
      println(diff);
      touch_count++;
      time = current_time;
      long time_sum = 0;
      for (int i = 0; i < TOUCH_AVG_SIZE; i++) {
        time_sum+=touch[i];
      }
      freq = int(time_sum/TOUCH_AVG_SIZE);

  }
    print("frequency: ");
    println(freq);
  
}

void shift(boolean stady){
  if(frameCount > 2000){
    
    if(stady && there_is_shift()){
        fill(255, 0, 0);
        ellipse(width/2, height/2, 100, 100);
     }
     fill(255, 153); 
  }
}
void help_(){
    //fill(0, 0, 255, 90);
    //ellipse(map(current_avg[0],-max_x, max_x, 0, width), map(current_avg[1],-max_x, max_x, 0, height), map(VARIANCE,-max_x, max_x, 0, width), map(VARIANCE,-max_x, max_x, 0, height));
    //fill(0, 255, 0, 50);
    //ellipse(map(total_avg[0],-max_x, max_x, 0, width), map(total_avg[1],-max_x, max_x, 0, height), map(SHIFTT_FACTOR,-max_x, max_x, 0, width), map(SHIFTT_FACTOR,-max_x, max_x, 0, height));
    fill(0, 255, 0);
    ellipse(map(total_avg[0],-max_x, max_x, 0, width), map(total_avg[1],-max_x, max_x, 0, height), 10, 10);
    fill(0, 0, 255);
    ellipse(map(current_avg[0],-max_x, max_x, 0, width), map(current_avg[1],-max_x, max_x, 0, height), 10, 10);
}

boolean not_stady(int index){
  return abs(current_avg[0] - input[0][index]) > VARIANCE || abs(current_avg[1] - input[1][index]) > VARIANCE;
}

boolean there_is_shift(){
  //print("cur avg ");
  //print(current_avg[0]);
  //print(",");
  //println(current_avg[1]);
  return abs(current_avg[0] - total_avg[0]) > SHIFTT_FACTOR && abs(current_avg[1] - total_avg[1]) > SHIFTT_FACTOR;
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
        x = Float.valueOf(val_array[0].trim());
        y = Float.valueOf(val_array[1].trim());
        push_x = Float.valueOf(val_array[2].trim());
        push_y = Float.valueOf(val_array[3].trim());
        push_z = Float.valueOf(val_array[4].trim());
      }
      catch(Exception e) {
        ;
      }
        print("x: ");
        print(x); // read it and store it in vals!
        print(" y: ");
        println(y); // read it and store it in vals!
    }
   
  }  
  background(51);

    if (abs(x) > max_x){
        max_x = abs(x);
    }
    if (abs(y) > max_y){
        max_y = abs(y);
    }
    int which = frameCount % SIZE;
    if(frameCount % RESET_FACTOR == 0){
        max_x=MAX;
        max_y=MAX;
        print("avg: "); print(total_avg[0]); print(", "); println(total_avg[1]);
    }
    input[0][which] = x;
    input[1][which] = y;
    coord[0][which] = map(x-total_avg[0],-max_x, max_x, 0, width);
    coord[1][which] = map(y-total_avg[1],-max_y, max_y, 0, height);
   
    update_avg();
   
    sum_x=0;
    sum_y=0;
    boolean stady = true;
    fill(255, 153); 
    for (int i = 0; i < SIZE; i++) {
      int index = (which+1 + i) % SIZE;
      sum_x+=input[0][index];
      sum_y+=input[1][index];
      if (not_stady(index)){
        stady = false;
      }
      ellipse(coord[0][index], coord[1][index], i, i);
    }
    
    touch();
    help_();
    
    current_avg[0]=sum_x/SIZE;
    current_avg[1]=sum_y/SIZE; 
    
    shift(stady);
}
