# ExportRawData
<h2>Short Description</h2>
An ImageJ / Fiji macro that helps exporting raw images fro their proprietary format to .tiff. This macro also has the option of saving a maximum intensity projection for each image or to save the individual channels.<br><br>
</center><img width="381" alt="Screenshot 2025-05-27 at 12 04 57" src="https://github.com/user-attachments/assets/934b72ed-522f-4f0e-8f55-84fd1e6b4760" />
<h2>Description</h2>
The macro can be use to export images from proprietary formats to .tiff or ome.tiff The macro reads all the contents of a folder exlcuding subfolders and for each image file (or each series of an image container file), opens and exports using the BioFormats plugin. It also gives the option to save maximum intesities projections of z-stack or individual channels.<br>
<h2>Limitations</h2>
In case you process the contents of a folder, make sure that only image files are contained in this folder. There is no problem if other sub-folders are within the processed directory. If one of the images (or series) cannot be imported with BioFormats, then this macro will stop, reporting the error. 
