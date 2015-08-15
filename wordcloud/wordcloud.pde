import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Collection;
import java.util.Comparator;
import java.util.Collections;
ArrayList<TermForce> actu;
Model [] modeles= new Model[8];
String BASE="Base";
Table tableEssay1;
Table tableEssay2;
Table tableEssay3;
Table tableEssay4;
Table tableEssay5;
Table tableEssay6;
Table tableEssay7;
Table tableEssay8;
boolean loading=false;
int xbase=100,ybase=100;
int indiceActu=4;
String labelActuel=BASE;
void setup(){
	tableEssay1 = loadTable("TermConcept_Essay1.csv");
	tableEssay2 = loadTable("TermConcept_Essay2.csv");
	tableEssay3 = loadTable("TermConcept_Essay3.csv");
	tableEssay4 = loadTable("TermConcept_Essay4.csv");
	tableEssay5 = loadTable("TermConcept_Essay5.csv");
	tableEssay6 = loadTable("TermConcept_Essay6.csv");
	tableEssay7 = loadTable("TermConcept_Essay7.csv");
	tableEssay8 = loadTable("TermConcept_Essay8.csv");
        Table modelLoad = loadTable("ModelTest.csv");
        
        HashMap<String,Float> essai = new HashMap<String,Float>();
        for (int i=0;i<8;i++) {
          modeles[i]=new Model();
        }
// Putting key-value pairs in the HashMap        
        for (TableRow row : modelLoad.rows()) {
            String name = row.getString(0);
            String label = row.getString(1);
            ArrayList<Float> list= new ArrayList();
            for (int k=2;k<33;k++)
            {
              list.add(row.getFloat(1));
            }
            if(name.equals("Essay1")){ modeles[0].put(label,list); }          
            if(name.equals("Essay2")){ modeles[1].put(label,list); }
            if(name.equals("Essay3")){ modeles[2].put(label,list); }
            if(name.equals("Essay4")){ modeles[3].put(label,list); }
            if(name.equals("Essay5")){ modeles[4].put(label,list); }
            if(name.equals("Essay6")){ modeles[5].put(label,list); }
            if(name.equals("Essay7")){ modeles[6].put(label,list); }
            if(name.equals("Essay8")){ modeles[7].put(label,list); }
        }
        size(800,800);
        

        completeActu=makeComplex (tableEssay1,modeles[0]);
        completeActu=sortAndOrder(completeActu);
        complete=select(sortAndOrder(completeActu),500);
        calculateFontSize(complete);
        arrange(complete);
        actu=complete.get(BASE);
        println(tableEssay1.getColumnCount());
        
        
      
      }
      HashMap<String,ArrayList<TermForce> > complete;
      HashMap<String,ArrayList<TermForce> > completeActu;
      int maxiXounter=1;
      int maxi=500;
      void keyPressed() {
        complete=select(completeActu,maxi);
        maxi-=50;
        maxi=max(50,maxi);
        calculateFontSize(complete);
        arrange(complete);
        if(maxiXounter>4){
          actu=complete.get(BASE);
          maxiXounter=1;
        }
        else{
          actu=complete.get(""+maxiXounter);
          maxiXounter++; 
        }
        
        
        
      }
      void draw(){
        background(255);
        for (TermForce term:actu){
          term.display();
        }
        if (mousePressed) {
          calculate(mouseX,mouseY,750,10);
        }
        
        drawButtons();

        if(loading){ 
          writeButton("Loading",width/2,height/2,true,true,sizeButtonW, sizeButtonH,18);
        }
        
        drawSizer();
      }
      
      int actualEssay=1;
