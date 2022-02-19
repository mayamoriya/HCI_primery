PVector[] curves[] = new PVector[0][0];
int rad = 8;
float spd = 0.05;

void setup() {
  size(displayWidth, displayHeight);
  background(0);
  stroke(255);
  noFill();
}

void mousePressed() {
  PVector mousePos[] = {new PVector(mouseX,mouseY)};
  append(curves,mousePos);
  print("!!!");
  print(curves.length);
}

//void mouseDragged() {
//  if(curves.length > 0) {
//    PVector mousePos = new PVector(mouseX,mouseY);
//    PVector lastPos = curves[curves.length-1][curves[curves.length-1].length-1];
//    if(PVector.sub(mousePos,lastPos).mag() > 2) {
//      PVector mousePos_arr[] = {mousePos};
//      curves[curves.length-1] = mousePos_arr;
//    }
//  }
//}

//void draw() {
//  background(0);
    
//  if(curves.length >= 1 && !mousePressed) {
    
//    for(var i1=0; i1<curves.length; ++i1) {
//      for(var j1=0; j1<curves[i1].length; ++j1) {
//        for(var i2=0; i2<curves.length; ++i2) {
//          for(var j2=0; j2<curves[i2].length; ++j2) {
//            if(PVector.sub(curves[i1][j1],curves[i2][j2]).mag() < 2*rad) {
//              curves[i1][j1] = curves[i1][j1].add(PVector.sub(curves[i1][j1],curves[i2][j2]).setMag((2*rad-PVector.dist(curves[i1][j1],curves[i2][j2]))*spd));
//              // break;
//            }
//          }
//        }
//      }
//    }
    
//    for(var i1=0; i1<curves.length; ++i1) {
//      for(var j1=1; j1<curves[i1].length; ++j1) {
//        if(PVector.sub(curves[i1][j1],curves[i1][j1-1]).mag() > 2*rad) {
//          splice(curves[i1][j1],PVector.add(curves[i1][j1],curves[i1][j1-1]).mult(0.5), 0);
//          // break;
//        }
//      }
//    }
    
//  }
  
//  if(curves.length >= 1) {
//    for(var i=0; i<curves.length; ++i) {
//      beginShape();
//      for(var j=0; j<curves[i].length; ++j) {
//        curveVertex(curves[i][j].x,curves[i][j].y);
//      }
//      endShape();
//    }
//  }
  
//}
