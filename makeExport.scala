//make export
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


def makeExportSave( name:String) :Int = {
	new File("./DocConcept_"+name+".csv").delete()
	new File("./TermConcept_"+name+".csv").delete()
	var coll=sc.textFile("file:"+new File(".").getCanonicalPath()+"/docConceptLSAWithLabel_"+name)
	
	// Save metrics
	

	coll.map(a => a.replaceAll("(\\(|\\))","")).foreach(label => 
	{
		var writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/DocConcept_"+name+".csv" ,true))
		writer.println(label)
		writer.close()
	})
      	
	coll=sc.textFile("file:"+new File(".").getCanonicalPath()+"/termConceptLSA_"+name)
	
	// Save metrics
	

	coll.map(a => a.replaceAll("(\\(|\\))","")).foreach(label => 
	{
		var writer = new PrintWriter(new FileWriter(new File(".").getCanonicalPath()+"/TermConcept_"+name+".csv" ,true))
		writer.println(label)
		writer.close()
	})
	
	return 0
}
new File(new File(".").getCanonicalPath()+"/ResultTest.csv").delete()
new File(new File(".").getCanonicalPath()+"/ModelTest.csv").delete()
makeExportSave( "Essay1") 
makeExportSave( "Essay2") 
makeExportSave( "Essay3") 
makeExportSave( "Essay4") 
makeExportSave( "Essay5") 
makeExportSave( "Essay6") 
makeExportSave( "Essay7") 
makeExportSave( "Essay8") 

