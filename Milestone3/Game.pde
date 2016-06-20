import processing.core.PApplet;
import processing.video.*;

//WINDOW dimensions
final int WINDOW_HEIGHT = 600;
final int WINDOW_WIDTH = 800;

//Scores;
float score;
float lastScore;
float moved = 0.015;

//New Layer
PGraphics dataVisualization;
PGraphics topView;
PGraphics scoreView;
PGraphics video;
BarChart  barChart;

//Data visu parameters
HScrollbar scrollBar;
int heightBar = height/5;
long timeInterv = 1000;
long updateTime = 0;

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
final float gravityConstant = 0.05;

//Paramètres box 
Board board;
final float BOARD_HEIGHT = 10;
final float BOARD_WIDTH = 400;
final float BOARD_LENGTH = 400;

//Ball
Ball ball;
final float RADIUS_BALL = 16;

//Image Processing
ImageProcessing imgproc;

PVector rotations;

void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, P3D);
}

void setup() {
  //Initialization of score
  score = 0;
  lastScore = 0;
  heightBar = height/5;
  
  imgproc = new ImageProcessing(new Movie( this, "../data/testvideo.mp4"));
  String []args = {"Camera"};
  PApplet.runSketch(args, imgproc);
  imgproc.getSurface().setVisible(false);
  noStroke();
  ball = new Ball(0, 0, 0, RADIUS_BALL);
  board = new Board(width/2, height/2, -width/2, BOARD_WIDTH, BOARD_HEIGHT, BOARD_LENGTH);

  //Initialisation de la gravité/friction
  gravityForce = new PVector(0, 0, 0);
  friction = new PVector(0, 0, 0);

  dataVisualization = createGraphics(width, heightBar, P2D);
  topView = createGraphics(dataVisualization.height-width/40, 
    dataVisualization.height-width/40, P2D);
  scoreView = createGraphics(dataVisualization.height-width/40, 
    dataVisualization.height-width/40, P2D);

  barChart = new BarChart(dataVisualization.width-topView.width-scoreView.width-width/15, 
    dataVisualization.height- dataVisualization.height/5-dataVisualization.height/20);

  scrollBar = new HScrollbar(topView.width+scoreView.width+width/20, height-width/30, 
    barChart.getWidth(), dataVisualization.height/7);
    
}


void draw() {
  //Setup
  directionalLight(50, 100, 125, 0, -1, 0);
  lights();
  
  //Handle user iteraction
  handleKeys();
  updateScrollBar();
  float tmp_score = 0;
  tmp_score = board.checkCylinderCollision(ball);
  tmp_score += ball.checkEdges(BOARD_WIDTH, BOARD_LENGTH);
  lastScore = (tmp_score != 0) ? tmp_score : lastScore;
  score += tmp_score;
  handleInteraction();


  //Tracer plaque/la Ball
  pushMatrix();
  background(200, 200, 200);
  board.draw();
  ball.draw(BOARD_HEIGHT);
  board.drawPlaceHolder();
  popMatrix();

  //Save last position mouse
  if (locked && !cylinderMode) {
    lastX = mouseX;
    lastY = mouseY;
  }

  //Update chart
 if (System.currentTimeMillis() - updateTime > timeInterv) {
    barChart.addScore((int)score);
    updateTime = System.currentTimeMillis();
  }

  //Draw data visualization
  drawDataVisualization();
  image(dataVisualization, 0, height-dataVisualization.height);
  scrollBar.display();

   //Display Image
  //imgproc.display();
  image(imgproc.getVideo(), 0, 0, 200, 200);
  rotations = imgproc.getAngles();
  
  // Set angles
  if (rotations != null && !cylinderMode) {
    
    float rotationX = checkBorders(newAngles(board.angleX, imgproc.getAngles().x));
    float rotationZ= checkBorders(newAngles(board.angleZ, -imgproc.getAngles().y)) ;

    board.setAngleX(rotationX);
    board.setAngleZ(rotationZ);
  }
}

