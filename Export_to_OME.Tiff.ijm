/*****************************************************************************
 *  Author Dr. Ioannis Alexopoulos
 * The author of the macro reserve the copyrights of the original macro.
 * However, you are welcome to distribute, modify and use the program under 
 * the terms of the GNU General Public License as stated here: 
 * (http://www.gnu.org/licenses/gpl.txt) as long as you attribute proper 
 * acknowledgement to the author as mentioned above.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *****************************************************************************
 * Description of macro
 * --------------------
 * Export to (OME) tiff
 * 
 * The macro can be use to export images from proprietary formats to .tiff or ome.tiff
 * The macro reads all the contents of a folder exlcuding subfolders and for each image file
 * (or each series of an image container file), opens and exports using the BioFormats plugin.
 * 
 * Limitations:
 * If one of the images (or series) cannot be imported with BioFormats, then this macro 
 * will stop reporting the error.
 * 
 * 
 */
html = "<html>"+"<h2>License</h2>" +"<font size=+1>"
     +"  Author Dr. Ioannis Alexopoulos<br>"
     +"The author of the macro reserve the copyrights of the original macro.<br>"
     +"However, you are welcome to distribute, modify and use the program under <br>"
     +"the terms of the GNU General Public License as stated here: <br>"
     +"(http://www.gnu.org/licenses/gpl.txt) <u>as long as you attribute proper <br>"
     +"acknowledgement to the author as mentioned above</u>.<br>"
     +"This program is distributed in the hope that it will be useful,<br>"
     +"but WITHOUT ANY WARRANTY; without even the implied warranty of<br>"
     +"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the<br>"
     +"GNU General Public License for more details.<br>"
     +"<br>"
     +"<b>Description of macro</b><br>"
     +"Export to (OME) tiff<br>"
     +""
     +"The macro can be use to export images from proprietary formats to .tiff or ome.tiff<br>"
     +"The macro reads all the contents of a folder exlcuding subfolders and for each image file<br>"
     +"(or each series of an image container file), opens and exports using the BioFormats plugin.<br>"
	 +"It also gives the option to save maximum intesities projections of z-stack or individual channels.<br>"
 	 +"<br>"
     +"<b>Limitations:</b><br>"
     +"In case you process the contents of a folder, make sure that only image files are contained in this folder.<br>"
     +"There is no problem if other sub-folders are within the processed directory.<br>"
     +"If one of the images (or series) cannot be imported with BioFormats, then this macro <br>"
     +"will stop, reporting the error.<br>";
     
// Create dialog, create save folders, and select file(s) to process
SaveOptions=newArray(3);
SaveOptions[0]="Tiff";
SaveOptions[1]="Ome Tiff";
SaveOptions[2]="Do Not Export";
Dialog.createNonBlocking("Parameters");
Dialog.addMessage("     Export Original Raw Images", 18, "#FF6633");
Dialog.addMessage("");
Dialog.addCheckbox("Analyse single image container file", false);
Dialog.addChoice("Export As...: ", SaveOptions, "Ome Tiff");
Dialog.addCheckbox("Save a MIP (Maximum Intensity Projection)", false);
Dialog.addCheckbox("Split multi-channel images", false);
Dialog.addMessage("");
Dialog.addString("Name of saving folder: ", "_Export");
Dialog.addMessage("");
Dialog.addMessage("");
Dialog.addMessage("Macro written from Ioannis Alexopoulos for Multiscale Imaging Platform.\nPress Help button for more info", 9, "#0000FF");
Dialog.addHelp(html);
Dialog.show();

  

// Variables of Dialog
single_file=Dialog.getCheckbox();
saveAsOption=Dialog.getChoice();
MIP=Dialog.getCheckbox();
SplitChannels=Dialog.getCheckbox();
save_folder=Dialog.getString();
if (saveAsOption=="Do Not Export" && MIP==false && SplitChannels==false){
	exit("None of the export options was selected. This macro has nothing to do!");
}

