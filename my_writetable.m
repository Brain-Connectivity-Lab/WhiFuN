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
    end

end
end