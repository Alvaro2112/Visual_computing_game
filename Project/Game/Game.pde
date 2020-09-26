ParticleSystem ps;
float depth = 2000;
float rx = 0;
float rz = 0;
float old_rx = 0;
float old_rz = 0;
boolean shift = false;
ArrayList<Cylinder> Cylinders = new ArrayList<Cylinder>();




public final int xBox = 1000;
public final int yBox = 50;


Sphere sphere;

void settings() {
  size(500, 500, P3D);
}
void setup() {
  ps = new ParticleSystem();
  sphere = new Sphere();
  noStroke();
}
void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  //directionalLight(201, 226, 255, 1, 1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);


  if (shift) {

    directionalLight(201, 226, 255, 1, 0, 1);
    rotateX(-PI/2);
  } else {

    directionalLight(201, 226, 255, 1, 1, 0);
    rotateX(-rx);
    rotateZ(rz);

    sphere.update(rx, rz);
  }
  box(xBox, yBox, xBox);

  for (int i = 0; i < ps.particles.size(); i++) {

    translate(ps.particles.get(i).center.x, ps.particles.get(i).center.y, ps.particles.get(i).center.z);
    rotateX(-PI/2);
    shape(ps.particles.get(i).shape(), 0, 0);
    rotateX(PI/2);
    translate(-ps.particles.get(i).center.x, -ps.particles.get(i).center.y, -ps.particles.get(i).center.z);
  }

  sphere.checkCylinders();
  sphere.checkEdges();
  sphere.display();
  if (ps.particles.size()!=0) {
    ps.run();
  }

  translate(mouseX, mouseY, 0);
}

float speed = 1;
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  speed -=  e;
  if (speed > 1.4) { 
    speed = 1.4;
  } else if (speed <-3) {
    speed = -3;
  }
  if (speed < 0) {
    speed = 1/speed;
  }
}

void mouseMoved() {
  rx = map(mouseY, 0, height, -PI/3, PI/3) * speed;
  if (rx > PI/3) {
    rx = PI/3;
  } else if ( rx < -PI/3) {
    rx=-PI/3;
  }
  rz = map(mouseX, 0, width, -PI/3, PI/3)  * speed;
  if (rz > PI/3) {
    rz = PI/3;
  } else if ( rz < -PI/3) {
    rz=-PI/3;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shift = true; 
      old_rx = rx; 
      old_rz = rz;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shift = false; 
      rx = old_rx; 
      rz = old_rz;
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT && shift) {
    if (Position_Check(new PVector((mouseX-(width/2))*4.2, -Cylinder.cylinderHeight, (mouseY-(height/2))*4.2))) {
      ps = new ParticleSystem(new PVector((mouseX-(width/2))*4.2, -Cylinder.cylinderHeight, (mouseY-(height/2))*4.2));
    }
  }
}


void mouseDragged() {
  if (!shift && mouseY < 650) {
    rx += (mouseX - pmouseX)/100f * speed; 
    if ((rx > PI/3)) {
      rx = PI/3;
    } else if ((rx < -PI/3)) {
      Cylinders.add(new Cylinder(new PVector((mouseX-(width/2))*4.2, -Cylinder.cylinderHeight, (mouseY-(height/2))*4.2)));
      rx = - PI/3;
    }
    rz += (mouseY - pmouseY)/100f * speed; 
    if ((rz > PI/3)) {
      rz = PI/3;
    } else if ((rz < -PI/3)) {
      rz = - PI/3;
    }
  }
}

boolean Position_Check(PVector position) {

  for (Cylinder p : ps.particles) {
    if (p.center.dist(position) < 2 * Cylinder.cylinderBaseSize ) {
      return false;
    }
  }

  if (position.x <= -xBox/2 + Cylinder.cylinderBaseSize || position.x >= xBox/2  -Cylinder.cylinderBaseSize || position.z <= -xBox/2 + Cylinder.cylinderBaseSize || position.z >= xBox/2 - Cylinder.cylinderBaseSize) {
    return false;
  } 

  if (position.dist(sphere.location) < Cylinder.cylinderBaseSize + sphere.RADIUS) {
    return false;
  }


  return true;
}
