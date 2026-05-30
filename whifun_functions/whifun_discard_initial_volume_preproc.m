function Subj_list_1 = whifun_discard_initial_volume_preproc(quality_control_path,Subj_list_1,in_func_path,out_func_path,n_vol_dis,over_write)
% WHIFUN_DISCARD_INITIAL_VOLUME Removes initial volumes from a functional scan.
%
%   Subj_list_1 = WHIFUN_DISCARD_INITIAL_VOLUME(quality_control_path, Subj_list_1, ..., over_write)
%   discards a specified number of initial volumes (`n_vol_dis`) from a
%   functional NIfTI file. This is a common step in fMRI preprocessing to
%   allow for signal to stabilize.
%
%   The function first checks if the output file already exists and, based on
%   the `over_write` flag, either uses the existing file or deletes it and
%   creates a new one. It then reads the functional data, discards the
%   initial volumes, and saves the new file. The subject structure is updated
%   with the path to the new file and the new number of time points.
%
%   In case of an error during this process, the function catches the
%   exception, sets the subject's `error` flag to 1, and logs the error to a
%   file.
%
%   Input Arguments:
%   quality_control_path - Path to the quality control directory for saving logs.
%   Subj_list_1          - A single subject structure to be updated.
%   in_func_path         - The path to the input functional NIfTI file.
%   out_func_path        - The desired path for the output file.
%   n_vol_dis            - The number of initial volumes to discard.
%   over_write           - (Optional) A logical value (0 or 1) to force
%                          overwriting the output file. Defaults to 0.
%
%   Output Arguments:
%   Subj_list_1 - The updated subject structure with the new `initial_vol_cut`
%                 file path and the updated `nt_dis` (number of time points
%                 after discarding).
%
%   Example:
%      % Discard 4 initial volumes from a functional scan
%      % updated_subj = whifun_discard_initial_volume(qc_path, subj, in_path, out_path, 4);
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, NIFTIINFO, NIFTIREAD, NIFTISAVE, TRY, CATCH.
if ~exist("over_write",'var')
    over_write = 0 ;
end

if n_vol_dis ~= 0
    disp(['Discarding ',num2str(n_vol_dis ),' Initial Volumes'])

    try
        % Check if the discarded volume file already exists
        cfunc_dir = whifun_create_file(over_write,out_func_path);
        
        if isempty(cfunc_dir)
            now_func_path = dir(in_func_path) ;
            if length(now_func_path) > 1
                now_func_path = whifun_multiple_file_found(now_func_path,anat_func);
            end
            func_info = niftiinfo(fullfile(now_func_path.folder,now_func_path.name));    % read the nifti header
            func_image = niftiread(fullfile(now_func_path.folder,now_func_path.name));   % read the image

            cfunc_image = func_image(:,:,:,n_vol_dis+1:end);                             % Discard the volumes
            Subj_list_1.nt_dis = Subj_list_1.nt - n_vol_dis;
            Subj_list_1.initial_func_native = out_func_path;
            niftisave(cfunc_image,out_func_path,func_info); % Save the new file

            disp(['Discarding volumes is complete for ' Subj_list_1.name])
        else
            info = niftiinfo(fullfile(cfunc_dir.folder,cfunc_dir.name));
            Subj_list_1.initial_func_native = out_func_path;
            Subj_list_1.nt_dis = info.ImageSize(4);
            disp(['Volumes already discarded for ' Subj_list_1.name])
        end

    catch exception                                                                       % If error is found

        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp(['Preprocessing has encountered errors in Discarding Initial Volumes for ' Subj_list_1.name ', I have saved the variables in the participant folder :-) '])
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')

        Subj_list_1.error = 1;                                                                                    % Remove participant from further preprocessing                             % Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_1.name)).error = 1;
        write_error(exception,quality_control_path, Subj_list_1.name)                % write error to text file and display                % write error to text file, update csv and display
        return
    end
    disp(['Discarding Volumes over for ' Subj_list_1.name])
else
    Subj_list_1.nt_dis = Subj_list_1.nt;
    Subj_list_1.initial_func_native = in_func_path;
end