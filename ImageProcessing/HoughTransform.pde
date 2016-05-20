import java.util.*;

public class HoughTransform{
  
  PImage src;
  final int tresholdVotes = 200;
  List<Integer> bestCandidates;
  List<PVector> bestLines;
  int[] accumulator;
  int phiDim, rDim;
  final float discretizationStepsPhi = 0.04f;
  final float discretizationStepsR = 2.5f;
  float[] tabSin;
  float[] tabCos;
  
  public HoughTransform(PImage img){
    this.src = img;
    
    phiDim = (int)(Math.PI / discretizationStepsPhi);
    rDim = (int)(((src.width + src.height) * 2 + 1) / discretizationStepsR);
    
    bestCandidates = new ArrayList<Integer>();
    bestLines = new ArrayList<PVector>();
    
    tabSin = new float[phiDim];
    tabCos = new float[phiDim];
    // pre-compute the sin and cos values
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
    
    hough();
  }
 
  private void hough(){

    // our accumulator (with a 1 pix margin around)
    accumulator = new int[(phiDim + 2) * (rDim + 2)];
  
    for (int y = 0; y < src.height; y++) {
     for (int x = 0; x < src.width; x++) {
      // Are we on an edge?
      if (brightness(src.pixels[y * src.width + x]) != 0) {
        for (int phiStep = 0; phiStep < phiDim; ++phiStep) {
          
            float r = (x * tabCos[phiStep]) + (y * tabSin[phiStep]);
            r += (rDim - 1) * 0.5; 
            accumulator[(phiStep+1) * (rDim+2) + (int)(r+1)] += 1;
            
          }
      }
     }
    }    
    
    // size of the region we search for a local maximum
    int neighbourhood = 30;
    // only search around lines with more that this amount of votes
    // (to be adapted to your image)
    int minVotes = 200;
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate=true;
          // iterate over the neighbourhood
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
              if (accR+dR < 0 || accR+dR >= rDim) continue;
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                // the current idx is not a local maximum!
                bestCandidate=false;
                break;
              }
            }
            if (!bestCandidate) break;
          }
          if (bestCandidate) {
            float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
            float phi = accPhi * discretizationStepsPhi;
            bestCandidates.add(idx);
            bestLines.add(new PVector(r, phi));
          }
        }
      }
    }
    
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    
  }
  
  public List<PVector> getBestCandidates(){   
    return bestLines;
  }
  
  public void displayLines(){
    //Display of the lines
    for (int idx = 0; idx < accumulator.length; idx++) {
      if (bestCandidates.contains(idx)) {
  
        // first, compute back the (r, phi) polar coordinates:
        int accPhi = (int) (idx / (rDim + 2)) - 1;
        int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
        float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;
  
        // Cartesian equation of a line: y = ax + b
        // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
        // => y = 0 : x = r / cos(phi)
        // => x = 0 : y = r / sin(phi)
        // compute the intersection of this line with the 4 borders of
        // the image
        int x0 = 0;
        int y0 = (int) (r / sin(phi));
        int x1 = (int) (r / cos(phi));
        int y1 = 0;
        int x2 = src.width;
        int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
        int y3 = src.width;
        int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
        // Finally, plot the lines
        stroke(255, 0, 0);
        if (y0 > 0) {
          if (x1 > 0)
            line(x0, y0, x1, y1);
          else if (y2 > 0)
            line(x0, y0, x2, y2);
          else
            line(x0, y0, x3, y3);
        } else {
          if (x1 > 0) {
            if (y2 > 0)
              line(x1, y1, x2, y2);
            else
              line(x1, y1, x3, y3);
          } else
            line(x2, y2, x3, y3);
        }
      }
    } 
  }
  
  public PImage getHoughImage(){
    PImage result = createImage(rDim +2, phiDim +2, ALPHA);
    for(int i = 0; i < accumulator.length; i++)
      result.pixels[i] = color(min(accumulator[i], 255));
    result.resize(600,600);
    result.updatePixels();
    return result;
  }
  
  
}