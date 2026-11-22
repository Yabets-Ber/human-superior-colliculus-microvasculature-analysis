// Define your classes here
def manualClassName = "Neuron or Glia Ground Truth"
def autoClassName = "Neuron or Glia detections"

def manualClass = getPathClass(manualClassName)
def autoClass = getPathClass(autoClassName)

// Get objects
def allDetections = getDetectionObjects().findAll { it.getPathClass() == autoClass }
def allManualPoints = getAnnotationObjects().findAll { it.getPathClass() == manualClass }

if (allDetections.isEmpty() && allManualPoints.isEmpty()) {
    println "No objects found for classes: $manualClassName / $autoClassName"
    return
}

// 1. True Positives (TP): Auto-detections containing at least one manual marker
def tpDetections = allDetections.findAll { det ->
    allManualPoints.any { pnt -> det.getROI().contains(pnt.getROI().getCentroidX(), pnt.getROI().getCentroidY()) }
}
double tp = tpDetections.size()

// 2. False Positives (FP): Auto-detections that do NOT contain a manual marker
double fp = allDetections.size() - tp

// 3. False Negatives (FN): Manual markers that are NOT inside any auto-detection
double fn = allManualPoints.findAll { pnt ->
    !allDetections.any { det -> det.getROI().contains(pnt.getROI().getCentroidX(), pnt.getROI().getCentroidY()) }
}.size()

// Calculate Metrics
double precision = (tp + fp > 0) ? (tp / (tp + fp)) : 0
double recall = (tp + fn > 0) ? (tp / (tp + fn)) : 0
double f1 = (precision + recall > 0) ? (2 * (precision * recall) / (precision + recall)) : 0

// Print Report
println "--- Performance Report for $autoClassName ---"
println String.format("TP: %.0f | FP: %.0f | FN: %.0f", tp, fp, fn)
println String.format("Precision: %.2f%%", precision * 100)
println String.format("Recall: %.2f%%", recall * 100)
println String.format("F1-Score: %.4f", f1)
