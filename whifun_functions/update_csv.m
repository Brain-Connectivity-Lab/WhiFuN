function Subj_list_all = update_csv(Subj_list_subji,Subj_list_all,output_folder)
Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).motion_ex = Subj_list_subji.motion_ex;
Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).error = Subj_list_subji.error;
Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).nt_dis = Subj_list_subji.nt_dis;

Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).time_preprocess_min = Subj_list_subji.time_preprocess_min;
my_writetable(struct2table(Subj_list_all), fullfile(output_folder,"Subj_list.csv"))
end