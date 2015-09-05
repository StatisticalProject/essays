/* Table qui seront charger avec les resultats de LSA*/
Table tableEssay1;
Table tableEssay2;
Table tableEssay3;
Table tableEssay4;
Table tableEssay5;
Table tableEssay6;
Table tableEssay7;
Table tableEssay8;
/*Table actuel*/
Table actualTableEssay=tableEssay1;
/* Index actuel*/
int actualIndexSort=0;
/* Est ce qu il n y a plus de desimilarite */
boolean finish=false;
/* tableau des couleurs */
color []inside = new color[11];

int column=1;
int loopH=1;
/* taille du bouton */
int sizeButtonW=70;
int sizeButtonH=40;
/* essai actuel */
int actualEssay=1;
/* tri actuel */
boolean sortActual=false;
/* nombre Error maximum pour accepter une similarite*/ 
int limitError=22;
/* nombre de changement */
int nbChange=0;

/* Setup de la demo */
void setup() {
  size(1024, 768);
  /* on charge tous les essays */
  tableEssay1 = loadTable("TermConcept_Essay1.csv");
  tableEssay2 = loadTable("TermConcept_Essay2.csv");
  tableEssay3 = loadTable("TermConcept_Essay3.csv");
  tableEssay4 = loadTable("TermConcept_Essay4.csv");
  tableEssay5 = loadTable("TermConcept_Essay5.csv");
  tableEssay6 = loadTable("TermConcept_Essay6.csv");
  tableEssay7 = loadTable("TermConcept_Essay7.csv");
  tableEssay8 = loadTable("TermConcept_Essay8.csv");
  actualTableEssay=tableEssay1;
  /* on charge les couleurs*/
  inside[0]=color(247,252,253);
  inside[1]=color(229,245,249);
  inside[2]=color(204,236,230);
  inside[3]=color(153,216,201);
  inside[4]=color(102,194,164);
  inside[5]=color(65,174,118);
  inside[6]=color(35,139,69);
  inside[7]=color(0,109,44);
  inside[8]=color(0,68,27);
  inside[9]=color(33,102,172);
  inside[10]=color(5,48,97);
  /* on imprime le nombre de ligne*/
  println(actualTableEssay.getRowCount() + " total rows in table"); 
  finish=false;
  frameRate(300) ;

}

/* on dessine */
void draw(){
  /* on nettoie l ecran*/
  clear();
  /* on tri les lignes*/
  sortAllLine();
  /* on color l arriere plan*/
  background(240);
  /* demarage des element en y*/
  int globalStartH=150;
  drawPart(0,globalStartH);
  drawAll(750,globalStartH);
  
  if (mousePressed) {
    calculate(mouseX,mouseY,750,globalStartH);
  }
 
  drawButtons();
}

void mousePressed() {
  for (int y=1;y<9;y++){
    int x=110+(y-1)*sizeButtonW+(y-1)*5;
    if(overRect(x,40,sizeButtonW,sizeButtonH)){
      sortActual=false;
      actualEssay=y;
      if(y==1){
        actualTableEssay=tableEssay1;
      }
      if(y==2){
        actualTableEssay=tableEssay2;
      }
      if(y==3){
        actualTableEssay=tableEssay3;
      }
      if(y==4){
        actualTableEssay=tableEssay4;
      }
      if(y==5){
        actualTableEssay=tableEssay5;
      }
      if(y==6){
        actualTableEssay=tableEssay6;
      }
      if(y==7){
        actualTableEssay=tableEssay7;
      }
      if(y==8){
        actualTableEssay=tableEssay8;
      }
    }
  }
  int x=110+(10)*sizeButtonW+10;
  if(overRect(x,40,sizeButtonW,sizeButtonH)){
    sortActual=!sortActual;
    limitError=15;
    actualIndexSort=0;
  }  
}

void drawButtons(){
  for (int y=1;y<9;y++){
    drawButton(y,actualEssay==y);
  }  
  int x=110+(10)*sizeButtonW;
  writeButton("Similaire",x,20,true,overRect(x,20,sizeButtonW,sizeButtonH));
}
void drawButton(int i,boolean sel){
  int x=110+(i-1)*sizeButtonW+(i-1)*5;
  writeButton("Essai "+i,x,20,!sel,overRect(x,20,sizeButtonW,sizeButtonH));
}
void writeButton(String name,int x,int y,boolean selected,boolean median){
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
    rect(x, y, sizeButtonW, sizeButtonH, 7);
    fill(0);
    translate(x, y);
    text(name,58,25);
    translate(-x, -y);
}

