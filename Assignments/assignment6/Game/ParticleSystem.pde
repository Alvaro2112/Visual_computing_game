// A class to describe a group of Particles
class ParticleSystem {

  ArrayList<Cylinder> particles;
  PVector origin;
  float particleRadius = Cylinder.cylinderBaseSize;

  ParticleSystem() {
    particles = new ArrayList<Cylinder>();
  }

  ParticleSystem(PVector origin) {
    this.origin = origin.copy();
    particles = new ArrayList<Cylinder>();
    Cylinder originC = new Cylinder(origin);
    originC.isCenter = true;
    particles.add(originC);
    
  }
  void addParticle() {
    PVector center;
    int numAttempts = 100;
    for (int i=0; i<numAttempts; i++) {
      // Pick a cylinder and its center.
      int index = int(random(particles.size()));
      center = particles.get(index).center.copy();
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2*particleRadius;
      center.z += cos(angle) * 2*particleRadius;
      if (checkPosition(center)) {
        particles.add(new Cylinder(center));
        break;
      }
    }
  }

  // Check if a position is available, i.e.
  // - would not overlap with particles that are already created
  // (for each particle, call checkOverlap())
  // - is inside the board boundaries
  boolean checkPosition(PVector center) {
    for (int i = 0; i < particles.size(); i++) {
      Cylinder p = particles.get(i);
      if (!checkOverlap(p.center, center)) {
        return false;
      }
    }
    if (center.x - particleRadius < -xBox/2 || center.x + particleRadius > xBox/2   || center.z - particleRadius < -xBox/2  || center.z + particleRadius > xBox/2 ) { //Add particle radius? how to know what is the radius? add a parameter?
      return false;
    }
    return true;
  }
  // Check if a particle with center c1
  // and another particle with center c2 overlap.
  boolean checkOverlap(PVector c1, PVector c2) {
    return c1.dist(c2) >= 2 * particleRadius;
  }

  // Iteratively update and display every particle,
  // and remove them from the list if their lifetime is over.
  void run() {
    if(frameCount % 30 == 0){
      addParticle();
    }
  }
}
