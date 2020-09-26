class Cylinder {

  static final float cylinderBaseSize = 50; //Radius
  static final float cylinderHeight = 130;
  int cylinderResolution = 40;
  PVector center=new PVector(0, 0, 0);
  boolean isCenter = false;



  PShape closedCylinder = new PShape();

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
    translate(center.x, center.y, center.z);
    rotateX(-PI/2);
    shape(closedCylinder);
  }

  /*PShape shape() {
    return closedCylinder;
  }*/
}
