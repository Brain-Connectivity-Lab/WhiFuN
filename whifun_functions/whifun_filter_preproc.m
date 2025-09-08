function [Subj_list_1,out_func_path] = whifun_filter_preproc(quality_control_path,Subj_list_1,in_func_path,in_func_mask_path,filter_lp,filter_hp,f_pre,log_fileID,over_write)
% WHIFUN_FILTER_PREPROC Performs bandpass filtering on functional data.
%
%   [Subj_list_1, out_func_path] = WHIFUN_FILTER_PREPROC(...) is a high-level
%   function that manages the bandpass filtering step of fMRI preprocessing.
%   Filtering removes unwanted high-frequency physiological noise and low-frequency
%   scanner drift, isolating the BOLD signal of interest.
%
%   The function performs the following steps:
%   1. **Check Existence**: It checks if a pre-filtered file already exists.
%      Based on the `over_write` flag, it either skips the process or
%      creates a new file.
%   2. **Load Data**: It loads the functional data and the brain mask into
%      the workspace.
%   3. **Design Filter**: It uses the `butter` function to design a 2nd-order
%      Butterworth bandpass filter based on the specified low-pass (`filter_lp`)
%      and high-pass (`filter_hp`) cutoffs and the TR of the scan.
%   4. **Apply Filter**: It applies the filter to the time series of each
%      voxel within the brain mask using `filtfilt` to avoid phase distortion.
%      The mean signal is added back to the filtered data to preserve its
%      original magnitude.
%   5. **Save Output**: The filtered data is saved as a new NIfTI file, and
%      the subject structure is updated. The process output is logged to a
%      file.
%
%   In case of an error, the function catches the exception, updates the
%   subject's `error` flag, and logs the detailed error information.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_func_path         - The path to the input functional file.
%   in_func_mask_path    - The path to the brain mask in functional space.
%   filter_lp            - The low-pass filter cutoff frequency in Hz.
%   filter_hp            - The high-pass filter cutoff frequency in Hz.
%   f_pre                - The prefix for the output filtered file.
%   log_fileID           - File ID of the log file for writing process output.
%   over_write           - A logical value (0 or 1) to force overwriting.
%
%   Output Arguments:
%   Subj_list_1   - The updated subject structure, with the `filtered` file path.
%   out_func_path - The full path to the filtered functional file.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, BUTTER, FILTFILT, NIFTIREAD, NIFTISAVE, TRY, CATCH.

disp(['Filtering is started for ' Subj_list_1.name])
try
    now_func_path = dir(in_func_path) ;
    out_func_path = fullfile(now_func_path.folder,[f_pre,now_func_path.name]);

    f_path =  whifun_create_file(over_write,out_func_path);
    
    if isempty(f_path)

        func_info = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));
        func_image = double(niftiread(fullfile(now_func_path.folder,now_func_path.name)));
        dim = size(func_image);
        nt  = dim(4);
        func_image = reshape(func_image,[],nt);
        tr = Subj_list_1.TR;

        % Loading Rest mask
        func_MASK = niftiread(in_func_mask_path);
        func_MASK = logical(reshape(func_MASK,[],1));

        fs = 1/tr;
        % disp('Using Butterworth filter of 2th order for filtering')
        [b,a] = butter(2,[filter_lp,filter_hp]/(fs/2),'bandpass');

        f_func_image = zeros(prod(dim(1:3)),nt)';
        ts = func_image(func_MASK,:)-mean(func_image(func_MASK,:),2);
        ts(isnan(ts)) = 0;
        f_func_image(:,func_MASK) = filtfilt(b,a,ts');
        f_func_image = f_func_image';
        f_func_image = f_func_image + mean(func_image,2);

        f_func_image = reshape(f_func_image,dim);
        f_func_image = cast(f_func_image,func_info.Datatype);

        niftisave(f_func_image,out_func_path,func_info);
        
        fprintf(log_fileID, 'Filtering\n');
        fprintf(log_fileID,'%s', ['Using Butterworth bandpass filter of 2th order for filtering with the following low and high cutoff : [' num2str(filter_lp) ' ' num2str(filter_hp) ']']);
    else
        disp(['Filtering already done for ' Subj_list_1.name])
    end
Subj_list_1.filtered_func_native = out_func_path;

catch exception
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp(['Preprocessing has encountered errors in filtering for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

    Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
    write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
    return
end

disp(['Filtering is done for ' Subj_list_1.name])