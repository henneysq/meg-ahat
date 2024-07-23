%% SETUP
clear;

% Flag to indicate whether we update source and leadfield models
update_forward_models = false;

% Add util and template dirs to path
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/templates')
if isfile('cd_to_proj.m')
    cd_to_proj
end

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');
derivatives_group_dir = fullfile(derivatives_dir, 'group');

% Start logging
diaryfile = fullfile(data_dir, 'logs', 'lcmv_beamformer.log');
if (exist(diaryfile, 'file'))
  delete(diaryfile);
end
diary (diaryfile)
    
% Set up Fieldtrip
configure_ft

% Load data details
data_details_cfg = get_data_details();

% Define subjects, tasks, and conditions
subjects = data_details_cfg.new_trigger_subs;

tasks = ["va" "wm"];
stim_conditions = ["con" "strobe"];

% Define mapping for easier indexing
stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);
task_maps = dictionary( ...
    ["va", "wm"], ...
    {dictionary( ...
        ["left", "right"], ...
        [1, 2]), ...
    dictionary( ...
        ["high", "low"], ...
        [1, 2])} ...
    );

%% BEAMFORMING
% Iterate over subjects to perform beamforming of the 40 Hz signal
% and contrast condtions given task(s) and condition(s).
% Each contrast is saved to disk for a given subject.
close all
for sub = subjects
    sub_str = sprintf('sub-%03d', sub)
    
    % Define subject-level directories
    deriv_anat_dir = fullfile(derivatives_dir, sub_str, '/ses-001/anat/');
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    raw2_meg_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    
    % Load headmodel
    mri_headmodel_file = fullfile(deriv_anat_dir, 'mri_headmodel.mat');
    load (mri_headmodel_file)
    % As we are defining a grid in mm, assure the unit of head model is mm
    mri_headmodel = ft_convert_units(mri_headmodel, 'mm');    

    % Symmentrical source model:
    % Define a source model with a grid symmetric around the midline
    % for conducting symmetric dipole beamforming.
    % As the grid is defined in 'CTF' coordinates, positive y-values
    % indicate the left side hemisphere:
    % https://www.fieldtriptoolbox.org/faq/coordsys/#details-of-the-ctf-coordinate-system
    if not(isfile(fullfile(deriv_meg_dir, 'sourcemodel.mat'))) || update_forward_models
        cfg = [];
        cfg.headmodel = mri_headmodel;
        cfg.symmetry = 'y';
        cfg.xgrid = -148:8:148; % in mm
        cfg.ygrid =    4:8:148; % in mm, left hemisphere, offset to the midline
        cfg.zgrid = -148:8:148; % in mm
        %cfg.tight = 'no';
        cfg.tight        = 'yes';
        cfg.inwardshift  = -1.5;
        sourcemodel = ft_prepare_sourcemodel(cfg);
        save (fullfile(deriv_meg_dir, 'sourcemodel.mat'), 'sourcemodel', '-v7.3')
    else
        load (fullfile(deriv_meg_dir, 'sourcemodel.mat'))
    end

    % Non-symmetrical source model:
    % Create a headmodel without the symmetry constraint.
    % This is needed to interpret the results of the symmetric dipole
    % beamforming results after untangling the hemispheres.
    if not(isfile(fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'))) || update_forward_models
        cfg = [];
        cfg.headmodel = mri_headmodel;
        cfg.xgrid = -148:8:148; % in mm
        cfg.ygrid = -148:8:148; % in mm, both hemispheres
        cfg.zgrid = -148:8:148; % in mm
        %cfg.tight = 'no';
        cfg.tight        = 'yes';
        cfg.inwardshift  = -1.5;
        nonsym_sourcemodel = ft_prepare_sourcemodel(cfg);
        save (fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'), 'nonsym_sourcemodel', '-v7.3')
    else
        load (fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'))
    end

    % Apparently, the dimensions of the source models can vary ever so
    % slightly between the symmentric and non-symmetric definitions, so we
    % check the difference between the pos array coordinates in the two
    % models to look for extrema that were included in one but not the
    % other.
    % The 'intersect_sourcemodels' function is defined in the bottom of the
    % script
    [sourcemodel, nonsym_sourcemodel] = intersect_sourcemodels(sourcemodel, nonsym_sourcemodel);


    % Load grad from raw2 version of meg data
    grad = ft_read_sens( ...
        fullfile(raw2_meg_dir, ...
            sprintf('sub-%03d_ses-001_task-flicker_meg.ds', sub)), ...
        'senstype', 'meg');

    % Leadfield:
    % Estimate the leadfield using the symmetric sourcemodel
    if not(isfile(fullfile(deriv_meg_dir, 'leadfield.mat'))) || update_forward_models
        cfg = [];
        cfg.grad = grad;
        cfg.channel = {'MEGGRAD'};
        cfg.headmodel = mri_headmodel;
        cfg.sourcemodel = sourcemodel;
        leadfield = ft_prepare_leadfield(cfg);
        save (fullfile(deriv_meg_dir, 'leadfield.mat'), 'leadfield', '-v7.3')  
    else
        load (fullfile(deriv_meg_dir, 'leadfield.mat'))
    end

    clear mri_headmodel

    % Iterate over tasks (i.e. runs 1 and 2: visual attention ('va') and 
    % working memory('wm') )
    for task = tasks
        % Load artefact-removed data containing MEG data from both runs
        var_name = sprintf('data_pca_%s', task);
        fname = strcat(var_name, '.mat');
        ar_source = fullfile(deriv_meg_dir, fname);
        data_all = load (ar_source, var_name);
        data_all = data_all.(var_name);

        % bandpass
        cfg = [];
        cfg.preproc.bpfilter = [38 42]; % check ft_preprocessing
        data_all = ft_preprocessing(cfg, data_all);
        
        switch task
            case "va"
                % task_map = dictionary(["left", "right"], [1, 2]);
                % Redefine trials to 2-second segments
                cfg = [];
                cfg.toilim    = [0.5 2.5-1/1200];
                data_task        = ft_redefinetrial(cfg,data_all);
            
            case "wm"
                % Redefine trials to 6-second segments
                cfg = [];
                cfg.toilim    = [0.5 6.5-1/1200];
                data_task        = ft_redefinetrial(cfg,data_all);  
        end

        data_task.trialinfo = data_all.trialinfo;

        % Iterate over the no-flicker and luminance-flicker
        % conditions for now (con & strobe)
        for stim_condition = stim_conditions
            sprintf('Stimulation condtition: %s', stim_condition)
    
            % Find and select trials that correspond to the 
            % stimulus condition and the appropriate tasks:
            % In run 1, task 1 corresponds to left attention, and 
            % task 2 corresponds to right attention.
            % In run 2, task 1 corresponds to high difficulty
            % and task 2 corresponds to low difficulty
            trials_cond = data_task.trialinfo(:,3) == stim_map(stim_condition) & ...
                bitor(data_task.trialinfo(:,4) == 1, ...
                    data_task.trialinfo(:,4) == 2);
            cfg = [];
            cfg.trials = trials_cond;
            data_task_cond = ft_selectdata(cfg, data_task);
    
            % Find and select left and right attention trials independently
            % or for the high/low arithmetic difficulty
            trials_task1 = data_task_cond.trialinfo(:,4) == 1; % Left / High
            trials_task2 = data_task_cond.trialinfo(:,4) == 2; % Right / Low
            cfg = [];
            cfg.trials = trials_task1;
            data_task1 = ft_selectdata(cfg, data_task_cond);
            cfg.trials = trials_task2;
            data_task2 = ft_selectdata(cfg, data_task_cond);

            % OBS: The ft_timelockanalysis estimates the covariance on the
            % timeseries and thus does not take into account any spectral
            % details. Thus, the variance is expected to be dominated by
            % the 40 Hz contribution and as such should be bp-filtered at
            % this point
            cfg = [];
            cfg.covariance = 'yes';
            cfg.keeptrials = 'yes';
            timelock_task1 = ft_timelockanalysis(cfg, data_task1);
            timelock_task2 = ft_timelockanalysis(cfg, data_task2);
            timelock_task_cond = ft_timelockanalysis(cfg, data_task_cond);
            clear data_task_cond data_task1 data_task2

            % do the beamformer source reconstuction on a 1 cm grid
            cfg = [];
            cfg.headmodel = leadfield;
            cfg.sourcemodel       = leadfield;
            cfg.grad = grad;
            cfg.method = 'lcmv';
            cfg.lcmv.keepcov = 'yes';
            cfg.lcmv.keepfilter   = 'yes';
            source = ft_sourceanalysis(cfg, timelock_task_cond);
            
            
            % Extract the common spatial filter and use in the
            % individual source estimates
            cfg.sourcemodel.filter = source.avg.filter;
            clear source
            cfg.rawtrial = 'yes';
            cfg.keeptrials = 'yes';

            % We want to first estimate the source power on a
            % trial-by-trial basis to estimate the correlation between it
            % reaction time.
            source_task1 = ft_sourceanalysis(cfg, timelock_task1);
            source_task2 = ft_sourceanalysis(cfg, timelock_task2);
            
            % Calculate the beta statistic
            [s1, ~] = statfun_rt_power_cor([],source_task1);
            [s2, ~] = statfun_rt_power_cor([],source_task2);

            % Then use the concatenated covariance to get the average
            % estimaes for the source power over trials
            cfg = rmfield(cfg, 'rawtrial');
            cfg = rmfield(cfg, 'keeptrials');
            source_task1 = ft_sourceanalysis(cfg, timelock_task1);
            source_task2 = ft_sourceanalysis(cfg, timelock_task2);
            
            % Add that beta stat images to the source objects
            source_task1.stat = s1.stat;
            source_task2.stat = s2.stat;
            clear timelock_task1 timelock_task2 s1 st2

            % From the symmetric dipole constraint, we get a
            % 6x6 covaraince matrix, defined by the 6-dimensional position
            % vector 'pos' , of which the first three elements are
            % the xyz coordinates of the left hemisphere diploe
            % (positive y), and the last three elements are the xyz
            % coordinates of the right hemisphere diploe (negative
            % y). As such, the CSD values reflect the coordinate
            % pairs defined by pos^T x pos.
            % Thus, the upper left 3x3 block represents the left
            % hemisphere dipole CSD, and the lower right 3x3 block
            % represents the right hemisphere dipole
            sources_task1_hsplit = [];
            sources_task1_hsplit.left = source_task1;
            sources_task1_hsplit.left.avg.pow = nan(prod(sourcemodel.dim),1);
            sources_task1_hsplit.right = sources_task1_hsplit.left;
            sources_task2_hsplit = [];
            sources_task2_hsplit.left = source_task2;
            sources_task2_hsplit.left.avg.pow = nan(prod(sourcemodel.dim),1);
            sources_task2_hsplit.right = sources_task1_hsplit.left;

            % Iterate over dipole (pairs)
            for k = 1:size(source_task1.pos,1)
                if ~isempty(source_task1.avg.cov{k})
                    % Exrtract the top left and lower right blocks from the
                    % covariance matrix
                    covL = source_task1.avg.cov{k}(1:3,1:3);
                    covR = source_task1.avg.cov{k}(4:6,4:6);

                    % Estimate the power as the first singular value
                    powL = svd(covL); powL = powL(1);
                    powR = svd(covR); powR = powR(1);
                    sources_task1_hsplit.left.avg.pow(k) = powL;
                    sources_task1_hsplit.right.avg.pow(k) = powR;

                    % repeat for task 2
                    covL = source_task2.avg.cov{k}(1:3,1:3);
                    covR = source_task2.avg.cov{k}(4:6,4:6);
                    powL = svd(covL); powL = powL(1); % use the lambda1 method
                    powR = svd(covR); powR = powR(1);
                    sources_task2_hsplit.left.avg.pow(k) = powL;
                    sources_task2_hsplit.right.avg.pow(k) = powR;

                end
            end

            % Grab the metadata from the non-symmetrical
            % sourcemodel and add value(s)
            source_reassembled_task1 = nonsym_sourcemodel;
            source_reassembled_task1.freq = 40;
            source_reassembled_task2 = source_reassembled_task1;

            % As we are left with two objects representing
            % simulataneously both hemispheres and one hemisphere,
            % we need to massage the estimates back into a
            % structure that fieldtrip understands downstream.
            source_reassembled_task1.avg.pow = reassemble_hemispheres(...
                sources_task1_hsplit.left, ...
                sources_task1_hsplit.right, ... 
                source_reassembled_task1, ...
                'avg.pow');
            clear sources_task1_hsplit

            source_reassembled_task2.avg.pow = reassemble_hemispheres(...
                sources_task2_hsplit.left, ...
                sources_task2_hsplit.right, ...
                source_reassembled_task2, ...
                'avg.pow');
            clear sources_task2_hsplit
            
            % Contrast the task conditions, normalising to their
            % combined power
            cfg           = [];
            cfg.operation = '(x2-x1)/(x2+x1)';
            cfg.parameter = 'avg.pow';
            source_contrast   = ft_math(cfg,source_reassembled_task1,source_reassembled_task2);
            clear source_reassembled_task1 source_reassembled_task2

            % Save output to derivatives
            source_constrast_file = fullfile(deriv_meg_dir, sprintf('source-lcmv_task-%s_cond-%s_contrast.mat', task, stim_condition));
            save (source_constrast_file, 'source_contrast', '-v7.3')

            % Repeat the same process for the beta estimates
            source_reassembled_beta1 = nonsym_sourcemodel;
            source_reassembled_beta1.freq = 40;
            source_reassembled_beta1.stat = reassemble_hemispheres(...
                source_task1, ...
                source_task1, ... 
                source_reassembled_beta1, ...
                'stat');
            source_reassembled_beta2 = nonsym_sourcemodel;
            source_reassembled_beta2.freq = 40;
            source_reassembled_beta2.stat = reassemble_hemispheres(...
                source_task2, ...
                source_task2, ... 
                source_reassembled_beta2, ...
                'stat');

            % Contrast the conditions, normalising to their
            % combined power
            cfg           = [];
            cfg.operation = '(x2-x1)/(x2+x1)';
            cfg.parameter = 'stat';
            source_beta_contrast   = ft_math(cfg,source_reassembled_beta1,source_reassembled_beta2);
            clear source_reassembled_beta1 source_reassembled_beta2

            % cfg = [];
            % cfg.funparameter = 'stat';
            % ft_sourceplot(cfg, source_beta_contrast)
            source_beta_file = fullfile(deriv_meg_dir, sprintf('source-lcmv_task-%s_cond-%s_beta.mat', task, stim_condition));
            save (source_beta_file, 'source_beta_contrast', '-v7.3')
            clear source_beta_contrast source_task1 source_task2
        end
    end
end


%% Gather contrasts over tasks and conditions

allsources_beta = [];
allsources_int_volnorm = [];

for task_no = 1:numel(tasks)
    task = tasks(task_no)
    allsources_beta.(task) = [];

    for stim_condition = stim_conditions
        sources_beta_int_volnorm = cell(1,numel(subjects));
        source_int_volnorm = sources_beta_int_volnorm;

        for s = 1:numel(subjects)
            sub = subjects(s)
            
            deriv_anat_dir = fullfile(derivatives_dir, sprintf('sub-%03d',subjects(s)), 'ses-001', 'anat');
            mri_realigned_file = fullfile(deriv_anat_dir, 'mri_realigned.mat');
            load (mri_realigned_file)

            deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), 'ses-001', 'meg');
            source_constrast_file = fullfile(deriv_meg_dir, sprintf('source-lcmv_task-%s_cond-%s_contrast.mat', task, stim_condition));
            load (source_constrast_file) % source_lateral_dif
            
            source_beta_file = fullfile(deriv_meg_dir, sprintf('source-lcmv_task-%s_cond-%s_beta.mat', task, stim_condition));
            load (source_beta_file)

            cfg           = [];
            cfg.parameter = 'pow';
            source_contrast_int_volnorm = ft_sourceinterpolate(cfg, source_contrast, mri_realigned);
            cfg = [];
            cfg.nonlinear     = 'no'; % yes?
            source_contrast_int_volnorm = ft_volumenormalise(cfg, source_contrast_int_volnorm);

            cfg           = [];
            cfg.parameter = 'stat';
            source_beta_contrast_int_volnorm = ft_sourceinterpolate(cfg, source_beta_contrast, mri_realigned);
            cfg = [];
            cfg.nonlinear     = 'no'; % yes?
            source_beta_contrast_int_volnorm = ft_volumenormalise(cfg, source_beta_contrast_int_volnorm);
            


            sources_beta_int_volnorm{s} = source_beta_contrast_int_volnorm;
            sources_int_volnorm{s} = source_contrast_int_volnorm;
        
        end
        
        allsources_beta_int_volnorm.(task).(stim_condition) = sources_beta_int_volnorm;
        allsources_int_volnorm.(task).(stim_condition) = sources_int_volnorm;
    end
end

allsources_beta_int_volnorm_filename = fullfile(derivatives_group_dir, 'allsources-lcmv_beta-contrast_proc-interp-volnorm.mat');
allsources_int_volnorm_filename = fullfile(derivatives_group_dir, 'allsources-lcmv_contrast_proc-interp-volnorm.mat');
save (allsources_beta_int_volnorm_filename, 'allsources_beta_int_volnorm', '-v7.3')
save (allsources_int_volnorm_filename, 'allsources_int_volnorm', '-v7.3')
