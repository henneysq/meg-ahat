%% Add util dir to path
clear;
addpath('/project/3031004.01/meg-ahat/util')

%% Set pilot data directory
data_dir = '/project/3031004.01/pilot-data';
diaryfile = strcat(data_dir, '/preprocessing.log');

if (exist(diaryfile, 'file'))
  delete(diaryfile);
end

diary (diaryfile)

raw2_dir = '/project/3031004.01/pilot-data/raw2';
derivatives_dir = '/project/3031004.01/pilot-data/derivatives';

%% Setup Fieldtrip
configure_ft

% Sebject (defined as cell array for future compatibility)
subj = {
  '099'
  };
ses = 2;

%% Load data
dataset_dir = sprintf('%s/sub-%s/ses-00%d/meg/sub-%s_ses-00%d_task-flicker_meg.ds', raw2_dir, subj{1}, ses, subj{1}, ses);
cfg = [];
cfg.dataset = dataset_dir;


%%
cfg.trialfun = 'definetrial_va';
cfg.trialdef.pre  = 0;
cfg.trialdef.post = 0;
cfg.continuous = 'yes';
cfg = ft_definetrial(cfg);

cfg.demean = 'yes';
%cfg.channel = 'meggrad';
data_meg = ft_preprocessing(cfg);

%%
outdir = sprintf('%s/sub-%s/ses-00%d/meg/', derivatives_dir, subj{1}, ses);

if not(exist(outdir, 'dir'))
  mkdir(outdir);
end

fname = sprintf('sub-%s_ses-00%d_task-flicker_proc-preproc_meg.mat', subj{1}, ses);
save (sprintf('%s%s', outdir, fname), 'data_meg', '-v7.3');

diary off

%%
%cfg          = [];
%cfg.method   = 'trial';
% cfg.ylim     = [-1e-12 1e-12];
%dummy        = ft_rejectvisual(cfg, data_meg);

%%
%cfg = [];
%cfg.continuous = 'yes';
%artf = ft_databrowser(cfg, data_meg);

%%
%event = ft_read_event(dataset_dir);

%%
%mri = ft_read_mri('/home/megmethods/markhen/meg-ahat/pilot-data/source/sub-099/sub-20231212T163000/ses-mri01/006-t1_mprage_sag_ipat2_1p0iso_20ch-head-neck/00001_1.3.12.2.1107.5.2.19.45416.2023121216372665153673835.IMA');
%%
%cfg.method = 'interactive';
%cfg.coordsys = 'ctf';
%mri_realigned = ft_volumerealign(cfg,mri);
%crosshair: voxel  10885729, index = [ 97 121 222], head = [-7.3 46.5 85.0] mm
%       nas: voxel   7315297, index = [ 97 213 149], head = [-4.0 102.4 -18.2] mm
%       lpa: voxel   4741653, index = [ 21 121  97], head = [-75.5 -5.3 -33.6] mm
%       rpa: voxel   4740845, index = [173 116  97], head = [76.3 -4.4 -23.8] mm
%    zpoint: voxel  10885729, index = [ 97 121 222], head = [-7.3 46.5 85.0] mm
%%
%cfg = [];
%ft_sourceplot(cfg, mri)

%%