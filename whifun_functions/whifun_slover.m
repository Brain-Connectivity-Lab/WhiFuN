function obj = whifun_slover(imgs,itype,cmap,slices,cnt_range,img_view,wt,fg,cbar_)
%WHIFUN_SLOVER A wrapper function around the core 'slover' visualization engine,
%   customized for WhiFuN's needs, particularly for image overlays and
%   segmentation QC displays.
%
%   OBJ = WHIFUN_SLOVER(IMGS, ITYPE, CMAP, SLICES, CNT_RANGE, IMG_VIEW, WT, FG, CBAR_)
%
%   This function initializes and configures a 'slover' object to display
%   multiple NIfTI images with custom colormaps, slices, and views, and then
%   calls a drawing function (whifun_paint) to render the output.
%
%   Input Arguments:
%   IMGS            - Cell array of full paths to NIfTI files to be displayed.
%   ITYPE           - Cell array of strings defining the image type for each image
%                     (e.g., 'Structural', 'Blobs', 'Truecolour', 'Contours', etc.).
%   CMAP            - Cell array of colormap matrices (e.g., {gray, hot, winter}) for each image.
%   SLICES          - Vector of slice coordinates to display (e.g., -20:5:60).
%   CNT_RANGE       - Vector [min_val max_val] defining the display/threshold range for
%                     overlay images (Blobs, Contours).
%   IMG_VIEW        - String defining the slice view ('axial', 'coronal', 'sagittal').
%   WT              - (Optional) Vector of display weights/proportions for each image
%                     when multiple images are set as 'truecolour' (e.g., for blending).
%   FG              - (Optional) Handle of the figure window to draw the visualization into.
%   CBAR_           - (Optional, default 0) Flag: 1 to force a colorbar for all images, 0 otherwise.
%
%   Output Arguments:
%   OBJ             - The configured 'slover' object structure after visualization.
%
%   Dependencies: 'slover' (assumed external/SPM related), 'spm_vol', 'spm_figure',
%                 'spm_orthviews', 'whifun_paint' (assumed external/custom).
%
%   Author: Pratik Jain

if ~exist("cbar_","var")
    cbar_ = 0;
end
if ~exist("fg","var")
    spm_figure('Create','Graphics');
end
spm_orthviews('addcolorbar')
obj = slover;

n_imgs = length(imgs);
cscale = [];
deftype = 1;
obj.cbar = [];
imgns = cell(n_imgs,1);
% cmap = {gray,turbo};
for i = 1:n_imgs
    obj.img(i).vol = spm_vol(imgs{i});
    imgns(i) = {sprintf('Img %d (%s)',i,itype{i})};
    [mx,mn] = slover('volmaxmin', obj.img(i).vol);
    if strcmp('Structural', itype{i})
        obj.img(i).type = 'truecolour';
        obj.img(i).cmap = cmap{i};
        obj.img(i).range = [mn mx];
        deftype = 2;
        cscale = [cscale i];
        if strcmp(itype{i},'Structural with SPM blobs')
            obj = add_spm(obj);
        end
    else
%         cprompt = ['Colormap: ' imgns{i}];
        switch itype{i}
            case 'Truecolour'
                obj.img(i).type = 'truecolour';
                dcmap = 'flow.lut';
                drange = [mn mx];
                cscale = [cscale i];
                obj.cbar = [obj.cbar i];
            case 'Blobs'
                obj.img(i).type = 'split';
                dcmap = 'hot';
                drange = [0 mx];
                obj.img(i).prop = 1;
                obj.cbar = [obj.cbar i];
            case 'Negative blobs'
                obj.img(i).type = 'split';
                dcmap = 'winter';
                drange = [0 mn];
                obj.img(i).prop = 1;
                obj.cbar = [obj.cbar i];
            case 'Contours'
                obj.img(i).type = 'contour';
                dcmap = 'turbo';
                drange = [mn mx];
                obj.img(i).prop = 1;
        end
        obj.img(i).cmap = cmap{i};
        obj.img(i).range =cnt_range;
    end

end

ncmaps=length(cscale);
if ~exist("wt","var")
    wt = 1/ncmaps*(ones(n_imgs));
end

if ncmaps == 1
    obj.img(cscale).prop = 1;
else
    remcol=1;
    for i = 1:ncmaps
        ino = cscale(i);
        obj.img(ino).prop = wt(ino);
    end
end

obj.transform = img_view;% 'axial','coronal','sagittal'

% use SPM figure window
obj.figure = fg;

% slices for display
obj = fill_defaults(obj);
dist   = mean(diff(slices));
prec   = ceil(-min(log10(dist), 0));
obj.slices = slices;
if cbar_
    obj.cbar = 1:length(imgs);
end
% and do the display
obj = whifun_paint(obj);

% function cmap = sf_return_cmap(prompt,defmapn)
% cmap = [];
% while isempty(cmap)
%     [cmap,w]= slover('getcmap', spm_input(prompt,'+1','s', defmapn));
%     if isempty(cmap), disp(w);end
% end
% end