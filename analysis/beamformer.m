%% SETUP
clear;

% Flag to indicate whether we update source and leadfield models
update_models = true;

% Add util and template dirs to path
addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/templates')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');

% Start logging
diaryfile = fullfile(data_dir, 'beamformer.log');
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
    if not(isfile(fullfile(deriv_meg_dir, 'sourcemodel.mat'))) || update_models
        cfg = [];
        cfg.headmodel = mri_headmodel;
        cfg.symmetry = 'y';
        cfg.xgrid = -148:8:148; % in mm
        cfg.ygrid =    4:8:148; % in mm, left hemisphere, offset to the midline
        cfg.zgrid = -148:8:148; % in mm
        sourcemodel = ft_prepare_sourcemodel(cfg);
        save (fullfile(deriv_meg_dir, 'sourcemodel.mat'), 'sourcemodel', '-v7.3')
    else
        load (fullfile(deriv_meg_dir, 'sourcemodel.mat'))
    end

    % Non-symmetrical source model:
    % Create a headmodel without the symmetry constraint.
    % This is needed to interpret the results of the symmetric dipole
    % beamforming results after untangling the hemispheres.
    if not(isfile(fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'))) || update_models
        cfg = [];
        cfg.headmodel = mri_headmodel;
        cfg.xgrid = -148:8:148; % in mm
        cfg.ygrid = -148:8:148; % in mm, both hemispheres
        cfg.zgrid = -148:8:148; % in mm
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

    % Leadfield:
    % Estimate the leadfield using the symmetric sourcemodel
    if not(isfile(fullfile(deriv_meg_dir, 'leadfield.mat'))) || update_models
        % Load grad from raw2 version of meg data
        grad = ft_read_sens( ...
            fullfile(raw2_meg_dir, ...
                sprintf('sub-%03d_ses-001_task-flicker_meg.ds', sub)), ...
            'senstype', 'meg');

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

    % Iterate over tasks (i.e. runs 1 and 2: visual attention ('va') and 
    % working memory('wm') )
    for task = tasks
        % Load artefact-removed data containing MEG data from both runs
        var_name = sprintf('data_pca_%s', task);
        fname = strcat(var_name, '.mat');
        ar_source = fullfile(deriv_meg_dir, fname);
        data_all = load (ar_source, var_name);
        data_all = data_all.(var_name);
        
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
        for condition = conditions
            sprintf('Stimulation condtition: %s', condition)
    
            % Find and select trials that correspond to the 
            % stimulus condition and the appropriate tasks:
            % In run 1, task 1 corresponds to left attention, and 
            % task 2 corresponds to right attention.
            % In run 2, task 1 corresponds to high difficulty
            % and task 2 corresponds to low difficulty
            trials_cond = data_task.trialinfo(:,3) == stim_map(condition) & ...
                bitor(data_task.trialinfo(:,4) == 1, ...
                    data_task.trialinfo(:,4) == 2);
            cfg = [];
            cfg.trials = trials_cond;
            data_task_cond = ft_selectdata(cfg, data_task);
    
            % Find and select left and right attention trials independently
            trials_task1 = data_task_cond.trialinfo(:,4) == 1;
            trials_task2 = data_task_cond.trialinfo(:,4) == 2;
            cfg = [];
            cfg.trials = trials_task1;
            data_task1 = ft_selectdata(cfg, data_task_cond);
            cfg.trials = trials_task2;
            data_task2 = ft_selectdata(cfg, data_task_cond);
                 
            % Calculate periodogram
            cfg              = [];
            cfg.channel     = 'MEG';
            cfg.output       = 'powandcsd';
            cfg.method       = 'mtmfft';
            cfg.taper        = 'boxcar';
            cfg.foilim       = [40 40];
            ERboxcar_ar_task1        = ft_freqanalysis(cfg, data_task1);
            ERboxcar_ar_task2        = ft_freqanalysis(cfg, data_task2);
            % We also need the combined data for calculating the
            % common spatial filter
            ERboxcar_Ar        = ft_freqanalysis(cfg, data_task_cond);
            
            % Source Analysis of lateral contrast
            cfg                   = []; 
            cfg.method            = 'dics';
            cfg.frequency         = 40;  
            cfg.channel           = data_all.label(:);
            cfg.sourcemodel       = leadfield;
            cfg.headmodel         = mri_headmodel;
            cfg.dics.keepfilter   = 'yes';
            cfg.dics.fixedori     = 'no';
            cfg.dics.projectnoise = 'yes';
            cfg.dics.lambda       = '5%';
            cfg.dics.realfilter   = 'yes';
            cfg.dics.keepcsd      = 'yes';
            source = ft_sourceanalysis(cfg, ERboxcar_Ar);
            
            % Extract the common spatial filter and use in the
            % individual source estimates
            cfg.sourcemodel.filter = source.avg.filter;
            % We need to use the 'pcc' method with keepdcsd = 'yes'
            % and then manually calculate the power on each
            % hemisphere, decoupling the symmetric dipoles
            cfg.method   = 'pcc';
            cfg.keepcsd = 'yes';
            cfg          = rmfield(cfg, 'dics');
            source_task1 = ft_sourceanalysis(cfg, ERboxcar_ar_task1);
            source_task2 = ft_sourceanalysis(cfg, ERboxcar_ar_task2);

            % From the symmetric dipole constraint, we get a
            % 6x6 CSD matrix, defined by the 6-dimensional position
            % vector 'pos' , of which the first three elements are
            % the xyz coordinates of the left hemisphere diploe
            % (positive y), and the last three elements are the xyz
            % coordinates of the right hemisphere diploe (negative
            % y). As such, the CSD values reflect the coordinate
            % pairs defined by pos^T x pos.
            % Thus, the upper left 3x3 block represents the left
            % hemisphere dipole CSD, and the lower right 3x3 block
            % represents the right hemisphere dipole
            hemispheres = ["left", "right"];
            sources_task1_hsplit = [];
            sources_task2_hsplit = [];
            for hn = 1:2
                for k = 1:size(source_task1.pos,1)
                    if ~isempty(source_task1.avg.csdlabel{k})
                        % Define 3x3 block indices for the CSD of
                        % interest
                        indices = (1:3) + 3 * (hn - 1);
                        % Set the CSD label to 'scandip' to
                        % indicate the it is a scanner dipole
                        source_task1.avg.csdlabel{k}(indices) = {'scandip'};
                        source_task2.avg.csdlabel{k}(indices) = {'scandip'};
                        % Define 3x3 block indices for the CSD of
                        % no-interest
                        indices = (4:6) - 3 * (hn - 1);
                        % Set the CSD label to 'scandip' to
                        % indicate the it is a suppression dipole
                        source_task1.avg.csdlabel{k}(indices) = {'supdip'};
                        source_task2.avg.csdlabel{k}(indices) = {'supdip'};
                        
                    end
                end
                % Estimate the power from the CSD using the first
                % singular value
                cfg = [];
                cfg.keepcsd = 'no';
                cfg.powmethod = 'lambda1';
                % ft_sourcedescriptives indexes the 6x6 CSD matric
                % based on the CSD labels and implements the power
                % estimate based on Gross et.al. eq (8) https://doi.org/10.1073/pnas.98.2.694
                sources_task1_hsplit.(hemispheres(hn)) = ft_sourcedescriptives(cfg, source_task1);
                sources_task2_hsplit.(hemispheres(hn)) = ft_sourcedescriptives(cfg, source_task2);
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

            source_reassembled_task2.avg.pow = reassemble_hemispheres(...
                sources_task2_hsplit.left, ...
                sources_task2_hsplit.right, ...
                source_reassembled_task2, ...
                'avg.pow');
            
            % Contrast the lateral conditions, normalising to their
            % combined power
            cfg           = [];
            cfg.operation = '(x2-x1)/(x1+x2)'; % right minus left
            cfg.parameter = 'avg.pow';
            source_contrast   = ft_math(cfg,source_reassembled_task1,source_reassembled_task2);                    

            % Save output to derivatives
            source_constrast_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_cond-%s_contrast.mat', task, condition));
            save (source_constrast_file, 'source_contrast', '-v7.3')

        end
    end
end

%% Average over lateral contrasts

lateral_dif_sources = cell(1,numel(subjects));
deriv_anat_dir = fullfile(derivatives_dir, 'sub-030', '/ses-001/anat/'); % Use sub 30 mri for now
mri_realigned_file = fullfile(deriv_anat_dir, 'mri_realigned.mat');
load (mri_realigned_file)
title_contrast = ["Left minus right attention" "High minus low arithmetic difficulty"];

for task_no = 1:numel(tasks)
    task = tasks(task_no)
    for condition = conditions
        title_str = sprintf('%s - Stim: %s', title_contrast(task_no), condition)
        for s = 1:numel(subjects)
            sub = subjects(s)
            
            deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
        
            source_constrast_file = fullfile(deriv_meg_dir, sprintf('source_task-%s_cond-%s_contrast.mat', task, condition));
            load (source_constrast_file) % source_lateral_dif
        
            lateral_dif_sources{s} = source_contrast;
        
        end
        
        % grand average over subjects
        cfg           = [];
        cfg.parameter = 'pow';
        gaall         = ft_sourcegrandaverage(cfg, lateral_dif_sources{1});
        
        % interpolate onto MRI
        % load ('mri152.mat');
        cfg           = [];
        cfg.parameter = 'pow';
        source_lateral_dif_interp  = ft_sourceinterpolate(cfg, gaall, mri_realigned);
        
        % Plot the estimated sources
        
        % thresholded opacity map, anything <65% of maximum is fully transparent,
        % anything >80% of maximum is fully opaque
        
        % cfg = [];
        % cfg.method        = 'ortho';
        % cfg.funparameter  = 'pow';
        % cfg.funcolormap   = 'jet';
        % 
        % figure;
        % ft_sourceplot(cfg, source_lateral_dif_interp);
        
        
        cfg = [];
        cfg.method        = 'slice';
        cfg.funparameter  = 'pow';
        cfg.funcolormap   = 'jet';
        
        figure;
        ft_sourceplot(cfg, source_lateral_dif_interp);
        title(title_str)
        saveas(gcf,fullfile(derivatives_dir, sprintf('sub-all_stim-%s_task-%s_source_contrast.png', condition, task)))

    end
end

%%