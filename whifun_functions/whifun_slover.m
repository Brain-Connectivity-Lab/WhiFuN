function obj = whifun_slover(imgs,itype,cmap,slices,cnt_range,img_view,wt,fg)

if ~exist("fg","var")
    spm_figure('Create','Graphics');
end

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

% and do the display
obj = whifun_paint(obj);

% function cmap = sf_return_cmap(prompt,defmapn)
% cmap = [];
% while isempty(cmap)
%     [cmap,w]= slover('getcmap', spm_input(prompt,'+1','s', defmapn));
%     if isempty(cmap), disp(w);end
% end
% end