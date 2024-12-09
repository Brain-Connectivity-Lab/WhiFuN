# WhiFuN
This GUI-based toolbox offers researchers a user-friendly suite of automated tools for investigating brain functional connectivity in WM and GM. One of the key advantages of WhiFuN is that it fully automates the preprocessing steps to derive data that can be used to analyze the WM and GM BOLD signals.

## New to WhiFuN? 
### Follow these steps to get started

1) Download WhiFuN in a local folder and unzip all the contents (Download WhiFuN by clicking on the green 'Code' button and then selecting Download zip)
2) Open MATLAB and addpath of the WhifuN toobox to MATLAB
   
     i) by using the addpath function:
          just type the following in MATLAB command window and press enter.
   
         addpath('<path to the WhiFuN folder>\WhiFuN-main\WhiFuN-main')  
   
   or
   
     ii) Click home when you are on the main screen of MATLAB (top left) and then under the environment section click on 'set path'. Next click on 'Add Folder' and select the WhiFuN-main folder that has the whifun.m code and click on 'Select folder'. Finally click 'save' and then 'close'.

4) If SPM12 toolbox is not downloaded, Please download the SPM12 toolbox from https://www.fil.ion.ucl.ac.uk/spm/software/download/ , and addpath of the spm toolbox in MATLAB
   
     i) by using the addpath function
       just type ' addpath('<path to the SPM folder>\spm12\spm12') ' in MATLAB command window and press enter;
   
   or
   
     ii) Click home when you are on the main screen of MATLAB (top left) and then under the environment section click on 'set path'. Next click on 'Add Folder' and select the SPM folder that has the spm.m code and click on 'Select folder'. Finally click 'save' and then 'close'.

5) Once all the paths are set, type 'whifun' in MATLAB command and press enter.
6) The main GUI window of WhiFuN will open.

   i) Now first Select the Output folder button and select an empty folder where all the outputs and quality control plots will be saved. Alternatively one can also paste the path of the output folder on the text field besides the Output folder button.

   ii) Click the 'Select Data Folder' button and select the folder that has all the Subjects folders. As an example, we show how WhiFuN can be used with some practice data that can be downloaded here https://drive.google.com/drive/folders/1l7dhG8dYYRCW5EWhkPZbBpA7TOau1W-B?usp=sharing . Download the practice data, unzip the contents and select the folder 'practice_NYU_abide' using the select 'Subject folder button' or paste the complete path to the practice_NYU_data. Please see the example screenshot below.
    
![Screenshot 2024-12-08 194913](https://github.com/user-attachments/assets/242c7345-dbd2-45ab-9fd7-e5ecc720d757)

   iii) Now this dataset is not in Brain Imaging Data Structure (BIDS) format (more information on BIDS here :  https://bids.neuroimaging.io/ ) hence uncheck the BIDS check box on the right of the 'Subject Data Folder' text field. That will open a new window where the folder names can be entered. Type the following in the fields  (as shown in the screenshot)

      a) Intermidiate Folder --> session_1 
      
      (there is an intermediate folder between the subject folder and the anatomical and functional file folder, if there are more than one folders session_1 and then 'MRI' folder, one can put the path as session_1/MRI for windows or session_1\MRI for linux or mac users )

      b) Functional Folder Name --> rest_1

      (the folder that contains the functional image)

      c) Anatomical Folder Name --> rest_1

      (the folder that contains the anatomical image)
      
      d) Functional Image Name --> rest

      (the .nii or .nii.gz functional image name, sometimes the subject name is there in the functional image name, then the common part can be mentioned and the subject name that changes for every subject can be replaced by a * . For instance if the func file name is sub-1001.nii for subject 1001 and sub-1002.nii for subject 2, one can put sub-*)
      
      e) Anatomical Image Name --> mprage

      (the .nii or .nii.gz anatomical image name, sometimes the subject name is there in the anatomical image name, then the common part can be mentioned and the subject name that changes for every subject can be replaced by a * . For instance if the func file name is sub-1001.nii for subject 1001 and sub-1002.nii for subject 2, one can put sub-*)
         
![Screenshot 2024-12-08 201926](https://github.com/user-attachments/assets/64f6c251-aa94-462a-b15b-766ea4261269)

   iv) Next check 'All subjects' checkbox, this means we want to process every subject, alternatively one can just select a subset of subjects if all subjects should not be processed. This will say the number of subjects that will be processed by WhiFuN. (see screenshot below)

   ![Screenshot 2024-12-08 202504](https://github.com/user-attachments/assets/e4982c4d-cade-406c-bd22-c28bf8abcd6b)

   v) Next click on Run Data check and make sure that the functional and Anatomical images are present for every subject and that all the MRI parameters of all the images are correct.

6) After Data check a Data check report will be shown. Make sure it says 'Data check completed successfully'.
7) Have a look at the preprocessing step parameters, if something needs to be changed it can be changed (for more details refer paper)
9) Click Run Preprocessing.
10) Preprocessing will take some time depending on the PC used to preprocess. After Preprocessing for one subject is done, WHiFuN will also display the estimated time to complete the preprocessing.
11) Once preprocessing is  complete 
