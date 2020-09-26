/**
 * Sphere class, 
 * Representing the ball on the board
 * @Authors: Alvaro, Pierre, Isis
 **/
import java.util.List; 

class Sphere {
  /** A T T R I B U T E S **/
  private PShape globe;
  public float sphere_score = 0;
  public int cylinders_hit = 0;




  private PVector location; //Coordinate vector of the ball
  private PVector velocity; // Velocity vector of the ball
  private PVector gravity ; // Gravity vector
  private PVector friction; // Friction force vector
  public boolean inContact = false;

  private final int RADIUS = 20;
  private final float GRAVITY_CST = 0.7;
  private final float MU = 0.01; //Friction force magnitude
  private final float BOUNCE_COEFF = 0.8;



  /** M E T H O D S **/

  /*
  * Sphere constructor, initialising attributes
   */
  Sphere() {
    location = new PVector(0, - RADIUS - Plate.plateThickness/2, 0); //TODO
    velocity = new PVector(0, 0, 0);
    gravity = new PVector(0, 0, 0);

    img = loadImage("earth.jpg");
    globe = createShape(SPHERE, RADIUS);
    globe.setStroke(false);
    globe.setTexture(img);
  }

  /*
  * Updates all vectors: gravity depending on position, 
   * friction, velocity, location
   * moves only if not in shift mode
   */
  void update(Plate plate) {
    if (!inShiftMode()) {
      gravity.set(sin(plate.rz) * GRAVITY_CST, 0, sin(plate.rx) * GRAVITY_CST);
      friction = velocity.copy().normalize().mult(-1); //getting opposite direction vector to velocity
      friction.mult(MU); // magnitude of the friction
      velocity.add(gravity);
      velocity.add(friction); //friction slowing down velocity
      location.add(velocity);
    }
  }

  /*
  * Draws the ball on the board
   */
  void drawSphere() {
    gameSurface.pushMatrix();
    gameSurface.noStroke();
    gameSurface.translate(location.x, location.y, location.z);
    gameSurface.shape(globe);

    //sphere(RADIUS);
    gameSurface.popMatrix();
  }

  /*
  * Method to check that the ball's position is on the plate
   */
  void checkSpherePosition(Plate plate) {
    if (location.x > plate.plateSize/2 - RADIUS) {
      location.x = plate.plateSize/2 - RADIUS;
      velocity.x = velocity.x * - BOUNCE_COEFF;
    } else if (location.x < - plate.plateSize/2 + RADIUS) {
      location.x =  - plate.plateSize/2 + RADIUS;
      velocity.x = velocity.x * - BOUNCE_COEFF;
    }
    if (location.z > plate.plateSize/2 - RADIUS) {
      location.z = plate.plateSize/2 - RADIUS;
      velocity.z = velocity.z * - BOUNCE_COEFF;
    } else if (location.z < -plate.plateSize/2 + RADIUS) {
      location.z = -plate.plateSize/2 + RADIUS;
      velocity.z = velocity.z * - BOUNCE_COEFF;
    }
  }

  /*
  * Method to check if there is a collision with cylinders on the plate
   * Removes the cylinder in case of collision, all of them if ot was center
   */
  void checkCollisionWithCylinder(CylinderSystem ps) {   
    List<Cylinder> toRemove = new ArrayList<Cylinder>();

    for (Cylinder c : ps.cylinders) {
      PVector ballToCylinderCenter = new PVector(c.center.x - location.x, 0, c.center.z - location.z);
      float distanceFromCylinder = ballToCylinderCenter.mag();
      if (distanceFromCylinder <= Cylinder.cylinderBaseSize + RADIUS) {
        if (c.isCenter) {
          Game.win = true;
          ps.cylinders.clear();
          return;
        } else {
          PVector normal = ballToCylinderCenter.normalize();
          velocity = velocity.sub(normal.mult(2*(velocity.dot(normal))));
          toRemove.add(c);
          sphere_score += mag(velocity.x, velocity.z);
          cylinders_hit += 1;
        }
      }
    }
    ps.cylinders.removeAll(toRemove);
  }
}
