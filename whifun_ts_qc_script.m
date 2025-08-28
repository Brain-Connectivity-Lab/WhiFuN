GM_mask_path = 'D:\practice_erode\0050952\session_1\anat_1\c1mprage.nii';
WM_mask_path = 'D:\practice_erode\0050952\session_1\anat_1\c2mprage.nii';

% For deep wm mask creation
num_erosions = 4;
out_pre = 'deep_';

CSF_mask_path = 'D:\practice_erode\0050952\session_1\anat_1\c3mprage.nii';
func_path = 'D:\practice_erode\0050952\session_1\rest_1\REG_rc_rest.nii';
motion_txt_path = 'D:\practice_erode\0050952\session_1\rest_1\rp_c_rest.txt';
pre_ = '';

whifun_ts_qc(GM_mask_path,WM_mask_path,CSF_mask_path,func_path,motion_txt_path,pre_,num_erosions,'0050952',0)
clcc