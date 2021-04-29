/* BSD 3-Clause License
 * 
 * Copyright (c) 2021, Peter-T-Ruehr
 * All rights reserved.
 * 
 */

requires("1.39l");
ROI_def_start = getTime();
if (isOpen("Log")) { 
     selectWindow("Log"); 
     run("Close"); 
} 
if (isOpen("Results")) { 
     selectWindow("Results"); 
     run("Close"); 
}
while (nImages>0) { 
          selectImage(nImages); 
          close(); 
}

plugins = getDirectory("plugins");
unix = '/plugins/';
windows = '\\plugins\\';

if(endsWith(plugins, unix)){
	print("Running on Unix...");
	dir_sep = "/";
}
else if(endsWith(plugins, windows)){
	print("Running on Windows...");
	dir_sep = "\\";
}

//get source dir from user and define other directories
source_dir = getDirectory("Select source Directory");
parent_dir_name = File.getName(source_dir);

print("Loading directory: "+parent_dir_name+"...");

setBatchMode(true);
//load new stack
//open(source_dir,"virtual");
//run("Image Sequence...", "open="+source_dir+" increment="+load_increment+" scale="+scale_perc+" sort");
open(source_dir); //,"virtual"

getPixelSize(unit, px_size, ph, pd);
print("Pixel size: "+ px_size,".");

Dialog.create("Check pixel size");
	Dialog.addNumber("Correct pixel size?:", px_size, 9, 15, "um")
	Dialog.show();
	px_size = Dialog.getNumber();
	unit = Dialog.getString();

//create first settings dialog
Dialog.create("Settings 1");
Dialog.addMessage("___________________________________");
	Dialog.addString("File name: ", "xxx");
	Dialog.addMessage("___________________________________");
	Dialog.addCheckbox("Crop to region of interest (ROI) in x and y?", true);
	Dialog.addCheckbox("Crop to region of interest (ROI) in z?", true);
	Dialog.addCheckbox("Define rotated ROI?", true);
	Dialog.addCheckbox("Use existing ROI file for cropping??", false);
	Dialog.addString("Name of ROI:", "head");
	Dialog.addMessage("___________________________________");
	Dialog.addNumber("Scale to [MB]: ", 280);
	Dialog.addNumber("Scale to [%] (deprecated): ", 100);
	Dialog.addMessage("___________________________________");
	Dialog.addCheckbox("Enhance contrast?", true);
	Dialog.addCheckbox("Normalize intensity fluctuations?*", false);
	Dialog.addMessage("___________________________________");
	Dialog.addString("Input format: ", ".tif", 5);
	Dialog.addChoice("Output format", format_outs, "8-bit TIFF");
	Dialog.addMessage("___________________________________");
	Dialog.addCheckbox("Work in memory", false);
	Dialog.addMessage("___________________________________");
	Dialog.addMessage("* handle with caution: Only for certain scans, needs external plugin (Capek et al. 2006)");
	Dialog.addMessage("  and usually mutually exclusive with contrast stack enhancement.");
	Dialog.addMessage("PTR, Jan. 2019");
	Dialog.addMessage("Inst. f. Zoologie, Koeln, GER");
	Dialog.show();
	species_name = Dialog.getString();
	crop_xy = Dialog.getCheckbox();
	crop_z = Dialog.getCheckbox();
	crop_rot_xy = Dialog.getCheckbox();
	use_ROI_file = Dialog.getCheckbox();
	ROI_name = Dialog.getString();
	d_size = Dialog.getNumber()/1024;  //MB/1024=GB
	scale_perc = Dialog.getNumber();
	scale = scale_perc/100;	
	enhance_contrast = Dialog.getCheckbox();
	normalize_bg = Dialog.getCheckbox();
	format_in = Dialog.getString();
	format_out = Dialog.getChoice();
	if(type != "none"){	// somethings strange here - I'm not so sure what this is all abaout anymore, but this feature is not in use anymore anyways
		reco_log = true;
		//does not work right now because KIT data is not implemented
		//reco_log = Dialog.getCheckbox(); 
	}
	else{
		reco_log = false;
	}
	memory = Dialog.getCheckbox();
	print("Working on "+species_name+" (# "+specimen_number+")...");
	
// calculate if scaling is necessary later
Stack.getDimensions(width_orig, height_orig, channels, slices, frames);
o_size = width_orig*height_orig*slices/(1024*1024*1024);
print("Target directory loaded. Stack size: "+o_size+" GB.");
d = pow(d_size/o_size,1/3);
perc_d = round(100 * d);
d = perc_d/100;
print(d);

