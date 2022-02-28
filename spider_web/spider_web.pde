float thold = 5;
float spifac = 1.05;
int outnum;
float drag = 0.01;
int big = 500;
ball bodies[];
float mX;
float mY;
color lilach = color(232, 196, 247, 5);
color navy = color(6, 38, 61);
color purple = color(21, 13, 33);
color green_blue = color(92, 199, 196, 5);
color sw_colors[][] = {{navy, lilach}, {purple, green_blue}};
int sw_color_set = 1;
color sw_background;
color sw_stroke;


void setup_spiderWeb() {
  bodies = new ball[big];
  sw_color_set = (sw_color_set+1)%2;
  sw_background = sw_colors[sw_color_set][0];
  sw_stroke = sw_colors[sw_color_set][1];
  background(sw_background);
  strokeWeight(1);
  fill(sw_stroke);
  stroke(sw_stroke);
  smooth();
  for(int i = 0; i < big; i++) {
    bodies[i] = new ball();
  }
 
}


  
void draw_spiderWeb() {
  if(check_touch()) {

    background(sw_background);
 
    mX += 0.3 * (coordinates[0] - mX);
    mY += 0.3 * (coordinates[1] - mY);
  }
  mX += 0.3 * (coordinates[0] - mX);
  mY += 0.3 * (coordinates[1] - mY);
  for(int i = 0; i < big; i++) {
    bodies[i].render();
  }
}

class ball {
  float X;
  float Y;
  float Xv;
  float Yv;
  float pX;
  float pY;
  float w;
  ball() {
    X = random(width);
    Y = random(height);
    w = random(1 / thold, thold);
  }
  void render() {
    if(!check_touch()) {
      Xv /= spifac;
      Yv /= spifac;
      
    }
    Xv += drag * (mX - X) * w;
    Yv += drag * (mY - Y) * w;
    X += Xv;
    Y += Yv;
    line(X, Y, pX, pY);
    pX = X;
    pY = Y;
  }
}