float newAngles(float prev, float curr){
  float ret = 0;
  if(curr > prev){
    ret = min(curr, prev + moved);
  } else {
    ret = max(curr, prev - moved);
  }
  return ret;
    
}

void updateScrollBar() {
  scrollBar.update();
  barChart.adjustSize(scrollBar.getPos());
}

void drawDataVisualization() {
  drawTopView();
  drawScoreView();
  drawBarChart();
  dataVisualization.beginDraw();
  dataVisualization.background(0);
  dataVisualization.image(topView, width/80, (dataVisualization.height-topView.height)/2);
  dataVisualization.image(scoreView, width/40+topView.width, (dataVisualization.height-scoreView.height)/2);
  dataVisualization.image(barChart.getLayer(), width/20+topView.width+scoreView.width, dataVisualization.height/20);
  dataVisualization.endDraw();
}

void drawBarChart() {
  barChart.display();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(109, 109, 33);

  float radiusEllipse = (PI*board.getCylinderRadius()*board.getCylinderRadius()/
    (BOARD_WIDTH*BOARD_LENGTH*8))*topView.width*topView.height;
  float ballRadius = (PI*RADIUS_BALL*RADIUS_BALL/
    (BOARD_WIDTH*BOARD_LENGTH*8))*topView.width*topView.height;

  // Draw cylinders in topView
  for (PVector cylinder : board.getCylinders()) {
    topView.fill(0, 0, 33);
    topView.ellipse(((cylinder.x+BOARD_WIDTH/2)/BOARD_WIDTH)*topView.width, 
      ((cylinder.z+BOARD_LENGTH/2)/BOARD_LENGTH)*topView.height, 
      radiusEllipse, radiusEllipse);
  }

  // Draw ball in topView
  topView.ellipse(((ball.getX()+BOARD_WIDTH/2)/BOARD_WIDTH)*topView.width, 
    ((ball.getZ()+BOARD_LENGTH/2)/BOARD_LENGTH)*topView.height, 
    ballRadius, ballRadius);
  topView.endDraw();
}

void drawScoreView() {
  scoreView.beginDraw();
  scoreView.background(0, 0, 0);
  textSize(12);
  scoreView.text("Total Score: ", 10, 10);
  scoreView.text(score, 10, 22);
  scoreView.text("Velocity: ", 10, 34);
  scoreView.text(ball.getVelocity().mag(), 10, 46);
  scoreView.text("Last Score: ", 10, 58);
  scoreView.text(lastScore, 10, 70);
  scoreView.endDraw();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT && !cylinderMode) {
      imgproc.cam.pause();
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

void handleKeys() {
  if (keyPressed) {
    if (!cylinderMode) {
      switch(keyCode) {
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

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      cylinderMode = false;
      board.setCylinderMode(false);
      ball.setCylinderMode(false);
      board.setAngleX(lastAngleX);
      board.setAngleZ(lastAngleZ);
      imgproc.cam.play();
    }
  }
}

void handleInteraction() {

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
  if (locked && !cylinderMode && !scrollBar.isMouseOver())
    board.addAngle(lastX, lastY);
}

void mousePressed() {
  //loopingGif.play ();
  if (!scrollBar.isMouseOver())
    locked = true;
  board.addCylinder(map(mouseX, 0, width, -BOARD_LENGTH/2, BOARD_LENGTH/2), 
    map(mouseY, 0, height, -BOARD_WIDTH/2, BOARD_WIDTH/2), ball);
}

void mouseReleased() {
  locked = false;
  //loopingGif.pause ();
}
float checkBorders(float x) {
  if (x > PI/3) {
    return PI/3;
  } else if (x < -PI/3) {
    return -PI/3;
  } else {
    return x;
  }
}
//TODO: Change name tilt + coeff acceleration
void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  if (vitesseY - e < 0) vitesseY = 0;
  else vitesseY -= e;

  board.addTilt(e);
}

void movieEvent(Movie m) {
  m.read();
}