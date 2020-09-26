/**
 * Robot class, 
 * Representing the evil robot
 * @Authors: Alvaro, Pierre, Isis
 **/
 
 class Robot {
   /** A T T R I B U T E S **/
   private PShape robot;
   private float Y_angle = PI/2;
   
   
   /** M E T H O D S **/
   Robot(){
      robot = loadShape("robotnik.obj");
      robot.setTexture(loadImage("robotnik.png"));
      robot.scale(100);
      robot.rotateY(Y_angle);
      robot.rotateX(-PI/2);
   }
   
   public PShape getShape(){
     return robot;
   }
   public void rotate(float angle){
     
     robot.resetMatrix();
     robot.scale(100);
     robot.rotateY( -angle + PI/2);
     robot.rotateX(-PI/2);



     
     
   }
}
