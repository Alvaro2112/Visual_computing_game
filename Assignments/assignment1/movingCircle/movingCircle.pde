float x= 0.0;

void settings(){
  size(200,200, P2D);
}

void setup(){
  frameRate(30);
}

void draw(){
 background(255,200,0);
 ellipse(x, height/2, 40, 40);
 x+=2;
 if (x > width + 40){
   x = -40.0;
 }
}

boolean isMoving = true;

void mousePressed(){
  if(isMoving){
    noLoop();
    isMoving = false;
  } else {
    loop();
    isMoving = true;  
  }
}
