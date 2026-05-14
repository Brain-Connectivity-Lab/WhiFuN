function whifun_change_datatype(Subj_list,data_type,field)

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