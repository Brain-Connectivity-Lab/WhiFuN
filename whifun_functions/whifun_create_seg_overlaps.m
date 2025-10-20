function whifun_create_seg_overlaps(GM_path,WM_path,CSF_path,ref,caption_1,caption_2)
%WHIFUN_CREATE_SEG_OVERLAPS Visualizes the overlap of Gray Matter (GM),
%   White Matter (WM), and Cerebrospinal Fluid (CSF) segmentation masks onto
%   a reference image using SPM's `spm_orthviews`.
%
%   WHIFUN_CREATE_SEG_OVERLAPS(GM_PATH, WM_PATH, CSF_PATH, REF, CAPTION_1, CAPTION_2)
%
%   This function is used for quality control (QC) in neuroimaging
%   pipelines, allowing a visual check of the accuracy of tissue segmentation
%   (e.g., from SPM's 'New Segment' or 'Segment' tools) by overlaying the
%   masks in distinct colors onto a T1-weighted or normalized reference image.
%
%   Input Arguments:
%   GM_PATH   - Full path to the NIfTI file containing the Gray Matter segmentation mask (e.g., c1T1.nii).
%   WM_PATH   - Full path to the NIfTI file containing the White Matter segmentation mask (e.g., c2T1.nii).
%   CSF_PATH  - Full path to the NIfTI file containing the CSF segmentation mask (e.g., c3T1.nii).
%   REF       - Full path to the NIfTI file to be used as the background reference image (e.g., T1.nii or rT1.nii).
%   CAPTION_1 - Caption/Title for the first displayed image (usually the segmentation mask).
%   CAPTION_2 - Caption/Title for the second displayed image (the reference image).
%
%   Output:
%   A SPM Graphics window displaying the reference image with the three tissue masks
%   overlaid as color blobs: GM (Red), WM (Green), and CSF (Blue).
%
%   Dependencies: Requires the SPM (Statistical Parametric Mapping) toolbox.
%   - `spm_check_registration`, `spm_orthviews`, `spm_vol`.
%
%   Author: Pratik Jain

imgs = char(GM_path,...  % Display the Gray matter segmentation [now_anat_path(1).folder,filesep, pre 'c1' now_anat_path.name]
        ref); %#ok<NASGU>
[~] = evalc('spm_check_registration(imgs)');

    % Display the participant's ID
    spm_orthviews('Caption', 1, caption_1);
    spm_orthviews('Caption', 2, caption_2);

    % Display contour of 1st image onto 2nd
    spm_orthviews('contour','display',1,2)

    global st %#ok<GVMIS>

    vol = spm_vol(GM_path);    % Display the Gray matter segmentation in Red
    mat = vol.mat;
    st.vols{1}.blobs=cell(1,1);
    bset = 1;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[1 0 0]);

    vol = spm_vol(WM_path);    % Display the White matter segmentation in Green
    mat = vol.mat;
    bset = 2;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[0 1 0]);

    vol = spm_vol(CSF_path);    % Display the CSF segmentation in Blue
    mat = vol.mat;
    bset = 3;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[0 0 1]);

    spm_orthviews('Redraw')
    spm_orthviews('Xhairs','off')