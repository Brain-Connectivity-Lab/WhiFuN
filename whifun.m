function whifun(varargin)
%% White matter Functional Networks Toolbox
% Written by Pratik Jain
% email:pj44@njit.edu
%% This code and Readme file was written by Pratik Jain.
%% This code was written with the help of different preprocessing scripts given by
%% Dr. Xin Di, Dr. Rakibul Hafeez, Donna Chen and Wohnbum Sohn.
% Run this code to start using the White Matter Functional Network toolbox. once you run
% this code a GUI window will pop up and you can look at the following steps
% to understand how to use the toolbox.
%
% # WhiFuN
% This GUI-based toolbox offers researchers a user-friendly suite of automated tools for investigating brain functional connectivity in WM and GM. One of the key advantages of WhiFuN is that it fully automates the preprocessing steps to derive data that can be used to analyze the WM and GM BOLD signals.
%
% ## New to WhiFuN?
% WhiFuN is based on MATLAB; hence, it will not work if MATLAB is not installed.
% MATLAB R2022a or later versions are recommended.
%
%
% Additionally WhiFuN uses
% 1) Image Processing Toolbox
% 2) Signal processing Toolbox
% 3) Statistics and Machine Learning Toolbox
% 4) Bioinformatics toolbox
%
% These toolboxes can be downloaded by using the Add ons feature in Matlab. More details here: https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html
%
%
% ### Follow these steps to get started
%
% 1) Download WhiFuN in a local folder and unzip all the contents (Download WhiFuN by clicking on the green 'Code' button and then selecting Download zip, the toolbox will take about 24MB od disk space)
% 2) Open MATLAB and addpath of the WhifuN toolbox to MATLAB
%
%      i) by using the addpath function: Type the following in the MATLAB command window and press enter.
%
%          addpath('<path to the WhiFuN folder>\WhiFuN-main\WhiFuN-main')
%
%    or
%
%      ii) Click _home_ when you are on the main screen of MATLAB (top left) and then under the environment section click on _set path_. Next, click on _Add Folder_, select the WhiFuN-main folder with the _whifun.m_ code and click on _Select folder_. Finally, click _save_ and then _close_.
%
% 4) If SPM12 toolbox is not downloaded, Please download the SPM12 toolbox from https://www.fil.ion.ucl.ac.uk/spm/software/download/ , and addpath of the spm toolbox in MATLAB
%
%      i) by using the addpath function: Type in the MATLAB command window and press enter.
%
%           addpath('<path to the SPM folder>\spm12\spm12')
%
%    or
%
%      ii) Click _home_ when you are on the main screen of MATLAB (top left) and then under the environment section click on _set path_. Next, click on _Add Folder_, select the SPM folder with the _spm.m_ code, and click _Select folder_. Finally, click _save_ and then _close_.
%
% 6) Once all the paths are set, type _whifun_ in the MATLAB command and press enter.
% 7) The main GUI window of WhiFuN will open.
%
%    i) Now, first, select the _Outputs folder_ button and select an empty folder where all the outputs and quality control plots will be saved. Alternatively, one can paste the path of the output folder in the text field beside the _Outputs folder_ button.
%
%    ii) Click the _Select Data Folder_ button and select the folder with all the Subjects folders. As an example, we show how WhiFuN can be used with some practice data that can be downloaded here https://drive.google.com/drive/folders/1l7dhG8dYYRCW5EWhkPZbBpA7TOau1W-B?usp=sharing . Download the practice data, unzip the contents, and select the folder 'practice_NYU_abide' using the _Subject folder button_ or paste the complete path into the practice_NYU_data.
%
%    iii) Now, this dataset is not in Brain Imaging Data Structure (BIDS) format (more information on BIDS here : https://bids.neuroimaging.io/ ); hence, uncheck the _BIDS_ check box on the right of the 'Subject Data Folder' text field. That will open a new window where the folder names can be entered. Type the following in the fields
%
%    a) Intermediate Folder --> session_1
%
%    (there is an intermediate folder between the subject folder and the anatomical and functional file folder. If there is more than one folder session_1 and then 'MRI' folder, one can put the path as session_1\MRI for windows or session_1/MRI for linux or mac users )
%
%    b) Functional Folder Name --> rest_1
%
%    (the folder that contains the functional image)
%
%    c) Anatomical Folder Name --> anat_1
%
%    (the folder that contains the anatomical image)
%
%    d) Functional Image Name --> rest
%
%    (the .nii or .nii.gz functional image name, sometimes the subject name is there in the functional image name, then the common part can be mentioned and the subject name that changes for every subject can be replaced by a * . For instance if the func file name is sub-1001.nii for subject 1001 and sub-1002.nii for subject 2, one can put sub-*)
%
%    e) Anatomical Image Name --> mprage
%
%    (the .nii or .nii.gz anatomical image name, sometimes the subject name is there in the anatomical image name, then the common part can be mentioned and the subject name that changes for every subject can be replaced by a * . For instance if the anat file name is sub-1001.nii for subject 1001 and sub-1002.nii for subject 2, one can put sub-*)
%
%    f) Once all the field are filled, click submit. If the toolbox doesnt find a folder or file for the first subject, it will notify the folder or file not found and changes can be made accordingly.
%
%    iv) Next, check the 'All folders are subjects' checkbox; this means we want to process every subject. Alternatively, one can just select a subset of subjects if all subjects should not be processed. This will display the number of subjects that will be processed by WhiFuN.
%
%    v) Next, click on _Run Data check_ and make sure that the functional and Anatomical images are present for every subject and that all the MRI parameters of all the images are correct.
%
% 6) After the Data check, a Data check report will be shown. Make sure it says, 'Data check completed successfully'.
% 7) Have a look at the preprocessing step parameters. If something needs to be changed, it can be changed (for more details, refer paper)
% 9) Click _Run Preprocessing_.
% 10) Preprocessing will take some time, depending on the PC used to preprocess. After Preprocessing for one subject is done, WhiFuN will also display the estimated time to complete the preprocessing.
% 11) Once preprocessing is complete, please go to the output folder (using the file browser) and check the quality control plots saved for every subject (refer to the paper for more details).
% 12) Based on the quality control, subjects with bad data should be discarded by checking the manually exclude subjects checkbox in the _Construct FN and FC_ section. Once the subjects are excluded, the White Matter Functional Networks (WM-FN) can be created. (Refer to the paper for more details on the parameters).
% 13) Click _Create WM-FN_, and WhiFuN will start creating the FN with the different values of K specified. After the cross-validation for every value of K specified is done, WhiFuN will plot the average dice coefficient and the distortion for every value of K. (refer to the paper to find the optimal K value).
% 14) Choose the desired value of K and the WM-FN will be saved as a .nii file in <outputs_folder>/Analysis/WM_FN .
% 15) Similarly, GM-FN can be created.
% 16) Once the FNs are created _Display_FN_ can be used to see the FNs using SPM or BrainNet viewer (already included in the toolbox).

