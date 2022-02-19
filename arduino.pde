import processing.serial.*;
Serial myPort;  // Create object from Serial class

static int RESET_FACTOR = 100;
static int RANGE_MAX = 10;
static float TOUCH_THRESH = 0.005;
static int WAIT_LENGTH = 20;
static int DRAW_LENGTH = 10;
static int LOCAL_AVG_SIZE = 60;
static float VARIANCE = 0.2;
static float SHIFTT_FACTOR = 0.0000002;

static String input_string; 
float push_x, push_y, push_z;
float giro[] = new float[2];
float giro_total_avg[] = new float[2];
float giro_loca_avg[] = new float[2];
float last_samples[][] = new float[2][LOCAL_AVG_SIZE];
int total_count = 0;
float max_giro[] = {RANGE_MAX, RANGE_MAX};
float coordinates[] = {width/2, height/2};
int wait_until = 0;
int draw_until = 0;
boolean  drawing_line=false;
boolean  panding_line=false;


void read_accelerometer(){
  if ( myPort.available() > 0) {  // If data is available,
    input_string = myPort.readStringUntil('\n'); 
    if(input_string != null){
      //print("@ ");
      //println(val);
      try {
        String[] splitted_input = input_string.split(",");
        giro[0] = Float.valueOf(splitted_input[0].trim());
        giro[1] = Float.valueOf(splitted_input[1].trim());
        push_x = Float.valueOf(splitted_input[2].trim());
        push_y = Float.valueOf(splitted_input[3].trim());
        push_z = Float.valueOf(splitted_input[4].trim());
      }
      catch(Exception e) {
        ;
      }
        print("x: ");
        print(giro[0]); // read it and store it in vals!
        print(" y: ");
        println(giro[1]); // read it and store it in vals!
    }
    //monitor_inputs();
   
  }  
}

void monitor_inputs(){
  push();
  fill(255, 0, 0);
  noStroke();
  ellipse(giro[0], giro[1], 10, 10);
  pop();
}

void map_data(){
  update_avg();
  update_range();
  coordinates[0] = map(giro[0]-giro_total_avg[0],-max_giro[0], max_giro[0], 0, width);
  coordinates[1] = map(giro[1]-giro_total_avg[1],-max_giro[1], max_giro[1], 0, height);
  monitor_coordinates();
}

void monitor_coordinates(){
  push();
  fill(255, 0, 0);
  noStroke();
  ellipse(coordinates[0], coordinates[1], 10, 10);
  pop();
}

boolean not_steady(int index){
  monitor_variance(index);
  return abs(giro_loca_avg[0] - last_samples[0][index]) > VARIANCE || abs(giro_loca_avg[1] - last_samples[1][index]) > VARIANCE;
}

boolean check_shifted(){
  monitor_shift();
  return abs(giro_loca_avg[0] - giro_total_avg[0]) > SHIFTT_FACTOR && abs(giro_loca_avg[1] - giro_total_avg[1]) > SHIFTT_FACTOR;
}

void monitor_shift(){
  print("shift ");
  print(giro_loca_avg[0] - giro_total_avg[0]);
  print(",");
  println(giro_loca_avg[1] - giro_total_avg[1]);
}

void monitor_variance(int index){
  print("variance ");
  print(abs(giro_loca_avg[0] - last_samples[0][index]));
  print(",");
  println(abs(giro_loca_avg[1] - last_samples[1][index]));
}


boolean check_steady(){
  
    int index = frameCount % LOCAL_AVG_SIZE;
    last_samples[0][index] = giro[0];
    last_samples[1][index] = giro[1];
    float sum[] = {0, 0};
    boolean steady = true;
    for (int i = 0; i < LOCAL_AVG_SIZE; i++) {
      sum[0] += last_samples[0][index];
      sum[1] += last_samples[1][index];
      if (not_steady(i)){
        steady = false;
      }
    }
    giro_loca_avg[0] = sum[0] / LOCAL_AVG_SIZE;
    giro_loca_avg[1] = sum[1] / LOCAL_AVG_SIZE;
    return steady;
}


boolean check_move(){
  boolean steady = check_steady();
  if (steady && check_shifted()){
    monitor_move();
    return true;

  }  
  else{
    return false;
  }
}

void monitor_move(){
  
    push();
    fill(0, 0, 255);
    noStroke();
    ellipse(width/2, height/2, 10, 10);
    pop();
}


void update_avg(){
  giro_total_avg[0] = ((giro_total_avg[0] * total_count) + giro[0]) / (total_count + 1);
  giro_total_avg[1] = ((giro_total_avg[1] * total_count) + giro[1]) / (total_count + 1);
  total_count += 1;
  monitor_avg();
}

void monitor_avg(){
  print("avg: "); print(giro_total_avg[0]); print(", "); println(giro_total_avg[1]);
}

boolean check_touch(){
  return push_x > TOUCH_THRESH && push_y > TOUCH_THRESH || push_z > TOUCH_THRESH;
}

void update_range(){
  if (abs(giro[0]) > max_giro[0]){
        max_giro[0] = abs(giro[0]);
    }
    if (abs(giro[1]) > max_giro[1]){
        max_giro[1] = abs(giro[1]);
    }
    if(frameCount % RESET_FACTOR == 0){
        max_giro[0]=RANGE_MAX;
        max_giro[1]=RANGE_MAX;
    }
}
