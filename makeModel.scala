//make linear regression
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.linalg.Vectors

var name="Essay1"
var coll=sc.textFile("docConceptLSAWithLabel_"+name)
//make labeled point
var labeled=coll.map((a,b) => LabeledPoint(a._2._1, Vectors.dense(a._2._2.toArray)))


val model = LinearRegressionWithSGD.train(labeled, numIterations)

