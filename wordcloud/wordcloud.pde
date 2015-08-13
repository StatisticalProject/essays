import java.util.ArrayList;
import java.util.HashMap;
import java.util.Collection;
ArrayList<TermForce> actu;
Model [] modeles= new Model[8];
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
        HashMap<String,ArrayList<TermForce> > ret=makeComplex (tableEssay1,modeles[0]);
        actu=ret.get("4");
        println(tableEssay1.getColumnCount());
        
      }
      
      void draw(){
        background(255);
        for (TermForce term:actu){
          term.display();
        }
      
      }
      
HashMap<String,ArrayList<TermForce> > makeComplex (Table essai,Model correction){
  
    HashMap<String,ArrayList<TermForce> > termeSize = new HashMap<String,ArrayList<TermForce> >();
    termeSize.put("Base",new ArrayList<TermForce>());
    for (String label : correction.getLabels()) {
      termeSize.put(label,new ArrayList<TermForce>());
    }
    
   for (TableRow row : essai.rows()) {
    String name = row.getString(0);
    float size=0.0;
    //first calculate the all
    for (int k=1;k<essai.getColumnCount();k++){
      size+=row.getFloat(k)*correction.getAll(k-1);
    }
    size=1/(1+(float)Math.exp(size));
    termeSize.get("Base").add(new TermForce(name,size,(int)random(width),(int)random(height)));
    for (String label : correction.getLabels()) {
       float sizedLabel=0.0;
       for (int k=1;k<essai.getColumnCount();k++){
        sizedLabel+=row.getFloat(k)*correction.getLabel(label,k-1);
       }
       sizedLabel=(float)Math.exp(sizedLabel)*size;
       termeSize.get(label).add(new TermForce(name,sizedLabel,(int)random(width),(int)random(height)));
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
    termeSize.add(new TermForce(name,size,(int)random(width),(int)random(height)));
  }
  return termeSize;
}

class TermForce{
  String name;
  float value;
  float colori;
  int x,y;
  float tileW,tileH;
  public TermForce(String name,float value,int x,int y){
    this.name=name;
    this.value=min(100,map(value,0,1,4,70));
    this.colori=map(value,0,1,255,50);
    
    this.x=x;
    this.y=y;
    tileW=textWidth(name);
    tileH=textAscent();
  }
  
  public void display(){
      stroke(1);
      fill(colori);
       textSize(value);
        text(name,x,y);
         
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
