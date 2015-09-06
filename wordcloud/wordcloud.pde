import java.util.ArrayList;
import java.util.List;
import java.util.*;
import java.util.Collection;
import java.util.Comparator;
import java.util.Collections;
/* liste des termes avec leur valeur*/
ArrayList<TermForce> actu;
/* 8 modele d'essai */
Model [] modeles= new Model[8];

String BASE="Base";
/* Table qui seront charger avec les resultats de LSA*/
Table tableEssay1;
Table tableEssay2;
Table tableEssay3;
Table tableEssay4;
Table tableEssay5;
Table tableEssay6;
Table tableEssay7;
Table tableEssay8;
/* loading flag*/
boolean loading=false;
/* debut */ 
int xbase=100,ybase=101;
/* indice actuel representant la note*/
int indiceActu=4;
/* indice representant la note en string */
String labelActuel="0";
/* taille des fontes max par nombre terme */
int selectedFontMax[]=new int []{33,30,30,25,22};
/* taille des fontes min par nombre terme */
int selectedFontMin[]=new int []{22,18,15,11,9};

/* Table hashé des termes et leur probabilité */
Map<String,ArrayList<TermForce> > complete;
Map<String,ArrayList<TermForce> > completeActu;
/* compteur */
int maxiXounter=1;
/* maximum de terme */ 
int maxi=500;
/* essai actuel */       
int actualEssay=1;
/* taille des boutons */
int windowSize=30,beginWindow=10,endWindows=beginWindow+windowSize;
/* boucle*/
int loopH=1;
/* taille des boutons*/
int sizeButtonW=70;
int sizeButtonH=40;
/* initalisation */
void setup(){
	/* chargement des essais */
	tableEssay1 = loadTable("TermConcept_Essay1.csv");
	tableEssay2 = loadTable("TermConcept_Essay2.csv");
	tableEssay3 = loadTable("TermConcept_Essay3.csv");
	tableEssay4 = loadTable("TermConcept_Essay4.csv");
	tableEssay5 = loadTable("TermConcept_Essay5.csv");
	tableEssay6 = loadTable("TermConcept_Essay6.csv");
	tableEssay7 = loadTable("TermConcept_Essay7.csv");
	tableEssay8 = loadTable("TermConcept_Essay8.csv");
        /* hcrgement des données de modèle*/
        Table modelLoad = loadTable("ModelTest.csv");
        
        
        HashMap<String,Float> essai = new HashMap<String,Float>();
        // initialisation de la liste des modèles
        for (int i=0;i<8;i++) {
          modeles[i]=new Model();
        }
	// chargement des modeles de chaque essai
        for (TableRow row : modelLoad.rows()) {
            String name = row.getString(0);
            String label = Integer.toString(Integer.parseInt(row.getString(1))+1);
            ArrayList<Float> list= new ArrayList();
            for (int k=2;k<32;k++)
            {
              list.add(row.getFloat(k));
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
        // taille dec l'ecran
        size(800,800);
        
        /* calcul les probabilite des notes par terme pour l essai 1 avec le modele */
        completeActu=makeComplex (tableEssay1,modeles[0]);
        /* on tri les resultats*/
        completeActu=sortAndOrder(completeActu);
        /* selectionne le nombre de resultat */
        complete=select(sortAndOrder(completeActu),500);
        /* on calcul la taille des font max et min*/
        calculateFontSize(complete);
        /* on arrange les resultats en spirale*/
        arrange(complete);
        /* on recupere le resultat de la note 0 pour le premier affichage*/ 
        actu=complete.get("0");
        /* on imprime le nombre de resultat*/ 
        println(tableEssay1.getColumnCount());
        
        
      
      }
      
      /* affichage *
      void draw(){
       /* on nettoie l 'arriere plan*/
        background(255);
        /* on dessine chacun des termes selectionnes sur la note et l essai*/
        for (TermForce term:actu){
          term.display();
        }
        /* action si la souris est cliquer*/
        if (mousePressed) {
          calculate(mouseX,mouseY,750,10);
        }
        /* on dessine les bouton*/
        drawButtons();
        /* si chargement alors on affiche un bouton*/
        if(loading){ 
          writeButton("Loading",width/2,height/2,true,true,sizeButtonW, sizeButtonH,18,25,12);
        }
        /* on dessine le selectionneur du nombre de resultat*/
        drawSizer();
      }
      
/* on dessine la reglette */      
void drawSizer(){
      stroke(1);
      // liste des 5 tailles
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
        //le bouton pour recalculer la spirale
        writeButton("Arranger",xbase-20,ybase-17,true,overRect(xbase-20,ybase-17,50,15),50,15,5,12,10);

}
// on dessine les boutons
void drawButtons(){
  for (int y=1;y<9;y++){
    drawButton(y,actualEssay==y);
  }  
  int sizeButtonW=70;
int sizeButtonH=40;
   int y=0;
   int x=5;
   text("Note",10,35);
  for (int i=0;i<complete.keySet().size();i++){
    if (y>700){
      y=0;x+=sizeButtonW/2+2;
    }
    y+=sizeButtonH+2;
    
    writeButton(Integer.toString(i),x,y,!labelActuel.equals(Integer.toString(i)),overRect(x,y,sizeButtonW/2,sizeButtonH),sizeButtonW/2, sizeButtonH,11,25,12);
  }
}      
/* on calcul la taille des fontes*/
void calculateFontSize(Map<String,ArrayList<TermForce> > arranging) {
  for (String label : arranging.keySet()) {
      ArrayList<TermForce> bases=arranging.get(label);
      bases.get(0).size.fontMax=selectedFontMax[indiceActu];
      bases.get(0).size.fontMin=selectedFontMin[indiceActu];//max(40,map(bases.size(),500,1,40,50));
  }
  
  
}

//intersection
void calculate(int mouseX,int mouseY,int x,int y){
  if (mouseX<x){
    return;
  }
  beginWindow=(mouseY-y)/loopH;
  
  if (beginWindow<0){
    beginWindow=0;
  }
  endWindows=beginWindow+windowSize;
  if(endWindows>=completeActu.get("0").size())
  {
    endWindows=completeActu.get("0").size();
    beginWindow=endWindows-windowSize;
  }
}
// calcule de la spirale des mots
void arrange(Map<String,ArrayList<TermForce> > arranging) {
     //cntre de la spirale
    float cx=width/2,cy=height/2;
    //Eloignement et angle
    float R=0.0,dR=1.0,theta=0.0,dTheta=0.05;
    //bruit
    float Rnoise=0.0,dRnoise=1.5;
    for (String label : arranging.keySet()) {
      R=0.0;
      theta=0.0;
      ArrayList<TermForce>  bases = arranging.get(label);
      ArrayList<TermForce> arrayCalcul=new ArrayList();
      for(TermForce arrange:bases){
              R=0.0;
        theta=random(100)/100;
        arrange.calculateValue();
        arrange.calculateDisplay();
        do{
          float radd=theta+(customNoise(Rnoise)*200)-100;
          arrange.x=(int)(cx+R*cos(radd));
          arrange.y=(int)(cy+R*sin(radd));
                    
          theta+=dTheta;
          R+=dR;
          Rnoise+=dRnoise;
        }while(check(arrayCalcul,arrange));
        arrayCalcul.add(arrange);
      }
      
    }

}
// bruit gaussien
float customNoise(float value){
    return noise(value);
}
//regarde si le terme actuel est en conflit avec les termes deja affiche
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

/* filtre les n premiers resultats*/
Map<String,ArrayList<TermForce> > select(Map<String,ArrayList<TermForce> > arranging,int sized) {
   Map<String,ArrayList<TermForce> > termeSize = new TreeMap<String,ArrayList<TermForce> >();
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
/* tri des resultats */
Map<String,ArrayList<TermForce> > sortAndOrder(Map<String,ArrayList<TermForce> > arranging) {
   Map<String,ArrayList<TermForce> > termeSize = new TreeMap<String,ArrayList<TermForce> >();
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
/* calcul de la probabilite de chaque note par terme*/      
Map<String,ArrayList<TermForce> > makeComplex (Table essai,Model correction){
    HashMap<String,Integer> colors=new HashMap();
    TreeMap<String,ArrayList<TermForce> > termeSize = new TreeMap<String,ArrayList<TermForce> >();
    HashMap<String,MaxSize> maxim=new HashMap();
    String labeli="0";
    maxim.put(labeli,new MaxSize());
    termeSize.put(labeli,new ArrayList<TermForce>());
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
    ttForce=new TermForce(name,size,(int)random(width),(int)random(height),max);
    ttForce.colori=colors.get(ttForce.name);
    termeSize.get(labeli).add(ttForce);

    for (String labele : correction.getLabels()) {
       String label=labele;
       float sizedLabel=0.0;
       for (int k=1;k<essai.getColumnCount();k++){
        sizedLabel+=row.getFloat(k)*correction.getLabel(label,k-1);
       }
       sizedLabel=(float)Math.exp(sizedLabel);
       sizedLabel*=size;
       if(maxim.get(label).max<sizedLabel){
          maxim.get(label).max=sizedLabel;
      }
      if(maxim.get(label).min>sizedLabel){
        maxim.get(label).min=sizedLabel;
      }
       ttForce=new TermForce(name,sizedLabel,(int)random(width),(int)random(height),maxim.get(label));
       ttForce.colori=colors.get(ttForce.name);
       termeSize.get(label).add(ttForce);
       
       
    }
     
    }
       
      
  return termeSize;      
}


/* taille maximum*/
class MaxSize{
  
  float max=0.0;
  float min=99999.9;
  float fontMax=10;
  float fontMin=8;
}

/* comparateur de terme avec sa probabilité*/
class TermForceComparator implements Comparator<TermForce>{
  int compare(TermForce o1, TermForce o2){
    return o1.compareTo(o2);
  }
}
/*terme avec sa probabilité, sa taille de fonte,sa couleur, sa taille et son emplacement*/
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
    for(String label:map.keySet()){
      finVal+=getLabel(label,column);
    }
    return finVal;
  } 
  float getLabel(String label,int column){
       return map.get(label).get(column);
  } 
}