void sortAllLine(){
  if(!sortActual)
  {
    return;
  }
  int i=actualIndexSort;
  int nextLine=1;
    TableRow row=actualTableEssay.getRow(i);
    int previousError=actualTableEssay.getRowCount()-1;
    int expected=i;
    for (int j=i+1;j<actualTableEssay.getRowCount();j++){
      TableRow rowSame=actualTableEssay.getRow(j);
      boolean same=true;
      int nbError=0;
      for (int k=1;k<actualTableEssay.getColumnCount();k++){
          if(calculateSpace(rowSame.getFloat(k))-calculateSpace(row.getFloat(k))!=0){
            nbError++;
            if(nbError>limitError){
              same=false;
              break;
            }
          }
      }
      //same value
      if(same){
        nbChange++;
        if(nbError<previousError){
          expected=j;
          previousError=nbError;
          //actualTableEssay=exchangeLines(actualTableEssay,i+1,j);
        }else{
          //actualTableEssay=exchangeLines(actualTableEssay,i+nextLine,j);
        }
        nextLine++;
        if(nextLine>50){
          break;
        }
        
      }
    }
    //make best
    if(i!=expected){
      actualTableEssay=exchangeLines(actualTableEssay,i+1,expected);  
    }
    
    //if no change make it at the end
    if(nbChange==0) {
      actualTableEssay=exchangeLines(actualTableEssay,actualIndexSort,actualTableEssay.getColumnCount()-1);
    } else{
      actualIndexSort++;
    }
  if(actualIndexSort>actualTableEssay.getRowCount())
  {
    if(nbChange==0) {
      sortActual=false;
    }
    limitError=(int)(limitError-1);
    actualIndexSort=0;
    if(limitError<5){
      limitError=2;
    }
  }
  
}

void calculate(int mouseX,int mouseY,int x,int y){
  if (mouseX<x){
    return;
  }
  beginWindow=(mouseY-y)/loopH;
  
  if (beginWindow<0){
    beginWindow=0;
  }
  endWindows=beginWindow+windowSize;
  if(endWindows>=actualTableEssay.getRowCount())
  {
    endWindows=actualTableEssay.getRowCount();
    beginWindow=endWindows-windowSize;
  }
}



Table exchangeLines(Table tableIn,int index1,int index2){
  if(index1>=tableIn.getRowCount()){
    return tableIn;
  }
  Table table = new Table();
  for (int i=0;i<tableIn.getRowCount();i++){
    
    if(i==index1){
      table.addRow(tableIn.getRow(index2));
    }
    if(i!=index2){
      table.addRow(tableIn.getRow(i));
    }
    
    
  }
  return table;
  
}

int windowSize=30,beginWindow=10,endWindows=beginWindow+windowSize;

void drawAll(int xStart,int xEnd){
  
  noStroke();
  pushMatrix();
  int pixelsizeH=loopH;
  int pixelsizeW=6;
   translate(xStart, xEnd);
   int j=0;
   int column=30;
  for (TableRow row : actualTableEssay.rows()) {
    column=row.getColumnCount();
    j++;
    if(j==endWindows){
      noFill();
      stroke(1);
      strokeWeight(3);
      rect(-1, 0-(endWindows-beginWindow)*pixelsizeH, pixelsizeW*row.getColumnCount()+8, pixelsizeH*((endWindows-beginWindow-1)));
      noStroke();
      strokeWeight(1);
      
    }
    translate(0, pixelsizeH);
    String name = row.getString(0);
    for (int i=1;i<row.getColumnCount();i++)
    {
      translate(pixelsizeW, 0);

      float value=row.getFloat(i);
      fill(inside[calculateSpace(value)]);
      rect(0, 0, pixelsizeW, pixelsizeH);
    }
    translate(-pixelsizeW*(row.getColumnCount()-1), 0);
    
  }
  stroke(1);fill(0);
  translate(-630,-500);
  textAlign(LEFT);
  for(int i=0;i<30;i++){
     translate(i*(pixelsizeW*3.32),0);
    rotate(5*PI/3);
    //translate(500,-200);
    text("Concetp "+i, 0, 0);
    rotate(-5*PI/3);
    translate(-i*(pixelsizeW*3.32),0);
  
  }
  textAlign(RIGHT);
  popMatrix();
}


void drawPart(int xStart,int xEnd){
  int pixelsizeH=20;
  int pixelsizeW=20;
  //translate(800, 0);
  
  for (int k=beginWindow;k<endWindows;k++ ) {
    pushMatrix();
    translate(xStart, xEnd);
    stroke(1);
    textAlign(RIGHT);
    fill(0); 
    translate(pixelsizeW*5, (k-beginWindow+0.8)*pixelsizeH);
    TableRow row=actualTableEssay.getRow(k);
    String name = row.getString(0);
    text(name,0,0);
    popMatrix();
    pushMatrix();
    translate(xStart, xEnd);
    translate(4*pixelsizeW+5, (k-beginWindow)*pixelsizeH);
    for (int i=1;i<row.getColumnCount();i++)
    {
      translate(pixelsizeW, 0);
      float value=row.getFloat(i);
      fill(inside[calculateSpace(value)]);
      rect(0, 0, pixelsizeW, pixelsizeH);
    }
    translate(-pixelsizeW*(row.getColumnCount()-1), 0);
    popMatrix();
    
    
  }
   
  
}

int calculateSpace(float value){
  int maximum=9;
  int minimum=0;
  return min(maximum,max(minimum,(int)map(value, -0.01, 0.01,minimum, maximum)));
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

