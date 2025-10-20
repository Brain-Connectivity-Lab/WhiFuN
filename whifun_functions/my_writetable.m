function my_writetable(Subj_list_all_table,path)
%MY_WRITETABLE Writes a WhiFuN Subj_list to a CSV, with robust
%   error handling for common issues like open files.
%
%   MY_WRITETABLE(SUBJ_LIST_ALL_TABLE, PATH)
%
%   This function is a wrapper around MATLAB's built-in `writetable`
%   that first attempts to remove common metadata fields (like those from a
%   `dir` structure) from the table before writing. It also includes specific
%   error handling for the case where the output file is currently open and
%   locked by another application.
%
%   Input Arguments:
%   SUBJ_LIST_ALL_TABLE - The MATLAB table object to be written to disk.
%   PATH                - The full file path and name where the table should be saved
%                         (e.g., 'C:\data\Subj_list.csv').
%
%   Error Handling:
%   - Attempts to catch and handle the 'MATLAB:table:write:FileOpenError'
%     which occurs when the file is locked (e.g., open in Excel). It prompts
%     the user to close the file and retry.
%   - Catches other errors, prints detailed error information to the command
%     window (including identifier, message, and stack trace), and terminates
%     execution with an error.
%
%   Author: Pratik Jain

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