void drawSizer(){
      stroke(1);
        String sizeStr[]=new String[]{"10","50","100","250","500"};
        for (int i=0;i<5;i++){
          int lin=ybase+20+28*i;
          line(xbase-5, lin,xbase+15, lin);
          textSize(10);
          text(sizeStr[i],xbase+18,lin+2);
        }
        fill(0);
        rect(xbase, ybase, 10, 150, 7);
        fill(255);
        rect(xbase-5, ybase+20+28*indiceActu-5, 20, 10, 7);
        

}
void drawButtons(){
  for (int y=1;y<9;y++){
    drawButton(y,actualEssay==y);
  }  
  int sizeButtonW=70;
int sizeButtonH=40;
   int y=0;
   int x=5;
  for (String label : complete.keySet()){
    if (y>700){
      y=0;x+=sizeButtonW/2+2;
    }
    y+=sizeButtonH+2;
    
    writeButton(label,x,y,true,overRect(x,y,sizeButtonW/2,sizeButtonH),sizeButtonW/2, sizeButtonH,11);
  }
}      
void calculateFontSize(HashMap<String,ArrayList<TermForce> > arranging) {
  for (String label : arranging.keySet()) {
      ArrayList<TermForce> bases=arranging.get(label);
      bases.get(0).size.fontMax=max(11,map(bases.size(),500,1,14,36));
  }
  
  
}
int windowSize=30,beginWindow=10,endWindows=beginWindow+windowSize;
int loopH=1;
void calculate(int mouseX,int mouseY,int x,int y){
  if (mouseX<x){
    return;
  }
  beginWindow=(mouseY-y)/loopH;
  
  if (beginWindow<0){
    beginWindow=0;
  }
  endWindows=beginWindow+windowSize;
  if(endWindows>=completeActu.get(BASE).size())
  {
    endWindows=completeActu.get(BASE).size();
    beginWindow=endWindows-windowSize;
  }
}

void arrange(HashMap<String,ArrayList<TermForce> > arranging) {
     
    float cx=width/2,cy=height/2;
    float R=0.0,dR=0.0008,theta=0.0,dTheta=0.04;
    for (String label : arranging.keySet()) {
      R=0.0;
      theta=0.0;
      ArrayList<TermForce>  bases = arranging.get(label);
      ArrayList<TermForce> arrayCalcul=new ArrayList();
      for(TermForce arrange:bases){
        arrange.calculateValue();
        arrange.calculateDisplay();
        do{
          arrange.x=(int)(cx+R*cos(theta));
          arrange.y=(int)(cy+R*sin(theta));
          
          theta+=dTheta;
          R+=dR;
        }while(check(arrayCalcul,arrange));
        arrayCalcul.add(arrange);
      }
      
    }

}

boolean check(ArrayList<TermForce> checks, TermForce toCheck){
  if(toCheck.checkLimit(0,0,width,height)){
    return true;
  }
  for(TermForce onCheck:checks){
    if(toCheck.intersect(onCheck)){
      return true;
    }
  }

  return false;
}

HashMap<String,ArrayList<TermForce> > select(HashMap<String,ArrayList<TermForce> > arranging,int sized) {
   HashMap<String,ArrayList<TermForce> > termeSize = new HashMap<String,ArrayList<TermForce> >();
    //respect same order for all
    for (String label : arranging.keySet()) {
      ArrayList<TermForce> labeled=arranging.get(label);
      ArrayList<TermForce> labelCloneFilter=new ArrayList();
      int counter=0;
      
      for(int i=0;i<labeled.size();i++){
            TermForce force=labeled.get(i);
            if(counter++<sized){
              labelCloneFilter.add(force);
            }
      }
      
      termeSize.put(label,labelCloneFilter);
     
    }
    return termeSize;
}  
HashMap<String,ArrayList<TermForce> > sortAndOrder(HashMap<String,ArrayList<TermForce> > arranging) {
   HashMap<String,ArrayList<TermForce> > termeSize = new HashMap<String,ArrayList<TermForce> >();
    //respect same order for all
    for (String label : arranging.keySet()) {
      ArrayList<TermForce> labeled=arranging.get(label);
      ArrayList<TermForce> labelClone=new ArrayList();
      labelClone.addAll(labeled);
      Collections.sort(labelClone,
        new Comparator<TermForce>(){
          public int compare(TermForce o1, TermForce o2){
            return o1.compareTo(o2);
        }
      });
      termeSize.put(label,labelClone);
     
    }
    return termeSize;
} 
      
