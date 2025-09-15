function [build_net,K] = whifun_build_net(out_analysis_path,out_pattern,over_write)
if ~exist('over_write','var')
    over_write = 0;
end
build_net = 0;
cluster_path = fullfile(out_analysis_path,out_pattern);
cluster_dir = whifun_create_file(over_write,cluster_path);
if ~isempty(cluster_dir)

    if isscalar(cluster_dir)
        K_old = str2double(cluster_dir(1).name(16:end-4));
    elseif length(cluster_dir) > 1
        K_old = zeros(1,length(cluster_dir));
        for i = 1:length(cluster_dir)
            K_old(i) = str2double(cluster_dir(i).name(16:end-4));
        end
    end

    answer = questdlg(['WM Clustering file already found with K = ', num2str(K_old) ,'. Do you want to build the networks again?'],...
        'WM CLustering file found','Yes','No','No');
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