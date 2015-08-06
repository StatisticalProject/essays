import java.io.File

import com.cloudera.datascience.lsa._
import com.cloudera.datascience.lsa.ParseWikipedia._
import com.cloudera.datascience.lsa.RunLSA._
import org.apache.spark.rdd.EmptyRDD
import scala.collection.mutable.ListBuffer
import org.apache.spark.mllib.linalg._
import org.apache.spark.mllib.linalg.distributed.RowMatrix
import breeze.linalg.{DenseMatrix => BDenseMatrix, DenseVector => BDenseVector, SparseVector => BSparseVector}
import org.apache.spark.mllib.regression._
import org.apache.spark.rdd._

val csv = sc.textFile("file:"+new File(".").getCanonicalPath()+"/data/training_set_rel3.tsv")
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

val stopWordsIn = sc.broadcast(ParseWikipedia.loadStopWords("deps/lsa/src/main/resources/stopwords.txt")).value
val numTerms = 500
val k = 100 // nombre de valeurs singuliers à garder
val nbConcept = 20

def makeLSAAndSave( essay:RDD[Array[String]], column:Int , name:String,stopWords:Set[String]) :Int = {
  var lemmatized=essay.map(s=> (s(0),ParseWikipedia.plainTextToLemmas(s(2), stopWords, ParseWikipedia.createNLPPipeline())))
  val filtered = lemmatized.filter(_._2.size > 1)
  val documentSize=essay.collect().length
  println("Documents Size : "+documentSize)
  println("Number of Terms : "+numTerms)
  val (termDocMatrix, termIds, docIds, idfs) = ParseWikipedia.termDocumentMatrix(filtered, stopWords, numTerms, sc)

  val mat = new RowMatrix(termDocMatrix)

  val svd = mat.computeSVD(k, computeU=true)
  val topConceptTerms = RunLSA.topTermsInTopConcepts(svd, nbConcept, numTerms, termIds)
  val topConceptDocs = RunLSA.topDocsInTopConcepts(svd, nbConcept, documentSize, docIds)

  var all=sc.emptyRDD[(String,Double)]
  import collection.mutable.HashMap
  val docConcept = new HashMap[String,ListBuffer[Double]]()
  var count=0
  for ( a <- topConceptDocs) {
    count+=1
    for ( (b,c) <- a) {
      if (!docConcept.contains(b)) {
        docConcept.put(b, new ListBuffer[Double]())
      }
      docConcept(b) += c
    }
    for((k,v) <- docConcept){
      while(v.size<count){
        v+=0.0
      }
    }
  }
  //Add notes


  var docConceptRDD=sc.parallelize(docConcept.toSeq)
  var toJoin=essay.map(s=> (s(0),s(column).toDouble))
  var joined=toJoin.join(docConceptRDD)
  joined.saveAsTextFile("docConceptLSAWithLabel_"+name)
  //make labeled point
  var labeled=joined.map(a => LabeledPoint(a._2._1, Vectors.dense(a._2._2.toArray)))

  val termConcept = new HashMap[String,ListBuffer[Double]]()
  count=0
  for ( a <- topConceptTerms) {
    count+=1
    for ( (b,c) <- a) {
      if (!termConcept.contains(b)) {
        termConcept.put(b, new ListBuffer[Double]())
      }
      termConcept(b) += c
    }
    for((k,v) <- termConcept){
      while(v.size<count){
        v+=0.0
      }
    }
  }
  sc.parallelize(termConcept.toSeq).saveAsTextFile("termConceptLSA_"+name)
  return 0
}

makeLSAAndSave(essay1,3,"Essay1",stopWordsIn)
makeLSAAndSave(essay2,3,"Essay2",stopWordsIn)
makeLSAAndSave(essay3,3,"Essay3",stopWordsIn)
makeLSAAndSave(essay4,3,"Essay4",stopWordsIn)
makeLSAAndSave(essay5,3,"Essay5",stopWordsIn)
makeLSAAndSave(essay6,3,"Essay6",stopWordsIn)
makeLSAAndSave(essay7,3,"Essay7",stopWordsIn)
makeLSAAndSave(essay8,3,"Essay8",stopWordsIn)




