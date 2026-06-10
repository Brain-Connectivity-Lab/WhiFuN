function whifun_qc(quality_control_path, Subj_list_1, varargin)

% Create input parser
p = inputParser;

% Required args
addRequired(p, 'quality_control_path', @ischar);
addRequired(p, 'Subj_list_1');

% Optional parameters with defaults
addParameter(p, 'over_write', false, @islogical);
addParameter(p, 'template_path', Subj_list_1.MNI_template, @ischar);
addParameter(p, 'slover_slices_native', [-65 -57 -43.2 -26.6 -14.4 -5 5 14.4 26.6 43.2 57 65], @isnumeric);
addParameter(p, 'slover_contour_range_native',[0 100], @isnumeric);
addParameter(p, 'slover_slices_mni', [-68 -65 -57 -43.2 -26.6 -14.4 -5 5 14.4 26.6 43.2 57 65 72 78], @isnumeric);
addParameter(p, 'slover_contour_range_mni',[0 100], @isnumeric);
addParameter(p, 'slover_contour_range_final_mni',[0 5000],  @isnumeric)
addParameter(p, 'slover_view', 'axial', @ischar);
addParameter(p, 'max_fd', 5, @isnumeric);
addParameter(p, 'mean_fd', 0.2, @isnumeric);
addParameter(p, 'greater_than_20', 0.2, @isnumeric);
addParameter(p, 'Reg_CSF', 0);
addParameter(p, 'n_pca', 5, @isnumeric);
addParameter(p, 'motion_reg', 0, @islogical);
addParameter(p, 'pca_for_temp_reg', 0, @islogical);
addParameter(p, 'filter_lp', 0.1, @isnumeric);
addParameter(p, 'filter_hp', 0.01, @isnumeric);
addParameter(p, 'Reg_MNI', 0, @isnumeric);

if isfield(Subj_list_1,'motion_txt')
    addParameter(p, 'motion_txt', Subj_list_1.motion_txt);
else
    addParameter(p, 'motion_txt', []);
end

% Parse inputs
parse(p, quality_control_path, Subj_list_1, varargin{:});
params = p.Results;

% Access values like this:
over_write           = params.over_write;
template_path        = params.template_path;
slover_slices_native     = params.slover_slices_native;
slover_contour_range_native = params.slover_contour_range_native;
slover_slices_mni    = params.slover_slices_mni;
slover_contour_range_mni = params.slover_contour_range_mni;
slover_contour_range_final_mni = params.slover_contour_range_final_mni;
slover_view          = params.slover_view;
max_fd               = params.max_fd;
mean_fd              = params.mean_fd;
greater_than_20      = params.greater_than_20;
Reg_CSF              = params.Reg_CSF;
n_pca                = params.n_pca;
motion_reg           = params.motion_reg;
pca_for_temp_reg     = params.pca_for_temp_reg;
filter_lp            = params.filter_lp;
filter_hp            = params.filter_hp;
motion_txt           = params.motion_txt;
Reg_MNI              = params.Reg_MNI;

if isstring(template_path) || ischar(template_path)
    if strcmp(template_path,'NaN')
        template_path = nan;
    end
end

if any(isnan(template_path)) || isempty(template_path)
    
    whifun_path = fileparts(which('whifun'));
    template_path = fullfile(whifun_path,'Templates','MNI152_T1_2mm_brain.nii');
    warning('Choosing the Default WhifuN MNI template: MNI152_T1_2mm_brain.nii, as template was not specified')
end

    
% ---- Your function logic here ---- %
% disp('Running QC with these params:');
% disp(params);
fg = spm_figure('GetWin','Graphics');
temp = spm('WinSize','Graphics');
set(fg,'Position',[temp(1),temp(2),temp(4),temp(3)])
set(fg,'PaperPosition',[temp(1),temp(2),temp(4),temp(3)])

