%% Normalization check
clear
clc
close all
%% Load files

% MSC
% load('D:\iit_mandi\Research\Anil_Sir\classify fmri\codes\midnight\midnight_0.01_0.1.mat')
% load('D:\iit_mandi\Research\Anil_Sir\classify fmri\codes\midnight\new\midnight_0.01_0.1.mat')
% reg_ts1 = reshape(reg_ts(8:end,:,:,:),[810,164,10*10]);
% 
% % HNU
% load('D:\iit_mandi\Research\Anil_Sir\classify fmri\codes\midnight\hnu_0.01_0.1.mat')
% reg_ts = reshape(reg_ts(11:end,:,:,:),[290,164,10*30]);

%% Schaefer 200

% MSC
% load('D:\iit_mandi\Research\Anil_Sir\classify fmri\movie variables\midnight_0.01_0.1_schaefer_200_7net.mat')
% reg_ts1 = reshape(reg_ts(8:end,:,:,:),[810,200,10*10]);
% 
% % HNU 
% load('D:\iit_mandi\Research\Anil_Sir\classify fmri\movie variables\hnu_0.01_0.1_schafer_200.mat')
% reg_ts = reshape(reg_ts(11:end,:,:,:),[290,200,10*30]);

%% schaefer 300

% load('D:\iit_mandi\Research\Anil_Sir\classify fmri\movie variables\midnight_0.01_0.1_schafer_yeo_300_7net.mat')
% reg_ts1 = reshape(reg_ts(8:end,:,:,:),[810,300,10*10]);
% 
% load('D:\iit_mandi\Research\Anil_Sir\classify fmri\movie variables\hnu_0.01_0.1_schafer_300_7net.mat')
% reg_ts = reshape(reg_ts(46:end,:,:,:),[255,300,10*30]);
% load('/home/pratik/Data/Research_desktop/Individuality/full_final_codes/schaefer_300_idx_yeo.mat')
% 

%% Schaefer 400

load('/home/pratik/Data/Research_desktop/mat files/midnight_0.01_0.1_schafer_yeo_400_7net.mat')
reg_ts1 = reshape(reg_ts(8:end,:,:,:),[810,400,10*10]);

% HNU 
load('/home/pratik/Data/Research_desktop/mat files/hnu_0.01_0.1_schafer_400_7net.mat')
reg_ts = reshape(reg_ts(46:end,:,:,:),[255,400,10*30]);

    %%
    net  = {'dor','fropar','vent','lim','motor','vis','def'};
    for net_i = 7
    switch char(net(net_i))
        
% sp = 51:84;%[1:18,51:84];
% sp = [74:100 182:200];% def shaf 200
        case 'vis'
sp = [1:31,200:230];% vis shaf 400
        case 'dor'
sp = [69:91,271:293]; % dosal attention schafer 400
        case 'fropar'
sp = [127:148,332:361]; % frontopar schaefer 400
        case 'vent'
sp = [92:113,294:318]; % ventral attention schaefer 400
        case 'lim'
sp = [114:126,319:331]; % limbic schaefer 400 
        case 'motor'
sp = [32:68,231:270]; % somatomotor schaefer 400
%         case 'def'
% sp = [149:200,362:400]; % def schaefer 400;
        case 'def'
% load('/home/pratik/Data/Research_desktop/mat files/midnight_0.01_0.1_schafer_yeo_300_7net.mat')
% reg_ts1 = reshape(reg_ts(8:end,:,:,:),[810,300,10*10]);
% 
% load('/home/pratik/Data/Research_desktop/mat files/hnu_0.01_0.1_schafer_300_7net.mat')
% reg_ts = reshape(reg_ts(46:end,:,:,:),[255,300,10*30]);
% % sp = [25:53,174:201]; % senmotor schaefer 300
% sp = [113:150,271:300]; % default schaefer 300
% sp = 1:164;
        sp = [149:200,362:400]; % def schaefer 400;
    end
%% Train test split
% Puting 1st 5 scans in train and the next 5 in test
train = [];
test = [];
for i = 1:10:400
    train = [train i:i+4];
    test = [test i+5:i+9];
end
scan_length_min = [1,3,5,7,8.5];                                           % Scan length in min
sc_msc = round(scan_length_min * 60 / 2.2);                                 % MSC data has TR of 2.2s
sc_hnu = round(scan_length_min * 60 / 2);                                   % HNU data has TR of 2s

for sc = 4:5
% sc = 5;                                                                     % choose the  Scan length
nor = {'nothing','fis','deg','nor','fis_nor'};
dl = {'pca','ksvd','cobe','rpca','shssdl'};%

for dl_i = 4
for nor_i = 1:3

% nor  = 'fis_nor';

switch char(nor(nor_i))
    case 'nothing'
        %% Functional connectivity 
