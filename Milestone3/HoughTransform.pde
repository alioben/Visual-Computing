import java.util.*;

public class HoughTransform{
  
  PImage src;
  final int tresholdVotes = 200;
  List<Integer> bestCandidates;
  List<PVector> bestLines;
  int[] accumulator;
  int phiDim, rDim;
  final float discretizationStepsPhi = 0.06f;
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
          
            int r = (int)((x * tabCos[phiStep]) + (y * tabSin[phiStep]));
             int maxval = (rDim - 1) /2;
             if (-maxval <= r && r <= maxval)
                  r += maxval;
            accumulator[(phiStep) * (rDim+2) + (r)] += 1;
            
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
            //float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
            //float phi = accPhi * discretizationStepsPhi;
            bestCandidates.add(idx);
           // bestLines.add(new PVector(r, phi));
          }
        }
      }
    }
    
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    
   for (int i = 0; i < min(6, bestCandidates.size()); i++) {
        int idx = bestCandidates.get(i);
        int accPhi = (int) (idx / (rDim + 2)) ;
        int accR = idx - accPhi*(rDim + 2);
        float r = (accR - (rDim -1) / 2.)* discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;
        bestLines.add(new PVector(r, phi));
    }
    
    
  }
  
  public List<PVector> getBestCandidates(){   
    return bestLines;
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