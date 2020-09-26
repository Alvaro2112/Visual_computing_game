/**
 * Game class, main class which draws and allows to play the game
 * @Authors: Alvaro, Pierre, Isis
 **/

/** VIDEO PATH **/

public static final String PATH_TO_VIDEO = "/home/sapino/Documents/EPFL/InfoVisu/projet_visual_computing/Assignments/assignment12/Game/testvideo.avi";

/** GAME ATTRIBUTES **/
private CylinderSystem cs;
private Sphere sphere;
private Plate plate;
private Robot robot;
private double angleInRadians;
private PVector Robot_center = new PVector(0, 0, 0);
PImage img;

BonusParticleSystem bps;
public static boolean win;

public PGraphics gameSurface;
public PGraphics topView;
public PGraphics scoreBoard;
public PGraphics barChart;
private HScrollbar scrollBar;

int seconds;
int SIZE_RECT_BAR_CHART = 10;

ArrayList<int[]> coordRectScore = new ArrayList<int[]> ();

float depth = 2000;
int floatView_size;
private float score = 0;
private float last_score = 0;
private int last_cylinders_hit = 0; //previous number of removed cylinder

/** INTERACTION WITH ENVIRONMENT **/
ImageProcessing imgproc;

void settings() {
  System.setProperty("jogl.disable.openglcore", "true");
  size(displayWidth - 100 , displayHeight - 100, P3D);
}

void setup() {
  /*GRAPHIAL FRAMES*/
  floatView_size = height/4;
  gameSurface = createGraphics(width, height - floatView_size, P3D);
  topView = createGraphics(floatView_size, floatView_size, P2D);
  scoreBoard = createGraphics(floatView_size, floatView_size, P2D);
  barChart = createGraphics(width - 2*floatView_size, floatView_size, P2D);
  
  /*OBJECTS*/
  scrollBar = new HScrollbar( 2*floatView_size + 10 , height - 35, width - 2*floatView_size - 20, 15);  //its position depends on BarChart
  cs = new CylinderSystem();
  bps = new BonusParticleSystem(new PVector(width/2, height/4));
  sphere = new Sphere();
  plate = new Plate();
  robot = new Robot();

  seconds = 0;

  /*IMAGE PROC*/
  imgproc = new ImageProcessing();
  String[] args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);

}

void draw() {
  /* DRAWING THE GAME*/

  if(imgproc.getRotation() != null){
      drawGame(imgproc.getRotation());
  }else{
      drawGame(new PVector(0,0,0));
  }

  drawTopView();
  drawScoreBoard();
  drawBarChart();
  drawScrollBar();

}

void drawScrollBar(){
  scrollBar.update();
  scrollBar.display();  
}

void drawGame(PVector rotations) {
  if (win) {
    gameSurface.beginDraw();
    gameSurface.background(0);
    bps.addParticle();
    bps.run();
    gameSurface.endDraw();
  } else {
    gameSurface.beginDraw();

    seconds = (int) (frameCount/frameRate);

    lights();
    background(100);

    gameSurface.translate(gameSurface.width/2, gameSurface.height/2, 0);

    angleInRadians =  Math.atan2(-sphere.location.z+Robot_center.z, sphere.location.x-Robot_center.x);

    if (inShiftMode()) {
      gameSurface.rotateX(-PI/2);
    } else {
      gameSurface.rotateX(-plate.rx);
      gameSurface.rotateZ(plate.rz);
    }
    
  
    
    if(sphere.cylinders_hit - last_cylinders_hit != 0){ //Only updates last score when a new cylinder has been touched
    last_cylinders_hit = sphere.cylinders_hit;
    last_score = score;
    }
    score = sphere.sphere_score - cs.cylinder_score;
    
    for (Cylinder c : cs.cylinders) {
      fill(255, 255, 255);
      c.display();
      if (c.isCenter && !inShiftMode()) {
        gameSurface.pushMatrix();
        gameSurface.translate(c.center.x, c.center.y, c.center.z);
        gameSurface.rotateX(-PI/2);
        gameSurface.shape(robot.getShape(), 0, 0);
        Robot_center = c.center;
        gameSurface.popMatrix();
      }
    }

    fill(255, 255, 255);
    robot.rotate((float)angleInRadians);

    updatePlate(rotations);

    plate.drawPlate();
    sphere.update(plate);
    sphere.checkSpherePosition(plate);
    sphere.checkCollisionWithCylinder(cs);
    sphere.drawSphere();

    if (cs.cylinders.size()!=0) {
      cs.run();
    }

    gameSurface.endDraw();
  }
  image(gameSurface, 0, 0);
}

void drawBarChart(){
  barChart.beginDraw();
  int middleBarChart = floatView_size/2;
  float normalisedScrollBPos = scrollBar.getPos() - 0.5;
  float rectangleWidth = SIZE_RECT_BAR_CHART + normalisedScrollBPos * SIZE_RECT_BAR_CHART;
  for(int i = 0; i < abs(score); i+=SIZE_RECT_BAR_CHART){
    int coord[] = {seconds, score > 0 ? middleBarChart - i : middleBarChart + SIZE_RECT_BAR_CHART + i};
    coordRectScore.add(coord);
  }
  barChart.background(20, 40, 75);
  barChart.fill(170, 120, 30);
  for (int[] coords: coordRectScore){
    barChart.rect(coords[0] * rectangleWidth, coords[1], rectangleWidth, SIZE_RECT_BAR_CHART);
  }
  barChart.endDraw();
  image(barChart, 2*floatView_size, height - floatView_size);
}

