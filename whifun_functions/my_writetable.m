function my_writetable(Subj_list_all_table,path)
try
    try
        Subj_list_all_table(:,'bytes') = [];
    catch
    end
    try
        Subj_list_all_table(:,'date') = [];
    catch
    end
    try
        Subj_list_all_table(:,'datenum') = [];
    catch
    end
    try
        Subj_list_all_table(:,'isdir') = [];
    catch
    end
    writetable(Subj_list_all_table,path)
catch ex
    switch ex.identifier
        case 'MATLAB:table:write:FileOpenError'
            response_ = questdlg('The Subj_list.csv file is open, Please manually close it and hit done. ','Subj_list.csv file open','done','close msgbox','done');

            switch response_
                case 'done'
                    writetable(Subj_list_all_table,path)
                case 'close msgbox'
                    
            end
        otherwise
            
            fprintf([ '<strong>' ex.identifier '</strong> \n'])
            fprintf(['Error Message :' '<strong>' ex.message '</strong> \n'])
            fprintf(['Code ran on ' char(datetime) '\n \n']);
            for err_i = 1:length(ex.stack)
                fprintf(['Error using ' '<strong>' ex.stack(err_i).name '</strong>' ' (line ' num2str(ex.stack(err_i).line) ')\n' ])

            end
            error('See above');
    end

end
end