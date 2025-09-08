function whifun_create_seg_overlaps(GM_path,WM_path,CSF_path,ref,caption_1,caption_2)
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