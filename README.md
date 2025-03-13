# WhiFuN
This GUI-based toolbox offers researchers a user-friendly suite of automated tools for investigating brain functional connectivity in WM and GM. One of the key advantages of WhiFuN is that it fully automates the preprocessing steps to derive data that can be used to analyze the WM and GM BOLD signals.

## New to WhiFuN? 
WhiFuN is based on MATLAB; hence, it will not work if MATLAB is not installed. 
MATLAB R2022a or later versions are recommended.


Additionally WhiFuN uses 
1) Bioinformatics toolbox
2) Image Processing Toolbox
3) Signal processing Toolbox
4) Statistics and Machine Learning Toolbox

These toolboxes can be downloaded by using the Add ons feature in Matlab. More details here: https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html


### Follow these steps to get started

1) Download WhiFuN in a local folder and unzip all the contents (Download WhiFuN by clicking on the green 'Code' button and then selecting Download zip, the toolbox will take about 24MB of disk space)
2) Open MATLAB and addpath of the WhifuN toolbox to MATLAB
   
     i) by using the addpath function: Type the following in the MATLAB command window and press enter.
   
         addpath('<path to the WhiFuN folder>\WhiFuN-main\WhiFuN-main')  
   
   or
   
     ii) Click _home_ when you are on the main screen of MATLAB (top left), and then under the environment section, click on _set path_. Next, click on _Add Folder_, select the WhiFuN-main folder with the _whifun.m_ code and click on _Select folder_. Finally, click _save_ and then _close_.

4) If SPM12 toolbox is not downloaded, Please download the SPM12 toolbox from https://www.fil.ion.ucl.ac.uk/spm/software/download/ , and addpath of the spm toolbox in MATLAB
   
     i) by using the addpath function: Type in the MATLAB command window and press enter.

          addpath('<path to the SPM folder>\spm12\spm12') 
   
   or
   
     ii) Click _home_ when you are on the main screen of MATLAB (top left), and then under the environment section, click on _set path_. Next, click on _Add Folder_, select the SPM folder with the _spm.m_ code, and click _Select folder_. Finally, click _save_ and then _close_.

6) Once all the paths are set, type _whifun_ in the MATLAB command and press enter.
7) The main GUI window of WhiFuN will open.

   i) Now, first, select the _Outputs folder_ button and select an empty folder where all the outputs and quality control plots will be saved. Alternatively, one can paste the path of the output folder in the text field beside the _Outputs folder_ button.

   ii) Click the _Participant Data Folder_ button and select the folder with all the participants folders. As an example, we show how WhiFuN can be used with some practice data that can be downloaded here https://drive.google.com/drive/folders/1l7dhG8dYYRCW5EWhkPZbBpA7TOau1W-B?usp=sharing . Download the practice data, unzip the contents, and select the folder 'practice_NYU_abide' using the _participant data folder button_ or paste the complete path into the practice_NYU_data. Please see the example screenshot below.
    
![Screenshot 2025-03-13 165540](https://github.com/user-attachments/assets/ea662e73-07e9-42da-9455-8f98b97f466d)

   iii) Now, this dataset is not in Brain Imaging Data Structure (BIDS) format (more information on BIDS here : https://bids.neuroimaging.io/ ); hence, uncheck the _BIDS_ check box on the right of the.
 'participant Data Folder' text field. That will open a new window where the folder names can be entered. Type the following in the fields  (as shown in the screenshot)

   a) Intermediate
 Folder --> session_1 
   
   (there is an intermediate folder between the participant data folder and the anatomical and functional file folder. If there is more than one folder session_1 and then 'MRI' folder, one can put the path as session_1\MRI for Windows or session_1/MRI for Linux or Mac users )

   b) Functional Folder Name --> rest_1

   (the folder that contains the functional image)

   c) Anatomical Folder Name --> anat_1

   (the folder that contains the anatomical image)
   
   d) Functional Image Name --> rest

   (the .nii or .nii.gz functional image name, sometimes the participant name is there in the functional image name, then the common part can be mentioned and the participant name that changes for every participant can be replaced by a * . For instance if the func file name is sub-1001.nii for participant 1001 and sub-1002.nii for participant 2, one can put sub-*)
   
   e) Anatomical Image Name --> mprage

   (the .nii or .nii.gz anatomical image name, sometimes the participant name is there in the anatomical image name, then the common part can be mentioned and the participant name that changes for every participant can be replaced by a * . For instance if the anat file name is sub-1001.nii for participant 1001 and sub-1002.nii for participant 2, one can put sub-*)
         
![Screenshot 2025-03-13 164232](https://github.com/user-attachments/assets/4841cb8a-878e-48d6-87cc-41d8671b602a)

   f) Once all the fields are filled, click submit. If the toolbox doesn't find a folder or file for the first participant, it will notify the folder or file not found, and changes can be made accordingly.


   iv) Next, check the 'All folders are participants' checkbox; this means we want to process every participant. Alternatively, one can just select a subset of participants if all participants should not be processed. This will display the number of participants that will be processed by WhiFuN. (see screenshot below)
 
![Screenshot 2025-03-13 164504](https://github.com/user-attachments/assets/9b2f6ad0-be93-4130-a110-3399da96f157)

   v) Next, click on _Run Data check_ and make sure that the functional and Anatomical images are present for every participant and that all the MRI parameters of all the images are correct.


6) After the Data check, a Data check report will be shown. Make sure it says, 'Data check completed successfully'.
7) Have a look at the preprocessing step parameters. If something needs to be changed, it can be changed (for more details, refer to the paper)
9) Click _Run Preprocessing_.
10) Preprocessing will take some time, depending on the PC used to preprocess. After Preprocessing for one participant is done, WhiFuN will also display the estimated time to complete the preprocessing.
11) Once preprocessing is complete, please go to the output folder (using the file browser) and check the quality control plots saved for every participant (refer to the paper/Manual for more details).
12) Based on the quality control, participants with bad data should be discarded by checking the manually exclude participants checkbox in the _Construct FN and FC_ section. Once the participants are excluded, the White Matter Functional Networks (WM-FN) can be created. (Refer to the paper for more details on the parameters).
13) Click _Create WM-FN_, and WhiFuN will start creating the FN with the different values of K specified. After the cross-validation for every value of K specified is done, WhiFuN will plot the average dice coefficient and the distortion for every value of K. (refer to the paper to find the optimal K value).
14) Choose the desired value of K and the WM-FN will be saved as a .nii file in <outputs_folder>/Analysis/WM_FN .
15) Similarly, GM-FN can be created.
16) Once the FNs are created _Display_FN_ can be used to see the FNs using SPM or BrainNet viewer (already included in the toolbox).
17) _Display_FC_ can be used to see the Functional connectivity Matrix. If behavioural scores or age, sex csv file is also present one can use the statistics module to fit a GLM and find the associations of behaviour data with the FC. (More details in the paper).

Refer to the WhiFuN Manual for understanding and using all features of WhiFuN.
