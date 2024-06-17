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
diaryfile = fullfile(data_dir, 'beamformer_group_ga.log');
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


allsources_int_volnorm_filename = fullfile(derivatives_group_dir, 'allsources-lcmv_contrast_proc-interp-volnorm.mat');
load (allsources_int_volnorm_filename)

%%

baddies = [];

cfg = [];
cfg.method        = 'slice';
cfg.funparameter="pow"
for task_no = 1:numel(tasks)
    task = tasks(task_no)
    for condition = conditions
        for s = 1:numel(subjects)
            sub = subjects(s)
            substr = sprintf('sub%d', sub)
            tit_str = sprintf('sub-%d task-%s cond-%s', sub, task, condition);
            try
                figure;
                ft_sourceplot(cfg, allsources_int_volnorm.(task).(condition){s})
                title(tit_str)
            catch
                close gcf
                if not(isfield(baddies, task))
                    baddies.(task) = [];
                end
                if not(isfield(baddies.(task), condition))
                    baddies.(task).(condition) = [];
                end
                if not(isfield(baddies.(task).(condition), substr))
                    baddies.(task).(condition).(substr) = true;
                    sprintf('Badde: %s', tit_str)
                end
            end
        end
    end
end

%%

allsources_int_volnorm_ga = [];
for task=tasks
    allsources_int_volnorm_ga.(task) = [];
    for condition = conditions

        % grand average over subjects
        cfg           = [];
        cfg.parameter = 'pow';%{'pow', 'anatomy'};
        allsources_int_volnorm_ga.(task).(condition) = ft_sourcegrandaverage(cfg, allsources_int_volnorm.(task).(condition){:});
        
        cfg           = [];
        cfg.parameter = 'anatomy';%{'pow', 'anatomy'};
        anatomy = ft_sourcegrandaverage(cfg, allsources_int_volnorm.(task).(condition){:});
        allsources_int_volnorm_ga.(task).(condition).anatomy = anatomy.anatomy;
    end
end
%
allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
save (allsources_ga_filename, 'allsources_int_volnorm_ga', '-v7.3')

%%
allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
load (allsources_ga_filename)

%%

cfg = [];
cfg.method        = 'slice';
cfg.funparameter = "pow";
for task_no = 1:numel(tasks)
    task = tasks(task_no);
    for condition = conditions
        tit_str = sprintf('grand average task-%s cond-%s', task, condition)
        allsources_int_volnorm_ga.(task).(condition).cfg = []; % a bit hacky, but could speed up
        figure;
        ft_sourceplot(cfg, allsources_int_volnorm_ga.(task).(condition))
        title(tit_str)
    end
end