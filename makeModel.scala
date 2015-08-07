//make linear regression
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.classification.{LogisticRegressionWithLBFGS, LogisticRegressionModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import java.io.File
import org.apache.commons.io.FileUtils;

var path="file:"+new File(".").getCanonicalPath()


def makeModelSave( name:String, alpha:Int , numClasse:Int) :Int = {
	var dir=path+"/logisticModel_"+name	
	var toDelete=new File(dir)
	if(toDelete.isDirectory())
	{
		toDelete.delete()
	}
	var coll=sc.textFile("file:"+new File(".").getCanonicalPath()+"/docConceptLSAWithLabel_"+name)
	//make labeled point
	var labeled=coll.map(a => a.replaceAll("(\\(|\\))","").split(",")).map(a=>LabeledPoint(a(1).toDouble+alpha,Vectors.dense(a.slice(2,500).map(a=>a.toDouble))))

	// Split data into training (70%) and test (30%).
	val splits = labeled.randomSplit(Array(0.7, 0.3), seed = 11L)
	val training = splits(0).cache()
	val test = splits(1)

	// Run training algorithm to build the model
	val modelLogistic = new LogisticRegressionWithLBFGS().setNumClasses(numClasse).run(training)

	// Compute raw scores on the test set.
	val predictionAndLabels = test.map { case LabeledPoint(label, features) =>
	  val prediction = modelLogistic.predict(features)
	  (prediction, label)
	}

	// Get evaluation metrics.
	val metrics = new MulticlassMetrics(predictionAndLabels)
	val precision = metrics.precision
	
	// Save and load model
	modelLogistic.save(sc, dir)
	val sameModel = LogisticRegressionModel.load(sc, dir)
	return 0
}

makeModelSave( "Essay1", 0-1 , 6) 
makeModelSave( "Essay2", 0-1 , 6) 
makeModelSave( "Essay3", 0 , 4) 
makeModelSave( "Essay4", 0 , 5) 
makeModelSave( "Essay5", 0 , 5) 
makeModelSave( "Essay6", 0 , 5) 
makeModelSave( "Essay7", 0 , 16) 
makeModelSave( "Essay8", 0 , 31) 

