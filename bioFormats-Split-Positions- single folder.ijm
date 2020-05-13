inputFolder = getDirectory("Choose the folder containing images to process:");
Dialog.create("How many positions?");
Dialog.addString("Positions", "1");
Dialog.show();
Pos= Dialog.getString();
// Create an output folder based on the inputFolder
parentFolder = getPath(inputFolder); inputFolderPrefix = getPathFilenamePrefix(inputFolder);
outputFolder = inputFolder + inputFolderPrefix + "-splitPositions" + File.separator;
if ( !(File.exists(outputFolder)) ) { File.makeDirectory(outputFolder); }

run("Close All");
setBatchMode(true);

flist = getFileList(inputFolder);

for (i=0; i<flist.length; i++) {
	filename = inputFolder + flist[i];
	filenamePrefix = getFilenamePrefix(flist[i]);

	if ( endsWith(filename, ".nd") || endsWith(filename, ".nd2") || endsWith(filename, ".czi") ) {
		run("Bio-Formats Macro Extensions");
		Ext.setId(filename); Ext.getSeriesCount(seriesCount);
		print(seriesCount);
	
		//for(seriesNum = 0; seriesNum < seriesCount; seriesNum++) {
		for(seriesNum = 0; seriesNum < Pos; seriesNum++) {
			Ext.setSeries(seriesNum);
			Ext.openImagePlus(filename);
			
			saveAs("TIFF",outputFolder+ filenamePrefix + "-pos-" + seriesNum);
			open(filename); id0 = getImageID();
		}
		
		//run("Close All");
	}
}
function processFile(input, targetD, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    selectImage(id0);
            run("Correct 3D drift", "channel=2 multi_time_scale edge_enhance only=5000 lowest=1 highest=31");
selectWindow("registered time points"); //saveAs("Tiff", output+"AL-"+SaveName2);//rename("registered time points");
  
    print("Saving to: " + output); 
    saveAs("TIFF", targetD+"AL_"+filenamePrefix + "-pos-" + seriesNum);//close();
    close(id0);

function getPathFilenamePrefix(pathFileOrFolder) {
	// this one takes full path of the file
	temp = split(pathFileOrFolder, File.separator);
	temp = temp[temp.length-1];
	temp = split(temp, ".");
	return temp[0];
}

function getFilenamePrefix(filename) {
	// this one takes just the file name without folder path
	temp = split(filename, ".");
	return temp[0];
}

function getPath(pathFileOrFolder) {
	// this one takes full path of the file (input can also be a folder) and returns the parent folder path
	temp = split(pathFileOrFolder, File.separator);
	if ( File.separator == "/" ) {
	// Mac and unix system
		pathTemp = File.separator;
		for (i=0; i<temp.length-1; i++) {pathTemp = pathTemp + temp[i] + File.separator;}
	}
	if ( File.separator == "\\" ) {
	// Windows system
		pathTemp = temp[0] + File.separator;
		for (i=1; i<temp.length-1; i++) {pathTemp = pathTemp + temp[i] + File.separator;}
	}
	return pathTemp;
}