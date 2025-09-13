function whifun_qc_filter(out_folder,Subj_list_1,over_write,filter_freq_response_flag,filter_lp,filter_hp)
% WHIFUN_QC_FILTER Generates quality control figures for the filtering step.
%
%   WHIFUN_QC_FILTER(out_folder, Subj_list_1, over_write, filter_freq_response_flag, filter_lp, filter_hp)
%   creates visual quality control reports to assess the effectiveness of
%   the bandpass filtering applied to functional data.
%
%   The function performs the following steps:
%   1.  **Check Existence**: It checks if the output plots already exist and,
%       based on the `over_write` flag, either skips or generates new ones.
%       The output includes up to two figures.
%   2.  **Global Time Series Plot**: It plots the mean global time series of
%       the functional data *before* and *after* filtering. The global mean
%       is calculated across all voxels at each time point. The plot, with
%       the mean subtracted, visually demonstrates the removal of
%       low-frequency drift and high-frequency noise.
%   3.  **Frequency Response Plot**: If `filter_freq_response_flag` is true,
%       it calculates the frequency response of the Butterworth filter that was
%       used. This plot provides a technical verification of the filter's design.
%       It uses an assumed helper function `whifun_plot_freqz` for this purpose.
%   4.  **Export**: All generated plots are saved as PNG files in a dedicated
%       quality control directory.
%
%   Input Arguments:
%   out_folder                 - The root directory for saving all QC output.
%   Subj_list_1                - A single subject structure with `nuisance_regressed`
%                                and `filtered` file paths, and `TR`.
%   over_write                 - A logical value (0 or 1) to force overwriting existing
%                                QC images.
%   filter_freq_response_flag  - A logical flag (0 or 1) to generate the
%                                frequency response plot.
%   filter_lp                  - (Optional) The low-pass cutoff frequency of the filter in Hz.
%   filter_hp                  - (Optional) The high-pass cutoff frequency of the filter in Hz.
%
%   Author: Pratik Jain
%   See also WHIFUN_CREATE_FILE, NIFTIREAD, FIGURE, PLOT, LEGEND, EXPORTGRAPHICS.


if ~exist("filter_freq_response_flag",'var')
    filter_freq_response_flag = 0;
    filter_lp = [];
    filter_hp = [];
end
out_image_path = fullfile(out_folder,'Native_Space','Global_timeseries_before_and_after_filtering',[Subj_list_1.name '.png']);
if ~exist(fileparts(out_image_path),"dir")
    mkdir(fileparts(out_image_path)); % Create the directory if it does not exist
end
out_filter_path = fullfile(out_folder,'Native_Space','filter',[Subj_list_1.name '_filter_freq_response.png']);
if ~exist("out_filter_path","dir")
    mkdir(fileparts(out_filter_path));
end
fil_qc_file=  whifun_create_file(over_write,out_image_path);

if isempty(fil_qc_file)

    % Quality Control
    % Plot the mean time series before and after regression

    % Read the raw file

    func_image = double(niftiread(Subj_list_1.nuisance_regressed_func_native));
    [x,y,z,nt] = size(func_image);
    func_image = reshape(func_image,x*y*z,nt);

    global_ts = mean(func_image,'omitnan');

    f_func_image = double(niftiread(Subj_list_1.filtered_func_native));
    [x,y,z,nt] = size(f_func_image);
    f_file = reshape(f_func_image,x*y*z,nt);
    global_ts_f = mean(f_file,'omitnan');

    f = gcf; plot(global_ts-mean(global_ts));
    hold on
    plot(global_ts_f -mean(global_ts_f))
    title(['Global Time Series (mean subtracted)' ' participant ' Subj_list_1.name])
    legend('Before filtering','After filtering')
    
    xlabel('time points')
    ylabel('Bold Signal (mean substracted)')
    exportgraphics(f,out_image_path)

    if filter_freq_response_flag
        tr = Subj_list_1.TR;
        fs = 1/tr;
        [b,a] = butter(2,[filter_lp,filter_hp]/(fs/2),'bandpass');
        gf = gcf; whifun_plot_freqz(b,a,fs);          % Plot the frequency responce using 512 points
        exportgraphics(gf,out_filter_path)
    end
end

disp(' ')
disp(['Global timeseries after Filtering QC Plot generated for Participant : ' Subj_list_1.name])
disp(['See : ' fullfile(out_folder,'Native_Space')])
disp(' ')
