/**
 * Game class, main class which draws and allows to play the game
 * @Authors: Alvaro, Pierre, Isis
 **/

private CylinderSystem cs;
private Sphere sphere;
private Plate plate;
private Robot robot;
private double angleInRadians;
private PVector Robot_center = new PVector(0, 0, 0);
PImage img;

float depth = 2000;


void settings() {
  size(500, 500,P3D);

}

void setup() {

  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);//default?
  cs = new CylinderSystem();
  
  sphere = new Sphere();
  plate = new Plate();
  robot = new Robot();
  

}

void draw() {
  lights();
  background(200);
  plate.drawPlate();
  //translate(0, -Plate.plateThickness/2, 0);


  angleInRadians =  Math.atan2(-sphere.location.z+Robot_center.z, sphere.location.x-Robot_center.x);

  for (Cylinder c : cs.cylinders) {
    c.display();
    if (c.isCenter && !inShiftMode()) {
      shape(robot.getShape(), 0, 0);
      Robot_center = c.center;
    }
    rotateX(PI/2);
    translate(-c.center.x, -c.center.y, -c.center.z);
  }
  
  robot.rotate((float)angleInRadians);
  sphere.update(plate);
  sphere.checkSpherePosition(plate);
  sphere.checkCollisionWithCylinder(cs);
  sphere.drawSphere();
  
 if(cs.cylinders.size()!=0) {
   cs.run();
  }

  //translate(mouseX, mouseY, 0);
}

/*
 * On mouse wheel should change rotation speed of the plate
 */
void mouseWheel(MouseEvent event) {
  if(!inShiftMode()){
    float e = event.getCount();
    if (e < 0 && plate.rotation_speed < Plate.MAX_PLATE_ROT_SPEED) { 
      plate.rotation_speed = min(plate.rotation_speed + Plate.CHANGE_PLATE_ROT_SPEED, Plate.MAX_PLATE_ROT_SPEED);
    } else if (e > 0 && plate.rotation_speed > Plate.MIN_PLATE_ROT_SPEED) {
      plate.rotation_speed = max(plate.rotation_speed - Plate.CHANGE_PLATE_ROT_SPEED, Plate.MIN_PLATE_ROT_SPEED);
    }
  }
}

/*
 * On mouse move should change orientation of the plate only on normal mode
 */
void mouseDragged() {
  if(!inShiftMode()){
    plate.rx = map(mouseY, 0, height, -PI/3, PI/3) * plate.rotation_speed;
    if (plate.rx > Plate.LIMIT_ROTATION_ANGLE) {
      plate.rx = Plate.LIMIT_ROTATION_ANGLE;
    } else if ( plate.rx < -Plate.LIMIT_ROTATION_ANGLE) {
      plate.rx = -Plate.LIMIT_ROTATION_ANGLE;
    }
    plate.rz = map(mouseX, 0, width, -PI/3, PI/3)  * plate.rotation_speed;
    if (plate.rz > Plate.LIMIT_ROTATION_ANGLE) {
      plate.rz = Plate.LIMIT_ROTATION_ANGLE;
    } else if ( plate.rz < -Plate.LIMIT_ROTATION_ANGLE) {
      plate.rz=-Plate.LIMIT_ROTATION_ANGLE;
    }
  }
}

/*
 * Method to signal Shift mode
 */
boolean inShiftMode(){
  return (keyPressed && keyCode == SHIFT);
}

/*
 * Method reacting on press of the mouse
 * If in Shift mode, adds a cylinder acting as the center 
 * where the bad guy is
 * Adds it only if the position clicked by the user is valid
 */
void mousePressed() {
  if (mouseButton == LEFT && inShiftMode()) {
    Cylinder toadd = new Cylinder(new PVector((mouseX-(width/2))*4.2, -Cylinder.cylinderHeight, (mouseY-(height/2))*4.2));
    if (Position_Check(toadd.center)) {
      cs = new CylinderSystem(toadd);
    }
  }
}


/*
 * Method reacting on press of the mouse
 * If in Shift mode, adds a cylinder acting as the center 
 * where the bad guy is
 * Adds it only if the position clicked by the user is valid
 */
boolean Position_Check(PVector position) {

  for (Cylinder p : cs.cylinders) {
    if (p.center.dist(position) < 2 * Cylinder.cylinderBaseSize ) {
      return false;
    }
  }

  if (position.x <= -plate.plateSize/2 + Cylinder.cylinderBaseSize || position.x >= plate.plateSize/2  -Cylinder.cylinderBaseSize || position.z <= -plate.plateSize/2 + Cylinder.cylinderBaseSize || position.z >= plate.plateSize/2 - Cylinder.cylinderBaseSize) {
    return false;
  } 

  if (position.dist(sphere.location) < Cylinder.cylinderBaseSize + sphere.RADIUS) {
    return false;
  }


  return true;
}
