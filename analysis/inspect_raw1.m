subs = [1:7 10 12 14:17 19:20];

% Configure fieldtrip
addpath('/project/3031004.01/meg-ahat/util')
configure_ft

project_dir = fullfile('/project', '3031004.01');
repo_dir = fullfile(project_dir, 'meg-ahat');

% Add util dir to path
util_dir = fullfile(repo_dir, 'util');
addpath(util_dir);

% Set pilot data directory
data_dir = fullfile(project_dir, 'data');
raw1_dir = fullfile(data_dir, 'raw1');

% Prepare book keeping to avoid repeated inspection
if not(isfile('inspection_bookkeeping.mat'))
    inspection_bookkeeping = [];
else
    load inspection_bookkeeping.mat
end

% Iterate over subjects
for sub = subs
    % Check book keeping
    if not(isfield(inspection_bookkeeping, sprintf('sub%03d', sub)))
        inspection_bookkeeping.(sprintf('sub%03d', sub)) = [];
    end
    
    % Use temporary subject specific book keeping struct
    sub_inspection_bookkeping = inspection_bookkeeping.(sprintf('sub%03d', sub));

    sub_str = sprintf('sub-%03d', sub);
    ses_str = 'ses-001';
    sub_dir = fullfile(raw1_dir, sub_str);
    ses_dir = fullfile(sub_dir, ses_str);

    % Check MRI
    if not(isfield(sub_inspection_bookkeping, 'mri'))
        sub_inspection_bookkeping.mri = false;
    end

    if sub_inspection_bookkeping.mri
        % PASS
    else
        mri_file = fullfile(ses_dir, 'anat', ...
            sprintf('%s_%s_T1w.nii', sub_str, ses_str));
    
        mri = ft_read_mri(mri_file);
        cfg = [];
        mri_realigned = ft_volumerealign(cfg, mri);

        sub_inspection_bookkeping.mri = true;
    end

    % MEG Events
    if not(isfield(sub_inspection_bookkeping, 'events'))
        sub_inspection_bookkeping.events = false;
    end

    if sub_inspection_bookkeping.events
        % PASS
    else
        dataset_dir = fullfile(ses_dir, 'meg', ...
            sprintf('%s_%s_task-flicker_meg.ds', sub_str, ses_str));
        cfg = [];
        cfg.dataset = dataset_dir;
        
        event = ft_read_event(cfg.dataset);
        
        % search for "trigger" events
        mask = find(strcmp('UPPT001', {event.type}));
        value  = [event(mask).value]';
        mask_start_events = find(value == 1);
        timestamp = [event(mask).timestamp]';
        sample = [event(mask).sample]';
    
        figure;
        plot(timestamp, value);
        
        sub_inspection_bookkeping.events = true;
    end

    % MEG time series
    if not(isfield(sub_inspection_bookkeping, 'meg'))
        sub_inspection_bookkeping.meg = false;
    end

    if sub_inspection_bookkeping.meg
        % PASS
    else
        % read the data from disk and segment it into 1-second pieces
        dataset_dir = fullfile(ses_dir, 'meg', ...
            sprintf('%s_%s_task-flicker_meg.ds', sub_str, ses_str));
        cfg = [];
        cfg.dataset = dataset_dir;
        cfg.trialfun             = 'ft_trialfun_general';
        cfg.trialdef.triallength = 1;                      % duration in seconds
        cfg.trialdef.ntrials     = inf;                    % number of trials, inf results in as many as possible
        cfg                      = ft_definetrial(cfg);
        
        data_segmented           = ft_preprocessing(cfg);

        cfg = [];
        cfg.channel = 'M****'; % Only meg sensors
        cfg.method   = 'summary';
        %cfg.ylim     = [-1e-12 1e-12];
        dummy        = ft_rejectvisual(cfg, data_segmented);
        
        % Update book keeping
        sub_inspection_bookkeping.meg = true;
    end

    % Update and save book keeping
    inspection_bookkeeping.(sprintf('sub%03d', sub)) = sub_inspection_bookkeping;
    save ('inspection_bookkeeping.mat', 'inspection_bookkeeping')
end