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
sc.parallelize(topConceptTerms).saveAsTextFile("conceptTerms.sav")
sc.parallelize(topConceptDocs).saveAsTextFile("conceptDocs.sav")
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

docConcept.saveAsTextFile("mirordocconcept")
var docConceptRDD=sc.parallelize(docConcept.toSeq)
var toJoin=essay1.map(s=> (s(0),s(3).toDouble))
var joined=toJoin.join(docConceptRDD)

//make labeled point
var labeled=joined.map(a => LabeledPoint(a._2._1, Vectors.dense(a._2._2.toArray)))

//make linear regression
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.linalg.Vectors
val model = LinearRegressionWithSGD.train(labeled, numIterations)

//make logistic regression
import org.apache.spark.SparkContext
import org.apache.spark.mllib.classification.{LogisticRegressionWithLBFGS, LogisticRegressionModel}
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.util.MLUtils
// Run training algorithm to build the model
val model = new LogisticRegressionWithLBFGS().setNumClasses(7).run(labeled)


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
sc.parallelize(termConcept.toSeq).saveAsTextFile("mirortermconcept")