HashMap<String,ArrayList<TermForce> > makeComplex (Table essai,Model correction){
    HashMap<String,Integer> colors=new HashMap();
    HashMap<String,ArrayList<TermForce> > termeSize = new HashMap<String,ArrayList<TermForce> >();
    HashMap<String,MaxSize> maxim=new HashMap();
    termeSize.put("Base",new ArrayList<TermForce>());
    for (String label : correction.getLabels()) {
      termeSize.put(label,new ArrayList<TermForce>());
      maxim.put(label,new MaxSize());
    }
    MaxSize max= new MaxSize();
    
   for (TableRow row : essai.rows()) {
    String name = row.getString(0);
    float size=0.0;
    
    //first calculate the all
    for (int k=1;k<essai.getColumnCount();k++){
      size+=row.getFloat(k)*correction.getAll(k-1);
    }
    size=1/(1+(float)Math.exp(size));
    if(max.max<size){
      max.max=size;
    }
    if(max.min>size){
      max.min=size;
    }
    TermForce ttForce=new TermForce(name,size,(int)random(width),(int)random(height),max);
    colors.put(ttForce.name,ttForce.colori);
    termeSize.get(BASE).add(ttForce);
    for (String label : correction.getLabels()) {
       float sizedLabel=0.0;
       for (int k=1;k<essai.getColumnCount();k++){
        sizedLabel+=row.getFloat(k)*correction.getLabel(label,k-1);
       }
       sizedLabel=(float)Math.exp(sizedLabel)*size;
       if(maxim.get(label).max<sizedLabel){
          maxim.get(label).max=sizedLabel;
      }
      if(maxim.get(label).min>sizedLabel){
        maxim.get(label).min=sizedLabel;
      }
       ttForce=new TermForce(name,sizedLabel,(int)random(width),(int)random(height),maxim.get(label));
       ttForce.colori=colors.get(ttForce.name);
       termeSize.get(label).add(new TermForce(name,sizedLabel,(int)random(width),(int)random(height),maxim.get(label)));
    }
    }
       
      
  return termeSize;      
}



class MaxSize{
  
  float max=0.0;
  float min=99999.9;
  float fontMax=10;
  float fontMin=5;
}

class TermForceComparator implements Comparator<TermForce>{
  int compare(TermForce o1, TermForce o2){
    return o1.compareTo(o2);
  }
}
class TermForce  {
  String name;
  float value;
  float fontsize;
  color colori;
  int x,y;
  float tileW,tileH;
  public MaxSize size;
  public TermForce(String name,float value,int x,int y,MaxSize max){
    this.name=name;
    this.value=value;
    this.fontsize=max(4,min(20,map(value,0.0,1,max.fontMin,max.fontMax)));
    this.colori=color(random(name.toCharArray()[0]),random(name.toCharArray()[0]),random(name.toCharArray()[0]));
    this.size=max;
    this.x=x;
    this.y=y;
    calculateDisplay();
  }
  
  public void calculateValue(){  
    fontsize=max(size.fontMin,min(size.fontMax,map( value,size.min,size.max,size.fontMin,size.fontMax)));
  }  
  
  public void calculateDisplay(){
    textSize(fontsize);
    tileW=textWidth(name)+1;
    tileH=textAscent()+1;
  }
  
  public void display(){

    calculateValue();
       textSize(fontsize);
             fill(colori);
        text(name,x-tileW*0.5,y+tileH*0.5);
         
  }
  
  public boolean intersect(TermForce force){
    float left1=x -tileW*0.5;
    float right1= x +tileW*0.5;
    float top1=y-tileH*0.5;
    float bot1=y+tileH*0.5;
    
    float left2=force.x-force.tileW*0.5;
    float right2= force.x +force.tileW*0.5;
    float top2=force.y-force.tileH*0.5;
    float bot2=force.y+force.tileH*0.5;
    
    return !(right1<left2||right2<left1||bot1<top2||bot2<top1);
    
  }
  public boolean checkLimit(int startX,int startY,int endX,int endY){
    return x -tileW*0.5<startX || x +tileW*0.5>endX || startY>y+tileH*0.5 || endY<y-tileH*0.5;
  }
  