void drawTopView() {
  topView.beginDraw();
  topView.background(3, 98, 127);
  topView.fill(10, 10, 220);
  topView.ellipse(sphere.location.x * floatView_size/plate.plateSize + floatView_size / 2, sphere.location.z* floatView_size/plate.plateSize + floatView_size / 2, 20, 20);
  topView.fill(250, 250, 250);

  if (cs != null) {
    for (Cylinder c : cs.cylinders) {
      if (c.isCenter) {      
        topView.fill(255, 20, 20);
        topView.ellipse(c.center.x* floatView_size/plate.plateSize+ floatView_size / 2, c.center.z * floatView_size/plate.plateSize+ floatView_size / 2, 20, 20);  //plein de magic value mais je sais pas faire autrement
        topView.fill(250, 250, 250);
      } else {
        topView.ellipse(c.center.x* floatView_size/plate.plateSize+ floatView_size / 2, c.center.z * floatView_size/plate.plateSize+ floatView_size / 2, 20, 20);  //plein de magic value mais je sais pas faire autrement
      }
    }
  }
  topView.endDraw();
  image(topView, 0, height - floatView_size);
}

void drawScoreBoard() {
  scoreBoard.beginDraw();
  scoreBoard.noFill();
  scoreBoard.rect(floatView_size/15, floatView_size/15, floatView_size - floatView_size/10, floatView_size - floatView_size/10);
  String velocity = String.format("%.2f", sphere.velocity.mag());
  String scorex = String.format("%.2f", score);
  String previousScore = String.format("%.2f", last_score);
  textSize(22);
  text("Total score:\n " + scorex, floatView_size + floatView_size/10, height-floatView_size + floatView_size/4);
  text("Velocity: \n "+ velocity, floatView_size + floatView_size/10, height-floatView_size + 2*floatView_size/4);
  text("Last score: \n" + previousScore, floatView_size + floatView_size/10, height-floatView_size + 3*floatView_size/4);

  scoreBoard.endDraw();
  scoreBoard.background(64, 224, 208);

  image(scoreBoard, floatView_size, height - floatView_size);
}
/*
 * On mouse wheel should change rotation speed of the plate
 */
void mouseWheel(MouseEvent event) {
  if (!inShiftMode()) {
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
// void mouseDragged() {
//   if (!inShiftMode() && !scrollBar.isLocked()) {
//     plate.rx = map(mouseY, 0, gameSurface.height, -PI/3, PI/3) * plate.rotation_speed;
//     if (plate.rx > Plate.LIMIT_ROTATION_ANGLE) {
//       plate.rx = Plate.LIMIT_ROTATION_ANGLE;
//     } else if ( plate.rx < -Plate.LIMIT_ROTATION_ANGLE) {
//       plate.rx = -Plate.LIMIT_ROTATION_ANGLE;
//     }
//     plate.rz = map(mouseX, 0, gameSurface.width, -PI/3, PI/3)  * plate.rotation_speed;
//     if (plate.rz > Plate.LIMIT_ROTATION_ANGLE) {
//       plate.rz = Plate.LIMIT_ROTATION_ANGLE;
//     } else if ( plate.rz < -Plate.LIMIT_ROTATION_ANGLE) {
//       plate.rz=-Plate.LIMIT_ROTATION_ANGLE;
//     }
//   }
// }

void updatePlate(PVector rot){
  if (!inShiftMode() && !scrollBar.isLocked()) {
    plate.rx = rot.x; //TODO

    if (plate.rx > Plate.LIMIT_ROTATION_ANGLE) {
      plate.rx = Plate.LIMIT_ROTATION_ANGLE;
    } else if ( plate.rx < -Plate.LIMIT_ROTATION_ANGLE) {
      plate.rx = -Plate.LIMIT_ROTATION_ANGLE;
    }
       //println(plate.rx*180/PI);

    plate.rz = rot.y;// - PI;//rot.z; //rotation speed? !!!!!!!!!!!!!!!!!!!!!!!!!!

    if (plate.rz > Plate.LIMIT_ROTATION_ANGLE) {
      plate.rz = Plate.LIMIT_ROTATION_ANGLE;
    } else if ( plate.rz < -Plate.LIMIT_ROTATION_ANGLE) {
      plate.rz=-Plate.LIMIT_ROTATION_ANGLE;
    }
     //println(plate.rz*180/PI);


  }
}

/*
 * Method to signal Shift mode
 */
boolean inShiftMode() {
  return (keyPressed && keyCode == SHIFT);
}

/*
 * Method reacting on press of the mouse
 * If in Shift mode, adds a cylinder acting as the center 
 * where the bad guy is
 * Adds it only if the position clicked by the user is validgit 
 */
void mousePressed() {
  if (mouseButton == LEFT && inShiftMode()) {
    
    sphere.sphere_score = 0;
    sphere.cylinders_hit = 0;
    score = 0;
    last_score = 0;
    last_cylinders_hit = 0;
    
    Cylinder toadd = new Cylinder(new PVector((mouseX-(gameSurface.width/2)), -Cylinder.cylinderHeight, (mouseY-(gameSurface.height/2))));
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
