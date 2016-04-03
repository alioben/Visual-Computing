public class Board{
  //Cylinder Mode
  boolean cylinderMode = false;
  
  //Constantes
  final float tiltAcceleration=0.01;
  final float TILT_COEFF = 0.01;
  
  //Paramètres box 
  final PVector location;
  final float bHeight;
  final float bWidth;
  final float bLength;
  
  //Tilt paramters
  float angleX, angleZ;
  float titlCoeff = TILT_COEFF;
  
  //Cylinders
  final float cylinderRadius = 20;
  final float cylinderHeight = -60;
  final float cylinderResolution = 40;
  private final ArrayList<Cylinder> cylinders;
  private final ArrayList<PVector> cylinderPositions;
  private final Cylinder placeHolderCylinder;
  
  public Board(float x, float y,  float z, float bwidth, float bheight, float blength){
    this.bHeight = bheight;
    this.bWidth = bwidth;
    this.bLength = blength;
    location = new PVector(x, y, z);
    angleX = 0;
    angleZ = 0;
    cylinders = new ArrayList<Cylinder>();
    cylinderPositions = new ArrayList<PVector>();
    placeHolderCylinder = new Cylinder(cylinderRadius, cylinderHeight, cylinderResolution);
  }
  
  void draw(){
    fill(0, 128, 0);
    float z = location.z;
    float x = location.x;
    float y = location.y;
    if(cylinderMode){
      z = 0;
      x = width/2;
      y = height/2;
    }
    translate(x, y, z);
    rotateX(angleX);
    rotateZ(angleZ);

    fill(0,0,0,128);
    hint(DISABLE_DEPTH_TEST);
    stroke(10);
    box(bWidth, bHeight, bLength);
  
    hint(ENABLE_DEPTH_TEST);
    //Draw cylinders
    for(int i = 0; i < cylinderPositions.size(); i++) {
      Cylinder cylinder = cylinders.get(i);
      PVector position = cylinderPositions.get(i);
      pushMatrix();
      translate(position.x, -bHeight/2, position.z);
      cylinder.draw();
      popMatrix();
    }
  }
  
  void setCylinderMode(boolean c){
    cylinderMode = c;  
  }
  
  void drawPlaceHolder(){
     if(cylinderMode){
      float cx = map(mouseX, 0, width, -bLength/2, bLength/2);
      float cz = map(mouseY, 0, height, -bWidth/2, bWidth/2);
      translate(cx, -bHeight/2, cz);
      placeHolderCylinder.draw();
    }  
  }
  
  void addCylinder(float x, float z, Ball ball){
    if(cylinderMode){
      PVector position = new PVector(x, 0, z);
      float dist = PVector.dist(new PVector(x, 0, z), ball.getLocation());
      if(dist > cylinderRadius + ball.getRadius()) {
        cylinderPositions.add(position);
        cylinders.add(new Cylinder(cylinderRadius, cylinderHeight, cylinderResolution));
      }
    }
  }
  
   void checkCylinderCollision(Ball ball) {
     PVector normal;
    for(PVector cylinderPosition : cylinderPositions) {
      float distanceBallCylinder = PVector.dist(cylinderPosition, ball.getLocation());
      if(distanceBallCylinder <= cylinderRadius + ball.getRadius()) {
        normal = PVector.sub(cylinderPosition, ball.getLocation());
        normal.normalize();
        normal.mult(2 * ball.getVelocity().dot(normal));
        ball.setVelocity(PVector.sub(ball.getVelocity(), normal));
        ball.addLocation(ball.getVelocity());
      }
    }
  }
  
  void addAngle(float lastX, float lastY){
    if(angleX - (mouseY-lastY)*titlCoeff <= PI/3 &&
         angleX - (mouseY-lastY)*titlCoeff >= -PI/3 )
        angleX += -(mouseY-lastY)*titlCoeff;  
    if(board.getAngleZ() + (mouseX-lastX)*titlCoeff <= PI/3 &&
         angleZ + (mouseX-lastX)*titlCoeff >= -PI/3)
        angleZ += (mouseX-lastX)*titlCoeff;
  }
  
  
  void addVelocityY(float v){
    location.y += v;
  }
  
  void addTilt(float e){
    if(titlCoeff - e*tiltAcceleration >= 0) titlCoeff -= e*tiltAcceleration;
    else titlCoeff = 0;  
  }
  
  float getX(){
    return location.x;
  }
  
  float getY(){
    return location.y;
  }
  
  float getZ(){
    return location.z;
  }
  
  float getAngleZ(){
   return angleZ; 
  }
  
  float getAngleX(){
    return angleX;
  }
  
   void setAngleZ(float angle){
     angleZ = angle; 
  }
  
  void setAngleX(float angle){
    angleX = angle;
  }
}