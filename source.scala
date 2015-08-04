import com.cloudera.datascience.lsa._
import com.cloudera.datascience.lsa.ParseWikipedia._
import com.cloudera.datascience.lsa.RunLSA._
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import breeze.linalg.{DenseMatrix => BDenseMatrix, DenseVector => BDenseVector, SparseVector => BSparseVector}

val csv = sc.textFile("file:/home/cloudera/data/training_set_rel3.tsv")
// split / clean data
val headerAndRows = csv.map(line => line.split("\t").map(_.trim).map(_.replaceAll("(^\"|\"$)","")))
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
var lemmatized=essay1.map(s=> (s(0),ParseWikipedia.plainTextToLemmas(s(2), stopWords, ParseWikipedia.createNLPPipeline())))
val filtered = lemmatized.filter(_._2.size > 1)

val numTerms = 1000
val (termDocMatrix, termIds, docIds, idfs) = ParseWikipedia.termDocumentMatrix(filtered, stopWords, numTerms, sc)

val mat = new RowMatrix(termDocMatrix)
val k = 200 // nombre de valeurs singuliers à garder
val svd = mat.computeSVD(k, computeU=true)
val topConceptTerms = RunLSA.topTermsInTopConcepts(svd, 30, 30, termIds)
val topConceptDocs = RunLSA.topDocsInTopConcepts(svd, 30, 30, docIds)
    for ((terms, docs) <- topConceptTerms.zip(topConceptDocs)) {
              println("Concept terms: " + terms.map(_._1).mkString(", "));
              println("Concept docs: " + docs.map(_._1).mkString(", "));
              println();
           }
var all=new EmptyRDD[String,Double](sc)
for ( a <- topConceptDocs) {
 all=all.join(sc.parallelize(a))
}
