function write_error(exception,quality_control_path,name)

% Display in command 
        fprintf([ '<strong>' exception.identifier '</strong> \n'])
        fprintf(['Error Message :' '<strong>' exception.message '</strong> \n'])
        fprintf(['Code ran on ' char(datetime) '\n \n']);
        for err_i = 1:length(exception.stack)
            fprintf(['Error using ' '<strong>' exception.stack(err_i).name '</strong>' ' (line ' num2str(exception.stack(err_i).line) ')\n' ])
            
        end
        
        % write to file
        err_fileID = fopen(fullfile(quality_control_path,'Error_Info',[name '_error_info.txt']),'a');
                
        fprintf(err_fileID,'#####################################################################################################################\n \n');
        fprintf(err_fileID, ['Subject Name: ' name '\n \n']);
        fprintf(err_fileID,['Code ran on ' char(datetime) '\n \n']);
        fprintf(err_fileID,[ exception.identifier ' \n']);
        fprintf(err_fileID,['Error Message :'  exception.message '\n']);
        
        for err_i = 1:length(exception.stack)
            fprintf(err_fileID,['Error using ' exception.stack(err_i).name ' (line ' num2str(exception.stack(err_i).line) ')\n' ]);
        end
        fprintf(err_fileID,'\n');
        fclose(err_fileID);
end
