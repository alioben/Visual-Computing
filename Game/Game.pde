//Some constants
final float VITESSE_Y = 3;

//Last position
float lastX, lastY;
float lastAngleX, lastAngleZ;

//Angle Rotation
boolean locked = false;

//Vitesse mouvement
float vitesseY = VITESSE_Y;

//Paramètre engine
PVector gravityForce;
PVector friction;
boolean cylinderMode = false;

// constante mouvement
final float normalForce = 1;
final float mu = 0.01;
final float frictionMagnitude = normalForce * mu;
final float gravityConstant = 0.07;
  
//Paramètres box 
Board board;
final float BOARD_HEIGHT = 5;
final float BOARD_WIDTH = 400;
final float BOARD_LENGTH = 400;

//Ball
Ball ball;
final float RADIUS_BALL = 16;

void settings() {
  size(540, 540, P3D);
}

void setup() {
  noStroke();
  ball = new Ball(width/2, 0, -BOARD_LENGTH/2, RADIUS_BALL);
  board = new Board(width/2, height/2, -width/2, BOARD_WIDTH, BOARD_HEIGHT, BOARD_LENGTH);
  
  //Initialisation de la gravité/friction
  gravityForce = new PVector(0, 0, 0);
  friction = new PVector(0, 0, 0);
}

void draw(){
   
 
  //Setup
  directionalLight(50, 100, 125, 0, -1, 0);
  lights();
  background(255,255,255);
  
  //Handle user iteraction
  handleKeys();
  board.checkCylinderCollision(ball);
  ball.checkEdges(BOARD_WIDTH, BOARD_LENGTH);
  handleInteraction();
  
  
  //Tracer plaque/la Ball
  pushMatrix();
  background(200,200,200);
  board.draw();
  ball.draw(BOARD_HEIGHT);
  board.drawPlaceHolder();
  popMatrix();
 
  //Save last position mouse
  if(locked && !cylinderMode){
    lastX = mouseX;
    lastY = mouseY;
  }
}

void keyPressed(){
  if(key == CODED) {
    if(keyCode == SHIFT && !cylinderMode) {
      cylinderMode = true;
      board.setCylinderMode(true);
      ball.setCylinderMode(true);
      lastAngleX = board.getAngleX(); 
      lastAngleZ = board.getAngleZ();
      board.setAngleX(-PI/2); 
      board.setAngleZ(0);
    }
  }
}

void handleKeys(){
  if(keyPressed){
      if (!cylinderMode){
        switch(keyCode){
          case UP:
            board.addVelocityY(-vitesseY);
            break;
          case DOWN:
            board.addVelocityY(vitesseY);
            break;
        }
      }
  }
}

void keyReleased(){
  if(key == CODED) {
    if(keyCode == SHIFT){
      cylinderMode = false;
      board.setCylinderMode(false);
      ball.setCylinderMode(false);
      board.setAngleX(lastAngleX);
      board.setAngleZ(lastAngleZ);
   }
 }
}

void handleInteraction(){
  //Update gravity force
  gravityForce.x = sin(board.getAngleZ())*gravityConstant;
  gravityForce.z = -sin(board.getAngleX())*gravityConstant;
  
  //Update friction vector
  friction = ball.getVelocity().get();
  friction.mult(-1);
  friction.normalize();
  friction.mult(frictionMagnitude);
  
  //Update location Ball
  ball.update(gravityForce, friction);
}

void mouseDragged() {
  if(locked && !cylinderMode)
    board.addAngle(lastX, lastY);
}

void mousePressed(){
  //loopingGif.play ();

  locked = true;
  board.addCylinder(map(mouseX, 0, width, -BOARD_LENGTH/2, BOARD_LENGTH/2), 
                    map(mouseY, 0, height, -BOARD_WIDTH/2, BOARD_WIDTH/2), ball);
}

void mouseReleased(){
  locked = false;
  //loopingGif.pause ();

}

//TODO: Change name tilt + coeff acceleration
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  
  if(vitesseY - e < 0) vitesseY = 0;
  else vitesseY -= e;
 
   board.addTilt(e);
}