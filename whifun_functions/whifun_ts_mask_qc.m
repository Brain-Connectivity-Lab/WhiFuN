function whifun_ts_mask_qc(output_path,GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,func_path,name,slover_slices,slover_contour_range,slover_view)
mkdir(fullfile(output_path),'Orthoslice_View')
mkdir(fullfile(output_path),[slover_view '_Slice_View'])
now_func_path = dir(func_path);
ref = [now_func_path(1).folder,filesep,now_func_path(1).name];
ref_cap = now_func_path.name;

% Quality Control
imgs = char(GM_mask_path,...  % Display the Gray matter segmentation
    [ref ',1']);                    %#ok<NASGU> % Display the reference func image

fg = spm_figure('Create','Graphics','Visible','off');

[~] = evalc('spm_check_registration(imgs)');

% Display the participant's ID
spm_orthviews('Caption', 1, name);
spm_orthviews('Caption', 2, ref_cap);

% Display contour of 1st image onto 2nd
spm_orthviews('contour','display',1,2)

global st %#ok<GVMIS,TLEV>

vol = spm_vol(GM_mask_path);    % Display the Gray matter segmentation in Red
mat = vol.mat;
st.vols{1}.blobs=cell(1,1);
bset = 1;
st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
    'max',1, 'min',0, 'colour',[1 0 0]);

vol = spm_vol(WM_mask_path);    % Display the White matter segmentation in Green
mat = vol.mat;
bset = 2;
st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
    'max',1, 'min',0, 'colour',[0 1 0]);

vol = spm_vol(deep_WM_mask_path);    % Display the Deep WM segmentation in Yellow
mat = vol.mat;
bset = 3;
st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
    'max',1, 'min',0, 'colour',[1 1 0]);

vol = spm_vol(CSF_mask_path);    % Display the CSF segmentation in Blue
mat = vol.mat;
bset = 4;
st.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
    'max',1, 'min',0, 'colour',[0 0 1]);

spm_orthviews('Redraw')
%                                     spm_orthviews('Addtruecolourimage',1,[now_anat_path(1).folder,filesep, 'wc1' now_anat_path.name],[0 0 0;1 0 0])
%                                     spm_orthviews('Addtruecolourimage',1,[now_anat_path(1).folder,filesep, 'wc2' now_anat_path.name],[0 0 0;0 1 0])
%                                     spm_orthviews('Addtruecolourimage',1,[now_anat_path(1).folder,filesep, 'wc3' now_anat_path.name],[0 0 0;0 0 1])
%                                     spm_orthviews('Redraw')
%                                     spm_orthviews('Xhairs','off')
spm_orthviews('Xhairs','off')

exportgraphics(fg,fullfile(output_path,'Orthoslice_View',[name '.png']))

% Axial View
fg = spm_figure('Create','Graphics','Visible','off');
temp = spm('WinSize','Graphics');
set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
mapp = ones(64,3);
mapp(1:32,:) = 0;
rmap = mapp.*[1,0,0];
gmap = mapp.*[0,1,0];
ymap = mapp.*[1,1,0];
bmap = mapp.*[0,0,1];

whifun_slover({GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path},{'Structural','Structural','Structural','Structural'},{rmap,gmap,ymap,bmap},slover_slices,slover_contour_range,slover_view,[1 1 1 1],fg);% end
exportgraphics(fg,fullfile(output_path,[slover_view '_Slice_View'],[name '.png']))
end