sep = File.separator;
if (single_file)
{
	Filelist=newArray(1);
	Filelist[0] = File.openDialog("Select a file to proccess...");
	SourceDir=File.getParent(Filelist[0]);
	Filelist[0]=File.getName(Filelist[0]);
	save_folder_name_add=Filelist[0];
	SAVE_DIR=SourceDir;
	run("Bio-Formats Macro Extensions");
	Ext.setId(SourceDir+sep+Filelist[0]);
	Ext.getSeriesCount(SERIES_COUNT);
	// Create arrays...
	SERIES_NAMES=newArray(SERIES_COUNT);
	default_check_box_values=newArray(SERIES_COUNT);
	SERIES_2_OPEN=newArray(SERIES_COUNT);
	
	// Create the dialog
	rows=10;
	columns=(SERIES_COUNT/10)+1;
	Dialog.create("Select Series to Analyze");
	if(SERIES_COUNT == 1){default_check_box=true;}else{default_check_box=false;}
	for (i=0; i<SERIES_COUNT; i++) {
		// Get series names and channels count
		Ext.setSeries(i);
		SERIES_NAMES[i]="";
		Ext.getSeriesName(SERIES_NAMES[i]);
		default_check_box_values[i]=default_check_box;
	}
	Dialog.addCheckboxGroup(rows,columns,SERIES_NAMES,default_check_box_values);
	Dialog.addCheckbox("Select All", true);
	Dialog.show();
	for (i=0; i<SERIES_COUNT; i++)
	{
		SERIES_2_OPEN[i]=Dialog.getCheckbox();
	}
	select_all=Dialog.getCheckbox();
	if (select_all)
	{
		for (i=0; i<SERIES_COUNT; i++)
		{
			SERIES_2_OPEN[i]=select_all;
		}
	}
	// Check if user selected image
	ok_to_proc=0;
	for(i=0; i<SERIES_COUNT; i++){
		if(SERIES_2_OPEN[i]==1){
			ok_to_proc=1;
		}
	}
	if(ok_to_proc<1){
		exit("Please Select an image to open")
	}
}else
{
	SourceDir = getDirectory("Choose source directory");
	Filelist=getFileList(SourceDir);
	SAVE_DIR=SourceDir;
	save_folder_name_add=File.getName(SourceDir);
	SERIES_2_OPEN=newArray(1);
	SERIES_2_OPEN[0]=1;
}

save_folder=save_folder+"_"+save_folder_name_add;
// Remove Folders from Filelist array
tmp=newArray();
for(k=0;k<Filelist.length;k++)
{
	if (!File.isDirectory(SourceDir+"/"+Filelist[k]))
	{
		tmp = Array.concat(tmp,Filelist[k]); 
	}
}
Filelist=tmp;

//getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
//month=month+1;
//save_folder=save_folder+"_"+year+"_"+month+"_"+dayOfMonth+"_"+hour+"_"+minute+"_"+second;
new_folder=SAVE_DIR + sep + save_folder;
File.makeDirectory(new_folder);
run("Input/Output...", "jpeg=85 gif=-1 file=.xls copy_row save_column save_row");
setBatchMode(true);
for (k=0;k<Filelist.length;k++)
{
	if(!endsWith(Filelist[k], sep))
	{
		run("Bio-Formats Macro Extensions");
		Ext.setId(SourceDir+sep+Filelist[k]);
		Ext.getSeriesCount(SERIES_COUNT);
		FILE_PATH=SourceDir + sep + Filelist[k];
		for (i=0;i<SERIES_COUNT; i++) 
		{
			if(single_file){
				if(SERIES_2_OPEN[i]==1){
						options="open=["+ FILE_PATH + "] " + "autoscale color_mode=Default view=Hyperstack stack_order=XYCZT " + "series_"+d2s(i+1,0) + " use_virtual_stack";
						run("Bio-Formats Importer", options);
				//		FILE_NAME=File.getName(FILE_PATH);
						FILE_NAME=File.nameWithoutExtension;
						Ext.setSeries(i);
						Ext.getSeriesName(SERIES_NAMES2);
						SERIES_NAMES2=replace(SERIES_NAMES2, " ", "_");
						SERIES_NAMES2=replace(SERIES_NAMES2, "/", "_");
						SERIES_NAMES2=replace(SERIES_NAMES2, "\\(", "");
						SERIES_NAMES2=replace(SERIES_NAMES2, "\\)", "_");
						SAVE_NAME=FILE_NAME+"_"+SERIES_NAMES2;
						if(saveAsOption == "Ome Tiff"){
							run("Bio-Formats Exporter", "save=["+new_folder+sep+SAVE_NAME+".ome.tiff] compression=Uncompressed");
						}else if(saveAsOption == "Do Not Export"){
							print ("Not to save was selected");
						}else{
							saveAs("tif", new_folder+sep+SAVE_NAME);
						}
						getDimensions(width, height, channels, slices, frames);
						if (MIP){
							if(slices >1){
								run("Z Project...", "projection=[Max Intensity] all");
								saveAs("tif", new_folder+sep+SAVE_NAME+"_MAX");
							}else{
								print ("Selected image "+SAVE_NAME+" is not a z-stack");
							}
						}
						if(SplitChannels){
							if(channels>1){
								for(ch=1;ch<=channels;ch++){
									run("Duplicate...", "duplicate channels="+ch+"");
									saveAs("tif", new_folder+sep+SAVE_NAME+"_Ch"+ch);
									close();
								}
							}else{
								print ("Selected image "+SAVE_NAME+" is not a multi-channel image");
							}
						}
						run("Close All");
				}
			}else{
				 	options="open=["+ FILE_PATH + "] " + "autoscale color_mode=Default view=Hyperstack stack_order=XYCZT " + "series_"+d2s(i+1,0) + " use_virtual_stack";
					run("Bio-Formats Importer", options);
			//		FILE_NAME=File.getName(FILE_PATH);
					FILE_NAME=File.nameWithoutExtension;
					Ext.setSeries(i);
					Ext.getSeriesName(SERIES_NAMES2);
					SERIES_NAMES2=replace(SERIES_NAMES2, " ", "_");
					SERIES_NAMES2=replace(SERIES_NAMES2, "/", "_");
					SERIES_NAMES2=replace(SERIES_NAMES2, "\\(", "");
					SERIES_NAMES2=replace(SERIES_NAMES2, "\\)", "_");
					SAVE_NAME=FILE_NAME+"_"+SERIES_NAMES2;
					if(saveAsOption == "Ome Tiff"){
						run("Bio-Formats Exporter", "save=["+new_folder+sep+SAVE_NAME+".ome.tiff] compression=Uncompressed");
					}else if(saveAsOption == "Do Not Export"){
						print ("Not to save was selected");
					}else{
						saveAs("tif", new_folder+sep+SAVE_NAME);
					}
					getDimensions(width, height, channels, slices, frames);
					if (MIP){
						if(slices >1){
							run("Z Project...", "projection=[Max Intensity] all");
							saveAs("tif", new_folder+sep+SAVE_NAME+"_MAX");
						}else{
							print ("Selected image "+SAVE_NAME+" is not a z-stack");
						}
					}
					if(SplitChannels){
						if(channels>1){
							for(ch=1;ch<=channels;ch++){
								run("Duplicate...", "duplicate channels="+ch+"");
								saveAs("tif", new_folder+sep+SAVE_NAME+"_Ch"+ch);
								
							}
						}else{
							print ("Selected image "+SAVE_NAME+" is not a multi-channel image");
						}
					}
					run("Close All");
			}
		}
	}
}
setBatchMode(false);
exit("Macro Finished!");
