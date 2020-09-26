/**
* Cylinder class, representing a closed cylinder
* @Authors: Alvaro, Pierre, Isis
**/

class Cylinder {

  /** A T T R I B U T E S **/
  static final float cylinderBaseSize = 20; //Radius
  static final float cylinderHeight = 60;
  int cylinderResolution = 40;
  PVector center=new PVector(0, 0, 0);
  boolean isCenter = false;
  PShape closedCylinder = new PShape();

  /** M E T H O D S **/
  Cylinder(PVector location) {
    stroke(0);
    center = location;
    PShape openCylinder = new PShape();
    PShape sidesCylinder = new PShape();

    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    openCylinder.endShape();

    sidesCylinder = createShape();
    sidesCylinder.beginShape(TRIANGLE);
    for (int i = 1; i < x.length; i++) {
      sidesCylinder.vertex(x[i-1], y[i-1], 0);
      sidesCylinder.vertex(x[i], y[i], 0);
      sidesCylinder.vertex(0, 0, 0);
      sidesCylinder.vertex(x[i-1], y[i-1], cylinderHeight);
      sidesCylinder.vertex(x[i], y[i], cylinderHeight);
      sidesCylinder.vertex(0, 0, cylinderHeight);
    }
    sidesCylinder.endShape();

    closedCylinder = createShape(GROUP);
    closedCylinder.addChild(openCylinder);
    closedCylinder.addChild(sidesCylinder);
    noStroke();
  }

  void display(){
    gameSurface.pushMatrix();
    noStroke();
    gameSurface.translate(center.x, center.y, center.z);
    gameSurface.rotateX(-PI/2);
    gameSurface.shape(closedCylinder);
    gameSurface.popMatrix();
  }
  
  boolean overlapWithSphere(Sphere s){
   return center.dist(s.location) < Cylinder.cylinderBaseSize + s.RADIUS;
  }

}
