/**
 * Plate class, 
 * Representing the playing board
 * @Authors: Alvaro, Pierre, Isis
 **/
 
 class Plate{
   /** A T T R I B U T E S **/
   private float rx; // Angle of rotation X axis
   private float rz; // Angle of rotation Z axis
   private float rotation_speed;
   private final int plateSize = 1000; 
   
   public static final int plateThickness = 50; 
   public static final float MAX_PLATE_ROT_SPEED = 2.5;
   public static final float MIN_PLATE_ROT_SPEED = 0.4;
   public static final float CHANGE_PLATE_ROT_SPEED = 0.5;
   public static final float LIMIT_ROTATION_ANGLE = PI/3;
   
   
   /** M E T H O D S **/
   /*
   * Plate constructor, initialising playing plate
   */
   Plate(){
     rx = 0;
     rz = 0;
     rotation_speed = 1;
   }
   
   /*
   * Method to draw the plate
   */
   void drawPlate(){
     //pushMatrix();
     noStroke();
     translate(width/2, height/2, 0);
     if (inShiftMode()) {
      rotateX(-PI/2);
     } else {
      rotateX(-rx);
      rotateZ(rz);
     }
     box(plateSize, plateThickness, plateSize);
     //popMatrix();
   }
}
