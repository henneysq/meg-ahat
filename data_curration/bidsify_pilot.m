% CURRATION OF PILOT DATA - PART 1
% Convert source data to raw data
%
% This module converts source pilot data to a BIDS-compliant
% version with minimal changes (/raw1 directory).
% Thus, no changes are made to contents of the source files,
% and behavioural data (both eye-tracking and presentation-log files
% recorded along with MEG) is saved to the /beh directory.
%
% In part 2, behevioural data recorded along with MEG
% will be moved to the /meg directory, and files will
% be enriched and aligned in time.


%% Add util dir to path
addpath('/project/3031004.01/meg-ahat/util')

%% Setup Fieldtrip
configure_ft

%% Set pilot data directory
data_dir = '/project/3031004.01/pilot-data';

% Sebject (defined as cell array for future compatibility)
subj = {
  '099'
  };

% Tasks in the two runs
tasks = {
  'visual';
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
    head_pos_file = sprintf('sub-%s.pos', subj{subindx})
    source_ses1_dir = sprintf('%s/source/sub-%s/ses-001/', data_dir, subj{subindx});
    head_pos_d = strcat(source_ses1_dir, head_pos_file);
    
    % Specify destination file path
    head_pos_file_raw1 = sprintf('sub-%s_ses-001_headshape.pos', subj{subindx})
    source_ses1_raw1_dir = sprintf('%s/sub-%s/ses-001/', general_cfg.bidsroot, subj{subindx});
    head_pos_raw1_d = strcat(source_ses1_raw1_dir, head_pos_file_raw1);
    
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
        cfg.dataset_description.BIDSVersion = 'unofficial extension';
        cfg.method    = 'convert'; % the eyelink-specific format is not supported, convert it to plain TSV
        cfg.dataset = fullfile(d.folder, d.name);
        cfg.datatype  = 'eyetracker';
        cfg.suffix = 'meg';
        cfg.Manufacturer          = 'SR Research';
        cfg.ManufacturerModelName = 'Eyelink 1000';
        cfg.TaskDescription = 'The experiment consisted of visual flicker stimulation combined with a visual attention discrimination task and an arithmetic task.';
        cfg.task = 'flicker';
        
        % convert the data
        cfg.sub = subj{subindx};
        cfg.ses = sprintf('00%d', sesindx);
        data2bids(cfg);

        %
        % Iterate over runs
        %
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
            
            % Specify the output path in the raw1 directory
            out_dir = sprintf('%s/sub-%s/ses-00%d/beh/', general_cfg.bidsroot, subj{subindx}, sesindx);
            out_file = sprintf('sub-%s_ses-00%d_run-00%d_beh.tsv', subj{subindx}, sesindx, runindx);
            out_d = fullfile(strcat(out_dir, out_file));
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
            out_json_file = sprintf('sub-%s_ses-00%d_run-00%d_beh.json', subj{subindx}, sesindx, runindx);
            out_json_d = fullfile(strcat(out_dir, out_json_file));
            % Write the file
            fid = fopen(out_json_d,'w');
            fprintf(fid,'%s',json_txt);
            fclose(fid);
    
        end % for each run      
    end % for each ses  
end % for each subject