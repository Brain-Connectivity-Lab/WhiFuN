%% White matter Functional Networks Toolbox
% Written by Pratik Jain 
% email:pj44@njit.edu
%% This code and Readme file was written by Pratik Jain. 
%% This code was written with the help of different preprocessing scripts given by 
%% Dr. Xin Di, Dr. Rakibul Hafeez, Donna Chen and Wohnbum Sohn. 
%{
Run this code to start using the White Matter Functional Network toolbox. once you run
this code a GUI window will pop up and you can look at the following steps
to understand how to use the toolbox.

White matter Functional Connectivity script

Make sure you have SPM 12 downloaded.

1) Locate the subject folder where all the subject files are placed (eg. 'D:\Data\ABIDE') (either push the button or put the path directly)
3) Click on the folder names button. That will open a new window. There assuming based on the file sturcture you can fill the spaces. for insatnace if follwoing is the file stucture 

folder stucture example

ABIDE                                                         (main directory that contains all the data)
	Subject1                                                (first subject folder)
		session1                                          (may or maynot contain sessions)
			rest_1                                      (folder containing the rest file)
				rest.nii                              (rest file name)
			anat_1                                      (folder containing the anatomical T1 weighted file)
				mprage.nii                            (anatomical file name)
	Subject2                                                (Second subject folder)
		session1                                          (may or maynot contain sessions)
			rest_1                                      (folder containing the rest file)
				rest.nii                              (rest file name)
			anat_1                                      (folder containing the anatomical T1 weighted file)
				mprage.nii                            (anatomical file name)

then  Common subject Name = Subject*
	Intermediate folders = session1
	Functional Folder name = rest_1
	Anatomical folder name = anat_1
	Functional Image Name = rest.nii
	Anatomical Image name = mprage.nii

4) Put the path of the folder where the results i.e the WM networks, Quality control scripts will be stored. (eg. 'D:\DATA\output') (Similar to above either push the button or put the path directly)

	there maybe instances where there are a couple of folders between the subject file and the functional files for instance

ABIDE                                                         (main directory that contains all the data)
	Subject1                                                (first subject folder)
		MRI							        (A sub-folder)
			NIFTI                                       (Another sub-folder)
				session1                              (may or maynot contain sessions)
					rest_1                          (folder containing the rest file)
						rest.nii                  (rest file name)
					anat_1                          (folder containing the anatomical T1 weighted file)
						mprage.nii                (anatomical file name)
	Subject2                                                (Second subject folder)
		MRI							        (A sub-folder)
			NIFTI                                       (Another sub-folder)
				session2                              (may or maynot contain sessions)
					rest_1                          (folder containing the rest file)
						rest.nii                  (rest file name)
					anat_1                          (folder containing the anatomical T1 weighted file)
						mprage.nii                (anatomical file name)al file name)
	in the above mentioned case one can mention the following

	Common subject Name = Subject*
	Intermediate folders = MRI/NIFTI/session*
	Functional Folder name = rest_1
	Anatomical folder name = anat_1
	Functional Image Name = rest.nii
	Anatomical Image name = mprage.nii

