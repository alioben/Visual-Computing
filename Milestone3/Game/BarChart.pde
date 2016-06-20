public class BarChart{
 
 PGraphics layer;
 int heightBlock, widthBlock;
 float tab[];
 int resize;
 int index; 
 ArrayList<Float> scores;
 float highScore = 1;
 int nbDisp;
 int widthB, heightB;
 final int SIZETAB = 90;
 int TAILLE_MAX;
 
  public BarChart(int widthB, int heightB){
    layer = createGraphics(widthB, heightB, P2D);
    scores = new ArrayList<Float>();
    this.heightB = heightB;
    this.widthB = widthB;
    heightBlock = heightB/30;
    index = 0;
    resize = 0;
     TAILLE_MAX = widthB/20;
     widthBlock = widthB/SIZETAB;
  }
  
  public void addScore(float score){
   if(score > highScore) highScore = score*2;
   //tab[index%SIZETAB] = score;
   scores.add(score);
   //index++;
  }
  
  void drawScore(float score,int xpos){
    int ypos = heightB-heightBlock;
    for(int i = 0; i < maxit(score) ; i += 1){
      //print(widthBlock+" "+heightBlock);
      layer.fill(0, 0 , 255);
      layer.rect(xpos, ypos, widthBlock, heightBlock);
      if(ypos-heightBlock > 0)
        ypos-=heightBlock+1; 
    }
  }
  
  void drawScores(){
    int xpos = -(widthBlock+1);
    int startIndex = max(0,scores.size()-nbDisp);
    for(int i=startIndex; i<scores.size(); i++){
        xpos += widthBlock+1; 
       drawScore(scores.get(i), xpos);
    }
  }
  
  void adjustSize(float factor){
    if(factor>0 && factor<1){
       nbDisp =(int) (10 + (1-factor)*SIZETAB);
      /*for(int i =resize;i<sizeTab;i++)
        tab[i]=0;
        */
    widthBlock = (int)(widthB/nbDisp);
    }
  }
  
  void display(){
    layer.beginDraw();
    layer.noStroke();
    layer.background(238,235,201);
    drawScores();
    layer.fill(255,0,0);
    layer.endDraw();
  }
  
  PGraphics getLayer(){
    return layer;
  }
  int getWidth(){
    return widthB;
  }
  int getHeight(){
    return heightB;
  }
  int maxit(float score){
    int ret = (int)Math.max(Math.min(30,(score*30)/highScore),1);
    return ret;
  }
}