run("Properties...", "unit=um pixel_width="+px_size+" pixel_height="+px_size+" voxel_depth="+px_size);
print("Pixel size set to "+px_size+".");

if(bitDepth() != 8){
	run("8-bit");
}

Stack.getDimensions(width_orig, height_orig, channels, slices, frames);
o_size = width_orig*height_orig*slices/(1024*1024*1024);
print("Stack size: "+o_size+" GB.");
d_size = 0.35;
d = pow(d_size/o_size,1/3);
perc_d = round(100 * d);
d = perc_d/100;

if(perc_d < 100){
	print("Scaling stack to "+perc_d+"%. to reach stack size of ~"+d_size+" GB...");
	run("Scale...", "x="+d+" y="+d+" z="+d+" interpolation=Bicubic average process create");
	px_size = px_size/d;
	print("New px size = "+px_size+" um.");
	tiff_name = source_dir+parent_dir_name+"_red"+perc_d;
	file_name = parent_dir_name+"_red"+perc_d+".tif\" ";
}
else{
	print("No scaling necessary; stack is already smaller than ~"+d_size+" GB.");
	tiff_name = source_dir+parent_dir_name;
	file_name = parent_dir_name+".tif\" ";
}

saveAs("Tiff", tiff_name);
print("Saved stack as "+source_dir+dir_sep+parent_dir_name+".tif.");

checkpoint_file = File.open(source_dir+dir_sep+parent_dir_name+".ckpt.");
print(checkpoint_file, "Version 5");
print(checkpoint_file, "Stratovan Checkpoint (TM)");
print(checkpoint_file, "");
print(checkpoint_file, "[Specimen Information]");
print(checkpoint_file, "Name: "+parent_dir_name+", .ckpt");
print(checkpoint_file, parent_dir_name);
print(checkpoint_file, "Birthdate: ");
print(checkpoint_file, "Sex: ");
print(checkpoint_file, "");
print(checkpoint_file, "[Specimen Study]");
print(checkpoint_file, "StudyInstanceUID: ");
print(checkpoint_file, "StudyID: ");
print(checkpoint_file, "StudyDate: ");
print(checkpoint_file, "StudyTime: ");
print(checkpoint_file, "StudyDescription: ");
print(checkpoint_file, "");
print(checkpoint_file, "[Specimen Series]");
print(checkpoint_file, "SeriesInstanceUID: ");
print(checkpoint_file, "SeriesNumber: ");
print(checkpoint_file, "SeriesDate: ");
print(checkpoint_file, "SeriesTime: ");
print(checkpoint_file, "SeriesModality: ");
print(checkpoint_file, "SeriesProtocol: ");
print(checkpoint_file, "SeriesPart: ");
print(checkpoint_file, "SeriesDescription: ");
print(checkpoint_file, "");
print(checkpoint_file, "[Specimen File(s)]");
print(checkpoint_file, "NumberOfFolders: 1");
print(checkpoint_file, "Folder: "+source_dir);
print(checkpoint_file, "");
print(checkpoint_file, "[Surface Information]");
print(checkpoint_file, "NumberOfSurfaces: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Templates]");
print(checkpoint_file, "NumberOfTemplates: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Landmarks]");
print(checkpoint_file, "NumberOfPoints: 0");
print(checkpoint_file, "Units: um");
print(checkpoint_file, "");
print(checkpoint_file, "[SinglePoints]");
print(checkpoint_file, "NumberOfSinglePoints: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Curves]");
print(checkpoint_file, "NumberOfCurves: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Patches]");
print(checkpoint_file, "NumberOfPatches: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Joints]");
print(checkpoint_file, "NumberOfJoints: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Lengths]");
print(checkpoint_file, "NumberOfLengths: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Lines]");
print(checkpoint_file, "NumberOfLines: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Angles]");
print(checkpoint_file, "NumberOfAngles: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Planes]");
print(checkpoint_file, "NumberOfPlanes: 0");
print(checkpoint_file, "");
print(checkpoint_file, "[Image Stack]");
print(checkpoint_file, "Units: um");
print(checkpoint_file, "Spacing: "+px_size+" "+px_size+" "+px_size+" ");
print(checkpoint_file, "NumberOfFiles: 1");
print(checkpoint_file, "Files: \""+file_name);
print(checkpoint_file, "");
print(checkpoint_file, "[Contrast and Brightness]");
print(checkpoint_file, "Width: 82");
print(checkpoint_file, "Level: -19");
print(checkpoint_file, "");
print(checkpoint_file, "[Landmark Size]");
print(checkpoint_file, "Size: 2");

print("Saved checkpoint file as "+source_dir+dir_sep+parent_dir_name+".ckpt.");
print("All done!");