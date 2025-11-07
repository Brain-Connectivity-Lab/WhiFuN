function Subj_list_all = write_error_preproc(exception,quality_control_path,Subj_list_subji,Subj_list_all,output_folder)

% Display in command 
        fprintf([ '<strong>' exception.identifier '</strong> \n'])
        fprintf(['Error Message :' '<strong>' exception.message '</strong> \n'])
        fprintf(['Code ran on ' char(datetime) '\n \n']);
        for err_i = 1:length(exception.stack)
            fprintf(['Error using ' '<strong>' exception.stack(err_i).name '</strong>' ' (line ' num2str(exception.stack(err_i).line) ')\n' ])
            
        end
        
        % write to file
        err_fileID = fopen(fullfile(quality_control_path,'Error_Info',[Subj_list_subji.name '_error_info.txt']),'a');
                
        fprintf(err_fileID,'#####################################################################################################################\n \n');
        fprintf(err_fileID, ['Subject Name: ' Subj_list_subji.name '\n \n']);
        fprintf(err_fileID,['Code ran on ' char(datetime) '\n \n']);
        fprintf(err_fileID,[ exception.identifier ' \n']);
        fprintf(err_fileID,['Error Message :'  exception.message '\n']);
        
        for err_i = 1:length(exception.stack)
            fprintf(err_fileID,['Error using ' exception.stack(err_i).name ' (line ' num2str(exception.stack(err_i).line) ')\n' ]);
        end
        fprintf(err_fileID,'\n');
        fclose(err_fileID);

        Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).motion_ex = Subj_list_subji.motion_ex;
        Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).error = Subj_list_subji.error;
        Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).nt_dis = Subj_list_subji.nt_dis;


        my_writetable(struct2table(Subj_list_all), fullfile(output_folder,"Subj_list.csv"))
end