%
% Quality Check Files
%
% Q1a_scanning_parameters --> This file tells the number of volumes in every subject in the first row, the TR for every subject, The x,y,z direction
% voxels sizes of all the subjects from fmri and anatomical files. Based on the values of voxel size of fmri images the motion parameters can be set.
% For eg. if fmri voxel sizes of all subjects is 2mm, then the max_trans and max_rotat values should be less than 2mm.
%
% Initial check --> This folder shows how far away the anatomical and functional images are from the standard MNI space. One should observe the orientation
% of every subject here, if the orientation of a subject's image is flipped or is upside down then one will have to mannualy orient those first such that
% the images have the same orientation
%
%
% Head motion --> Here the global mean rigid body motion pairwise variance and framewise displacement correponding to every subject will be stored.
%  If excessive motion is present it will also show the max cutoff line in the framewise displacement plot. Which can tell at which timepoint on the
% x-axis the motion occured. Also a file Q3_head_motion will be present that has the translational motion and rotational motion plotted on the x and
% y axis respectively. And the maximum cutoff for both will be shown. This also contains a text file that tells information about the excluded subjects.
%
% Segmentation --> Plots the Gray matter (Red), White Matter (Green) and CSF (Blue) and the MNI template below. Make sure that the Gray Matter, White matter
%  and CSF are correctly identified in all subjects.
%
% Co-registeration --> Shows the anatomical and the  functional images plotted for every subject and the contour of the anatomical image plotted on the functional image to
% check the registeration properly.
%
% Masks --> Here the CSF and WM masks for all the images are plotted along with the functional file, make sure that the masks are correctly oriented to the
% functional image and there might also be subjects for which the mask shows a empty matrix. You might have to change the CSF or WM threshold to get the masks
% for such subjects.
%
% Regression --> Here the mean timeseries before and after regression is plotted. One can see the effects of regression with these plots.
%
% Smoothing --> here the Smoothed functional image is plotted.
%
% Normalization --> here the normalized functional image in MNI space is plotted with the reference MNI space image. Make sure that both are correctly aligned
%
%
% Time-series check --> (A) Global mean intensity for the raw fMRI images. (B) Six rigid-body head motion parameters in mm or degree.
% (C) The task design regressors of the Task and Control conditions. (D) Correlations among (A) through (C).
%  (E) Variance between consecutive images from the raw data. (F) Framewise displacement in translation and rotation.
%  (G) Derivatives of the task design regressors. (H) Correlations among (E) through (G).
%
% Error handling --> If there is an error that is occured either due to file name or a missing file for any subject, the error information will be stored in
% a txt file in the quality_control_path folder
%
% eg:
%
% Code ran on 09-Aug-2023 17:43:45
%
% #####################################################################################################################
%
% Subject Name: 201
%
% MATLAB:narginchk:notEnoughInputs
% Error Message :Not enough input arguments.
% Error using fullfile (line 43)
% Error using complete_filepath (line 12)
% Error using preprocess_sunlab_complete_with_QC (line 293)
%
% As seen above it shows the time when the code was run,
% The subject name where the error occured,
% The error identifier in matlab along with the error message and the lines where the error ocuured.
% In the above example the error occured on line 293 of the main file, inside that there is a function called complete filepath and inside that function there
% is a function fullfile where the error has occured. The error is that there were not enough arguments given to the fullfile function.
%
% For all the subjects that get an error their information will be appened in this text file, and the code will ignore them while preprocessing and
% continue to process other subjects, After the code has done preprocessing it will show a message that there were errors with some subjets, one can check
% all the errors then in this file.
%
%
% References
%
% Wang P, Meng C, Yuan R, Wang J, Yang H, Zhang T, Zaborszky L, Alvarez TL, Liao W, Luo C, Chen H, Biswal BB. The Organization of the Human Corpus
% Callosum Estimated by Intrinsic Functional Connectivity with White-Matter Functional Networks. Cereb Cortex. 2020 May 14;30(5):3313-3324.
% doi: 10.1093/cercor/bhz311. PMID: 32080708.

