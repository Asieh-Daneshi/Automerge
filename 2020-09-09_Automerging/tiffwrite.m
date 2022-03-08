function []=tiffwrite(file,filename)
%--------------------------------------------------------------------------
% This function is to write images in '.tif' and '.tiff' format.
%--------------------------------------------------------------------------
A=file;
t=Tiff(filename, 'w');
tagstruct.ImageLength=size(A,1);
tagstruct.ImageWidth=size(A,2);
tagstruct.Compression=Tiff.Compression.None;
tagstruct.SampleFormat=Tiff.SampleFormat.UInt;
tagstruct.Photometric=Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample=8;
tagstruct.RowsPerStrip=16;
tagstruct.SamplesPerPixel=size(A,3);
tagstruct.PlanarConfiguration=Tiff.PlanarConfiguration.Separate;
t.setTag(tagstruct);
t.write(A);
t.close();