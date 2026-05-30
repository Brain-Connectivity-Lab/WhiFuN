function whifun_change_datatype(Subj_list,data_type,field)
%WHIFUN_CHANGE_DATATYPE Converts NIfTI image data to a new datatype and overwrites.
%
%   WHIFUN_CHANGE_DATATYPE(Subj_list, data_type) takes a single NIfTI file path 
%   (string or char) and casts its internal image data to the specified 
%   data_type. It calculates the Mean Squared Error (MSE) introduced by the 
%   conversion, displays the memory footprint before and after, and saves 
%   the newly typed image back to disk.
%
%   WHIFUN_CHANGE_DATATYPE(Subj_list, data_type, field) processes a batch 
%   of files. If Subj_list is a structure array, you must provide the 'field' 
%   argument as a string/char indicating which field contains the file paths.
%
%   Important Note: This function overwrites the original file in place and 
%   applies the AdditiveOffset and MultiplicativeScaling from the NIfTI header 
%   prior to saving.
%
%   Dependencies: 
%       Requires 'whifun_niftiread' to read the image data and info.
%
%   Inputs:
%       Subj_list - String/char array for a single file path, OR a struct 
%                   array containing multiple file paths.
%       data_type - String or char array of the target MATLAB datatype 
%                   (e.g., 'single', 'int16', 'uint8').
%       field     - (Optional) String or char array specifying the fieldname 
%                   in Subj_list that holds the file paths. Required if 
%                   Subj_list is a struct.
%
%   Example 1: Single File
%       whifun_change_datatype('C:\Data\T1.nii', 'single');
%
%   Example 2: Structure Array
%       files = dir('C:\Data\*\T1.nii');
%       whifun_change_datatype(files, 'single', 'name');
%
%   Author: Pratik Jain


if ischar(Subj_list) || isstring(Subj_list)
    field = 'a';
    Subj_list1 = Subj_list;
    Subj_list = struct('a',Subj_list1);
    % Subj_list(1).(field) = Subj_list;
    n = 1;
elseif isstruct(Subj_list)
    n = length(Subj_list);
    if ~exist("field","var")
        error('Please specify the field')
    end
end
for i = 1:n
    [image_org_data_type,info] = whifun_niftiread(Subj_list(i).(field));
    image_new_data_type = cast(image_org_data_type, data_type);
    mse_loss = mean((double(image_new_data_type) - image_org_data_type).^2,'all');
    S = whos('image_new_data_type');
    S1 = whos('image_org_data_type');
    

    disp('-----------------------------------------------------------------------------------------------------------------')
    disp(Subj_list(i).(field))
    disp(['MSE error : ' num2str(mse_loss)])
    disp(['Original Image size (.nii): ' num2str(S1.bytes/1024^2) ' Mega bytes']);
    disp(['New Datatype Image size (.nii): ' num2str(S.bytes/1024^2) ' Mega bytes']);
    niftisave((image_new_data_type-info.AdditiveOffset)/info.MultiplicativeScaling,Subj_list(i).(field),info);
end