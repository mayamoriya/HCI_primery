static int NUM_LINES = 1;
static int WAIT_LENGTH = 8;
static int DRAW_LENGTH = 100;
static int NOT_TOUCHED_FACTOR = 500;


PVector curves[][] = new PVector[0][0];
PVector second[][];
int rad = 8;
float spd = 0.05;
boolean start = false;
int wl_c = 0;
color brown = color(58, 53, 59, 4);
color orange = color(255, 208, 146);
color green = color(234, 252, 157);
color blue = color(21 ,46 ,63, 4 );
int wait_until = 0;
int draw_until = 0;
color wl_colors[][] = {{brown, green}, {blue, orange}};
int wl_color_set = 1;
color wl_background;
color wl_stroke;

int not_touched_countdown = 0;

void setup_whiteLine() {
  
  wl_color_set = (wl_color_set+1)%2;
  wl_background = wl_colors[wl_color_set][0];
  wl_stroke = wl_colors[wl_color_set][1];
  background(wl_background);
  stroke(wl_stroke);
  fill(wl_background);
  curves = new PVector[0][0];
  not_touched_countdown = NOT_TOUCHED_FACTOR;
}   


void new_line() {
  PVector mousePos[] = {new PVector(coordinates[0] ,coordinates[1])};
  if (curves.length < NUM_LINES){
      curves = (PVector[][])append(curves,mousePos);
  }
  else {
    curves[frameCount % NUM_LINES] = mousePos;
  }
}

void expand_line() {
  if(curves.length > 0) {
    PVector mousePos = new PVector(coordinates[0] ,coordinates[1]);
    PVector lastPos = curves[curves.length-1][curves[curves.length-1].length-1];
    if(PVector.sub(mousePos,lastPos).mag() > 2) {
      curves[curves.length-1] = (PVector [])append(curves[curves.length-1], mousePos);
    }
  }
}

void draw_whiteLine() {
  if (check_touch() && frameCount > wait_until){
    wait_until = frameCount + WAIT_LENGTH;
    println(wl_c);
    wl_c++;
    new_line();
    draw_until = frameCount + DRAW_LENGTH;
  }
  else if (frameCount < draw_until){
    expand_line();
  }
  
  if(curves.length >= 1 && !mousePressed) {
    for(var i1=0; i1<curves.length; ++i1) {
      for(var j1=0; j1<curves[i1].length; ++j1) {
        for(var i2=0; i2<curves.length; ++i2) {
          for(var j2=0; j2<curves[i2].length; ++j2) {
            if(PVector.sub(curves[i1][j1],curves[i2][j2]).mag() < 2*rad) {
              curves[i1][j1] = curves[i1][j1].add(PVector.sub(curves[i1][j1],curves[i2][j2]).setMag((2*rad-PVector.dist(curves[i1][j1],curves[i2][j2]))*spd));
               //break;
            }
          }
        }
      }
    }
    
    for(var i1=0; i1<curves.length; ++i1) {
      for(var j1=1; j1<curves[i1].length; ++j1) {
        if(PVector.sub(curves[i1][j1],curves[i1][j1-1]).mag() > 2*rad) {
          curves[i1] = (PVector [])splice(curves[i1], PVector.add(curves[i1][j1],curves[i1][j1-1]).mult(0.5), j1);
           //break;
        }
      }
    }
    
  }
  if(curves.length >= 1) {
    for(var i=0; i<curves.length; ++i) {
      beginShape();
      for(var j=0; j<curves[i].length; ++j) {
        curveVertex(curves[i][j].x,curves[i][j].y);
      }
      endShape();
    }
  }

  
}
