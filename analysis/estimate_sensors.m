function estimate_sensors(sub, task, stim_condition)
    
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


    % Load artefact-removed data containing MEG data from both runs
    var_name = sprintf('data_pca_%s', task);
    fname = strcat(var_name, '.mat');
    ar_source = fullfile(deriv_meg_dir, fname);
    data_all = load (ar_source, var_name);
    data_all = data_all.(var_name);


    % 
    % % bandpass
    % cfg = [];
    % cfg.preproc.bpfilter = [38 42]; % check ft_preprocessing
    % data_all = ft_preprocessing(cfg, data_all);
    
    % Find and select trials that correspond to the 
    % stimulus condition and the appropriate tasks:
    % In run 1, task 1 corresponds to left attention, and 
    % task 2 corresponds to right attention.
    % In run 2, task 1 corresponds to high difficulty
    % and task 2 corresponds to low difficulty
    trials_cond = data_all.trialinfo(:,3) == stim_map(stim_condition) & ...
        bitor(data_all.trialinfo(:,4) == 1, ...
            data_all.trialinfo(:,4) == 2);
    cfg = [];
    cfg.trials = trials_cond;
    data_task_cond = ft_selectdata(cfg, data_all);

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

    data_task_cond = ft_redefinetrial(cfg, data_task_cond);
    data_task_cond.trialinfo = data_task_cond.trialinfo;


    % Select task levels independently
    trials_task1 = data_task_cond.trialinfo(:,4) == 1;
    trials_task2 = data_task_cond.trialinfo(:,4) == 2;
    cfg = [];
    cfg.trials = trials_task1;
    data_task1 = ft_selectdata(cfg, data_task_cond);
    cfg.trials = trials_task2;
    data_task2 = ft_selectdata(cfg, data_task_cond);

    % PSD output filename structure
    switch task
        case "va"
            task_levels = ["left", "right"];
        case "wm"
            task_levels = ["high", "low"];
    end

    output_files = [];
    bids_str = sprintf("sub-%03d_task-%s_stimcondition-%s", sub, task, stim_condition);

    for i = 1:2
        output_file = fullfile( ...
            deriv_meg_dir, ...
            sprintf("%s_tasklevel-%s_psd.mat", bids_str, task_levels(i)));

        output_files = [output_files output_file];
    end
    output_file = fullfile(deriv_meg_dir, sprintf("%s_psd.mat", bids_str));
    output_files = [output_files output_file];


    % plot TFR for sanity check (clear 40 Hz artefact only in strobe)
    % if not(all(isfile(output_files)))
    channels         = 'M*O**';
    cfg              = [];
    cfg.output       = 'pow';
    cfg.channel      = channels;
    cfg.method       = 'mtmfft';
    cfg.taper        = 'boxcar';
    cfg.foi          = 30:1:50;                         
    cfg.t_ftimwin    = 10./cfg.foi;%ones(length(cfg.foi),1).*1;   
    cfg.toi          = -0.5:0.05:2.5;
    psd_task1 = ft_freqanalysis(cfg, data_task1);
    psd_task2 = ft_freqanalysis(cfg, data_task2);
    save (output_files(1), 'psd_task1', '-v7.3')
    save (output_files(2), 'psd_task2', '-v7.3')

    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = '(x1+x2)/2';
    psd = ft_math(cfg, psd_task1, psd_task2);

    save (output_files(3), 'psd', '-v7.3')
    % end

    %%%%%%%%%%%%%%%%%%%%
    % Planar gradients %
    output_files = [];
    bids_str = sprintf("sub-%03d_task-%s_stimcondition-%s", sub, task, stim_condition);

    for i = 1:2
        output_file = fullfile( ...
            deriv_meg_dir, ...
            sprintf("%s_tasklevel-%s_psd-planar.mat", bids_str, task_levels(i)));

        output_files = [output_files output_file];
    end
    output_file = fullfile(deriv_meg_dir, sprintf("%s_psd-planar.mat", bids_str));
    output_files = [output_files output_file];


    cfg                 = [];
    cfg.feedback        = 'yes';
    cfg.method          = 'template';
    neighbours      = ft_prepare_neighbours(cfg, data_all);
    close gcf;

    % Calculate planar gradients
    cfg                 = [];
    cfg.feedback        = 'yes';
    cfg.planarmethod    = 'sincos';
    cfg.neighbours      = neighbours;
    data_task1_planar = ft_megplanar(cfg, data_task1);
    data_task2_planar = ft_megplanar(cfg, data_task2);


    % Combine
    cfg = [];
    data_task1_planar_combined = ft_combineplanar(cfg, data_task1_planar);
    data_task2_planar_combined= ft_combineplanar(cfg, data_task2_planar);

    % Calculate FFT
    cfg              = [];
    channels = 'MEG';
    cfg.output       = 'pow';
    cfg.channel      = channels;
    cfg.method       = 'mtmfft';
    cfg.taper        = 'boxcar';
    cfg.foilim       = [39 41];
    psd_data_task1_planar        = ft_freqanalysis(cfg, data_task1_planar_combined);
    psd_data_task2_planar        = ft_freqanalysis(cfg, data_task2_planar_combined);
    save (output_files(1), 'psd_data_task1_planar', '-v7.3')
    save (output_files(2), 'psd_data_task2_planar', '-v7.3')


    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = '(x1+x2)/2';
    psd_data_planar = ft_math(cfg, psd_data_task1_planar, psd_data_task2_planar);
    save (output_files(3), 'psd_data_planar', '-v7.3')




end