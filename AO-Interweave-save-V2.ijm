TLpath=File.openDialog("Open the ECM file");open(TLpath);
SaveName =getTitle();
imgID = getImageID();
SaveName2=replace(SaveName, ".tif","");
//targetD = getDirectory("Target Directory");
//targetD3= targetD+"IW Files"+File.separator;
//File.makeDirectory(targetD3);
Stack.getDimensions(width, height, channels, slices, frames);
tempName = "Null-Stack";
newImage(tempName, "16-bit black", width, height, nSlices);

// go to the 1st slice of source and copy it
selectImage(imgID);
Stack.setSlice(1);
run("Select All");
run("Copy");

// go to new black image and paste them
selectWindow(tempName);
for (i = 0; i < nSlices; i++) {
	Stack.setSlice(i+1);
	run("Paste");
}
selectWindow(SaveName); rename("Second");
Stack.setSlice(1);
run("Delete Slice");

selectWindow(tempName); rename("First");
Stack.setSlice(1);
run("Delete Slice");

run("Interleave", "stack_1=First stack_2=Second");selectWindow("Combined Stacks"); rename(SaveName2);
run("Image Sequence... ", "format=TIFF digits=3 save=[D:/ECM IW files/SaveName000.tif]");
close("First"); close("Second");
