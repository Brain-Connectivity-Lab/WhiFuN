function whifun_segment_qc(quality_control_path,preproc_code_path,now_anat_path,anat_name,name,over_write,skull_pre,slover_slices_ss,slover_slices_mni,slover_contour_range_ss,slover_contour_range_mni,slover_view)

make_plots(1,quality_control_path,now_anat_path,preproc_code_path,anat_name,name,over_write,skull_pre,slover_slices_mni,slover_contour_range_mni,slover_view) % MNI space
make_plots(2,quality_control_path,now_anat_path,preproc_code_path,anat_name,name,over_write,skull_pre,slover_slices_ss,slover_contour_range_ss,slover_view) % Subject space

end

function make_plots(space,quality_control_path,now_anat_path,preproc_code_path,anat_name,name,over_write,skull_pre,slover_slices,slover_contour_range,slover_view)


if space == 1
    pre = 'w';
    ref = fullfile(preproc_code_path,'Templates','MNI152_T1_2mm_brain.nii');
    ref_cap = 'MNI 152 T1 FSL (MNI)';
    space_name = 'MNI';
else
    pre = '';
    ref = [now_anat_path(1).folder,filesep, skull_pre anat_name];
    ref_cap = [skull_pre now_anat_path.name];
    space_name = 'Subject';
end


seg_qc_file = dir(fullfile(quality_control_path,'c_Segmentation',[space_name '_Space'],'Orthoslice_View',[name '.png']));
% now_anat_path = dir(fullfile(Subj_list(subji).folder, Subj_list(subji).name,app.comm_sess_name,app.anat_folder_name,[app.anat_data_name '.nii'])) ;

if length(now_anat_path) > 1

    [~,idx] = sort([now_anat_path.datenum]);
    now_anat_path = now_anat_path(idx);
    now_anat_path(2:end) = [];
    warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first.']);
end

if isempty(seg_qc_file) || over_write == 1
    % Quality Control
    imgs = char([now_anat_path(1).folder,filesep, pre 'c1' now_anat_path.name],...  % Display the Gray matter segmentation
        ref);                    %#ok<NASGU> % Display the reference single subject MNI space image from SPM

    fg = spm_figure('Create','Graphics','Visible','off');

    [~] = evalc('spm_check_registration(imgs)');

    % Display the participant's ID
    spm_orthviews('Caption', 1, name);
    spm_orthviews('Caption', 2, ref_cap);

    % Display contour of 1st image onto 2nd
    spm_orthviews('contour','display',1,2)

    global st %#ok<GVMIS,TLEV>

    vol = spm_vol([now_anat_path(1).folder,filesep, pre 'c1' now_anat_path.name]);    % Display the Gray matter segmentation in Red
    mat = vol.mat;
    st.vols{1}.blobs=cell(1,1);
    bset = 1;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[1 0 0]);

    vol = spm_vol([now_anat_path(1).folder,filesep, pre 'c2' now_anat_path.name]);    % Display the White matter segmentation in Green
    mat = vol.mat;
    bset = 2;
    st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',1, 'min',0, 'colour',[0 1 0]);

    vol = spm_vol([now_anat_path(1).folder,filesep, pre 'c3' now_anat_path.name]);    % Display the CSF segmentation in Blue
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
    exportgraphics(fg,fullfile(quality_control_path,'c_Segmentation',[space_name '_Space'],'Orthoslice_View',[name '.png']))

    % Axial View
    fg = spm_figure('Create','Graphics','Visible','off');
    temp = spm('WinSize','Graphics');
    set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
    set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
    mapp = ones(64,3);
    mapp(1:32,:) = 0;
    rmap = mapp.*[1,0,0];
    gmap = mapp.*[0,1,0];
    bmap = mapp.*[0,0,1];

    whifun_slover({[now_anat_path(1).folder,filesep, pre 'c1' now_anat_path.name],[now_anat_path(1).folder,filesep, pre 'c2' now_anat_path.name],[now_anat_path(1).folder,filesep, pre 'c3' now_anat_path.name]},{'Structural','Structural','Structural'},{rmap,gmap,bmap},slover_slices,slover_contour_range,slover_view,[1 1 1],fg);% end
    exportgraphics(fg,fullfile(quality_control_path,'c_Segmentation',[space_name '_Space'],[slover_view '_Slice_View'],[name '.png']))
end
end