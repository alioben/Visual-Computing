class Cylinder {
  PShape openCylinder = new PShape();
  PShape topCylinder = new PShape();
  PShape bottomCylinder = new PShape();
  
  Cylinder(float cylinderBaseSize, float cylinderHeight, float cylinderResolution) {
    float angle;
    float[] x = new float[(int)cylinderResolution + 1];
    float[] z = new float[(int)cylinderResolution + 1];
    
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      z[i] = cos(angle) * cylinderBaseSize;
    }
    
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);

    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0 , z[i]);
      openCylinder.vertex(x[i], cylinderHeight, z[i]);
    }
    openCylinder.endShape();
    topCylinder = createShape();
    topCylinder.beginShape(TRIANGLE_FAN);
    topCylinder.vertex(0, cylinderHeight, 0);
    for(int i = 0; i < x.length; i++) 
      topCylinder.vertex(x[i], cylinderHeight, z[i]);
    topCylinder.endShape();
    bottomCylinder = createShape();
    bottomCylinder.beginShape(TRIANGLE_FAN);
    bottomCylinder.vertex(0, 0, 0);
    for(int i = 0; i < x.length; i++)
      bottomCylinder.vertex(x[i], 0, z[i]);
    bottomCylinder.endShape(); 
  }
  
  void draw() {
    noStroke();
    fill(150, 150, 150, 250);
    shape(openCylinder);
    shape(topCylinder);
    shape(bottomCylinder);
  }
 
}