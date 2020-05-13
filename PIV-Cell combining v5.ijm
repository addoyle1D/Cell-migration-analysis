//Select the Output directory for saving
targetD3= getDirectory("Output directory");


//Select the timelapse file 
TLpath=File.openDialog("Open the 3-color timelapse file");open(TLpath);
run("Make Composite");saveName1=getTitle();rename("Timelapse"); saveName3=replace(saveName1,".tif","");run("Delete Slice", "delete=frame");
waitForUser("Create an ROI around that around the cell at a frame of interest");roiManager("Add");
Stack.setChannel(1); run("Enhance Contrast", "saturated=0.2");run("Magenta");
Stack.setChannel(2); run("Enhance Contrast", "saturated=1.5");run("Green");
Stack.setChannel(3); run("Enhance Contrast", "saturated=0.2");run("Blue");
roiManager("Deselect");

//Select the PIV image file
PIVpath=File.openDialog("Select the 1st image of the PIV series");
run("Bio-Formats", "open=" + PIVpath +" autoscale color_mode=Composite group_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT  contains=PIVlab_out]");
run("RGB Color", "slices"); saveAs("Tiff", targetD3+"PIV-RGB_"+saveName3); rename("PIV-RGB");

//Resize the cell or 3 color image to match the PIV image
selectWindow("PIV-RGB"); getDimensions(W,H,CH,S,FR);
selectWindow("Timelapse");run("Size...", "width=W height=H depth=FR average interpolation=Bilinear");
run("Z Project...", "projection=[Max Intensity]"); 

//Create an ROI for cropping
waitForUser("Create and ROI on the MAX_Timelapse image");
roiManager("Add");
selectWindow("Timelapse");
roiManager("Select", 1);
selectWindow("Timelapse");run("Duplicate...", "title=Timelapse-1 duplicate");;close("Timelapse");selectWindow("Timelapse-1"); saveAs("Tiff", targetD3+saveName3+"-crop");rename("Timelapse");
selectWindow("PIV-RGB");
roiManager("Select", 1);
selectWindow("PIV-RGB");run("Crop");saveAs("Tiff", targetD3+"PIV-RGB_"+saveName3+"-crop");rename("PIV-RGB");close("MAX_Timelapse");

//Create a cell nucleus overlay
selectWindow("Timelapse");run("Duplicate...", "title=DUP-Time duplicate");
selectWindow("PIV-RGB");run("Duplicate...", "title=DUP-PIV-RGB duplicate");
selectWindow("DUP-Time");run("Split Channels");close("C2-DUP-Time");
imageCalculator("Add stack", "C1-DUP-Time","C3-DUP-Time");run("Enhance Contrast", "saturated=0.35");run("Grays");
selectWindow("C1-DUP-Time");saveAs("Tiff", targetD3+"Cell-nuc_"+saveName3+"-crop");rename("DUP");close("C3-DUP-Time");
selectWindow("DUP");run("Merge Channels...", "c1=DUP c2=DUP c3=DUP");
selectWindow("RGB");saveAs("Tiff", targetD3+"Cell-nuc_"+saveName3+"-crop");rename("RGB");
imageCalculator("Add create stack", "RGB","PIV-RGB");saveAs("Tiff", targetD3+"Cell-PIV_"+saveName3+"-crop");
rename("PIV-OV");

//Create a combined stack side by side
selectWindow("Timelapse");run("RGB Color");run("Combine...", "stack1=[Timelapse] stack2=PIV-OV");
saveAs("Tiff", targetD3+"PIV-OV_"+saveName3+"-crop-mon");
run("Close All");roiManager("Deselect");roiManager("Delete");