maph = (functional_connectivity(reg_ts1(1:(sc_msc(sc)),sp,:),0));
maph1 = (functional_connectivity(reg_ts(1:(sc_hnu(sc)),sp,:),0));
maph = cat(2,maph,maph1);
maph_n = (maph(:,train));
maph1_n = (maph(:,test));

    case 'fis' 
maph = (functional_connectivity(reg_ts1(1:(sc_msc(sc)),sp,:),1));
maph1 = (functional_connectivity(reg_ts(1:(sc_hnu(sc)),sp,:),1));
maph = cat(2,maph,maph1);
maph_n = (maph(:,train));
maph1_n = (maph(:,test));

    case 'nor '
maph = (functional_connectivity(reg_ts1(1:(sc_msc(sc)),sp,:),0));
maph1 = (functional_connectivity(reg_ts(1:(sc_hnu(sc)),sp,:),0));
maph = cat(2,maph,maph1);
maph_n = zscore(maph(:,train));
maph1_n = zscore(maph(:,test));

    case 'fis_nor'
maph = (functional_connectivity(reg_ts1(1:(sc_msc(sc)),sp,:),1));
maph1 = (functional_connectivity(reg_ts(1:(sc_hnu(sc)),sp,:),1));
maph = cat(2,maph,maph1);
maph_n = zscore(maph(:,train));
maph1_n = zscore(maph(:,test));        
        
    case 'deg'
maph = (functional_connectivity(reg_ts1(1:(sc_msc(sc)),sp,:),0));
maph1 = (functional_connectivity(reg_ts(1:(sc_hnu(sc)),sp,:),0));
maph = cat(2,maph,maph1);

for i = 1:size(maph,2)
    
    temp = veccorr(maph(:,i));
    deg = sum(abs(temp));
    
    temp_deg = (diag(deg))^(-1/2)*abs(temp)*(diag(deg))^(-1/2);
    
    maph_deg(:,i) = corrvec(temp_deg);
    
    
end
maph_n = (maph_deg(:,train));
maph1_n = (maph_deg(:,test));

end
%%
% addpath('D:\iit_mandi\Research\Anil_Sir\classify fmri\Individuality\full_final_codes');

addpath '/home/pratik/Data/Research_desktop/Individuality'
addpath('/home/pratik/Data/Research_desktop/Individuality/full_final_codes');
addpath('/home/pratik/Data/Research_desktop/Individuality/rpca/solvers');
addpath('/home/pratik/Data/Research_desktop/Individuality/COBE/OCD_Cerebellar-Visual-Community-main/demo_CIFE/demo_CIFA')
addpath('/home/pratik/Data/Research_desktop/Individuality/ompbox');
addpath '/home/pratik/Data/Research_desktop/Individuality/SPAMS/spams-matlab-v2.6/build'

ses = 5; % taking 5 sessions at a time
hei = 1000; % height of the histogram

switch char(dl(dl_i))
    case 'pca'
%% PCA
pca_comp = [50,40,37,48,47,65,48;
            47,42,38,45,48,48,40;
            190,40,41,73,64,68,47];

% dim = 37; 
[Overlap_pca,Idiff_pca,Sub_spec_pca,V_pca] = individuality_pca(maph_n,maph1_n,ses,pca_comp(nor_i,net_i),1000,0,1);

Overlap_nor(nor_i,net_i,sc) = Overlap_pca.train;
Overlap_pca_nor(nor_i,net_i,sc) = Overlap_pca.dl_train;
Overlap_nor_test(nor_i,net_i,sc) = Overlap_pca.test;
Overlap_pca_nor_test(nor_i,net_i,sc) = Overlap_pca.dl_test;

Idiff_nor(nor_i,net_i,sc) = Idiff_pca.train;
Idiff_pca_nor(nor_i,net_i,sc) = Idiff_pca.dl;
Idiff_nor_test(nor_i,net_i,sc) = Idiff_pca.test;
Idiff_pca_nor_test(nor_i,net_i,sc) = Idiff_pca.dl_test;

save([char(dl(dl_i)),char(net(net_i))],'Overlap_nor','Overlap_pca_nor','Overlap_nor_test','Overlap_pca_nor_test','Idiff_nor','Idiff_pca_nor',...
    'Idiff_nor_test','Idiff_pca_nor_test')
close all
%% ksvd
    case 'ksvd'

% k0 = 4;
% s0 = 10;
so_ksvd = [7,14,5,11,11,10,15;
           8,5,9,7,14,11,11;
           7,7,6,8,4,5,14];
k_ksvd = [2,4,2,5,5,3,3;
          2,2,6,4,4,4,5;
          2,2,3,3,4,3,4];

