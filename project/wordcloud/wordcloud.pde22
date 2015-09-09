import java.util.ArrayList;
import java.util.HashMap;
import java.util.Collection;
import java.util.Collections;
ArrayList<TermForce> actu;
Model [] modeles= new Model[8];
String BASE="Base";
void setup(){
	Table tableEssay1 = loadTable("TermConcept_Essay1.csv");
	Table tableEssay2 = loadTable("TermConcept_Essay2.csv");
	Table tableEssay3 = loadTable("TermConcept_Essay3.csv");
	Table tableEssay4 = loadTable("TermConcept_Essay4.csv");
	Table tableEssay5 = loadTable("TermConcept_Essay5.csv");
	Table tableEssay6 = loadTable("TermConcept_Essay6.csv");
	Table tableEssay7 = loadTable("TermConcept_Essay7.csv");
	Table tableEssay8 = loadTable("TermConcept_Essay8.csv");
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
        
        actu=makeSimple(tableEssay1);
        complete=sortAndOrder(makeComplex (tableEssay1,modeles[0]),50);
        arrange(complete);
        actu=complete.get(BASE);
        println(tableEssay1.getColumnCount());
       
      
      }
      HashMap<String,ArrayList<TermForce> > complete;
      int counter=1;
      void keyPressed() {
        if(counter>4){
          actu=complete.get(BASE);
          counter=1;
        }
        else{
          actu=complete.get(""+counter++);
        }
        
      }
      void draw(){
        background(255);
        for (TermForce term:actu){
          term.display();
        }
        
      
      }

void arrange(HashMap<String,ArrayList<TermForce> > arranging) {
     
    float cx=width/2,cy=height/2;
    float R=0.0,dR=0.2,theta=0.0,dTheta=0.5;
    int count=0;
    ArrayList<TermForce> bases=arranging.get(BASE);
    ArrayList<TermForce> arrayCalcul=new ArrayList();
    for(TermForce arrange:bases){
      arrange.calculateValue();
      arrange.calculateDisplay();
      do{
        arrange.x=(int)(cx+R*cos(theta));
        arrange.y=(int)(cy+R*sin(theta));
        theta+=dTheta;
        R+=dR;
      }
      while(check(arrayCalcul,arrange)&&count++ <10000);
      arrayCalcul.add(arrange);
    }
    
    for (String label : arranging.keySet()) {
      R=0.0;
      theta=0.0;
      bases = arranging.get(label);
      arrayCalcul=new ArrayList();
      for(TermForce arrange:bases){
        arrange.calculateValue();
        arrange.calculateDisplay();
        count=0;
        do{
          arrange.x=(int)(cx+R*cos(theta));
          arrange.y=(int)(cy+R*sin(theta));
          
          theta+=dTheta;
          R+=dR;
        }while(check(arrayCalcul,arrange)&&count++ <10000);
        arrayCalcul.add(arrange);
        println(arrange.x+":"+arrange.y+":"+arrange.tileW+":"+arrange.tileH+":"+R);
      }
      
    }

}

boolean check(ArrayList<TermForce> checks, TermForce toCheck){
  for(TermForce onCheck:checks){
    if(toCheck.intersect(onCheck)){
      return true;
    }
  }

  return false;
}
      
HashMap<String,ArrayList<TermForce> > sortAndOrder(HashMap<String,ArrayList<TermForce> > arranging,int size) {
   HashMap<String,ArrayList<TermForce> > termeSize = new HashMap<String,ArrayList<TermForce> >();
    for (String label : arranging.keySet()) {
      termeSize.put(label,new ArrayList<TermForce>());
    }
    ArrayList<TermForce> bases=arranging.get(BASE);
    ArrayList<TermForce> basesClone=new ArrayList();
    basesClone.addAll(bases);
    Collections.reverse(basesClone);
    ArrayList<TermForce>  basesCloneFilter=new ArrayList();
    int counter=0;
    for(TermForce force:basesClone){
      if(counter++<size){
              basesCloneFilter.add(force);
      }else{
            break;
      }
    }
    termeSize.put(BASE,basesCloneFilter);
    //respect same order for all
    for (String label : arranging.keySet()) {
      ArrayList<TermForce> labeled=arranging.get(label);
      ArrayList<TermForce> labelClone=new ArrayList();
      counter=0;
      for(TermForce force:basesClone){
        for(TermForce forceClo:labeled){
          if(force.name.equals(forceClo.name)){
            if(counter++<size){
              labelClone.add(forceClo);
            }
            break;
          }
        }
      }
      termeSize.put(label,labelClone);
      
    }
    return termeSize;
} 
      
HashMap<String,ArrayList<TermForce> > makeComplex (Table essai,Model correction){
  
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
    termeSize.get(BASE).add(new TermForce(name,size,(int)random(width),(int)random(height),max));
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
       termeSize.get(label).add(new TermForce(name,sizedLabel,(int)random(width),(int)random(height),maxim.get(label)));
    }
    }
       
      
  return termeSize;      
}

ArrayList<TermForce> makeSimple (Table essai){
    int nbColumn=essai.getColumnCount()-1;
    
    float []correction=new float[essai.getColumnCount()-1];
    for (int i=0;i<nbColumn;i++){
      correction[i]=1.0;
    }
    return make(essai,correction);
} 
ArrayList<TermForce> make (Table essai,float []correction){     
  ArrayList<TermForce> termeSize = new ArrayList<TermForce>();
  for (TableRow row : essai.rows()) {
    String name = row.getString(0);
    float size=0.0;
    for (int k=1;k<essai.getColumnCount();k++){
      size+=row.getFloat(k)*correction[k-1];
    }
    println(name+":"+size);
    termeSize.add(new TermForce(name,size,(int)random(width),(int)random(height),new MaxSize()));
  }
  return termeSize;
}

class MaxSize{
  
  float max=0.0;
  float min=99999.9;
}

class TermForce implements Comparable<TermForce> {
  String name;
  float value;
  float fontsize;
  float colori;
  int x,y;
  float tileW,tileH;
  MaxSize size;
  public TermForce(String name,float value,int x,int y,MaxSize max){
    this.name=name;
    this.value=value;
    this.fontsize=max(4,min(20,map(value,0.0,1,4,20)));
    this.colori=color(10, 40, 5);
    this.size=max;
    this.x=x;
    this.y=y;
    calculateDisplay();
  }
  
  public void calculateValue(){  
    fontsize=max(6,min(30,map(value,size.min,size.max,6,30)));
  }  
  
  public void calculateDisplay(){
    textSize(fontsize);
    tileW=textWidth(name);
    tileH=textAscent();
  }
  
  public void display(){


       textSize(fontsize);
             fill(colori);
        text(name,x,y);
         
  }
  
  public boolean intersect(TermForce force){
    float left1=x;
    float right1= x +tileW;
    float top1=y-tileH;
    float bot1=y;
    
    float left2=force.x;
    float right2= force.x +force.tileW;
    float top2=force.y-force.tileH;
    float bot2=force.y;
    
    return !(right1<left2||right2<left1||bot1<top2||bot2<top1);
    
  }
  
  public int compareTo(TermForce anotherInstance) {
        return (int)(value*1000.0 - anotherInstance.value*1000.0);
    }
  
  
}

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
