clear; clc;

%% Setup and flagging behaviour
% Specify which subjects to process and which curration
% steps to complete

subs = 1:30;

conv_source_to_raw1_flag = true; % Whether or not to convert source to raw1
conv_raw1_to_raw2_flag = true; % whether or not to convert raw1 to raw2

overwrite_flags = [];
overwrite_flags.anat = false; % Whether or not to overwrite MRI if it exists
overwrite_flags.polhemous = false; % Whether or not to overwrite Polhemous
overwrite_flags.meg = false; % Whether or not to overwrite MEG
overwrite_flags.eyetrack = false; % Whether or not to overwrite eytrack
overwrite_flags.beh = false; % Whether or not to overwrite behaviour

%% setup
project_dir = fullfile('/project', '3031004.01');
repo_dir = fullfile(project_dir, 'meg-ahat');

% Add util dir to path
util_dir = fullfile(repo_dir, 'util');
addpath(util_dir);

% Set pilot data directory
data_dir = fullfile(project_dir, 'data');
diaryfile = fullfile(data_dir, 'data_curration.log');

if (exist(diaryfile, 'file'))
    delete(diaryfile);
end

diary (diaryfile)

% Configure fieldtrip
configure_ft


%% BIDSify data

% Set directories
source_dir = fullfile(data_dir, 'source');
raw1_dir = fullfile(data_dir, 'raw1');
raw2_dir = fullfile(data_dir, 'raw2');

%% Specify some general information
general_cfg = [];
general_cfg.bidsroot = raw1_dir;
general_cfg.InstitutionName             = 'Radboud University';
general_cfg.InstitutionalDepartmentName = 'Donders Institute for Brain, Cognition and Behaviour';
general_cfg.InstitutionAddress          = 'Kapittelweg 29, 6525 EN, Nijmegen, The Netherlands';
general_cfg.dataset_description.Name                = 'MEG-AHAT: Propagation of spectral flicker during visual- and non-visual cognitive tasks';
general_cfg.dataset_description.License             = 'RU-DI-HD-1.0';
general_cfg.dataset_description.Authors             = 'Henney MA, Spaak E,Oostenveld R';
general_cfg.dataset_description.EthicsApprovals     = 'DCCN 3031004.01';

%% Make conversions

for s = 1:numel(subs)
    sub = subs(s);

    % Convert source to raw 1
    if conv_source_to_raw1_flag
        convert_source_to_raw1(sub, general_cfg, source_dir, overwrite_flags)
    end

    if conv_raw1_to_raw2_flag
        convert_raw1_to_raw2(sub, general_cfg, raw1_dir, raw2_dir, [])

        % Update project-wide sidecars
        copyfile(fullfile(raw1_dir, 'dataset_description.json'), ...
            fullfile(raw2_dir, 'dataset_description.json'))
        copyfile(fullfile(raw1_dir, 'participants.tsv'), ...
            fullfile(raw2_dir, 'participants.tsv'))

    end


end

% Write entries to the .bidsignore file
bidsignore_text = ['*eyetrack.tsv' newline '*eyetrack.json' newline];

% Specify the destination
bidsignore_file = fullfile(general_cfg.bidsroot, '.bidsignore');

% Write the file
fid = fopen(bidsignore_file, 'w');
fprintf(fid, '%s', bidsignore_text);

diary off