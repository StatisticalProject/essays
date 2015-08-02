val csv = sc.textFile("data/training_set_rel3.tsv")
// split / clean data
val headerAndRows = csv.map(line => line.split("\t").map(_.trim))
// get header
val header = headerAndRows.first
// filter out header (eh. just check if the first val matches the first header name)
val data = headerAndRows.filter(_(0) != header(0))
data.foreach(println)
