/**
 * CylinderSystem class, representing a system of cylinders evolving on the board
 * @Authors: Alvaro, Pierre, Isis
 **/

class CylinderSystem {

  private ArrayList<Cylinder> cylinders;
  private PVector origin;
  private float cylinderRadius = Cylinder.cylinderBaseSize;

  CylinderSystem() {
    cylinders = new ArrayList<Cylinder>();
  }

  CylinderSystem(Cylinder cOrigin) {
    this.origin = cOrigin.center;
    cylinders = new ArrayList<Cylinder>();
    cOrigin.isCenter = true;
    cylinders.add(cOrigin);
  }


  void addCylinder() {
    PVector center;
    int numAttempts = 100;
    for (int i=0; i<numAttempts; i++) {
      // Pick a cylinder and its center.
      int index = int(random(cylinders.size()));
      center = cylinders.get(index).center.copy();
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2*cylinderRadius;
      center.z += cos(angle) * 2*cylinderRadius;
      Cylinder c = new Cylinder(center);
      if (checkPosition(center) && !c.overlapWithSphere(sphere)) {
        cylinders.add(c);
        break; // return
      }
    }
  }

  // Check if a position is available, i.e.
  // - would not overlap with particles that are already created
  // (for each particle, call checkOverlap())
  // - is inside the board boundaries
  boolean checkPosition(PVector center) {
    for (int i = 0; i < cylinders.size(); i++) {
      Cylinder p = cylinders.get(i);
      if (!checkOverlap(p.center, center)) {
        return false;
      }
    }
    if (center.x - cylinderRadius < -plate.plateSize/2 || center.x + cylinderRadius > plate.plateSize/2   || center.z - cylinderRadius < -plate.plateSize/2  || center.z + cylinderRadius > plate.plateSize/2 ) { //Add particle radius? how to know what is the radius? add a parameter?
      return false;
    }
    return true;
  }

  // Check if a cylinder with center c1
  // and another cylinder with center c2 overlap.
  boolean checkOverlap(PVector c1, PVector c2) {
    return c1.dist(c2) >= 2 * cylinderRadius;
  }

  // Iteratively update and display every particle,
  // and remove them from the list if their lifetime is over.
  void run() {
    if (frameCount % 30 == 0) {
      addCylinder();
    }
  }
}
