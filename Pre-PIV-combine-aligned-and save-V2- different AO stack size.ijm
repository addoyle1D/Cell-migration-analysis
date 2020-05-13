//Select the Output directory for saving
output = getDirectory("Output directory");
targetD3= output+"Aligned-ECM"+File.separator;
File.makeDirectory(targetD3);

//Select the timelapse file 
TLpath=File.openDialog("Open the timelapse file");open(TLpath);
run("Make Composite");saveName1=getTitle();rename("Main");

//select the AO file
AOpath=File.openDialog("Open the AO file");open(AOpath);
run("Make Composite");saveName2=getTitle();waitForUser("Select top and bottom for substack");
run("Make Substack...");rename("AO");close(saveName2);

//Concatenate and align the combined file
run("Concatenate...", "open image1=AO image2=Main");
rename("Combined");
run("Correct 3D drift", "channel=2 only=7500 lowest=1 highest=31");

//Create a substack
selectWindow("registered time points");
waitForUser("Select top and bottom for substack");
run("Make Substack...");close("registered time points"); //close("Untitled");
saveName3=replace(saveName1,".tif","");close("Combined");

//Create a mask and ROi to crop the images
selectWindow("registered time points-1");run("Duplicate...", "title=DUP duplicate");
selectWindow("DUP");
run("Split Channels");
selectWindow ("C1-DUP");close();selectWindow ("C3-DUP");close();
selectWindow ("C2-DUP");
run("Z Project...", "projection=[Min Intensity] all");selectWindow("MIN_C2-DUP");
run("Z Project...", "projection=[Min Intensity]");selectWindow("MIN_MIN_C2-DUP");
setThreshold(1, 65535);
setTool("wand");
doWand(250,250);
run("ROI Manager...");
roiManager("Add");
selectWindow("registered time points-1");
roiManager("Select", 0);
run("Crop");
close("MIN_C2-DUP");
close("MIN_MIN_C2-DUP");

//Create a MIP image of the  3-color stack and save both versions
selectWindow("registered time points-1");
run("Z Project...", "projection=[Max Intensity] all");
selectWindow("MAX_registered time points-1");
saveAs("Tiff", output+"AL_MAX_"+saveName3);
selectWindow("registered time points-1");saveAs("Tiff", output+ "AL_"+saveName3);

//Split the cropped image and save the Max version of each 
rename("Stack");
run("Split Channels");
selectWindow ("C2-Stack");
roiManager("Select", 0);run("Crop");run("Z Project...", "projection=[Max Intensity] all"); run("Enhance Contrast", "saturated=0.30");
saveAs("Tiff", targetD3+"AL_MAX_"+saveName3+"_ECM");close("AL_MAX_"+saveName3+"_ECM");

selectWindow ("C1-Stack");
roiManager("Select", 0);run("Crop");run("Z Project...", "projection=[Max Intensity] all");setSlice(1);run("Delete Slice", "delete=frame");run("Enhance Contrast", "saturated=0.30");
run("Enhance Contrast", "saturated=0.02");
saveAs("Tiff", output+"AL_MAX_"+saveName3+"_Cell");close("AL_MAX_"+saveName3+"_Cell");

selectWindow ("C3-Stack");
roiManager("Select", 0);run("Crop");run("Z Project...", "projection=[Max Intensity] all");setSlice(1);run("Delete Slice", "delete=frame");run("Enhance Contrast", "saturated=0.30");
saveAs("Tiff", output+"AL_MAX_"+saveName3+"_Nuc");close(saveName3+"_Nuc");
run("Close All");roiManager("Deselect");roiManager("Delete");
