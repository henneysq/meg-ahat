clear; clc;

subs = [1:7 10 12];

overwrite_cfg = [];
overwrite_cfg.anat = false;
overwrite_cfg.polhemous = false;
overwrite_cfg.meg = false;
overwrite_cfg.eyetrack = false;
overwrite_cfg.beh = false;

%% setup
project_dir = fullfile('/project', '3031004.01');
repo_dir = fullfile(project_dir, 'meg-ahat');

% Add util dir to path
util_dir = fullfile(repo_dir, 'util');
addpath(util_dir);

% Set pilot data directory
data_dir = fullfile(project_dir, 'data');
diaryfile = fullfile(data_dir, 'source_to_raw1.log');

if (exist(diaryfile, 'file'))
    delete(diaryfile);
end

diary (diaryfile)

% Configure fieldtrip
configure_ft


%% BIDSify data

% Specify some general information
source_dir = fullfile(data_dir, 'source');
raw1_dir = fullfile(data_dir, 'raw1');

general_cfg = [];
general_cfg.bidsroot = raw1_dir;
general_cfg.InstitutionName             = 'Radboud University';
general_cfg.InstitutionalDepartmentName = 'Donders Institute for Brain, Cognition and Behaviour';
general_cfg.InstitutionAddress          = 'Kapittelweg 29, 6525 EN, Nijmegen, The Netherlands';
general_cfg.dataset_description.Name                = 'MEG-AHAT: Propagation of spectral flicker during visual- and non-visual cognitive tasks';
general_cfg.dataset_description.License             = 'RU-DI-HD-1.0';
general_cfg.dataset_description.Authors             = 'Henney MA, Spaak E,Oostenveld R';
general_cfg.dataset_description.EthicsApprovals     = 'DCCN 3031004.01';


for s = 1:numel(subs)
    sub = subs(s);
    
    % Evaluate subject specific details script
    %details = sprintf('details_sub%03d', sub);
    %eval(details);

    convert_source_to_raw1(sub, general_cfg, source_dir, overwrite_cfg)

end

% Write entries to the .bidsignore file
bidsignore_text = ['*eyetrack.tsv' newline '*eyetrack.json' newline];

% Specify the destination
bidsignore_file = fullfile(general_cfg.bidsroot, '.bidsignore');

% Write the file
fid = fopen(bidsignore_file, 'w');
fprintf(fid, '%s', bidsignore_text);

diary off