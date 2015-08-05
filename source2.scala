import java.io.File

val csv = sc.textFile("file:"+new File(".").getCanonicalPath()+"/data/training_set_rel3.tsv")
var coll=sc.textFile("mirordocconcept")

