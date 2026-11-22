// Single-click pipeline: duplicate -> 3D median (3px,9px) -> 3D edge -> 3D hysteresis -> OR -> 3D simple seg -> mask -> 3D closing (MorphoLibJ)
// Assumes: original image is open and active. Requires 3D Suite (3D Median, 3D Edge, 3D hysteresis, 3D simple segmentation) and MorphoLibJ installed.
orig = getTitle();
// --- branch A: 3px median -> edge -> hysteresis
selectWindow("Title of original image");
 // 3D median filter (3 px radius in x,y,z)
run("Median 3D...", "x=3 y=3 z=3");
rename("med_3px");
 // 3D edge filter (using the exact command you provided)
selectWindow("med_3px");
run("3D Edge and Symmetry Filter", "alpha=1.000 radius=5 normalization=10 scaling=2");
rename("edge_med_3px");
close("med_3px");
 // 3D hysteresis thresholding for the 3px branch
selectWindow("edge_med_3px");
run("3D Hysteresis Thresholding", "seeds=None high=16 low=15");
rename("hyst_med_3px");
close("edge_med_3px");
// --- branch B: 9px median -> edge -> hysteresis
selectWindow("Title of original image ");
 // 3D median filter (9 px radius in x,y,z)
run("Median 3D...", "x=9 y=9 z=9");
rename("med_9px");
 // 3D edge filter
selectWindow("med_9px");
run("3D Edge and Symmetry Filter", "alpha=1.000 radius=5 normalization=10 scaling=2");
rename("edge_med_9px");
close("med_9px");
 // 3D hysteresis thresholding for the 9px branch
selectWindow("edge_med_9px");
run("3D Hysteresis Thresholding", "seeds=None high=7 low=5");
rename("hyst_med_9px");
close("edge_med_9px");
// --- Combine the two hysteresis results with OR
imageCalculator("OR create stack", "hyst_med_3px", "hyst_med_9px");
rename("combined_OR");
// --- 3D simple segmentation on the combined image
selectWindow("combined_OR");
run("3D Simple Segmentation", "low_threshold=1 min_size=3000 max_size=-1");
selectImage("Bin");
close();
selectImage("Seg");
setThreshold(1, 10e30);
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");
run("Invert LUT");
rename("seg_mask");
// MorphoLibJ 3D closing call. Plugin command strings can vary by version; this is a common form:
selectWindow("seg_mask");
run("Morphological Filters (3D)", "operation=Closing element shape=Ball x-radius=5 y-radius=5 z-radius=5");
rename("seg_mask_closed");
// Done
