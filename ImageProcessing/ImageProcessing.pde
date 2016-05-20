/*import java.util.*;
 HoughTransform trans;
 
 import processing.video.*;
 Capture cam;
 
 void settings() {
 size(640, 480);
 }
 
 void setup(){
 String[] cameras = Capture.list();
 if (cameras.length == 0) {
 println("There are no cameras available for capture.");
 exit();
 } else {
 println("Available cameras:");
 for (int i = 0; i < cameras.length; i++) {
 println(cameras[i]);
 }
 cam = new Capture(this, cameras[0]);
 cam.start();
 }
 }
 
 void draw(){
 if (cam.available() == true)
 cam.read();
 img = cam.get();
 PImage result1 = sobel(IImage(gaussianBlur(HBSImage(img))));
 trans = new HoughTransform(result1, 4);
 image(result1,0,0);
 trans.displayLines();
 }
 */


import java.util.*;
HoughTransform trans;
PImage board;
QuadGraph graph;
int MAX_AREA, MIN_AREA;

void settings() {
  size(2200, 600);
}

void setup() {
  board = loadImage("data/board1.jpg");
  MAX_AREA = board.width*board.height*200;
  MIN_AREA = 15;
  graph = new QuadGraph();
}

void draw() {
  PImage result = HBSImage(board);
  result = gaussianBlur(result);
  result = IImage(result, 118);
  result = sobel(result);
  trans = new HoughTransform(result);
  image(board, 0, 0);

  trans.displayLines();
  graph.build(trans.getBestCandidates(), result.width, result.height);
  graph.findCycles();
  List<int[]> quads = graph.cycles;
  List<PVector> lines = trans.getBestCandidates();
  image(trans.getHoughImage(), 800, 0);
  image(result, 1400, 0);

  for (int[] quad : quads) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    // (intersection() is a simplified version of the
    // intersections() method you wrote last week, that simply
    // return the coordinates of the intersection between 2 lines)
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);
    PVector c41 = intersection(l4, l1);
    // Choose a random, semi-transparent colour
    if (graph.isConvex(c12, c23, c34, c41) && 
      graph.validArea(c12, c23, c34, c41, MAX_AREA, MIN_AREA) && 
      graph.nonFlatQuad(c12, c23, c34, c41)) {

      Random random = new Random();
      fill(color(min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 50));
      quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
      noStroke();
      fill(255, 69, 0, 255);
      ellipse(c12.x, c12.y, 10, 10);
      ellipse(c23.x, c23.y, 10, 10);
      ellipse(c34.x, c34.y, 10, 10);
      ellipse(c41.x, c41.y, 10, 10);
      break;
    }
  }

  noLoop();
}

public PImage gaussianBlur(PImage src) {
  float[][] kernel = {
    { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};
  return computeConvolution(src, kernel, 99);
}

private PImage computeConvolution(PImage src, float[][] kernel, float weight) {
  PImage resultingImg = createImage(src.width, src.height, ALPHA);
  src.loadPixels();
  for (int y =0; y < src.height; y++) {
    for (int x=0; x < src.width; x++) {
      float conv = 0;
      for (int i = -1; i < 2; i++) {
        int nX = x + i ;
        if (nX < 0)  nX = 0;
        else if (x + i >= src.width)  nX = src.width - 1;
        for (int j = -1; j < 2; j++) {
          int nY = y + j ;
          if (nY < 0) nY = 0;
          else if (nY >= src.height) nY = src.height - 1;
          conv += brightness(src.pixels[nY * src.width +nX]) * kernel[i+1][j+1];
        }
      }

      resultingImg.pixels[y * src.width + x] = color(conv/weight);
    }
  }
  resultingImg.updatePixels();
  return resultingImg;
}


public PImage sobel(PImage img) {
  float[][] hKernel = {
    { 0, 1, 0 }, 
    { 0, 0, 0 }, 
    { 0, -1, 0}};
  float[][] vKernel = {
    { 0, 0, 0 }, 
    {1, 0, -1}, 
    {0, 0, 0 }};

  PImage result = createImage(img.width, img.height, RGB);

  float max = 0;
  img.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int convHKernel = 0;
      int convVKernel = 0;
      for (int i = 0; i <= 2; i++) {
        int uX = x + i - 1;
        if (x + i - 1 < 0) uX = 0;
        else if (x + i - 1 >= img.width) uX = img.width - 1;
        for (int j = 0; j <= 2; j++) {
          int uY = y + j - 1;
          if (y + j - 1 < 0) uY = 0;
          else if (y + j - 1 >= img.height) uY = img.height - 1;
          convHKernel += img.pixels[uY * img.width + uX] * hKernel[i][j];
          convVKernel += img.pixels[uY * img.width + uX] * vKernel[i][j];
        }
      }

      float sum=sqrt(pow(convHKernel, 2) + pow(convVKernel, 2));
      max = max(sum, max);

      if (sum > (int)(max * 0.3f))
        result.pixels[y * img.width + x] = color(255, 255, 255);
      else 
        result.pixels[y * img.width + x] = color(0, 0, 0);
    }
  }
  result.updatePixels();
  return result;
}

public PImage HBSImage(PImage img) {
  PImage result = createImage(img.width, img.height, ALPHA);

  int hueMin = 95;
  int hueMax = 145;

  int satMin = 100;
  int satMax = 256;

  int brightMin = 30;
  int brightMax = 150;

  img.loadPixels();
  int size =  img.width * img.height;
  for (int i = 0; i < size; i++) {

    float h = hue(img.pixels[i]);
    float s = saturation(img.pixels[i]);
    float b = brightness(img.pixels[i]);

    result.pixels[i] = (h >= hueMin && h <= hueMax && 
      s >= satMin && s <= satMax && 
      b >= brightMin && b <= brightMax) ? color(255) : color(0);
  }
  result.updatePixels();
  return result;
}

public PImage IImage(PImage img, int minTreshold) {
  PImage result = createImage(img.width, img.height, ALPHA);
  img.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    float intensity = brightness(img.pixels[i]);
    result.pixels[i]= (intensity >= minTreshold) ? color(255) : color(0);
  }
  result.updatePixels();
  return result;
}

PVector intersection(PVector line1, PVector line2) {
  double d = Math.cos(line2.y)*Math.sin(line1.y) -Math.cos(line1.y)*Math.sin(line2.y);
  double x = (line2.x*Math.sin(line1.y)-line1.x*Math.sin(line2.y))/d;
  double y = (-line2.x*Math.cos(line1.y)+line1.x*Math.cos(line2.y))/d;
  return new PVector((float)x, (float)y);
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      intersections.add(intersection(line1, line2));
    }
  }
  return intersections;
}