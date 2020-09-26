class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float colors[] = {255.0, 255.0, 255.0};

  Particle(PVector l) {
    acceleration = new PVector(0, 0.5);
    velocity = new PVector(random(-10, 10), random(-15, 0));
    position = l.copy();
    lifespan = 255.0;
    colors[0] = random(255);
    colors[1] = random(255);
    colors[2] = random(255);
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    gameSurface.stroke(colors[0], colors[1], colors[2], lifespan);
    //Color c = new Color(100, 200, 0lifespan);
    gameSurface.fill(colors[0], colors[1], colors[2], lifespan);
    gameSurface.ellipse(position.x, position.y, 30, 30);
  }

  boolean isDead() {
    return lifespan < 0.0;
  }
}
