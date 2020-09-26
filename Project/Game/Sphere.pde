import java.util.List; 

class Sphere {

  PVector location;
  PVector velocity;
  PVector gravity ;

  boolean In_Contact = false;
  private final int RADIUS = 50;
  private final int gravityConstant = 1;

  Sphere() {
    location = new PVector(0, -RADIUS-yBox/2, 0);
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0, 0);
  }
  void update(float rx, float rz) {

    gravity.x = sin(rz) * gravityConstant; 
    gravity.z = sin(rx) * gravityConstant;
    float normalForce = 1;
    float mu = 0.01;
    float frictionMagnitude = normalForce * mu; 
    PVector friction = velocity.copy(); 
    friction.mult(-1);
    friction.normalize(); 
    friction.mult(frictionMagnitude);
    velocity.add(gravity);
    location.add(velocity);
    location.add(friction);
  }
  void display() {
    noStroke();
    lights();
    translate(location.x, location.y, location.z);
    sphere(RADIUS);
  }
  void checkEdges() {
    if (location.x > xBox/2 - RADIUS) {
      location.x = xBox/2 - RADIUS;
      velocity.x = velocity.x * -0.8;
    } else if (location.x < -xBox/2 + RADIUS) {
      location.x =  -xBox/2 + RADIUS;
      velocity.x = velocity.x * -0.8;
    }
    if (location.z > xBox/2 - RADIUS) {
      location.z = xBox/2 - RADIUS;
      velocity.z = velocity.z * -0.8;
    } else if (location.z < -xBox/2 + RADIUS) {
      location.z = -xBox/2 + RADIUS;
      velocity.z = velocity.z * -0.8;
    }
  }

  void checkCylinders() {      

    
    List<Cylinder> toRemove = new ArrayList<Cylinder>();
    for (Cylinder c : ps.particles) {
      PVector n = new PVector(c.center.x - location.x, 0, c.center.z - location.z);
      if (sqrt(n.x*n.x + n.z*n.z) <= Cylinder.cylinderBaseSize + RADIUS) {
        velocity = velocity.sub(n.mult(2*(velocity.dot(n.normalize()))));
        toRemove.add(c);
      }
    }
    ps.particles.removeAll(toRemove);
  }
}