  public int compareTo(TermForce anotherInstance) {
        int acc=(int)map(value,size.min,size.max,0,100);
        int ecc=(int)map(anotherInstance.value,anotherInstance.size.min,anotherInstance.size.max,0,100);
        return ecc-acc;
    }
  
  
}
int sizeButtonW=70;
int sizeButtonH=40;

class Model{
  HashMap <String,ArrayList<Float>> map;
  public Model(){
    map =new HashMap<String,ArrayList<Float>>();
  }
  void put(String  label, ArrayList<Float> values ){
    map.put(label,values);
  }
  Collection<String> getLabels(){
    return map.keySet();
  }
  float getAll(int column){
    float finVal=0.0;
    for(ArrayList<Float> values:map.values()){
      finVal+=values.get(column);
    }
    return finVal;
  } 
  float getLabel(String label,int column){
    return map.get(label).get(column);
  } 
}

void drawButton(int i,boolean sel){
  int x=110+(i-1)*sizeButtonW+(i-1)*5;
  writeButton("Essai "+i,x,40,!sel,overRect(x,40,sizeButtonW,sizeButtonH),sizeButtonW, sizeButtonH,18);
}
void writeButton(String name,int x,int y,boolean selected,boolean median,int sizeBonW,int sizeBonH,int decay){
    if(selected){
      if(median){
        fill(200);
      }else{
        fill(255);
      }
    }else{
      if(median){
        fill(120);
      }else{
        fill(160);
      }
    }
    stroke(1);
    rect(x, y, sizeBonW, sizeBonH, 7);
    fill(0);
    textSize(12);
    translate(x, y);
    text(name,decay,25);
    translate(-x, -y);
}
boolean sortActual=false;

void mousePressed() {
  for (int y=1;y<9;y++){
    int x=110+(y-1)*sizeButtonW+(y-1)*5;
    if(overRect(x,40,sizeButtonW,sizeButtonH)){
      sortActual=false;
      loading=true;
      actualEssay=y;
      if(y==1){
        completeActu=makeComplex (tableEssay1,modeles[0]);
        
      }
      if(y==2){
        completeActu=makeComplex (tableEssay2,modeles[1]);
      }
      if(y==3){
        completeActu=makeComplex (tableEssay3,modeles[2]);
      }
      if(y==4){
        completeActu=makeComplex (tableEssay4,modeles[3]);
      }
      if(y==5){
        completeActu=makeComplex (tableEssay5,modeles[4]);
      }
      if(y==6){
        completeActu=makeComplex (tableEssay6,modeles[5]);
      }
      if(y==7){
        completeActu=makeComplex (tableEssay7,modeles[6]);
      }
      if(y==8){
        completeActu=makeComplex (tableEssay8,modeles[7]);
      }
      completeActu=sortAndOrder(completeActu);
        complete=select(sortAndOrder(completeActu),500);
        calculateFontSize(complete);
        arrange(complete);
        actu=complete.get(BASE);
        
      loading=false;
    }
  }
  int y=0;
  int x=5;
  for (String label : complete.keySet()){
    if (y>700){
      y=0;x+=sizeButtonW/2+2;
    }
    y+=sizeButtonH+2;
    if(overRect(x,y,sizeButtonW/2,sizeButtonH)){
      actu=complete.get(label);
      labelActuel=label;
    }
  }
  int sizer[]=new int[]{10,50,100,250,500};
  for (int i=0;i<5;i++){
    int lin=ybase+20+28*i;
      if(overRect(xbase-15,lin-15,xbase+15,lin+15)){
        indiceActu=i;
        complete=select(completeActu,sizer[i]);
        actu=complete.get(labelActuel);        
      }      
  }
   
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}
