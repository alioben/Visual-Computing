import java.util.*;
import processing.video.*;

class ImageProcessing extends PApplet{
  HoughTransform trans;
  PImage img;
  Movie cam;
  PImage board;
  QuadGraph graph;
  int MAX_AREA, MIN_AREA;
  PVector angles;
  TwoDThreeD obj;
  boolean b = true;
  boolean stop = false;
  PGraphics video;

  public ImageProcessing(Movie cam) {
    this.cam = cam;

  }
  void settings(){
    size(680, 480);
  }
  
  void setup(){
    video = createGraphics(640, 480, JAVA2D);
    angles = new PVector(0, 0, 0);
    graph = new QuadGraph();
    obj = new TwoDThreeD(640, 480);
    MAX_AREA = 250000;
    MIN_AREA = 15;
    cam.loop();
  }
  
  void draw() {
    video.beginDraw();
    PImage legoboard = cam.get();
    video.background(255, 255, 255);
    PImage result = HBSImage(deleteNoise(legoboard));
    result = gaussianBlur(result);
    result = IImage(result, 100);
    result = gaussianBlur(result);
    result = sobel(result);
    video.image(legoboard, 0, 0);
    trans = new HoughTransform(result);
    graph.build(trans.getBestCandidates(), result.width, result.height);
    graph.findCycles();
    //video.image(trans.getHoughImage(), 0, 0);
    //video.image(result, 1400, 0);
    List<PVector> corners = drawAndReturnCorners(graph.cycles, trans.getBestCandidates());
    if (corners.size() > 0) {
      List<PVector> sorted = sortCorners(corners);
      angles = obj.get3DRotations(sorted);
    }
    video.endDraw();
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

    int hueMin = 63;
    int hueMax = 162;

    int satMin = 89;
    int satMax = 255;

    int brightMin = 80;
    int brightMax = 174;

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



  List<PVector> drawAndReturnCorners(List<int[]> quads, List<PVector> lines) {
    List<PVector> returned = new ArrayList<PVector>();
    for (int[] quad : quads) {
      // if(quad.length == 4) {
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
      returned.add(c12);
      returned.add(c23);
      returned.add(c34);
      returned.add(c41);
      displayLines(Arrays.asList(l1, l2, l3, l4));
      // Choose a random, semi-transparent colour

      Random random = new Random();
      video.fill(color(min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 
        min(255, random.nextInt(300)), 50));
      video.quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
      video.noStroke();
      video.fill(255, 69, 0, 255);
      video.ellipse(c12.x, c12.y, 10, 10);
      video.ellipse(c23.x, c23.y, 10, 10);
      video.ellipse(c34.x, c34.y, 10, 10);
      video.ellipse(c41.x, c41.y, 10, 10); 

      break;
    }

    return returned;
  }

  private PImage deleteNoise(PImage img) {
    PImage resultingImg = createImage(img.width, img.height, ALPHA);
    img.loadPixels();

    float hueMin = 63;
    float hueMax =  162;

    float satMin =  89;
    float satMax = 255;

    float brightMin =  80;
    float brightMax =  174;

    //List<int[]> tmp = new ArrayList();

    for (int y = 0; y < img.height; y++) {
      int sx = img.width;
      int ex = -1;
      int np = 0;
      for (int x = 0; x < img.width; x++) {
        int i = y*img.width+x;
        float h = hue(img.pixels[i]);
        float s = saturation(img.pixels[i]);
        float b = brightness(img.pixels[i]);
        boolean inrange = ( h >= hueMin && h <= hueMax && 
          s >= satMin && s <= satMax
          && 
          b >= brightMin && b <= brightMax);

        if (inrange && np < 20) {
          sx = x;
          np++;
        }
        resultingImg.pixels[i] = img.pixels[i];
      }

      np = 0;
      for (int x = img.width-1; x >= 0; x--) {
        int i = y*img.width+x;
        float h = hue(img.pixels[i]);
        float s = saturation(img.pixels[i]);
        float b = brightness(img.pixels[i]);
        boolean inrange =( h >= hueMin && h <= hueMax && 
          s >= satMin && s <= satMax && 
          b >= brightMin && b <= brightMax && x < img.width*0.75);

        if (inrange && np < 20) {
          ex = x;
          np++;
        }
      }

      for (int x = 0; x < img.width; x++) {
        int i = y*img.width+x;
        colorMode(HSB, 255);
        if (x > sx && x < ex)
          resultingImg.pixels[i] = color((hueMin+hueMax)/2, (satMin+satMax)/2, (brightMin+brightMax)/2);
        colorMode(RGB, 255);
      }
    }
    resultingImg.updatePixels();
    return resultingImg;
  }

  PVector getAngles() {
    return angles == null ? null : new PVector(angles.x, angles.y, angles.z);
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

  void movieEvent(Movie m) {
    m.read();
  }

  public void displayLines(List<PVector> lines) {
    //Display of the lines
    for (int idx = 0; idx < lines.size(); idx++) {
      /*if (bestCandidates.contains(idx)) {
       
       // first, compute back the (r, phi) polar coordinates:
       int accPhi = (int) (idx / (rDim + 2)) - 1;
       int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
       float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
       float phi = accPhi * discretizationStepsPhi;
       */

      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      float r = lines.get(idx).x;
      float phi = lines.get(idx).y;
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = 600;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = 600;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      video.stroke(255, 0, 0);
      if (y0 > 0) {
        if (x1 > 0)
          video.line(x0, y0, x1, y1);
        else if (y2 > 0)
          video.line(x0, y0, x2, y2);
        else
          video.line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            video.line(x1, y1, x2, y2);
          else
            video.line(x1, y1, x3, y3);
        } else
          video.line(x2, y2, x3, y3);
      }
    }
  }
  
  public PGraphics getVideo() {
    return video;
  }
}