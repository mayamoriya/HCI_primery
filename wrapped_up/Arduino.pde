static int RESET_ZOOM_FACTOR = 100;
static int NOT_TOUCHED_FACTOR = 500;
static int TINT_LENGHT = 100;
static float RANGE_MAX = 1;
static float TOUCH_THRESH = 7.5;

static int LOCAL_AVG_SIZE = 100;
static float VARIANCE = 0.4; //0.4;
static float SHIFTT_FACTOR = 0.2; //0.05;
static float RESET = 0.05;
static int DONT_SWITCH_TIME = 200;

static int DONT_SWITCH_SETUP = 700;
String input_string; 
int switch_frame = 0;
float acc[] = new float[3];
float giro[] = new float[3];
float giro_total_avg[] = new float[2];
float acc_total_avg[] = new float[3];
float giro_loca_avg[] = new float[3];
float last_samples[][] = new float[3][LOCAL_AVG_SIZE];
int total_count = 0;
float max_giro[] = {RANGE_MAX, RANGE_MAX};
float coordinates[] = {width/2, height/2};
int wait_until = 0;
int draw_until = 0;
boolean  drawing_line=false;
boolean  panding_line=false;
boolean total_steady = false;
int not_touched_countdown = 0;
boolean total_moved=false;


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
        giro[2] = Float.valueOf(splitted_input[2].trim());
        acc[0] = Float.valueOf(splitted_input[3].trim());
        acc[1] = Float.valueOf(splitted_input[4].trim());
        acc[2] = Float.valueOf(splitted_input[5].trim());
      }
      catch(Exception e) {
        ;
      }
        //print("x: ");
        //print(giro[0]); // read it and store it in vals!
        //print(" y: ");
        //println(giro[1]); // read it and store it in vals!
        //print("x: ");
        //print(abs(acc_total_avg[0]-acc[0])); // read it and store it in vals!
        //print(" y: ");
        //print(acc[1]); // read it and store it in vals!
        //print(" z: ");
        //println(acc[2]); // read it and store it in vals!
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
  //monitor_coordinates();
}

void monitor_coordinates(){
  push();
  fill(255, 0, 0);
  noStroke();
  ellipse(coordinates[0], coordinates[1], 10, 10);
  pop();
}

boolean not_steady(int index){
  //monitor_variance(index);
  return abs(giro_loca_avg[0] - last_samples[0][index]) > VARIANCE || abs(giro_loca_avg[1] - last_samples[1][index]) > VARIANCE;
}


boolean check_shifted(){
  //monitor_shift();
  return abs(giro_loca_avg[0] - giro_total_avg[0]) > SHIFTT_FACTOR && abs(giro_loca_avg[1] - giro_total_avg[1]) > SHIFTT_FACTOR;
}

boolean set_touch(){
  if(abs(giro[0] - giro_total_avg[0]) < 0.4 && abs(giro[1] - giro_total_avg[1]) < 0.4){
    println("wait");
    return false;
  }
  else{
    TOUCH_THRESH = 0.8 * max(acc[0], acc[1]);
    print("\n\n\n\n\n\n\n\n\nmax: ");
    println(TOUCH_THRESH);

    return true;
  }
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
    last_samples[2][index] = giro[2];
    float sum[] = {0, 0, 0};
    int count = 0;
    boolean steady = true;
    float alpha = 0.2;
    float betta = 0.8;
    for (int i = 0; i < LOCAL_AVG_SIZE; i++) {
      sum[0] += last_samples[0][index];
      sum[1] += last_samples[1][index];
      sum[2] += last_samples[2][index];
      if (abs(acc[0] - acc_total_avg[0]) > alpha && abs(acc[1] - acc_total_avg[1]) > alpha && abs(acc[2] - acc_total_avg[2]) > alpha){
        count++;
      }
      if (not_steady(i)){
        steady = false;
      }
      
    }
    giro_loca_avg[0] = sum[0] / LOCAL_AVG_SIZE;
    giro_loca_avg[1] = sum[1] / LOCAL_AVG_SIZE;
    giro_loca_avg[2] = sum[1] / LOCAL_AVG_SIZE;
    total_moved = (count > betta * LOCAL_AVG_SIZE);

    return steady;
}


boolean check_move(){
  total_steady = check_steady();
  boolean shifted = check_shifted();
  //print("steady: ");
  //println(total_steady);
  //print("shifted: ");
  //println(shifted);

  
  //if (total_steady && shifted){
  if (total_moved && total_steady){
    //monitor_move();
    println("MOVE");
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
  acc_total_avg[0] = ((acc_total_avg[0] * total_count) + acc[0]) / (total_count + 1);
  acc_total_avg[1] = ((acc_total_avg[1] * total_count) + acc[1]) / (total_count + 1);
  acc_total_avg[2] = ((acc_total_avg[0] * total_count) + acc[2]) / (total_count + 1);
  total_count += 1;
  //monitor_avg();
}

void monitor_avg(){
  print("avg: "); print(giro_total_avg[0]); print(", "); println(giro_total_avg[1]);
}

boolean check_touch(){
   if(acc[0] > TOUCH_THRESH || acc[1] > TOUCH_THRESH || acc[2]
  > TOUCH_THRESH){
          println  ("TOUCH ");

  }
  return acc[0] > TOUCH_THRESH || acc[1] > TOUCH_THRESH || acc[2]
  > TOUCH_THRESH;
}

void update_range(){
  if (abs(giro[0]) > max_giro[0]){
        max_giro[0] = abs(giro[0]);
    }
    if (abs(giro[1]) > max_giro[1]){
        max_giro[1] = abs(giro[1]);
    }
    if(frameCount % RESET_ZOOM_FACTOR == 0){
        max_giro[0]=RANGE_MAX;
        max_giro[1]=RANGE_MAX;
    }
}