5) Choose the TR, if Use Nifti Header check box is checked then the code will determine the header from the nifti file. However some times the data does not have the TR value in the nifti header in those cases the TR will be taked from the Text box
6) choose the number of initial volumes to be discarded
7)Choose the Motion threshold, Segementation CSF threshold
8) For regression there are 3 options, Mean CSF regression, n PCA components of CSF rege=ression ( where n is given in the no. of PCA components field) (check box for 24 motion parameters, if uncked, motion parameters wont be regressed)
9) choose the filter low and high cutoff frequency (Butter worth bandpass filter of the 5th order)
10) In smoothing again there are 3 options, Smooth White matter and gray matter sperately, all together and no smoothing. If smoothing option is choosen the FWHM text field specifies the width of the gaussian kernel in mm
11) Choose Normalization voxel dimension,(output MNI space voxel dimension)
12) Choose the Group Wm and GM mask threshold. 
13) Choose the K-means value search range and number of Cross validation (CV) folds.
14) Corpus callousum networks check box, if cheked the corpus callosum networks will be computed (For this all the subjects in the dataset should have the same number of timepoints).
15) There is a overwrite existeing files button check box, if checcked then if the code finds any previously processed files it will delete them and crate new files. If unchecked then the previous files will be used and the steps corresponding to those will be skipped.
16) Finally you can save these parameters as a mat file to folder, so next time if incase you want to run the same analysis you can just load the parameters file and you woudnt have to specify all the parameters again.
17) Finally hit the run preprocessing button.

    It will display the session of prepreocessing it is currently in and the subject that is currently being processed in matlab command window.

    Briefly it does the following steps
	1) Unziping the files if they are not already unzipped
	2) Initial data check (See the quality control folder after the preprocessing is done)
	3) Realignment of the functional scans (motion is detected here)
	4) Framewise displacement to detect the head motion. Subjects having max translation and rotaional motion of 2mm and a mean trtanlastiona and mean rotation of 0.3mm will be excluded (can be changed at line number 218)
	5) Segmentation of anatomical scans into Gray matter (GM), White matter (WM) and Cerebrospinal fluid (CSF)
	6) Skull striping
	7) Coregisteration of the functional and anatomical scans 
	8) Regression of the motion (detected during framewise dispacment), mean WM and CSF timeseries.
	9) Filtering 
	10) Smoothing
	11) Normalization of the functional images to MNI space
	12) Normalization of the Anatomical images to MNI space
	10) Creation of Group WM and GM masks 
	11) Creation of WM functional networks using K-Means algorithm (the code checks the dice correlation between the networks for values of k from K-range.)
		and plots the dice correlation value for differen values of K. One may then choose the value of K by looking at the plot.
	12) Getting the mean connectivity matrix corresponding to every WM network
	13) If the corpus callosum check box is checked, only then steps from 13 to 17 will be performed
	13) Getting the voxel time-series corresponding to every voxel in the corpus callosum (CC) using the CC mask.
	14) Partial correrlation between CC voxels and WM networks
	15) Projection of the correlation between the WM and current CC voxel values, to see which part of CC is correlated to which WM network.
	16) TTest on the above created projection maps
	17) Winner take all stratergy to define the CC to one of the WM networks.

11) the results will be stored in the output folder specified as follows

Output folder (Specified by User)
	Quality Control Quality control files. (See the below for more details)
	Results
		Group Masks 
			GMmask_allsubjs_buckner.nii                  (Group Gray matter mask)
			WMmask_allsubjs_buckner.nii                  (Group White matter mask)
		KMeans 
			WM_cluseterin_K< choosen value of K >.nii    (Contain the WM networks for the choosen value of K, eg. WM_cluseterin_K10.nii for K=10)
		Projection 
			Subject1
				Subject1_01.nii                        (Projection of correlation values on CC voxels for subject1 network 1)
				Subject1_02.nii                        (Projection of correlation values on CC voxels for subject1 network 2)
			Subject1
				Subject2_01.nii                        (Projection of correlation values on CC voxels for subject2 network 1)
				Subject2_02.nii                        (Projection of correlation values on CC voxels for subject2 network 2)
		
		ttest
			ttests_maps_1.nii                            (ttest results stored in nii file with the t values for network 1)
			ttests_maps_2.nii                            (ttest results stored in nii file with the t values for network 2)
	b1.nii                                                   (Winner take all result of network 1)
	b2.nii                                                   (Winner take all result of network 2)
	cc_signals.mat                                           (BOLD time series corresponding to all CC voxels for all subjects)
	network signals.mat                                      (Average BOLD time series corresponding to all networks for all subjects)     
	parcorr_result.mat                                       (Result of partial correlation)                   
	

Quality Check Files

