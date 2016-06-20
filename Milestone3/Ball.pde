public class Ball{
  private final float radius;
  private final PVector location;
  private  PVector velocity;
  private boolean cylinderMode = false;
  
  public Ball(float x, float y, float z, float radius){
    location = new PVector(x,y,z);
    velocity = new PVector(0, 0, 0);
    this.radius = radius;
  }
  
  void addVelocityY(float v){
    location.y += v;
  }
  
  void draw(float bHeight){
    pushMatrix();
    translate(ball.getX(), -bHeight/2-ball.getRadius(), ball.getZ());
    noStroke();
    fill(150, 150, 150);
    sphere(radius);
    popMatrix();
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
  
  float getRadius(){
    return radius;
  }
  
  float checkEdges(float bWidth, float bLength){
    float score = 0;
    if(location.x > bWidth/2-radius) {
      score = -(ball.getVelocity().mag()*0.1);
      location.x = bWidth/2-radius;
      velocity.x *= -1;
    }
    else if(location.x < -bWidth/2+radius) {
       score = -(ball.getVelocity().mag()*0.1);
      location.x = -bWidth/2+radius;
      velocity.x *= -1;
    }
    if(location.z > bLength/2-radius) {
       score = -(ball.getVelocity().mag()*0.1);
      location.z = bLength/2-radius;
      velocity.z *= -1;
    }
    else if(location.z < -bLength/2+radius) {
       score = -(ball.getVelocity().mag()*0.1);
      location.z = -bLength/2+radius;
      velocity.z *= -1;
    }
    return score;
  }
  
  void update(PVector gravityForce, PVector friction){
    if(!cylinderMode){
      velocity.add(gravityForce);
      velocity.add(friction);
      location.add(velocity);
    }
  }
  
  void setCylinderMode(boolean c){
    cylinderMode = c;
  }
  
  PVector getVelocity(){
    return velocity;
  }
  
  PVector getLocation(){
    return location;
  }
  void addLocation(PVector v){
   this.location.add(v); 
  }
  void setVelocity(PVector velocity){
   this.velocity.set(velocity); 
  }
}