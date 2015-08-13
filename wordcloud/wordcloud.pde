import java.util.ArrayList;
ArrayList<TermForce> actu;
void setup(){
	Table tableEssay1 = loadTable("TermConcept_Essay1.csv");
	Table tableEssay2 = loadTable("TermConcept_Essay2.csv");
	Table tableEssay3 = loadTable("TermConcept_Essay3.csv");
	Table tableEssay4 = loadTable("TermConcept_Essay4.csv");
	Table tableEssay5 = loadTable("TermConcept_Essay5.csv");
	Table tableEssay6 = loadTable("TermConcept_Essay6.csv");
	Table tableEssay7 = loadTable("TermConcept_Essay7.csv");
	Table tableEssay8 = loadTable("TermConcept_Essay8.csv");
        Table models = loadTable("ModelTest.csv");
        
        HashMap<String,Float> essai = new HashMap<String,Float>();

// Putting key-value pairs in the HashMap        
        float modelsFloat[][] = new float[8][];
        int i=0;
        for (TableRow row : models.rows()) {
            String name = row.getString(0);
            for (int k=1;k<31;k++)
            {
            }
            i++;         
        }
        size(800,800);
        actu=makeSimple(tableEssay1);
        println(tableEssay1.getColumnCount());
        
      }
      
      void draw(){
        for (TermForce term:actu){
          term.display();
        }
      
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
    this.value=map(value,-1,1,4,50);
    this.colori=map(value,-1,1,255,50);
    
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
