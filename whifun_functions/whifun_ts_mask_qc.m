function whifun_ts_mask_qc(output_path,GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path,func_path,name,slover_slices,slover_contour_range,slover_view)
% WHIFUN_TS_MASK_QC Generates quality control images for tissue masks.
%
%   WHIFUN_TS_MASK_QC(output_path, GM_mask_path, WM_mask_path, deep_WM_mask_path, CSF_mask_path, func_path, name, slover_slices, slover_contour_range, slover_view)
%   creates a visual report to assess the quality and alignment of multiple
%   brain tissue masks. This is a crucial step for verifying that the masks
%   used to extract time series data are accurate.
%
%   The function generates two types of plots:
%   1.  **SPM Orthoslice Plot**: A plot showing the functional image as the
%       underlay, with overlaid contours of the GM, WM, deep WM, and CSF masks.
%       Each tissue type is displayed in a different color (GM-red, WM-green,
%       deep WM-yellow, CSF-blue) for easy visual distinction.
%   2.  **SLover Plot**: A specialized plot using a helper function `whifun_slover`
%       to display the four tissue masks simultaneously, providing a clearer
%       visualization of the spatial relationship between the different masks.
%
%   The function creates a dedicated output directory for the generated plots
%   and saves the figures as PNG files. This allows for easy inspection and
%   archiving of the quality control process.
%
%   Input Arguments:
%   output_path            - The path to the root output directory.
%   GM_mask_path           - The path to the Gray Matter mask file.
%   WM_mask_path           - The path to the White Matter mask file.
%   deep_WM_mask_path      - The path to the eroded deep White Matter mask file.
%   CSF_mask_path          - The path to the CSF mask file.
%   func_path              - The path to the functional NIfTI file (used as a reference).
%   name                   - The subject's name.
%   slover_slices          - A vector of slice locations to display.
%   slover_contour_range   - A two-element vector for the contour range.
%   slover_view            - The view to display slices in (e.g., 'axial').
%
%   Author: Pratik Jain
%   See also MKDIR, SPM_FIGURE, SPM_CHECK_REGISTRATION, SPM_ORTHVIEWS, SPM_VOL, EXPORTGRAPHICS.
if ~exist(fullfile(output_path,'Orthoslice_View'),"dir")
    mkdir(fullfile(output_path,'Orthoslice_View'))
end
if ~exist(fullfile(output_path,[slover_view '_Slice_View']),'dir')
    mkdir(fullfile(output_path,[slover_view '_Slice_View']))
end
now_func_path = dir(func_path);
ref = [now_func_path(1).folder,filesep,now_func_path(1).name];
ref_cap = now_func_path.name;

% Quality Control
imgs = char(GM_mask_path,...  % Display the Gray matter segmentation
    [ref ',1']);                    %#ok<NASGU> % Display the reference func image

fg = spm_figure('GetWin','Graphics');

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

spm_orthviews('Xhairs','off')

exportgraphics(fg,fullfile(output_path,'Orthoslice_View',[name '.png']))

% Axial View
fg = spm_figure('GetWin','Graphics');
% temp = spm('WinSize','Graphics');
% set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
% set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
mapp = ones(64,3);
mapp(1:32,:) = 0;
rmap = mapp.*[1,0,0];
gmap = mapp.*[0,1,0];
ymap = mapp.*[1,1,0];
bmap = mapp.*[0,0,1];

whifun_slover({GM_mask_path,WM_mask_path,deep_WM_mask_path,CSF_mask_path},{'Structural','Structural','Structural','Structural'},{rmap,gmap,ymap,bmap},slover_slices,slover_contour_range,slover_view,[1 1 1 1],fg);% end
exportgraphics(fg,fullfile(output_path,[slover_view '_Slice_View'],[name '.png']))
end