function atlas_4d = convert3d_4d_atlas(filepath,out_filename)
    %% Input 
%     folder --> the subject folder that contains the 3d atlas
%     filename (optional) --> specify the output filename

    tic
    file_info = niftiinfo(filepath);
    atlas = niftiread(filepath);

    if nargin < 2
        out_filename = [filepath(1:end-4),'_4d.nii'];
    end
    
   roi = unique(atlas);
   roi(roi==0) = [];

   num_roi = numel(roi);
    atlas_4d = zeros(size(atlas,1),size(atlas,2),size(atlas,3),num_roi);
    
   for i = 1:num_roi
        temp = zeros(size(atlas));
        temp(atlas==i) = i;
        atlas_4d(:,:,:,i) = temp;
   end

   niftisave(atlas_4d,out_filename,file_info);
end