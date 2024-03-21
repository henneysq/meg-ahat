% CURRATION OF PILOT DATA - PART 1
% Convert source data to raw data (version 1)
%
% Raw data version 1 specs:
% This module converts source pilot data to a BIDS-compliant
% version with minimal changes (/raw1 directory).
% Thus, no changes are made to contents of the source files,
% and behavioural data (both eye-tracking and presentation-log files
% recorded along with MEG) is saved to the /beh directory.
%
% In part 2, behevioural data recorded along with MEG
% will be moved to the /meg directory, and files will
% be enriched and aligned in time.
%
% The result of this conversion is reflected in the difference
% between the organisation of /source/ and /raw1/ directories:
%
% pilot-data
% |-- raw1
% |   |-- dataset_description.json
% |   |-- participants.tsv
% |   `-- sub-099
% |       |-- ses-001
% |       |   |-- anat
% |       |   |-- beh
% |       |   |-- eyetrack
% |       |   |-- meg
% |       |   `-- sub-099_ses-001_scans.tsv
% |       |-- ses-002
% |       |   |-- beh
% |       |   |-- eyetrack
% |       |   |-- meg
% |       |   `-- sub-099_ses-002_scans.tsv
% |       `-- sub-099_sessions.tsv
% `-- source
%     `-- sub-099
%         |-- ses-001
%         |   |-- 099_1.ds
%         |   |-- behaviour
%         |   |-- pilot001_3031000.01_20231212_01.ds
%         |   |-- sub-099.pos
%         |   |-- sub-099_ses-001-eyetracking.asc
%         |   |-- sub-099_ses-001-eyetracking.edf
%         |   `-- sub-20231212T163000
%         `-- ses-002
%             |-- 099_2.ds
%             |-- behaviour
%             |-- pilot002_3031000.01_20231214_01.ds
%             |-- sub-099_ses-002-eyetracking.asc
%             `-- sub-099_ses-002-eyetracking.edf



%% Add util dir to path
addpath('/project/3031004.01/meg-ahat/util')

%% Set pilot data directory
data_dir = '/project/3031004.01/pilot-data';
diaryfile = strcat(data_dir, '/source_to_raw1.log');
diary (diaryfile)

%% Setup Fieldtrip
configure_ft

% Sebject (defined as cell array for future compatibility)
subj = {
  '099'
  };

% Tasks in the two runs
tasks = {
  'visualattention';
  'workingmemory'
};

% Specify some general information
general_cfg = [];
general_cfg.bidsroot = sprintf('%s/raw1', data_dir);
general_cfg.InstitutionName             = 'Radboud University';
general_cfg.InstitutionalDepartmentName = 'Donders Institute for Brain, Cognition and Behaviour';
general_cfg.InstitutionAddress          = 'Kapittelweg 29, 6525 EN, Nijmegen, The Netherlands';
general_cfg.dataset_description.Name                = 'MEG-AHAT: Propagation of spectral flicker during visual- and non-visual cognitive tasks';
general_cfg.dataset_description.License             = 'RU-DI-HD-1.0';
general_cfg.dataset_description.Authors             = 'Henney MA, Spaak E,Oostenveld R';
general_cfg.dataset_description.EthicsApprovals     = 'DCCN 3031004.01';

% Iterate over subjects
for subindx=1:numel(subj)
    %
    % MRI data
    %
    % Specify source file path
    d = dir(sprintf('%s/source/sub-%s/ses-001/sub-*T163000/ses-mri*/006-t1_mprage_sag_ipat2_1p0iso_20ch-head-neck/*.IMA', data_dir, subj{subindx}));
    fname = fullfile(d.folder, d.name);
    
    % Get the general information for the config
    cfg = general_cfg;
    
    % Specify the missing details
    cfg.sub = subj{subindx};
    cfg.ses = '001';
    cfg.dataset = fname;
    cfg.suffix = 'T1w';
    cfg.dataset_description.BIDSVersion = 'v1.5.0';
    
    % Convert with data2bids
    try
        data2bids(cfg);
    catch
        % this is probably because the output dataset already exists
        % this is due to running the script multiple times
        disp(lasterr)
    end

    %
    % HEAD POSITION (Polhemus)
    %
    % Specify source file path
    head_pos_file = sprintf('sub-%s.pos', subj{subindx});
    source_ses1_dir = sprintf('%s/source/sub-%s/ses-001/', data_dir, subj{subindx});
    head_pos_d = strcat(source_ses1_dir, head_pos_file);
    
    % Specify destination file path
    head_pos_file_raw1 = sprintf('sub-%s_ses-001_headshape.pos', subj{subindx});
    source_ses1_raw1_dir = sprintf('%s/sub-%s/ses-001/meg/', general_cfg.bidsroot, subj{subindx});
    head_pos_raw1_d = strcat(source_ses1_raw1_dir, head_pos_file_raw1);
    
    % Check that destination folder exists
    mkdir (source_ses1_raw1_dir)

    % Copy source to raw1 destination
    copyfile(head_pos_d, head_pos_raw1_d);

    %
    % Iterate over each session
    for sesindx=1:2
        % MEG data
        % the number 3031004.01 in the dataset name refers to the DCCN project identifier
        % all data acquisition was done using study-specific participant identifiers rather than names  
        % the CTF dataset name contains the recording date, but here we use a wildcard instead  
        
        % Specify source path
        d = dir(sprintf('%s/source/sub-%s/ses-00%d/pilot00%d_3031000.01_*_01.ds', data_dir, subj{subindx}, sesindx, sesindx));
        if isempty(d)
          continue
        else
          origname = fullfile(d.folder, d.name);
          anonname = fullfile(d.folder, sprintf('%s_%d.ds', subj{subindx}, sesindx));
          disp(anonname); % this is just an intermediate name, the final name will be assigned by data2bids
        end
        
        % Anonymise the data
        if ~isfolder(anonname)
          go_anonymiseDs(origname, anonname);
        end
        
        % Specify the configuration
        cfg = general_cfg;
        cfg.sub = subj{subindx};
        cfg.ses = sprintf('00%d', sesindx);
        cfg.dataset = anonname; % this is the intermediate name
        cfg.suffix = 'meg';
        cfg.method = 'copy'; % the original data is in a BIDS-compliant format and can simply be copied
        cfg.dataset_description.BIDSVersion = 'v1.5.0';
        cfg.TaskDescription = 'The experiment consisted of visual flicker stimulation combined with a visual attention discrimination task and an arithmetic task.';
        cfg.task = 'flicker';
        cfg.PowerLineFrequency  = 50;
        cfg.DewarPosition       = 'upright';
        cfg.SoftwareFilters     = 'n/a';
        cfg.DigitizedLandmarks  = true;
        cfg.DigitizedHeadPoints = false;
        
        % Convert to BIDS in raw1
        try
          data2bids(cfg);
        catch
          % this is probably because the output dataset already exists
          % this is due to running the script multiple times
          disp(lasterr)
        end
        
        %
        % EYE-TRACKING DATA
        %
        % Specify source data path
        d = dir(sprintf('%s/source/sub-%s/ses-00%d/sub-%s_ses-00%d-eyetracking.asc', data_dir, subj{subindx}, sesindx, subj{subindx}, sesindx));

        % Specify configuration
        cfg = general_cfg;
        cfg.dataset_description.BIDSVersion = 'v1.10.0-dev';
        cfg.method    = 'convert'; % the eyelink-specific format is not supported, convert it to plain TSV
        cfg.dataset = fullfile(d.folder, d.name);
        cfg.datatypedir  = 'beh';
        cfg.suffix = 'eyetrack';
        cfg.Manufacturer          = 'SR Research';
        cfg.ManufacturerModelName = 'Eyelink 1000';
        cfg.TaskDescription = 'The experiment consisted of visual flicker stimulation combined with a visual attention discrimination task and an arithmetic task.';
        cfg.task = 'flicker';
        cfg.EnvironmentCoordinates = 'top-left'; % verify
        %cfg.SamplingFrequency = 1000;
        cfg.SampleCoordinateUnit = 'pixel'; % verify
        cfg.SampleCoordinateSystem = 'gaze-on-screen';
        cfg.Columns = {"timestamp","eye1_x_coordinate", "eye1_y_coordinate", "eye1_pupil_size", "event_trigger"};
        cfg.AdditionalColumns = struct('event_trigger', 'Event trigger codes from BITSI');

        % convert the data
        cfg.sub = subj{subindx};
        cfg.ses = sprintf('00%d', sesindx);
        data2bids(cfg);

        % Add required columns to _events.tsv
        eyetrack_coords_file = sprintf('/sub-%s/ses-00%d/beh/sub-%s_ses-00%d_task-flicker_eyetrack.tsv', subj{subindx}, sesindx, subj{subindx}, sesindx);
        d = dir(strcat(cfg.bidsroot, eyetrack_coords_file));
        % Load the eyetrack events data as a table
        et_coords = readtable(fullfile(d.folder, d.name), 'filetype','text', 'delimiter','\t');
        et_coords = renamevars(et_coords,["Var1","Var2", "Var3", "Var4", "Var5"], ["timestamp","eye1_x_coordinate", "eye1_y_coordinate", "eye1_pupil_size", "event_trigger"]);
        %timepoints = 0:1/1000:(height(et_coords)-1)/1000;
        %et_coords.onset = timepoints';
        et_coords.timestamp = et_coords.timestamp - et_coords.timestamp(1) + 1;
        %et_coords.duration = repmat("n/a", height(et_coords), 1);
        %et_coords = et_coords(:, [end-1:end 1:end-3]);
        writetable(et_coords, fullfile(d.folder, d.name), 'filetype', 'text', 'delimiter','\t')

        % Update eyetrack.json
        %fname = sprintf('/sub-%s/ses-00%d/beh/sub-%s_ses-00%d_task-flicker_eyetrack.json', subj{subindx}, sesindx, subj{subindx}, sesindx);
        %d = dir(strcat(cfg.bidsroot, fname));
        %fid = fopen(fullfile(d.folder, d.name));
        %raw = fread(fid,inf);
        %str = char(raw');
        %fclose(fid);
        %eyetrack_json = jsondecode(str);

        %
        % Iterate over runs
        %
        % First, create a /beh/ dir
        beh_dir = sprintf('%s/sub-%s/ses-00%d/beh/', general_cfg.bidsroot, subj{subindx}, sesindx);
        if not(isfolder(beh_dir))
          mkdir(beh_dir)
        end

        for runindx=1:2
            %  
            % BEHAVIOURAL DATA
            %
            % the subsequent file is in a custom tabular format

            % Specify source path
            behav_dir = sprintf('%s/source/sub-%s/ses-00%d/behaviour/', data_dir, subj{subindx}, sesindx);
            filename = sprintf('sub-%s_ses-00%d_run-00%d_experimentdata_managerdump.csv', subj{subindx}, sesindx, runindx);
            d = dir(strcat(behav_dir, filename));
            % Load the behavioural data as a table
            log = readtable(fullfile(d.folder, d.name));

            % Add BIDS required columns
            log_len = size(log, 1);
            log.onset = repmat("n/a", log_len, 1);
            log.duration = repmat("n/a", log_len, 1);
            log = log(:, [end-1:end 1:end-3]);
            
            % Specify the output path in the raw1 directory
            filename = sprintf('sub-%s_ses-00%d_run-00%d_task-%s_events', subj{subindx}, sesindx, runindx, tasks{runindx});
            out_file = strcat(filename, '.tsv');
            out_d = fullfile(strcat(beh_dir, out_file));
            % Write the behavioural data to destination
            writetable(log,out_d, 'filetype','text', 'delimiter','\t')
            
            % Make a sidecar .json file
            info = [];
            % Specify task information
            info.TaskName = tasks{runindx};
            trial = [];
            trial.Levels = [];
            % Add more details based on the run
            if runindx == 1
                trial.LongName = 'Lateralised visual attention';
                trial.Description = 'Lateralised visual attention combined with a detection tasks that is congruent or incongruent';
                trial.Levels.congruent = 'Fixation- and detection grating orientations match.';
                trial.Levels.incongruent = 'Fixation- and detection grating orientations do not match.';
            else
                trial.LongName = 'Working memory arithmetic task';
                trial.Description = 'Mental arithmetic constisting of addition of two integers with simultaneous visual stimulation';
                trial.Levels.high = 'Integers are in the range [100;500].';
                trial.Levels.low = 'Integers are in the range [1;9].';
            end
            info.trial = trial;
            % Encode the information as json
            json_txt = jsonencode(info, "PrettyPrint", true);

            % Specify the destination
            out_json_file = strcat(filename, '.json');
            out_json_d = fullfile(strcat(beh_dir, out_json_file));
            % Write the file
            fid = fopen(out_json_d,'w');
            fprintf(fid,'%s',json_txt);
            fclose(fid);
    
        end % for each run      
    end % for each ses  
end % for each subject

% Write entries to the .bidsignore file
bidsignore_text = ['*eyetrack.tsv' newline '*eyetrack.json' newline];
% Specify the destination
bidsignore_file = fullfile(strcat(general_cfg.bidsroot, '/.bidsignore'));
% Write the file
fid = fopen(bidsignore_file, 'w');
fprintf(fid, '%s', bidsignore_text);

diary off