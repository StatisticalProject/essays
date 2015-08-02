import com.cloudera.datascience.lsa._
import com.cloudera.datascience.lsa.ParseWikipedia._
import com.cloudera.datascience.lsa.RunLSA._
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import breeze.linalg.{DenseMatrix => BDenseMatrix, DenseVector => BDenseVector, SparseVector => BSparseVector}

val csv = sc.textFile("file:/home/cloudera/data/training_set_rel3.tsv")
// split / clean data
val headerAndRows = csv.map(line => line.split("\t").map(_.trim))
// get header
val header = headerAndRows.first
// filter out header (eh. just check if the first val matches the first header name)
val data = headerAndRows.filter(_(0) != header(0))
//data.foreach(println)

var essay1=data.filter(a=>a(1).equals("1"))
var essay2=data.filter(a=>a(1).equals("2"))
var essay3=data.filter(a=>a(1).equals("3"))
var essay4=data.filter(a=>a(1).equals("4"))
var essay5=data.filter(a=>a(1).equals("5"))
var essay6=data.filter(a=>a(1).equals("6"))
var essay7=data.filter(a=>a(1).equals("7"))
var essay8=data.filter(a=>a(1).equals("8"))

val stopWords = sc.broadcast(ParseWikipedia.loadStopWords("deps/lsa/src/main/resources/stopwords.txt")).value
