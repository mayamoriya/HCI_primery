import processing.serial.*;

Serial myPort;  // Create object from Serial class

static float RANGE_MAX = 1;
static int RESET_ZOOM_FACTOR = 500;
static float SHIFT_THRESH= 0.1;
static float PERCENT_SHIFT_THRESH = 0.9;
float touch_thresh = 0;
float max_giro[] = {RANGE_MAX, RANGE_MAX, 0};
String input_string; 
float acc[] = new float[3];
float giro[] = new float[3];
float coordinates[] = {width/2, height/2};
float giro_total_avg[] = new float[3];
int total_count = 0;
float giro_local_avg[] = new float[2];
boolean steady_avg = false;
static int LOCAL_AVG_SIZE = 50;
static float VARIANCE = 0.4;
float last_samples[][] = new float[2][LOCAL_AVG_SIZE];


void read_accelerometer(){
  if ( myPort.available() > 0) {  // If data is available,
    input_string = myPort.readStringUntil('\n'); 
    if(input_string != null){
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
      
      print(giro[0]); print(" ");
      print(giro[1]); print(" ");
      print(giro[2]); print(" ");
      print(max_giro[2]); print(" ");
      print(touch_thresh); println(" ");
    }   
  }  
}

void update_avg(){
  giro_total_avg[0] = ((giro_total_avg[0] * total_count) + giro[0]) / (total_count + 1);
  giro_total_avg[1] = ((giro_total_avg[1] * total_count) + giro[1]) / (total_count + 1);
  giro_total_avg[2] = ((giro_total_avg[2] * total_count) + giro[2]) / (total_count + 1);
  int index = frameCount % LOCAL_AVG_SIZE;
  last_samples[0][index] = giro[0];
  last_samples[1][index] = giro[1];
  total_count += 1;
}



void map_data(){
  update_avg();
  update_range();
  coordinates[0] = map(giro[0]-giro_total_avg[0],-max_giro[0], max_giro[0], 0, width);
  coordinates[1] = map(giro[1]-giro_total_avg[1],-max_giro[1], max_giro[1], 0, height);
}

void update_range(){
  if (abs(giro[0]) > max_giro[0]){
        max_giro[0] = abs(giro[0]);
    }
    if (abs(giro[1]) > max_giro[1]){
        max_giro[1] = abs(giro[1]);
    }
    if (abs(giro[2]) > max_giro[2]){
        max_giro[2] = abs(giro[2]);
    }
    if(frameCount % RESET_ZOOM_FACTOR == 0){
        max_giro[0]=RANGE_MAX;
        max_giro[1]=RANGE_MAX;
        max_giro[2]=-999;
    }
    touch_thresh = 0.7 *  max_giro[2];
}

boolean check_touch(){
  // 0.5
  if(abs(abs(giro[2]) - abs(giro_total_avg[2])) > touch_thresh){
    print("TOUCH");
    return true;
  }
  return false;
}


boolean not_steady(int index){
  return abs(giro_local_avg[0] - last_samples[0][index]) > VARIANCE || abs(giro_local_avg[1] - last_samples[1][index]) > VARIANCE;
}

boolean check_move(){
    boolean steady = true;
    float sum[] = {0, 0};
    int shift_count = 0;
    for (int i = 0; i < LOCAL_AVG_SIZE; i++) {
      sum[0] += last_samples[0][i];
      sum[1] += last_samples[1][i];
      if ((abs(giro_local_avg[0] - last_samples[0][i]) > VARIANCE || abs(giro_local_avg[1] - last_samples[1][i]) > VARIANCE)){
        steady = false;
      }
      if (abs(giro[0] - giro_total_avg[0]) > SHIFT_THRESH && abs(giro[1] - giro_total_avg[1]) > SHIFT_THRESH){
        shift_count++;
      }
    }
    giro_local_avg[0] = sum[0] / LOCAL_AVG_SIZE;
    giro_local_avg[1] = sum[1] / LOCAL_AVG_SIZE;
    boolean shifted = (shift_count > PERCENT_SHIFT_THRESH * LOCAL_AVG_SIZE);
    print("shifted: ");println(shifted);
    print("steady: ");println(steady);
    return steady && shifted;
}
