output_folder = '/media/biswal5090pc/M/TRACK2-selected/tract_tbi_data_healthy_whifun_op_ses-1';
% output_folder = '/media/biswal5090pc/M/TRACK2-selected/tract_tbi_data_whifun_op_ses-1';
Subj_list = load_subjects(output_folder,'Subj_list.csv');
Subj_list_all = load_subjects_all(output_folder,'Subj_list.csv');

Subj_list = whifun_create_fields_preproc(Subj_list);
Subj_list_all = whifun_create_fields_preproc(Subj_list_all);

quality_control_path = fullfile(output_folder,'Quality_control');
n_tot = length(Subj_list);
n_vol_dis = 0;
max_fd = 5;
mean_fd = 0.5;
greater_than_20 = 0.5;
Reg_ = 1;
motion_reg = 1;
Reg_params = {'csf','trans_x','trans_x_derivative1','trans_x_power2','trans_x_derivative1_power2',...
                    'trans_y','trans_y_derivative1','trans_y_power2','trans_y_derivative1_power2',...
                    'trans_z','trans_z_derivative1','trans_z_power2','trans_z_derivative1_power2',...
                    'rot_x','rot_x_derivative1','rot_x_power2','rot_x_derivative1_power2',...
                    'rot_y','rot_y_derivative1','rot_y_power2','rot_y_derivative1_power2',...
                    'rot_z','rot_z_derivative1','rot_z_power2','rot_z_derivative1_power2'};
Smooth_ = 1;
WM_GM = 1;
smooth_fwhm = 4;
over_write = false;
[Cut_pre,~,~,Reg_pre,~,Smooth_pre,~] = whifun_prefixes;
if n_vol_dis ==0
    Cut_pre = '';
end
par_on = 0;
dq = parallel.pool.DataQueue;
hWaitbar = waitbar(0, 'Processing parfor loop...', 'Name', 'Parallel Progress');
afterEach(dq, @(~) whifun_update_waitbar(hWaitbar, n_tot));

for subji=1:n_tot%,parforArg) %par
    if ~par_on
        tic
    else
        Par.tic;
    end
    [~,func_name,~] = fileparts(Subj_list(subji).func_name);
    [~,func_name,~] = fileparts(func_name);

    [~,anat_name,~] = fileparts(Subj_list(subji).anat_name);
    [~,anat_name,~] = fileparts(anat_name);
    Subj_list(subji)= whifun_post_preproc_fmriprep(quality_control_path,Subj_list(subji),...
        'func_preproc_dir',[func_name '_preproc'],...
        'anat_preproc_dir','',...
        'Cut_pre',Cut_pre,'n_vol_dis',n_vol_dis,...                                                       Discard Volumes
        'max_fd',max_fd,'mean_fd',mean_fd,'greater_than_20',greater_than_20,...                           Framewise Displacement
        'Reg_',Reg_,'Reg_pre',Reg_pre,'Reg_params',Reg_params,...                                                     Nuisance Regression     
        'Smooth_',Smooth_,'Smooth_pre',Smooth_pre,'WM_GM_seperate',WM_GM,'smooth_fwhm',smooth_fwhm...    Smoothing
        );

    if ~par_on
        time_el = toc/60;
    else
        par_p(subji) = Par.toc;
        time_el = (par_p(subji).ItStop-par_p(subji).ItStart)/60;
    end
    toc
    if time_el > 1
        Subj_list(subji).time_preprocess_min = time_el;

    end

    % send(dq, 1);



end
close(hWaitbar)
if par_on
    stop(par_p)
end


%% update CSV
for subji = 1:length(Subj_list)
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)) = Subj_list(subji);
    Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list(subji).name)) = Subj_list(subji);

    Subj_list_all = update_csv(Subj_list(subji),Subj_list_all,output_folder);
end


Subj_list = load_subjects_all(output_folder,'Subj_list.csv');

fg = spm_figure('Create','Graphics','Visible','off');
temp = spm('WinSize','Graphics');
set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])
for subji = 1:length(Subj_list)
     
    disp('..')
    disp(['Currently Processing ' Subj_list(subji).name])

    Subj_list_1 = Subj_list(subji);

    whifun_qc(quality_control_path,Subj_list_1,...
        'over_write',over_write,...
        'max_fd',max_fd,'mean_fd',mean_fd,'greater_than_20',greater_than_20,...
        'Reg_',logical(Reg_),'motion_reg',logical(motion_reg));

end
close(fg)
