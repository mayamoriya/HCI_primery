PVector curves[][] = new PVector[0][0];
PVector second[][];
int rad = 8;
float spd = 0.05;
boolean start = false;
void setup() {
  String portName = "COM4";
  myPort = new Serial(this, portName, 9600);
  //size(displayWidth, displayHeight);
  size(690, 340);
  background(0);
  stroke(255);
  fill(0, 4);
}   


void new_line() {
  PVector mousePos[] = {new PVector(coordinates[0] ,coordinates[1])};
  curves = (PVector[][])append(curves,mousePos);
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

void draw() {
  read_accelerometer();
  map_data();
  if(check_touch()){
    wait_until = frameCount + WAIT_LENGTH;
    panding_line = true;
  }
  if(frameCount > wait_until && panding_line){
      new_line();
      drawing_line = true;
      draw_until = frameCount + DRAW_LENGTH;
      panding_line = false;
  }
  if (drawing_line){
    if(frameCount < draw_until){
       expand_line();
    }
  }
  if(check_move()){
    background(0);
  }
  //if(frameCount<50 && start == false){
  //  start = true;
  //  new_line();
  //}
  //if(50<frameCount && frameCount<200){
  //   expand_line();
  //}
  //background(0);

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
