function clean_up_after_preprocessing(Subj_list_1,log_file_id)

msg = '---------------------------------------------------Anat Clean up------------------------------------------------------------------\n';

fprintf(log_file_id,msg);
fprintf(msg);

% anat
clean_up_folder(Subj_list_1.anat_folder,log_file_id)

msg = '---------------------------------------------------func Clean up------------------------------------------------------------------\n';

fprintf(log_file_id,msg);
fprintf(msg);

%func
clean_up_folder(Subj_list_1.func_folder,log_file_id)

end

