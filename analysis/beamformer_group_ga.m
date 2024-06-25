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
derivatives_img_dir = fullfile(derivatives_dir, 'img');

% Start logging
diaryfile = fullfile(data_dir, 'logs', 'beamformer_group_ga.log');
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
allsources_beta_int_volnorm_filename = fullfile(derivatives_group_dir, 'allsources-lcmv_beta-contrast_proc-interp-volnorm.mat');
load (allsources_int_volnorm_filename)
load (allsources_beta_int_volnorm_filename)

%%

baddies = [];

cfg = [];
cfg.method        = 'slice';
for task_no = 1:numel(tasks)
    task = tasks(task_no)
    for condition = conditions
        for s = 1:numel(subjects)
            sub = subjects(s)
            subses_img_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), 'ses-001', 'img');
            substr = sprintf('sub%d', sub)
            tit_str = sprintf('sub-%d task-%s cond-%s', sub, task, condition);
            try
                cfg.funparameter="pow"
                figure;
                ft_sourceplot(cfg, allsources_int_volnorm.(task).(condition){s})
                title(tit_str)
                saveas(gcf, fullfile(subses_img_dir, sprintf('sub-%d_task-%s_cond-%s.png', sub, task, condition)))
                
                cfg.funparameter="stat"
                figure;
                ft_sourceplot(cfg, allsources_beta_int_volnorm.(task).(condition){s})
                saveas(gcf, fullfile(subses_img_dir, sprintf('sub-%03d_task-%s_cond-%s_beta.png', sub, task, condition)))
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
                    sprintf('Baddie: %s', tit_str)
                end
            end
        end
    end
end

%%

allsources_int_volnorm_ga = [];
allsources_beta_int_volnorm_ga = [];
for task=tasks
    allsources_int_volnorm_ga.(task) = [];
    for condition = conditions

        % grand average power over subjects
        cfg           = [];
        cfg.parameter = 'pow';
        allsources_int_volnorm_ga.(task).(condition) = ft_sourcegrandaverage(cfg, allsources_int_volnorm.(task).(condition){:});
        
        cfg           = [];
        cfg.parameter = 'anatomy';
        anatomy = ft_sourcegrandaverage(cfg, allsources_int_volnorm.(task).(condition){:});
        allsources_int_volnorm_ga.(task).(condition).anatomy = anatomy.anatomy;
        
        % grand average betas over subjects
        cfg           = [];
        cfg.parameter = 'stat';
        allsources_beta_int_volnorm_ga.(task).(condition) = ft_sourcegrandaverage(cfg, allsources_beta_int_volnorm.(task).(condition){:});
    end
end

allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
save (allsources_ga_filename, 'allsources_int_volnorm_ga', '-v7.3')
allsources_beta_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
save (allsources_beta_ga_filename, 'allsources_beta_int_volnorm_ga', '-v7.3')

%%
allsources_ga_filename = fullfile(derivatives_group_dir, 'allsources_contrast_grandaverage.mat');
load (allsources_ga_filename)

%%
close all
cfg = [];
cfg.method        = 'slice';
for task_no = 1:numel(tasks)
    task = tasks(task_no);
    for condition = conditions
        tit_str = sprintf('grand average power task-%s cond-%s', task, condition)
        cfg.funparameter = "pow";
        allsources_int_volnorm_ga.(task).(condition).cfg = []; % a bit hacky, but could speed up
        figure;
        ft_sourceplot(cfg, allsources_int_volnorm_ga.(task).(condition))
        title(tit_str)
        saveas(gcf,fullfile(derivatives_img_dir, sprintf('sub-all_power_task-%s_cond-%s.png', task, condition)))

        tit_str = sprintf('grand average beta task-%s cond-%s', task, condition)
        cfg.funparameter = "stat";
        allsources_beta_int_volnorm_ga.(task).(condition).cfg = []; % a bit hacky, but could speed up
        figure;
        ft_sourceplot(cfg, allsources_beta_int_volnorm_ga.(task).(condition))
        title(tit_str)  
        saveas(gcf,fullfile(derivatives_img_dir, sprintf('sub-all_beta_task-%s_cond-%s.png', task, condition)))
    end
end