iter = 20;
[Overlap_ksvd,Idiff_ksvd,Sub_spec_ksvd,D] = individuality_ksvd(maph_n,maph1_n,ses,k_ksvd(nor_i,net_i),so_ksvd(nor_i,net_i),iter);
overlap_ksvd(nor_i,net_i,sc) = Overlap_ksvd.dl_train;
idiff_ksvd(nor_i,net_i,sc) = Idiff_ksvd.dl;

overlap_ksvd_test(nor_i,net_i,sc) = Overlap_ksvd.dl_test;
idiff_ksvd_test(nor_i,net_i,sc) = Idiff_ksvd.dl_test;

close all


save([char(dl(dl_i)),char(net(net_i))],'overlap_ksvd','overlap_ksvd_test','idiff_ksvd',...
    'idiff_ksvd_test')

    case 'rpca'
%% RPCA
p=1;
D_a = 25:15:100;
l = 0.1:0.05:0.5;
    
l_rpca = [9,9,7,9,8,9,9;
          8,9,9,9,9,9,9
          9,9,9,6,6,4,9];
      
k_rpca = [2,2,2,2,2,2,2;
          2,2,2,2,2,2,2
          2,2,2,2,2,2,2];
      
[Overlap_rpca,Idiff_rpca,Sub_spec_rpca,L_com] = individuality_rpca(maph_n,maph1_n,ses,D_a(k_rpca(nor_i,net_i)),l(l_rpca(nor_i,net_i)));
overlap_rpca(nor_i,net_i,sc) = Overlap_rpca.dl_train;
idiff_rpca(nor_i,net_i,sc) = Idiff_rpca.dl;

overlap_rpca_test(nor_i,net_i,sc) = Overlap_rpca.dl_test;
idiff_rpca_test(nor_i,net_i,sc) = Idiff_rpca.dl_test;
close all
    save([char(dl(dl_i)),char(net(net_i))],'overlap_rpca','overlap_rpca_test','idiff_rpca',...
    'idiff_rpca_test')


    case 'cobe'
        %% COBE
for Component_remv = 5
% Component_remv = 3;
[Overlap_cobe,Idiff_cobe,Sub_spec_cobe,COBE_CM_Component] = individuality_cobe(maph_n,maph1_n,ses,Component_remv);
Overlap_cobe_nor(nor_i,net_i,sc) = Overlap_cobe.dl_train;
idiff_cobe_nor(nor_i,net_i,sc) = Idiff_cobe.dl;

Overlap_cobe_nor_test(nor_i,net_i,sc) = Overlap_cobe.dl_test;
idiff_cobe_nor_test(nor_i,net_i,sc) = Idiff_cobe.dl_test;
close all
save([char(dl(dl_i)),char(net(net_i))],'Overlap_cobe_nor','Overlap_cobe_nor_test','idiff_cobe_nor',...
    'idiff_cobe_nor_test')
end

    case 'shssdl'
        %%
p=2;
so_shssdl = [3,5,4,1,3,5;
             6,3,4,2,5,4;
             1,1,3,2,1,4];

k_shssdl = [3,5,4,1,4,5;
            5,1,2,4,4,1;
            2,3,2,3,4,2];
for D0 = 7:10%9:10
    q=1;
    for s0 = 4:D0%2:5
        tic
% D0 = 4;
Di = 3;
% s0 = 3;
si = 2;
eta = 1000;
[Overlap_shssdl,Idiff_shssdl,Sub_spec_shssdl1,D0h] = individuality_shssdl(maph_n,maph1_n,ses,D0,Di,s0,si,eta,hei);

overlap_shssdl(p,q,nor_i) = Overlap_shssdl.dl_train;
idiff_shssdl(p,q,nor_i) = Idiff_shssdl.dl;

overlap_shssdl_test(p,q,nor_i) = Overlap_shssdl.dl_test;
idiff_shssdl_test(p,q,nor_i) = Idiff_shssdl.dl_test;
save([char(dl(dl_i)),char(net(net_i))],'overlap_shssdl','overlap_shssdl_test','idiff_shssdl',...
    'idiff_shssdl_test')
q=q+1;

close all
clc
toc
disp([p,q])
    end
    p=p+1;
end
%%
end
end
end

end
clear overlap_ksvd overlap_ksvd_test idiff_ksvd Idiff_nor idiff_ksvd_test
clear Overlap_cobe_nor Overlap_cobe_nor_test idiff_cobe_nor Idiff_nor idiff_cobe_nor_test
clear Overlap_pca_nor Overlap_nor_test Overlap_pca_nor_test Idiff_nor Idiff_pca_nor...
    Idiff_pca_nor_test maph_deg Overlap_nor
clear overlap_rpca overlap_rpca_test idiff_rpca idiff_rpca_test
clear overlap_shssdl overlap_shssdl_test idiff_shssdl idiff_shssdl_test
    end
