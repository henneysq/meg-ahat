%%
clear;

% Load data details
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')
data_details_cfg = get_data_details();

% Define subjects, tasks, and conditions
subjects = data_details_cfg.new_trigger_subs; % Subjects correctly stimulated


data_dir = '/project/3031004.01/data/';
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');
%%

%%
for sub = subjects(3:end)
    task = "wm";
    stim_condition = "con";
    estimate_sources(sub, task, stim_condition)
    stim_condition = "strobe";
    estimate_sources(sub, task, stim_condition)
end
%%
task = "wm";
for sub = subjects
    % stim_condition = "con";
    % estimate_sources(sub, task, stim_condition)
    % stim_condition = "strobe";
    % estimate_sources(sub, task, stim_condition)
    
    source1_cfg = [];
    source1_cfg.sub = sub;
    source1_cfg.stim_condition = "strobe";
    source1_cfg.task = task;
    source2_cfg = source1_cfg;
    source2_cfg.task_level = "high";
    source1_cfg.task_level = "low";
    contrast_sources(source1_cfg, source2_cfg);
    
    source1_cfg = [];
    source1_cfg.sub = sub;
    source1_cfg.stim_condition = "con";
    source1_cfg.task = task;
    source2_cfg = source1_cfg;
    source2_cfg.task_level = "high";
    source1_cfg.task_level = "low";
    contrast_sources(source1_cfg, source2_cfg);
    % 
    % source1_cfg.stim_condition = "con";
    % source2_cfg.stim_condition = "con";
    % contrast_sources(source1_cfg, source2_cfg);
end
%%
permute_cfg.subs = [8 9];
permute_cfg.numrandomization = 2;
permute_cfg.task = "wm";
permute_cfg.permute.factor = "stim_condition";
permute_cfg.permute.levels = ["con", "strobe"];
stat = permute_conditions(permute_cfg);
cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'stat';
figure
ft_sourceplot(cfg, stat);

%% Permute 
permute_cfg.subs = subjects;
permute_cfg.numrandomization = 2;
for task = "wm"
    permute_cfg.task = "wm";
    permute_cfg.permute.factor = "stim_condition";
    permute_cfg.permute.levels = ["con", "strobe"];
    permute_cfg.contrast = ["low", "high"];


    stat = permute_conditions(permute_cfg);
    %
    
    allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
    load (allsources_ga_filename)
    anatomy = allsources_int_volnorm_ga.va.con.anatomy;
    %
    stat.anatomy = anatomy;
    cfg = [];
    cfg.method        = 'slice';
    cfg.funparameter  = 'stat';
    
    cfg.maskparameter = 'mask';
    % cfg.opacitylim    = [0 1];
    
    figure
    ft_sourceplot(cfg, stat);
end

%%
permute_cfg.subs = subjects;
permute_cfg.numrandomization = 2;
permute_cfg.task = "wm";
permute_cfg.permute.factor = "stim_condition";
permute_cfg.permute.levels = ["con", "strobe"];
permute_cfg.contrast = ["low", "high"];
stat = permute_conditions(permute_cfg);
%

allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
load (allsources_ga_filename)
anatomy = allsources_int_volnorm_ga.va.con.anatomy;