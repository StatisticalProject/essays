//make linear regression
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.classification.{LogisticRegressionWithLBFGS, LogisticRegressionModel}
import org.apache.spark.mllib.linalg.Vectors

var name="Essay1"
var alpha=0-1
var numClasse=6
var numIterations=1
var coll=sc.textFile("docConceptLSAWithLabel_"+name)
//make labeled point
var labeled=coll.map(a => a.replaceAll("(\\(|\\))","").split(",")).map(a=>LabeledPoint(a(1).toDouble+alpha,Vectors.dense(a.slice(2,500).map(a=>a.toDouble))))

val model = LinearRegressionWithSGD.train(labeled, numIterations)

// Run training algorithm to build the model
val modelLogistic = new LogisticRegressionWithLBFGS().setNumClasses(numClasse).run(labeled)

