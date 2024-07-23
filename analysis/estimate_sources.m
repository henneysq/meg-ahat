function [source1, source2] = estimate_sources(sub, task, stim_condition, update_forward_models)
    
    
    if ~exist('update_forward_models','var')
        update_forward_models = false;
    end

    sub_str = sprintf('sub-%03d', sub);

    % Add util dirs to path
    addpath('/project/3031004.01/meg-ahat/util')

    % Set up Fieldtrip
    configure_ft
    
    % Define directories
    data_dir = '/project/3031004.01/data/';
    raw2_dir = fullfile(data_dir, 'raw2');
    derivatives_dir = fullfile(data_dir, 'derivatives');
    % Define subject-level directories
    deriv_anat_dir = fullfile(derivatives_dir, sub_str, '/ses-001/anat/');
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    raw2_meg_dir = fullfile(raw2_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
   
    % Define mapping for easier indexing
    stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);


    % Load headmodel
    mri_headmodel_file = fullfile(deriv_anat_dir, 'mri_headmodel.mat');
    mri_headmodel = load (mri_headmodel_file);
    % As we are defining a grid in mm, assure the unit of head model is mm
    mri_headmodel = ft_convert_units(mri_headmodel.mri_headmodel, 'mm');    

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
        cfg.tight        = 'yes';
        cfg.inwardshift  = -1.5;
        sourcemodel = ft_prepare_sourcemodel(cfg);
        save (fullfile(deriv_meg_dir, 'sourcemodel.mat'), 'sourcemodel', '-v7.3')
    else
        sourcemodel = load (fullfile(deriv_meg_dir, 'sourcemodel.mat'));
        sourcemodel = sourcemodel.sourcemodel;
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
        cfg.tight        = 'yes';
        cfg.inwardshift  = -1.5;
        nonsym_sourcemodel = ft_prepare_sourcemodel(cfg);
        save (fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'), 'nonsym_sourcemodel', '-v7.3')
    else
        nonsym_sourcemodel = load (fullfile(deriv_meg_dir, 'nonsym_sourcemodel.mat'));
        nonsym_sourcemodel = nonsym_sourcemodel.nonsym_sourcemodel;
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
        leadfield = load (fullfile(deriv_meg_dir, 'leadfield.mat'));
        leadfield = leadfield.leadfield;
    end
    clear mri_headmodel


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
    
    % Crop data to segment of interest
    cfg = [];
    switch task
        case "va"
            % Redefine trials to 2-second segments
            cfg.toilim    = [0.5 2.5-1/1200];
        case "wm"
            % Redefine trials to 6-second segments
            cfg.toilim    = [0.5 6.5-1/1200];
    end

    data = ft_redefinetrial(cfg, data_all);
    data.trialinfo = data_all.trialinfo;

    % Find and select trials that correspond to the 
    % stimulus condition and the appropriate tasks:
    % In run 1, task 1 corresponds to left attention, and 
    % task 2 corresponds to right attention.
    % In run 2, task 1 corresponds to high difficulty
    % and task 2 corresponds to low difficulty
    trials_cond = data.trialinfo(:,3) == stim_map(stim_condition) & ...
        bitor(data.trialinfo(:,4) == 1, ...
            data.trialinfo(:,4) == 2);
    cfg = [];
    cfg.trials = trials_cond;
    data_task_cond = ft_selectdata(cfg, data);

    % Select task levels independently
    trials_task1 = data_task_cond.trialinfo(:,4) == 1;
    trials_task2 = data_task_cond.trialinfo(:,4) == 2;
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

    % do the beamformer source reconstuction
    cfg = [];
    cfg.headmodel = leadfield;
    cfg.sourcemodel = leadfield;
    cfg.grad = grad;
    cfg.method = 'lcmv';
    cfg.lcmv.keepcov = 'yes';
    cfg.lcmv.keepfilter   = 'yes';
    source = ft_sourceanalysis(cfg, timelock_task_cond);
    
    % Extract the common spatial filter and use in the
    % individual source estimates
    cfg.sourcemodel.filter = source.avg.filter;
    % clear source
    cfg.rawtrial = 'yes';
    cfg.keeptrials = 'yes';

    % We want to first estimate the source power on a
    % trial-by-trial basis to estimate the correlation between it
    % reaction time.
    % source_task1 = ft_sourceanalysis(cfg, timelock_task1);
    % source_task2 = ft_sourceanalysis(cfg, timelock_task2);
    % 
    % % Calculate the beta statistic
    % [s1, ~] = statfun_rt_power_cor([],source_task1);
    % [s2, ~] = statfun_rt_power_cor([],source_task2);

    % Then use the concatenated covariance to get the average
    % estimaes for the source power over trials
    cfg = rmfield(cfg, 'rawtrial');
    cfg = rmfield(cfg, 'keeptrials');
    source_task1 = ft_sourceanalysis(cfg, timelock_task1);
    source_task2 = ft_sourceanalysis(cfg, timelock_task2);
    
    % Add that beta stat images to the source objects
    % source_task1.stat = s1.stat;
    % source_task2.stat = s2.stat;
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
    sources_hsplit = [];
    sources_hsplit.left = source;
    sources_hsplit.left.avg.pow = nan(prod(sourcemodel.dim),1);
    sources_hsplit.right = sources_hsplit.left;
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
            % Extract the top left and lower right blocks from the
            % covariance matrix
            covL = source.avg.cov{k}(1:3,1:3);
            covR = source.avg.cov{k}(4:6,4:6);

            % Estimate the power as the first singular value
            powL = svd(covL); powL = powL(1);
            powR = svd(covR); powR = powR(1);
            sources_hsplit.left.avg.pow(k) = powL;
            sources_hsplit.right.avg.pow(k) = powR;

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
    source_reassembled = source_reassembled_task1;

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

    source_reassembled.avg.pow = reassemble_hemispheres(...
        sources_hsplit.left, ...
        sources_hsplit.right, ...
        source_reassembled, ...
        'avg.pow');
    clear sources_hsplit

    % mri_realigned = load (fullfile(deriv_anat_dir, 'mri_realigned.mat'));
    % mri_realigned = mri_realigned.mri_realigned;
    % 
    % cfg           = [];
    % cfg.parameter = 'pow';
    % source_int_volnorm = ft_sourceinterpolate(cfg, source_reassembled, mri_realigned);
    % source_int_volnorm1 = ft_sourceinterpolate(cfg, source_reassembled_task1, mri_realigned);
    % source_int_volnorm2 = ft_sourceinterpolate(cfg, source_reassembled_task1, mri_realigned);
    % cfg = [];
    % cfg.nonlinear     = 'no'; % yes?
    % source_int_volnorm = ft_volumenormalise(cfg, source_int_volnorm);
    % source_int_volnorm1 = ft_volumenormalise(cfg, source_int_volnorm1);
    % source_int_volnorm2 = ft_volumenormalise(cfg, source_int_volnorm2);

    bids_str = sprintf('sub-%03d_task-%s_stimcondition-%s', sub, task, stim_condition);
    
    switch task
        case "va"
            task_levels = ["left", "right"];
        case "wm"
            task_levels = ["high", "low"];
    end

    for i = 1:2
        output_file = fullfile( ...
            deriv_meg_dir, ...
            sprintf('%s_tasklevel-%s.mat', bids_str, task_levels(i)));

        save (output_file, sprintf('source_reassembled_task%d', i), '-v7.3')
    end

    output_file = fullfile(deriv_meg_dir, sprintf('%s.mat', bids_str));
    save (output_file, 'source_reassembled', '-v7.3')
end
