Table tableEssay1;
Table tableEssay2;
Table tableEssay3;
Table tableEssay4;
Table tableEssay5;
Table tableEssay6;
Table tableEssay7;
Table tableEssay8;

color []inside = new color[11];

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
  inside[0]=color(117,112,179);
  inside[1]=color(27, 158,119);
  inside[2]=color(217,95,2);
  inside[3]=color(244,165,130);
  inside[4]=color(253,219,199);
  inside[5]=color(247,247,247);
  inside[6]=color(209,229,240);
  inside[7]=color(146,197,222);
  inside[8]=color(67,147,195);
  inside[9]=color(33,102,172);
  inside[10]=color(5,48,97);
  
  println(tableEssay1.getRowCount() + " total rows in table"); 

  for (TableRow row : tableEssay1.rows()) {
    
    int id = row.getInt(1);
    String species = row.getString(2);
    String name = row.getString(0);
    
  }
  println(tableEssay1.getRowCount() + " total rows in table"); 

  
}

void draw(){
  noStroke();
  pushMatrix();
  int pixelsizeH=1;
  int pixelsizeW=6;
  for (TableRow row : tableEssay1.rows()) {
    translate(0, pixelsizeH);

    String name = row.getString(0);
    for (int i=1;i<row.getColumnCount();i++)
    {
      translate(pixelsizeW, 0);

      float value=row.getFloat(i);
      fill(inside[(int)map(value, -0.7, 0.7,0, 2)]);
      rect(0, 0, pixelsizeW, pixelsizeH);
    }
    translate(-pixelsizeW*(row.getColumnCount()-1), 0);
    
    
  }
  popMatrix();

}