void drawButton(int i,boolean sel){
  int x=110+(i-1)*sizeButtonW+(i-1)*5;
  writeButton("Essai "+i,x,40,!sel,overRect(x,40,sizeButtonW,sizeButtonH),sizeButtonW, sizeButtonH,18,25,12);
}
void writeButton(String name,int x,int y,boolean selected,boolean median,int sizeBonW,int sizeBonH,int decayx,int decayy,int fontsize){
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
    textSize(fontsize);
    translate(x, y);
    text(name,decayx,decayy);
    translate(-x, -y);
}
boolean sortActual=false;

void mousePressed() {
  int sizer[]=new int[]{10,50,100,250,500};
  
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
        complete=select(sortAndOrder(completeActu),sizer[indiceActu]);
        calculateFontSize(complete);
        arrange(complete);
        actu=complete.get("0");
      labelActuel="0";        
      loading=false;
    }
  }
  int y=0;
  int x=5;
  for (int i=0;i<complete.keySet().size();i++){
    String label=Integer.toString(i);
    if(i==0){
      label="0";
    }
    if (y>700){
      y=0;x+=sizeButtonW/2+2;
    }
    y+=sizeButtonH+2;
    if(overRect(x,y,sizeButtonW/2,sizeButtonH)){
      actu=complete.get(label);
      labelActuel=label;
    }
  }
  for (int i=0;i<5;i++){
    int lin=ybase+20+28*i;
      if(overRect(xbase-15,lin-15,xbase+15,lin+15)){
        indiceActu=i;
        complete=select(completeActu,sizer[i]);
        actu=complete.get(labelActuel);        
      }      
  }
  
  if(overRect(xbase-20,ybase-17,50,15)){
    complete=select(completeActu,sizer[indiceActu]);
    calculateFontSize(complete);
    arrange(complete);
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
