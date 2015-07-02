boxSize = 7; // box size in pixels
framesForAvg = 10; // how many frames to use for image avg

currDir = getDirectory("image"); // current directory
saveDir = currDir+"\\SubunitCount";
imgDir = saveDir+"\\Images";
traceDir = saveDir+"\\Traces";

File.makeDirectory(saveDir);
File.makeDirectory(imgDir);
File.makeDirectory(traceDir);
getDimensions(width, height, channels, slices, frames);
imageID = getImageID();
imageName = getInfo("image.filename");
dotIndex = indexOf(imageName, "."); 
imageName = substring(imageName, 0, dotIndex); 


s = selectionType();

if( s == -1 ) {
	exit("There was no selection.");
} else if( s != 10 ) {
	exit("The selection wasn't a point selection.");
} else {
	getSelectionCoordinates(xPoints,yPoints);
	numPoints = xPoints.length;
}
saveAs("xy Coordinates", saveDir+"\\"+imageName+"_selectionCoords.txt");


offset = boxSize / 2;
run("Set Measurements...", "mean redirect=None decimal=3");

for (i=0; i<numPoints; i++) {
	selectImage(imageID);
	makeRectangle(xPoints[i]-offset, yPoints[i]-offset, boxSize, boxSize);
	
	run("Plot Z-axis Profile");
	close();
	saveAs("results", traceDir+"\\"+imageName+"_profile"+IJ.pad(i,3)+".txt");
	run("Clear Results");

	run("Duplicate...", "title=selection.fits duplicate range=1-framesForAvg");
	imageDuplicate = getImageID();
	run("Z Project...", "start=1 stop=framesForAvg projection=[Average Intensity]");
	saveAs("PNG", imgDir+"\\"+imageName+"_avgImage"+IJ.pad(i,3));
	close();
	selectImage(imageDuplicate);
	close();
	
}
