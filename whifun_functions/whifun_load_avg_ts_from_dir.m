function out = whifun_load_avg_ts_from_dir(path_,freq)
if ~exist('freq','var')
    freq = 0;
end
subj_list = dir(path_);
n = length(subj_list);
out.avg_ts = cell(n,1);
i = 1;
temp = load(fullfile(subj_list(i).folder,subj_list(i).name));

if ~freq
    out.avg_ts{i} = temp.avg_ts;
else
    out.avg_ts{i} = temp.avg_ts_freq;
    out.hp = temp.hp;
    out.lp = temp.lp;
end
out.Subj_list = temp.Subj;
for i = 2:n
    temp = load(fullfile(subj_list(i).folder,subj_list(i).name));
    if ~freq
        out.avg_ts{i} = temp.avg_ts;
    else
        out.avg_ts{i} = temp.avg_ts_freq;
    end
    out.Subj_list(i) = temp.Subj;
end