Q1a_scanning_parameters --> This file tells the number of volumes in every subject in the first row, the TR for every subject, The x,y,z direction 
voxels sizes of all the subjects from fmri and anatomical files. Based on the values of voxel size of fmri images the motion parameters can be set. 
For eg. if fmri voxel sizes of all subjects is 2mm, then the max_trans and max_rotat values should be less than 2mm.

Initial check --> This folder shows how far away the anatomical and functional images are from the standard MNI space. One should observe the orientation
of every subject here, if the orientation of a subject's image is flipped or is upside down then one will have to mannualy orient those first such that
the images have the same orientation


Head motion --> Here the global mean rigid body motion pairwise variance and framewise displacement correponding to every subject will be stored.
 If excessive motion is present it will also show the max cutoff line in the framewise displacement plot. Which can tell at which timepoint on the
x-axis the motion occured. Also a file Q3_head_motion will be present that has the translational motion and rotational motion plotted on the x and 
y axis respectively. And the maximum cutoff for both will be shown. This also contains a text file that tells information about the excluded subjects.

Segmentation --> Plots the Gray matter (Red), White Matter (Green) and CSF (Blue) and the MNI template below. Make sure that the Gray Matter, White matter
 and CSF are correctly identified in all subjects.
 
Co-registeration --> Shows the anatomical and the  functional images plotted for every subject and the contour of the anatomical image plotted on the functional image to
check the registeration properly.

Masks --> Here the CSF and WM masks for all the images are plotted along with the functional file, make sure that the masks are correctly oriented to the
functional image and there might also be subjects for which the mask shows a empty matrix. You might have to change the CSF or WM threshold to get the masks
for such subjects.

Regression --> Here the mean timeseries before and after regression is plotted. One can see the effects of regression with these plots.

Smoothing --> here the Smoothed functional image is plotted.

Normalization --> here the normalized functional image in MNI space is plotted with the reference MNI space image. Make sure that both are correctly aligned


Time-series check --> (A) Global mean intensity for the raw fMRI images. (B) Six rigid-body head motion parameters in mm or degree. 
(C) The task design regressors of the Task and Control conditions. (D) Correlations among (A) through (C).
 (E) Variance between consecutive images from the raw data. (F) Framewise displacement in translation and rotation.
 (G) Derivatives of the task design regressors. (H) Correlations among (E) through (G).

Error handling --> If there is an error that is occured either due to file name or a missing file for any subject, the error information will be stored in
a txt file in the quality_control_path folder 

eg:

Code ran on 09-Aug-2023 17:43:45  
 
#####################################################################################################################
 
Subject Name: 201
 
MATLAB:narginchk:notEnoughInputs 
Error Message :Not enough input arguments.
Error using fullfile (line 43)
Error using complete_filepath (line 12)
Error using preprocess_sunlab_complete_with_QC (line 293)

As seen above it shows the time when the code was run,
The subject name where the error occured,
The error identifier in matlab along with the error message and the lines where the error ocuured.
In the above example the error occured on line 293 of the main file, inside that there is a function called complete filepath and inside that function there
is a function fullfile where the error has occured. The error is that there were not enough arguments given to the fullfile function. 

For all the subjects that get an error their information will be appened in this text file, and the code will ignore them while preprocessing and 
continue to process other subjects, After the code has done preprocessing it will show a message that there were errors with some subjets, one can check
all the errors then in this file. 


References 

Wang P, Meng C, Yuan R, Wang J, Yang H, Zhang T, Zaborszky L, Alvarez TL, Liao W, Luo C, Chen H, Biswal BB. The Organization of the Human Corpus
Callosum Estimated by Intrinsic Functional Connectivity with White-Matter Functional Networks. Cereb Cortex. 2020 May 14;30(5):3313-3324.
doi: 10.1093/cercor/bhz311. PMID: 32080708.


%}

temp_path = mfilename('fullpath');                % path of the toolbox
preproc_code_path = fileparts(temp_path);

addpath(preproc_code_path)
run(fullfile(preproc_code_path,'main.mlapp'))