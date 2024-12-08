function whifun_segment_qc(quality_control_path,now_anat_path,spm_path,name,over_write)

seg_qc_file = dir(fullfile(quality_control_path,'Segmentation',[name '.png']));
% now_anat_path = dir(fullfile(Subj_list(subji).folder, Subj_list(subji).name,app.comm_sess_name,app.anat_folder_name,[app.anat_data_name '.nii'])) ;
if length(now_anat_path) > 1

    [~,idx] = sort([now_anat_path.datenum]);
    now_anat_path = now_anat_path(idx);
    now_anat_path(2:end) = [];
    warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first.']);
end
if isempty(seg_qc_file) || over_write == 1
    % Quality Control
    imgs = char([now_anat_path(1).folder,filesep, 'wc1' now_anat_path.name],...  % Display the Gray matter segmentation
        fullfile(spm_path,'canonical','single_subj_T1.nii'));                    % Display the reference single subject MNI space image from SPM
    spm_check_registration(imgs);

    % Display the participant's ID
    spm_orthviews('Caption', 1, name);
    spm_orthviews('Caption', 2, 'single_subj_T1 (MNI)');

    % Display contour of 1st image onto 2nd
    spm_orthviews('contour','display',1,2)

    global st %#ok<GVMIS,TLEV>

    vol = spm_vol([now_anat_path(1).folder,filesep, 'wc1' now_anat_path.name]);    % Display the Gray matter segmentation in Red
    mat = vol.mat;
    st.vols{1}.blobs=cell(1,1);
    bset = 1;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[1 0 0]);

    vol = spm_vol([now_anat_path(1).folder,filesep, 'wc2' now_anat_path.name]);    % Display the White matter segmentation in Green
    mat = vol.mat;
    bset = 2;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[0 1 0]);

    vol = spm_vol([now_anat_path(1).folder,filesep, 'wc3' now_anat_path.name]);    % Display the CSF segmentation in Blue
    mat = vol.mat;
    bset = 3;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[0 0 1]);

    spm_orthviews('Redraw')
    %                                     spm_orthviews('Addtruecolourimage',1,[now_anat_path(1).folder,filesep, 'wc1' now_anat_path.name],[0 0 0;1 0 0])
    %                                     spm_orthviews('Addtruecolourimage',1,[now_anat_path(1).folder,filesep, 'wc2' now_anat_path.name],[0 0 0;0 1 0])
    %                                     spm_orthviews('Addtruecolourimage',1,[now_anat_path(1).folder,filesep, 'wc3' now_anat_path.name],[0 0 0;0 0 1])
    %                                     spm_orthviews('Redraw')
    %                                     spm_orthviews('Xhairs','off')
    spm_orthviews('Xhairs','off')
    saveas(gcf,fullfile(quality_control_path,'Segmentation',[name '.png']) ,'png')
    close gcf
end