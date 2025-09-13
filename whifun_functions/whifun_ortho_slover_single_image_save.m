function whifun_ortho_slover_single_image_save(image_path,out_image_ortho_path,out_image_slover_path,slover_slices,slover_contour_range,slover_view,caption_)


image_info = niftiinfo(image_path);


if length(image_info.ImageSize) == 4
   image_path = [image_path,',1'] ;
end
[~,name,ext] = fileparts(image_path);

if ~exist("caption_",'var')
    caption_ = [name,ext]; % Assign a default caption if not provided
end

if ~isempty(out_image_ortho_path)
    fold = fileparts(out_image_ortho_path);
    if ~exist(fold, 'dir')
        mkdir(fold); % Create the output directory if it does not exist
    end
end

if ~isempty(out_image_slover_path)
    fold = fileparts(out_image_slover_path);
    if ~exist(fold, 'dir')
        mkdir(fold); % Create the output directory if it does not exist
    end
end

if ~isempty(out_image_ortho_path)
    [~,fg] = spm_check_registration_evalc(char(image_path));
    spm_orthviews('Caption', 1,caption_);
    exportgraphics(fg,out_image_ortho_path)
end

if ~isempty(out_image_slover_path)
    fg = spm_figure('GetWin','Graphics');
    % temp = spm('WinSize','Graphics');
    % set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
    % set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
    whifun_slover({image_path},{'Structural'},{gray},slover_slices,slover_contour_range,slover_view,[],fg);
    exportgraphics(fg,out_image_slover_path)
end
