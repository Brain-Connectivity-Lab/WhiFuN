function [Subj_list_1,voxel_anat,no_anat,report] = whifun_check_data_anat(Subj_list_1,comm_sess_name,anat_folder_name,anat_data_name,report)
if ~exist('report','var')
    report = "";
    p = 1;
elseif strlength(report) == 0
    p = 1; % Initialize p if report is empty
else
    p = length(report) + 1;
end

[now_anat_path,report(p)] = whifun_check_anat_file(Subj_list_1,comm_sess_name,anat_folder_name,anat_data_name);

if length(now_anat_path)>1  % If more than one anat files found choose the one that was created the first

    [~,idx] = sort([now_anat_path.datenum]);
    now_anat_path = now_anat_path(idx);
    now_anat_path(2:end) = [];
    warning(['More than one Anatomical files found. Choosing the file ' ,char(now_anat_path(1).name), ' as it was created the first.']);
end
if ~isempty(now_anat_path)
    [Subj_list_1,voxel_anat] = whifun_get_anat_info(now_anat_path,Subj_list_1);
    no_anat = 0;
else
    no_anat = 1;
    Subj_list_1.error = 1;
    voxel_anat = [nan,nan,nan];
end