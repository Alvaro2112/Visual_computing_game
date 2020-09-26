class closedCylinder {

  static final float cylinderBaseSize = 60;
  static final float cylinderHeight= 150;
  int cylinderResolution= 40;
  PShape closedCylinder = new PShape();
  PShape capUp, capDown, parent;
  PVector location=new PVector(0, 0, 0);

  closedCylinder(float x_pos, float y_pos, float z_pos) {
    
    location = new PVector(x_pos, y_pos, z_pos);
    float angle;
    float[] x =new float[cylinderResolution+ 1];
    float[] y =new float[cylinderResolution+ 1];//get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle= (TWO_PI/ cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    parent = createShape(GROUP);
    closedCylinder = createShape();
    closedCylinder.beginShape(QUAD_STRIP);//draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      closedCylinder.vertex(x[i], y[i], 0);
      closedCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    closedCylinder.endShape();

    capUp = createShape();
    capUp.beginShape(TRIANGLE_FAN);//draw the pattern on top
    capUp.vertex(0, 0, 0);
    for (int i = 0; i < x.length; i++) {
      capUp.vertex(x[i], y[i], 0);
    }
    capUp.vertex(x[0], y[0], 0);
    capUp.endShape();

    capDown = createShape();
    capDown.beginShape(TRIANGLE_FAN);//draw the pattern on top
    capDown.vertex(0, 0, cylinderHeight);
    for (int i = 0; i < x.length; i++) {
      capDown.vertex(x[i], y[i], cylinderHeight);
    }
    capDown.vertex(x[0], y[0], cylinderHeight);
    capDown.endShape();

    parent.addChild(closedCylinder);
    parent.addChild(capUp);
    parent.addChild(capDown);
  }
  
  PShape shape() {
    return parent;
  }
}
