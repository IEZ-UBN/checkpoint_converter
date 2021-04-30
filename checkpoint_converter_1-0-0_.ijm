/*  
 * Creates a \*.ckpt file for the Checkpoint landmarking software (Stratovan Corporation, Davis, CA) from an image stack of tiffs.
 * Additional features:
 *   - downscaling to user-defined stack size
 *   - optional contrast enhancement
 *   
 *   Should run on Linux, Win & iOS.
 *   
 *   v. 1.0.0
 *   
 *   Please cite the following paper when you use this macro:
 *   Rühr et al. (in rev.): Juvenile ecology drives adult morphology in two insect orders.
 *  
 * BSD 3-Clause License
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

open(source_dir);

getPixelSize(unit, px_size, ph, pd);
print("Pixel size: "+ px_size,".");

Dialog.create("Settings");
Dialog.addMessage("___________________________________");
	Dialog.addString("File name: ", parent_dir_name);
	Dialog.addMessage("___________________________________");
	Dialog.addString("Name of ROI:", "ROI");
	Dialog.addMessage("___________________________________");
	Dialog.addNumber("Correct pixel size?:", px_size, 9, 10, "um")
	//Dialog.addString("Unit: ", "um");
	Dialog.addMessage("___________________________________");
	Dialog.addNumber("Scale to [MB]: ", 280);
	Dialog.addMessage("___________________________________");
	Dialog.addCheckbox("Enhance contrast?", true);
	Dialog.addMessage("___________________________________");
	Dialog.show();
	specimen_name = Dialog.getString();
	ROI_name = Dialog.getString();
	px_size = Dialog.getNumber();
	//unit = Dialog.getString();
	d_size = Dialog.getNumber()/1024;  //MB/1024=GB
	enhance_contrast = Dialog.getCheckbox();
	print("Working on "+specimen_name+"...");
	
	
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

if(perc_d < 100){
	print("Scaling stack to "+perc_d+"%. to reach stack size of "+d_size+" GB...");
	run("Scale...", "x="+d+" y="+d+" z="+d+" interpolation=Bicubic average process create");
	px_size = px_size/d;
	print("New px size = "+px_size+" um.");
	tiff_name = source_dir+parent_dir_name+"_red"+perc_d;
	file_name = parent_dir_name+"_red"+perc_d+".tif\" ";
	ckpt_name = parent_dir_name+"_red"+perc_d+".ckpt";
}
else{
	print("No scaling necessary; stack is already smaller than "+d_size+" GB.");
	tiff_name = source_dir+parent_dir_name;
	file_name = parent_dir_name+".tif\" ";
	ckpt_name = parent_dir_name+".ckpt";
}

saveAs("Tiff", tiff_name);
print("Saved stack as "+source_dir+dir_sep+file_name+".tif.");

checkpoint_file = File.open(source_dir+dir_sep+ckpt_name);
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

print("Saved checkpoint file as "+source_dir+dir_sep+ckpt_name+".ckpt.");
print("All done!");
