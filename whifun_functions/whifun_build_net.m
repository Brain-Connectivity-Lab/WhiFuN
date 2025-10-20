function [build_net,K] = whifun_build_net(cluster_folder,out_pattern,over_write)
%WHIFUN_BUILD_NET Manages the decision process for building Functional Networks (FNs).
%
%   [BUILD_NET, K] = WHIFUN_BUILD_NET(CLUSTER_FOLDER, OUT_PATTERN, OVER_WRITE)
%
%   This function checks if previously clustered FN files exist in the
%   specified folder. If files are found, it prompts the user to either
%   rebuild the networks or select an existing cluster solution (K value)
%   to proceed with.
%
%   Input Arguments:
%   CLUSTER_FOLDER - Full path to the directory where FN cluster results are stored.
%   OUT_PATTERN    - The filename pattern used for the clustered NIfTI files
%                    (e.g., 'WM_FN_K*.nii', where * is the K value).
%   OVER_WRITE     - (Optional, default 0) Flag to bypass prompts if set to 1.
%
%   Output Arguments:
%   BUILD_NET      - Flag indicating whether the networks should be built now:
%                    BUILD_NET = 1: Proceed with network building.
%                    BUILD_NET = 0: Skip building, proceed with existing K.
%   K              - The number of networks (clusters) to proceed with:
%                    K = 0: If BUILD_NET = 1 (K will be determined later).
%                    K = K_old: If BUILD_NET = 0 (using a previously computed K).
%
%   Dependencies: 'whifun_create_file', 'questdlg', 'inputdlg' functions.
%
%   Author: Pratik Jain

if ~exist('over_write','var')
    over_write = 0;
end
build_net = 0;
if ~exist(cluster_folder,"dir")
    mkdir(cluster_folder)
end
cluster_path = fullfile(cluster_folder,out_pattern);
cluster_dir = whifun_create_file(over_write,cluster_path);
if ~isempty(cluster_dir)

    if isscalar(cluster_dir)
        K_old = str2double(cluster_dir(1).name(8:end-4));
    elseif length(cluster_dir) > 1
        K_old = zeros(1,length(cluster_dir));
        for i = 1:length(cluster_dir)
            K_old(i) = str2double(cluster_dir(i).name(8:end-4));
        end
    end

    answer = questdlg(['FN file already found with K = ', num2str(K_old) ,'. Do you want to build the networks again?'],...
        'FN file found','Yes','No','No');
    switch answer
        case 'Yes'
            build_net = 1;
            K = 0;
        case 'No'
            if isscalar(K_old)
                K = K_old;
            else
                while (1)
                    ques = inputdlg(['Choose the K you want to proceed with, available options are K = ' num2str(K_old)]);
                    ques = str2double(cell2mat(ques));
                    if sum(ques == K_old)
                        K_old = ques;
                        K = K_old;
                        break
                    else
                        cancel = questdlg(['Requested K value not found please only choose from K = ' num2str(K_old)],'Not found K','Quit','Re-enter','Re-enter');

                        switch cancel
                            case 'Quit'
                                return
                        end
                    end
                end
            end
        otherwise
            return
    end
else
    build_net = 1;
    K = 0;
end