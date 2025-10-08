% separate_tissues.m
% This script separates a loaded brain segmentation matrix into three
% separate binary matrices for White Matter (WM), Gray Matter (GM),
% and Cerebrospinal Fluid (CSF) based on standard FreeSurfer labels.

% Assumes the wmparc.nii.gz file is already loaded into a 3D matrix,
% for example, using a command like:
wmparc = niftiread('M:\HCP_Dev\fmriresults01\HCD0001305_V1_MR\MNINonLinear\wmparc.nii.gz');
% or by loading it from a .mat file if it was previously saved.


% --- Define the FreeSurfer labels for each tissue type ---
% White Matter (WM) labels
% This list includes cerebral white matter, cerebellum white matter, and the corpus callosum.
wm_labels = [2, 7, 16, 28, 41, 46, 60, 77, 78, 79, 85, 251, 252, 253, 254, 255, ...
             3000:5002];

% Gray Matter (GM) labels
% This list includes both cortical and subcortical gray matter regions.
% Cortical labels are in the 1000-2000 range for the left hemisphere and
% 2000-3000 range for the right, and a few others are specified explicitly.
gm_labels = [8, 10, 11, 12, 13, 17, 18, 26, 30, 42, 47, 49, 50, 51, 52, 53, 54, 58, 62 ...
             1000:1035, 2000:2035]; % Range for left/right cortical regions

% Cerebrospinal Fluid (CSF) labels
% This list includes ventricles and other CSF spaces.
csf_labels = [4, 5, 14, 15, 24, 31, 43, 44, 63];

% removed due to ambiguity
% 31: LEFT-CHOROID-PLEXUS


% --- Initialize the output matrices with zeros ---
% These matrices will have the same dimensions as the input wmparc matrix.
wm_matrix = zeros(size(wmparc));
gm_matrix = zeros(size(wmparc));
csf_matrix = zeros(size(wmparc));

% --- Create the binary masks using logical indexing ---
% Iterate through the list of labels for each tissue type.
% For each label, find all voxels in the wmparc matrix that match that label
% and set the corresponding voxel in the new matrix to 1.

% White Matter
for label = wm_labels
    wm_matrix(wmparc == label) = 1;
end

% Gray Matter (cortical and subcortical)
for label = gm_labels
    gm_matrix(wmparc == label) = 1;
end

% Cerebrospinal Fluid
for label = csf_labels
    csf_matrix(wmparc == label) = 1;
end

% The matrices wm_matrix, gm_matrix, and csf_matrix now contain
% binary masks for the respective tissue types. You can use these
% matrices for further analysis or visualization. For example:
% figure; imshow3D(wm_matrix);
% figure; imshow3D(gm_matrix);
% figure; imshow3D(csf_matrix);

disp('Separation complete. The binary matrices are:');
disp('wm_matrix (White Matter)');
disp('gm_matrix (Gray Matter)');
disp('csf_matrix (Cerebrospinal Fluid)');