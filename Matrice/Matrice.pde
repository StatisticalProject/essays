Table tableEssay1;
Table tableEssay2;
Table tableEssay3;
Table tableEssay4;
Table tableEssay5;
Table tableEssay6;
Table tableEssay7;
Table tableEssay8;
int actualIndexSort=0;
boolean finish=false;
color []inside = new color[11];
int column=1;
int loopH=1;
void setup() {
  size(1024, 768);
  tableEssay1 = loadTable("TermConcept_Essay1.csv");
  tableEssay2 = loadTable("TermConcept_Essay2.csv");
  tableEssay3 = loadTable("TermConcept_Essay3.csv");
  tableEssay4 = loadTable("TermConcept_Essay4.csv");
  tableEssay5 = loadTable("TermConcept_Essay5.csv");
  tableEssay6 = loadTable("TermConcept_Essay6.csv");
  tableEssay7 = loadTable("TermConcept_Essay7.csv");
  tableEssay8 = loadTable("TermConcept_Essay8.csv");
  //['rgb(103,0,31)','rgb(178,24,43)','rgb(214,96,77)','rgb(244,165,130)',
  //'rgb(253,219,199)','rgb(247,247,247)','rgb(209,229,240)','rgb(146,197,222)',
  //::::'rgb(67,147,195)','rgb(33,102,172)','rgb(5,48,97)']
  //['rgb(247,252,253)','rgb(229,245,249)','rgb(204,236,230)','rgb(153,216,201)','rgb(102,194,164)','rgb(65,174,118)','rgb(35,139,69)','rgb(0,109,44)','rgb(0,68,27)']
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
  
  println(tableEssay1.getRowCount() + " total rows in table"); 

  for (TableRow row : tableEssay1.rows()) {
    
    int id = row.getInt(1);
    String species = row.getString(2);
    String name = row.getString(0);
    
  }
  println(tableEssay1.getRowCount() + " total rows in table"); 
  finish=false;
  frameRate(300) ;

  
}

void draw(){
  
  clear();
  sortAllLine();
  background(240);
  int globalStartH=50;
  drawPart(0,globalStartH);
  drawAll(750,globalStartH);
  
  if (mousePressed) {
    calculate(mouseX,mouseY,750,globalStartH);
  } 
}
int limitError=20;
void sortAllLine(){
  if(actualIndexSort>tableEssay1.getRowCount())
  {
    return;
  }
  int i=actualIndexSort;
  int nextLine=1;
    TableRow row=tableEssay1.getRow(i);
    for (int j=i+1;j<tableEssay1.getRowCount();j++){
      TableRow rowSame=tableEssay1.getRow(j);
      boolean same=true;
      int nbError=0;
      for (int k=1;k<tableEssay1.getColumnCount();k++){
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
        tableEssay1=exchangeLines(tableEssay1,i+nextLine,j);
        nextLine++;
        if(nextLine>100){
          break;
        }
      }
      actualIndexSort+=nextLine;
      
    }
  actualIndexSort++;
  if(actualIndexSort>tableEssay1.getRowCount())
  {
    limitError=(int)(limitError*0.5);
    actualIndexSort=0;
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
  if(endWindows>=tableEssay1.getRowCount())
  {
    endWindows=tableEssay1.getRowCount();
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
  for (TableRow row : tableEssay1.rows()) {
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
  //println( " draw : "+actualIndexSort+" "+tableEssay1.getRowCount()); 
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
    TableRow row=tableEssay1.getRow(k);
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

