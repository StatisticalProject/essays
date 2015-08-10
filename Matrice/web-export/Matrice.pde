Table table;

void setup() {
  
  table = loadTable("mammals.csv", "header");

  println(table.getRowCount() + " total rows in table"); 

  for (TableRow row : table.rows()) {
    
    int id = row.getInt("id");
    String species = row.getString("species");
    String name = row.getString("name");
    
    println(name + " (" + species + ") has an ID of " + id);
  }
  
}

