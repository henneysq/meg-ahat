%% SETUP
clear;close all

% Flag to indicate whether we update source and leadfield models
update_forward_models = false;

% Add util and template dirs to path
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/templates')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');

% Start logging
diaryfile = fullfile(data_dir, 'beamformer_group_stats.log');
if (exist(diaryfile, 'file'))
  delete(diaryfile);
end
diary (diaryfile)
    
% Set up Fieldtrip
configure_ft

% Load data details
data_details_cfg = get_data_details();

% Define subjects, tasks, and conditions
subjects = data_details_cfg.new_trigger_subs; % Subjects correctly stimulated

tasks = ["va" "wm"];
conditions = ["con" "strobe"];

%%

allsources_int_volnorm_filename = fullfile(derivatives_group_dir, 'allsources-lcmv_contrast_proc-interp-volnorm.mat');
load (allsources_int_volnorm_filename)

%%
% run statistics over subjects %
stats = [];
cfg=[];
cfg.dim         = allsources_int_volnorm.va.con{1}.dim;
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.parameter   = 'pow';
cfg.correctm    = 'cluster';
cfg.numrandomization = 1500;
cfg.alpha       = 0.05; % note that this only implies single-sided testing
cfg.tail        = 0;

nsubj=numel(subjects);
cfg.design(1,:) = [1:nsubj 1:nsubj];
cfg.design(2,:) = [ones(1,nsubj)*1 ones(1,nsubj)*2];
cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)

for task = tasks
    for n = numel(allsources_int_volnorm.(tasks(1)).(conditions(1)))
        allsources_int_volnorm.(task).(conditions(1)){n} = ...
            ft_struct2single(allsources_int_volnorm.(task).(conditions(1)){n});
        allsources_int_volnorm.(task).(conditions(2)){n} = ...
            ft_struct2single(allsources_int_volnorm.(task).(conditions(2)){n});
    end
    stats.(task) = ft_sourcestatistics(cfg, allsources_int_volnorm.(task).(conditions(1)){:}, allsources_int_volnorm.(task).(conditions(2)){:});
    
end

%%
stats_filename = fullfile(derivatives_group_dir, 'stats.mat');
save (stats_filename, 'stats', '-v7.3')

%%

stats_filename = fullfile(derivatives_group_dir, 'stats.mat');
load (stats_filename)
allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
load (allsources_ga_filename)
anatomy = allsources_int_volnorm_ga.va.con.anatomy;

%%


cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'stat';
% cfg.maskparameter = 'mask';

stat = stats.va;
stat.anatomy = anatomy;
figure
ft_sourceplot(cfg, stat);
title('Visual attention lateral contrast')
saveas(gcf,fullfile(derivatives_dir, 'img', 'sub-all_task-va_source_contrast_stat.png'))

stat = stats.wm;
stat.anatomy = anatomy;
figure
ft_sourceplot(cfg, stat);
title('Working memory arithmetic difficulty contrast')
saveas(gcf,fullfile(derivatives_dir, 'img', 'sub-all_task-wm_source_contrast_stat.png'))
