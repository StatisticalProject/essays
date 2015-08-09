//make linear regression
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.mllib.regression.LinearRegressionModel
import org.apache.spark.mllib.regression.LinearRegressionWithSGD
import org.apache.spark.mllib.classification.{LogisticRegressionWithLBFGS, LogisticRegressionModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.evaluation.MulticlassMetrics
import java.io.File
import java.io._
import util.control.Breaks._
import org.apache.commons.io.FileUtils

var path="file:"+new File(".").getCanonicalPath()


def makeModelSave( name:String, alpha:Int , numClasse:Int, threshold:Double, choixModel:Array[Int],saveIn:Boolean) :Double = {
	var dir=path+"/logisticSelectModel_"+name	
	new File("./PredictSelect_"+name+".csv").delete()
	var toDelete=new File(dir)
	if(toDelete.isDirectory())
	{
		toDelete.delete()
	}
	var coll=sc.textFile("file:"+new File(".").getCanonicalPath()+"/docConceptLSAWithLabel_"+name)
	//make labeled point
	var labeled=coll.map(a => a.replaceAll("(\\(|\\))","").split(",")).map(a=>LabeledPoint(a(1).toDouble+alpha,Vectors.dense(choixModel.map(b=>a.slice(2,500).map(a=>a.toDouble).apply(b)))))

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
	if(saveIn){
		predictionAndLabels.foreach(label => 
		{
			var writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/PredictSelect_"+name+".csv" ,true))
			writer.println(label._1+","+label._2)
			writer.close()
		})
	}
      	

	// Get evaluation metrics.
	val metrics = new MulticlassMetrics(predictionAndLabels)
	// Save metrics
	if(saveIn){
		var writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/ResultSelectTest.csv" ,true))
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
	
		writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/ModelSelectTest.csv" ,true))
		writer.println(name+","+modelLogistic.weights.toArray.mkString(","))
		writer.close()
		modelLogistic.save(sc, dir)
	}
	//val sameModel = LogisticRegressionModel.load(sc, dir)
	return metrics.precision 
}

var th=0.5
var precGl= -1.0

def makeBestModelSave( name:String, alpha:Int , numClasse:Int, threshold:Double) :Double = {
var globaArr=Array[Int]()
var globaWin=Array[Int]()
breakable{
	for( i<-0 to 29){
		var columnChoice=0
		
		var hasChanged=false
		var precBest= -1.0
		var injected=globaArr.toSet
		for( j<-0 to 29){
			if(!injected.contains(j)){
				columnChoice=j
			}
		}
		for( j<-0 to 29){
			if(!injected.contains(j)){
				val marray=globaArr.union(Array(i))
				val prec=makeModelSave( name, alpha , numClasse,threshold,marray,false)
				if(precBest<prec){
					precBest=prec
					columnChoice=j
					hasChanged=true
				}
			}
		}
		if(hasChanged){
			if (precGl<precBest){
				
				globaWin=globaArr.union(Array(columnChoice))
				precGl=precBest
				var writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/SelectTest.csv" ,true))
				writer.println(name+","+globaWin.mkString(",")+","+precBest)
				writer.close()
			}
			globaArr=globaArr.union(Array(columnChoice))
		}else{
			break
		}
	}
}

makeModelSave( name, alpha , numClasse,threshold,globaWin,true)
	return 0.0
}
new File("./SelectTest.csv").delete()
makeBestModelSave( "Essay1", 0-1 , 6,th) 
//makeModelSave( "Essay2", 0-1 , 6,th) 
//makeModelSave( "Essay3", 0 , 4,th) 
//makeModelSave( "Essay4", 0 , 4,th) 
//makeModelSave( "Essay5", 0 , 5,th) 
//makeModelSave( "Essay6", 0 , 5,th) 
//makeModelSave( "Essay7", 0 , 13,th) 
//makeModelSave( "Essay8", 0-5 , 26,th) 



