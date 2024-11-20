%% SETUP
clear;close all

% Add util and template dirs to path
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/templates')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');
derivatives_img_dir = fullfile(derivatives_dir, 'img');
    
% Start logging
diaryfile = fullfile(data_dir, 'logs', 'beamformer_group_stats.log');
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

% Flag to indicate whether we update source and leadfield models
% update_forward_models = false;
numrandomization = 1000;
correctm = 'cluster';
%%


allsources_beta_int_volnorm_filename = fullfile(derivatives_group_dir, 'allsources-lcmv_beta-contrast_proc-interp-volnorm.mat');
load (allsources_beta_int_volnorm_filename)

%%
% run statistics over subjects %
stats = [];
cfg=[];
cfg.dim         = allsources_beta_int_volnorm.va.con{1}.dim;
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.parameter   = 'stat';
cfg.numrandomization = numrandomization;
% cfg.correctm    = 'cluster';
cfg.correctm         = correctm;
cfg.tfce_H           = 2;       % default setting
cfg.tfce_E           = 0.5;     % default setting
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.alpha       = 0.05; % note that this only implies single-sided testing
cfg.tail        = 0;

nsubj=numel(subjects);
cfg.design(1,:) = [1:nsubj 1:nsubj];
cfg.design(2,:) = [ones(1,nsubj)*1 ones(1,nsubj)*2];
cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)
%%
for task = tasks
    for n = numel(allsources_beta_int_volnorm.(tasks(1)).(conditions(1)))
        allsources_beta_int_volnorm.(task).(conditions(1)){n} = ...
            ft_struct2single(allsources_beta_int_volnorm.(task).(conditions(1)){n});
        allsources_beta_int_volnorm.(task).(conditions(2)){n} = ...
            ft_struct2single(allsources_beta_int_volnorm.(task).(conditions(2)){n});
    end
    stats.(task) = ft_sourcestatistics(cfg, allsources_beta_int_volnorm.(task).(conditions(1)){:}, allsources_beta_int_volnorm.(task).(conditions(2)){:});
    stats.(task).nicemask = make_mask(stats.(task).stat, [0.65 0.8]);
end

%%
stats_filename = fullfile(derivatives_group_dir, sprintf('beta-stats_numrandomization-%d_correctm-%s.mat', numrandomization, correctm));
save (stats_filename, 'stats', '-v7.3')

%%

stats_filename = fullfile(derivatives_group_dir, sprintf('beta-stats_numrandomization-%d_correctm-%s.mat', numrandomization, correctm));
load (stats_filename)
allsources_beta_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
load (allsources_beta_ga_filename)
anatomy = allsources_beta_int_volnorm_ga.va.con.anatomy;

%%
% stats.va.nicemask = make_mask(stats.va.stat, [0.3 0.8]);
% stats.wm.nicemask = make_mask(stats.wm.stat, [0.3 0.8]);
close all

cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'stat';
cfg.opacitylim    = [0 1];

stat = stats.va;
stat.anatomy = anatomy;
figure
ft_sourceplot(cfg, stat);
title('Visual attention lateral contrast')
ax = gca;
exportgraphics(ax,fullfile(derivatives_img_dir, ...
    sprintf('sub-all_task-va_source_beta-contrast_stat_numrandomization-%d_correctm-%s_slice.png', ...
    numrandomization, correctm)),'Resolution',300) 
% saveas(gcf,)

stat = stats.wm;
stat.anatomy = anatomy;
figure
ft_sourceplot(cfg, stat);
title('Working memory arithmetic difficulty contrast')
saveas(gcf,fullfile(derivatives_img_dir, sprintf('sub-all_task-wm_source_beta-contrast_stat_numrandomization-%d_correctm-%s_slice.png', numrandomization, correctm)))


cfg.maskparameter = 'mask';
% cfg.method        = 'ortho';
stat = stats.va;
stat.anatomy = anatomy;
figure
ft_sourceplot(cfg, stat);
title('Visual attention lateral contrast')
saveas(gcf,fullfile(derivatives_img_dir, sprintf('sub-all_task-va_source_beta-contrast_stat_numrandomization-%d_correctm-%s_mask.png', numrandomization, correctm)))

stat = stats.wm;
stat.anatomy = anatomy;
figure
ft_sourceplot(cfg, stat);
title('Working memory arithmetic difficulty contrast')
saveas(gcf,fullfile(derivatives_img_dir, sprintf('sub-all_task-wm_source_beta-contrast_stat_numrandomization-%d_correctm-%s_mask.png', numrandomization, correctm)))

diary off