if Subj_list_1.error == 0 && Subj_list_1.manual_ex == 0

    %% Anatomical and Functional initial alignment check

    if ~whifun_isnan_or_empty(Subj_list_1,'nii_func_native') && ~whifun_isnan_or_empty(Subj_list_1,'nii_anat_native')
        out_folder = fullfile(quality_control_path,'a_Initial_check');

        whifun_qc_initial_align_check(out_folder,template_path,Subj_list_1,slover_slices_native,slover_contour_range_native,slover_view,over_write)
    end
    %% Head motion QC
    if (~isempty(motion_txt) || ~whifun_isnan_or_empty(Subj_list_1,'motion_txt')) && ~whifun_isnan_or_empty(Subj_list_1,'realigned_func_native')
        out_folder = fullfile(quality_control_path,'b_Head_motion');
        name = Subj_list_1.name; % Extract the subject name for further processing

        if isfield(Subj_list_1,'realigned_func_native')
            func_path = Subj_list_1.realigned_func_native;
        elseif isfield(Subj_list_1,'final_func_MNI')
            func_path = Subj_list_1.final_func_MNI;
        end
        % whifun_qc_head_motion(out_folder,Subj_list_1,max_fd,mean_fd,greater_than_20,over_write,motion_txt)
        whifun_qc_head_motion(out_folder,func_path,name,max_fd,mean_fd,greater_than_20,over_write,motion_txt)
      
    end

    if Subj_list_1.motion_ex ~= 1
        %% Segmentation QC
        out_folder = fullfile(quality_control_path,'c_Segmentation');
        if ~whifun_isnan_or_empty(Subj_list_1,'GM_MNI') && ~whifun_isnan_or_empty(Subj_list_1,'WM_MNI') && ~whifun_isnan_or_empty(Subj_list_1,'CSF_MNI') && ~whifun_isnan_or_empty(Subj_list_1,'anat_MNI')
            whifun_qc_segment(out_folder,Subj_list_1.name,Subj_list_1.anat_MNI,Subj_list_1.GM_MNI,Subj_list_1.WM_MNI,Subj_list_1.CSF_MNI,slover_slices_mni,slover_contour_range_mni,slover_view,'MNI',over_write)
        end

        if ~whifun_isnan_or_empty(Subj_list_1,'GM_native') && ~whifun_isnan_or_empty(Subj_list_1,'WM_native') && ~whifun_isnan_or_empty(Subj_list_1,'CSF_native') && ~whifun_isnan_or_empty(Subj_list_1,'skull_stripped_anat_native')
            whifun_qc_segment(out_folder,Subj_list_1.name,Subj_list_1.skull_stripped_anat_native,Subj_list_1.GM_native,Subj_list_1.WM_native,Subj_list_1.CSF_native,slover_slices_native,slover_contour_range_native,slover_view,'Native',over_write)
        end

        %% Coregisteration QC
        out_folder = fullfile(quality_control_path,'d_Co_registeration');
        if ~whifun_isnan_or_empty(Subj_list_1,'coregistered_func_native') && ~whifun_isnan_or_empty(Subj_list_1,'skull_stripped_anat_native')
            whifun_qc_coreg(out_folder,Subj_list_1.coregistered_func_native,Subj_list_1.skull_stripped_anat_native,Subj_list_1.name,slover_slices_native,slover_contour_range_native,slover_view,over_write)
        end


        %% CSF mask
        if Reg_CSF
            if Reg_MNI
                in_func = Subj_list_1.func_MNI;
            else
                in_func = Subj_list_1.coregistered_func_native;
            end
            out_folder = fullfile(quality_control_path,'e_CSF_Masks_for_Regression');
            if ~whifun_isnan_or_empty(Subj_list_1,'coregistered_func_native') && ~whifun_isnan_or_empty(Subj_list_1,'CSF_mask_func')
                whifun_qc_csf_mask_alignment(out_folder,in_func,Subj_list_1.CSF_mask_func,Subj_list_1.name,slover_slices_native,slover_contour_range_native,slover_view,over_write)
            end
        end

        %% Regression QC
        if Reg_CSF || motion_reg
            out_folder = fullfile(quality_control_path,'f_Nuisance_Regression');
            if ~whifun_isnan_or_empty(Subj_list_1,'coregistered_func_native') && ~whifun_isnan_or_empty(Subj_list_1,'nuisance_regressed_func_native') && ~whifun_isnan_or_empty(Subj_list_1,'motion_txt') && ~whifun_isnan_or_empty(Subj_list_1,'nuisance_regression_csf_covariates')
                whifun_qc_nuisance_regression_global_ts(out_folder,Subj_list_1,Reg_CSF,motion_reg,pca_for_temp_reg,over_write,n_pca)

                if ~whifun_isnan_or_empty(Subj_list_1,'GM_native') && ~whifun_isnan_or_empty(Subj_list_1,'WM_native') && ~whifun_isnan_or_empty(Subj_list_1,'CSF_native')
                    whifun_qc_nuisance_regression_vox_ts(out_folder,Subj_list_1,slover_slices_native,slover_contour_range_native,slover_view,over_write)
                end
            end
        end
        %% Filtering QC
        if ~whifun_isnan_or_empty(Subj_list_1,'filtered_func_native')
            out_folder = fullfile(quality_control_path,'g_Filtering');
            whifun_qc_filter(out_folder,Subj_list_1,over_write,1,filter_lp,filter_hp)
        end
        %% Smoothing QC
        if ~whifun_isnan_or_empty(Subj_list_1,'smoothed_func')
            out_folder = fullfile(quality_control_path,'h_Smoothing','Native_Space');
            whifun_qc_smooth(out_folder,Subj_list_1.smoothed_func,Subj_list_1.name,slover_slices_native,slover_contour_range_native,slover_view,over_write)
        end

        %% normalization QC
        out_folder = fullfile(quality_control_path,'i_Final_func_MNI');
        % slover_contour_range_final_mni = [0 5000];

        if ~whifun_isnan_or_empty(Subj_list_1,'final_func_MNI')
            whifun_qc_final_func_MNI(out_folder,Subj_list_1.final_func_MNI,Subj_list_1.GM_MNI,Subj_list_1.WM_MNI,Subj_list_1.CSF_MNI,template_path,motion_txt,Subj_list_1.name,slover_slices_mni,slover_contour_range_final_mni,slover_view,over_write)
        end

        %% Seed corr plots
        out_folder = fullfile(quality_control_path,"k_Seed_Based_Corr");
        thresh = [-0.25,0.25];
        % slover_view_array = {'sagittal','axial'};
        rad = 6;

        if ~whifun_isnan_or_empty(Subj_list_1,'final_func_MNI')
            whifun_qc_seed_corr(out_folder,Subj_list_1.final_func_MNI,Subj_list_1.name,thresh,rad,slover_slices_mni,slover_view,over_write,Subj_list_1.func_mask_MNI)
        end

        %% Time series Quality Check
        out_folder = fullfile(quality_control_path,'j_Time_series_check');
        if ~whifun_isnan_or_empty(Subj_list_1,'initial_func_native')
            if ~whifun_isnan_or_empty(Subj_list_1,'nuisance_regression_csf_covariates')
                whifun_qc_global_ts(out_folder,Subj_list_1.initial_func_native,Subj_list_1.final_func_MNI,Subj_list_1.motion_txt,Subj_list_1.func_mask_MNI,Subj_list_1.name,Reg_CSF,over_write,Subj_list_1.nuisance_regression_csf_covariates,n_pca,pca_for_temp_reg)
            else
                whifun_qc_global_ts(out_folder,Subj_list_1.initial_func_native,Subj_list_1.final_func_MNI,Subj_list_1.motion_txt,Subj_list_1.func_mask_MNI,Subj_list_1.name,0,over_write)
            end
        end
        clf(fg)
    else
        disp(['Participant ' Subj_list_1.name ' got rejected due to excessive motion during preprocessing. See b_Head_motion folder for more details'])
    end
else
    if Subj_list_1.error == 1
        disp(['Participant ' Subj_list_1.name ' got errors during preprocessing. See Error Info in Quality Control Folder'])
    elseif Subj_list_1.manual_ex == 1
        disp(['Participant ' Subj_list_1.name ' was manually rejected during preprocessing.'])
    end
end
% close(fg)