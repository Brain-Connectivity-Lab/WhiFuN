function fd = whifun_calculate_fd(func_path,motion_txt_path)

now_func_path = dir(func_path) ;
cd(now_func_path(1).folder)
now_txt_path = dir(motion_txt_path) ;
rp_rest = load(fullfile(now_txt_path.folder,now_txt_path.name));              % input the text file generated at the Realignment stage

rp_diff_trans = diff(rp_rest(:,1:3));                      % The first 3 parameters tell the displacement in x,y, and z direction in mm. Here the vector difference operator is used to get the derivative of vector. (framewise difference)
%                 rp_diff_rotat = diff(rp_rest(:,4:6)*180/pi);             % % The last  3 parameters tell the rotation values pitch, yaw and roll in radians (here we convert them to degrees)
rp_diff_rotat = diff(rp_rest(:,4:6)*50);                   % Converting angles to mm by asuming a 50mm radius circle


fd = sum(rp_diff_trans,2) + sum(rp_diff_rotat,2)  ;