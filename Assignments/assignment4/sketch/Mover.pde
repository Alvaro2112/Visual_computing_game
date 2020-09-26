class Mover { 
  PVector location;
  PVector velocity;
  PVector gravity ;
  
  private final int SIZE = 48;
  Mover() {
    location = new PVector(width/2, height/2);
    velocity = new PVector(1, 1);
    gravity = new PVector(0, 1);
  }
  void update() {
    velocity.add(gravity);
    location.add(velocity);
  }
  void display() {
    stroke(0);
    strokeWeight(2);
    fill(127);
    ellipse(location.x, location.y, SIZE, SIZE);
  }
  void checkEdges() {
    if (location.x + SIZE/2 > width){
      location.x = width - SIZE/2;
      velocity.x = velocity.x * -1;
    }else if ((location.y - SIZE/2 < 0)){
      location.y = 0 + SIZE/2;
      velocity.y = velocity.y * -1;
    }else if (location.x - SIZE/2 < 0) {
      location.x = 0 + SIZE/2;
      velocity.x = velocity.x * -1;
    }else if (location.y + SIZE/2 > height){
      location.y = height - SIZE/2;
      velocity.y = velocity.y * -0.9;
    }
  }
}
