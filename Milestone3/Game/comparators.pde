import java.util.*;
 static class CWComparator implements Comparator<PVector> {
  PVector center;
  public CWComparator(PVector center) {
    this.center = center;
  }
  @Override
    public int compare(PVector b, PVector d) {
    if (Math.atan2(b.y-center.y, b.x-center.x)<Math.atan2(d.y-center.y, d.x-center.x))
      return -1;
    else return 1;
  }
}

  public static List<PVector> sortCorners(List<PVector> quad) {
    PVector a = quad.get(0);
    PVector b = quad.get(2);
    PVector center = new PVector((a.x+b.x)/2, (a.y+b.y)/2);
    Collections.sort(quad, new CWComparator(center));

    PVector origin = new PVector(0, 0);
    float distToOrigin = Float.MAX_VALUE;

    for (PVector p : quad) {
      if (p.dist(origin) < distToOrigin) {
        distToOrigin = p.dist(origin);
      }
    }
    while (quad.get(0).dist(origin) != distToOrigin) {
      Collections.rotate(quad, 1);
    }
    return quad;
  }