%%

if nargin == 0
    Action = 'Welcome';
else
    Action = varargin{1};
end

switch Action

    case 'Welcome'
        clc;
        fprintf('\n');
        fprintf('----------------------------------------------------------------------\n');
        disp('      _       _    _     _    _    ______    _     _    __      _      ');
        disp('     | |     | |  | |   | |  | |  |  ____|  | |   | |  |   \   | |     ');
        disp('     | |     | |  | |___| |  | |  | |____   | |   | |  | |\ \  | |     ');
        disp('     | |  |  | |  |  ___  |  | |  |  ____|  | |   | |  | | \ \ | |     ');
        disp('     | | |_| | |  | |   | |  | |  | |       | |___| |  | |  \ \| |     ');
        disp('      |_|   |_|   |_|   |_|  |_|  |_|        |_____|   |_|   \___|     ');

        fprintf('----------------------------------------------------------------------\n');
        fprintf('            White matter Functional Network Toolbox   \n');
        fprintf('----------------------------------------------------------------------\n');
        fprintf('          WhiFuN initialized. Ready to explore WM-FC! 🚀\n\n');

        disp('<a href="https://github.com/Brain-Connectivity-Lab/WhiFuN/blob/main/WhiFuN-Manual.pdf">                Click here for WhiFuN documentation                   </a>') % Link to MATLAB documentation
        disp('<a href="https://direct.mit.edu/imag/article/doi/10.1162/IMAG.a.3/130628/WhiFuN-A-toolbox-to-map-the-white-matter">                             WhiFuN Paper                             </a>') % Link to an external website
        disp('Please cite')
        disp('Pratik Jain, Andrew M. Michael, Pan Wang, Xin Di, Bharat Biswal; WhiFuN: ')
        disp('A toolbox to map the white matter functional networks of the human brain.')
        disp('Imaging Neuroscience 2025; doi: https://doi.org/10.1162/IMAG.a.3')
        disp(' ')
        disp('Thank you for using WhiFuN.')
        whifun('ver')
        temp_path = mfilename('fullpath');                % path of the toolbox
        preproc_code_path = fileparts(temp_path);

        addpath(preproc_code_path)
        run(fullfile(preproc_code_path,'main.mlapp'))

    case 'ver'
        disp('Version : WhiFuN v1')

end