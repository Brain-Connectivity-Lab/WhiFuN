function [Subj_list_1,out_path] = whifun_gunzip_preproc(now_file_path,Subj_list_1,anat_func)
% WHIFUN_GUNZIP_PREPROC Unzips .nii.gz files for preprocessing.
%
%   [Subj_list_1, out_path] = WHIFUN_GUNZIP_PREPROC(now_file_path, Subj_list_1, anat_func)
%   unzips a compressed neuroimaging file (e.g., `file.nii.gz`) to a standard
%   NIfTI file (`file.nii`). The function handles both anatomical and
%   functional data, updating the subject structure with the path to the
%   unzipped file.
%
%   The function first checks for the existence of multiple files and, if
%   found, selects the oldest one. It then checks if the unzipped `.nii` file
%   already exists to avoid redundant processing. If the `.nii.gz` file is
%   present and the `.nii` file is not, it performs the unzipping operation.
%
%   Input Arguments:
%   now_file_path - A `dir` structure pointing to the file to be unzipped.
%   Subj_list_1   - A single subject structure that will be updated.
%   anat_func     - A string, either 'anatomical' or 'functional', to
%                   specify the type of data being processed.
%
%   Output Arguments:
%   Subj_list_1 - The updated subject structure, which now includes a new
%                 field (`nii_anat` or `nii_func`) with the path to the
%                 unzipped file.
%   out_path    - The full path to the unzipped `.nii` file.
%
%   Author: Pratik Jain
%   See also GUNZIP, DIR, FULLFILE, ISEMPTY, ISFILE, SPLIT.
disp(['Unzipping files for ' Subj_list_1.name])

if length(now_file_path)>1  % If more than one func files found choose the one that was created the first

    [~,idx] = sort([now_file_path.datenum]);
    now_file_path = now_file_path(idx);
    now_file_path(2:end) = [];
    warning(['More than one ' anat_func ' files found. Choosing the file ' ,char(now_file_path(1).name), ' as it was created the first for ' Subj_list_1.name]);
end
% cd(now_file_path(1).folder)
%   To extract the names of existing nii.gz files
file_name = now_file_path.name ;            %   Ex: file name.nii.gz
separate_name = split(file_name, '.') ;     %   Ex: 3×1 cell array: {'file name'} {'nii'        } {'gz'         }
data_name = char(separate_name(1)) ;        %   Ex: file name
data_type = char(separate_name(2)) ;        %   Ex: nii

%   If there is unzipped .nii file, skip this unzipping step
if ~isfile(fullfile(now_file_path.folder,[data_name '.' data_type]))       %   If there is no nii file
    if isfile(fullfile(now_file_path.folder,file_name))                  %   If there is gz file
        gunzip(fullfile(now_file_path.folder,file_name))
        
        if strcmp(anat_func,'anatomical')
            Subj_list_1.nii_anat_native = fullfile(now_file_path.folder,[data_name '.' data_type]);
            out_path = Subj_list_1.nii_anat_native;
            disp(['Complete unziping of anatomical data in ' file_name])
        else
            Subj_list_1.nii_func_native = fullfile(now_file_path.folder,[data_name '.' data_type]);
            out_path = Subj_list_1.nii_func_native;
            disp(['Complete unziping of functional data in ' file_name])
        end
    elseif ~isfile(file_name)             %   If there is not gz file also
        disp(['You need a .nii or a .gz file of ' anat_func ' data for further processing.'])
        error(['No .nii or .nii.gz found. Trying to look in ' fullfile(now_file_path.folder,file_name)])
    end
else    %   If there is nii file already
    disp(['You have already a .nii file of ' anat_func ' data for participant , ' Subj_list_1.name,' hence skipping this step.'])
    if strcmp(anat_func,'anatomical')
        Subj_list_1.nii_anat_native = fullfile(now_file_path.folder,[data_name '.' data_type]);
        out_path = Subj_list_1.nii_anat_native;
        disp(['Complete unziping of anatomical data in ' file_name])

    else
        Subj_list_1.nii_func_native = fullfile(now_file_path.folder,[data_name '.' data_type]);
        out_path = Subj_list_1.nii_func_native;
        disp(['Complete unziping of functional data in ' file_name])
    end
end
