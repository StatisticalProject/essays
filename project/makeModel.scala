//make linear regression
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.classification.{LogisticRegressionWithLBFGS, LogisticRegressionModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import java.io.File
import java.io._

import org.apache.commons.io.FileUtils

var path="file:"+new File(".").getCanonicalPath()
var nbConcept=30

def makeModelSave( name:String, alpha:Int , numClasse:Int, threshold:Double) :Int = {
	var dir=path+"/logisticModel_"+name	
	new File("./Predict_"+name+".csv").delete()
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
        modelLogistic.clearThreshold()
	modelLogistic.setThreshold(threshold)

	// Compute raw scores on the test set.
	val predictionAndLabels = test.map { case LabeledPoint(label, features) =>
	  val prediction = modelLogistic.predict(features)
	  (prediction, label)
	}

	// Save PREDICT
	
	predictionAndLabels.foreach(label => 
	{
		var writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/Predict_"+name+".csv" ,true))
		writer.println(label._1+","+label._2)
		writer.close()
	})
      	

	// Get evaluation metrics.
	val metrics = new MulticlassMetrics(predictionAndLabels)
	// Save metrics
	var writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/ResultTest.csv" ,true))
	var key=name+","+threshold+",T,"+metrics.precision+","+metrics.recall+","+metrics.fMeasure
	writer.println(key)
	metrics.labels.foreach(label => 
	{
		key=name+","+threshold+","+label+","+metrics.precision(label)+","+metrics.recall(label)+","
		key+=metrics.fMeasure(label)
		writer.println(key)
	})
      	writer.close()
	
	// Save and load model
	
	writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/ModelTest.csv" ,true))
	var begin=0
	var end=nbConcept
	var label=0;
	while(modelLogistic.weights.toArray.slice(begin,end).length>0){
		writer.println(name+","+label+","+modelLogistic.weights.toArray.slice(begin,end).mkString(","))
		begin=end
		end=begin+nbConcept
		label+=1
	}
	
	writer.close()
	modelLogistic.save(sc, dir)
	//val sameModel = LogisticRegressionModel.load(sc, dir)
	return 0
}
new File(new File(".").getCanonicalPath()+"/ResultTest.csv").delete()
new File(new File(".").getCanonicalPath()+"/ModelTest.csv").delete()
var th=0.5
makeModelSave( "Essay1", 0-1 , 6,th) 
makeModelSave( "Essay2", 0-1 , 6,th) 
makeModelSave( "Essay3", 0 , 4,th) 
makeModelSave( "Essay4", 0 , 4,th) 
makeModelSave( "Essay5", 0 , 5,th) 
makeModelSave( "Essay6", 0 , 5,th) 
makeModelSave( "Essay7", 0 , 13,th) 
makeModelSave( "Essay8", 0-5 , 26,th) 



