function Subj_list_all = update_csv(Subj_list_subji,Subj_list_all,output_folder)
%UPDATE_CSV Updates Subj_list structure with new information for a
%   specific subject and saves the entire list to a CSV file.
%
%   SUBJ_LIST_ALL = UPDATE_CSV(SUBJ_LIST_SUBJI, SUBJ_LIST_ALL, OUTPUT_FOLDER)
%
%   This utility function is typically used in a processing pipeline to
%   record the status and results (e.g., motion metrics, processing time,
%   error flags) for one subject into the complete subject list.
%
%   Input Arguments:
%   SUBJ_LIST_SUBJI - A structure representing a single subject, containing
%                     the updated fields to be transferred (e.g., `motion_ex`,
%                     `error`, `nt_dis`, `time_preprocess_min`). Must have a
%                     `name` field for matching.
%   SUBJ_LIST_ALL   - The master structure array containing data for all subjects.
%   OUTPUT_FOLDER   - The path to the folder where the updated CSV file
%                     ("Subj_list.csv") will be saved.
%
%   Output Arguments:
%   SUBJ_LIST_ALL   - The updated master structure array.
%
%   Dependencies: 'my_writetable'
%
%   Author: Pratik Jain

Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).motion_ex = Subj_list_subji.motion_ex;
Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).error = Subj_list_subji.error;
Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).nt_dis = Subj_list_subji.nt_dis;

Subj_list_all(logical(string({Subj_list_all.name}) == Subj_list_subji.name)).time_preprocess_min = Subj_list_subji.time_preprocess_min;
my_writetable(struct2table(Subj_list_all,"AsArray",true), fullfile(output_folder,"Subj_list.csv"))
end