%
% Module for extracting the trial numbers (0-indexed from python)
% from data before and after artefact and trial rejection
% and save these along with the rejected trial numbers
%

subjects = [8 9 11 13 17 18 21:23 25 27:30];

addpath('/project/3031004.01/meg-ahat/util')
addpath('/project/3031004.01/meg-ahat/analysis')

% Define directories
data_dir = '/project/3031004.01/data/';
raw2_dir = fullfile(data_dir, 'raw2');
derivatives_dir = fullfile(data_dir, 'derivatives');

trl_mgmt = [];

for sub = subjects
    sub_str = sprintf('sub%03d', sub)
    trl_mgmt.(sub_str) = [];
    trl_mgmt.(sub_str).va = [];
    trl_mgmt.(sub_str).wm = [];

    % Speciffy subject specific dirs
    deriv_meg_dir = fullfile(derivatives_dir, sprintf('sub-%03d', sub), '/ses-001/meg/');
    
    tasks = ["va", "wm"];
    
    for run = [1 2] 
        task = tasks(run);
    
        fname = sprintf('data_pca_%s.mat', task);
        ar_source = fullfile(deriv_meg_dir, fname);
        load (ar_source)

        switch task
            case "va"
                data_pca = data_pca_va;
            case "wm"
                data_pca = data_pca_wm;
        end

        trials_before_rej   = data_pca.cfg.previous{1}.previous.previous.previous{1}.trl(:, 4);
        trials_after_rej    = data_pca.trialinfo(:, 1);
        rejected_trials     = setdiff(trials_before_rej, trials_after_rej);
        
        trl_mgmt.(sub_str).(task).trials_before_rej = trials_before_rej';
        trl_mgmt.(sub_str).(task).trials_after_rej = trials_after_rej';
        trl_mgmt.(sub_str).(task).rejected_trials = rejected_trials';
    end
end

encoded_json = clean_json_txt(jsonencode(trl_mgmt, PrettyPrint=true));
json_out = fullfile(derivatives_dir, 'trial_rejections.json');
fid=fopen(json_out, 'w');
fprintf(fid, encoded_json);


function txt = clean_json_txt(txt)

    txt = regexprep(txt,',\s+(?=\d)',','); % , white-spaces digit
    txt = regexprep(txt,',\s+(?=-)',','); % , white-spaces minussign
    txt = regexprep(txt,'[\s+(?=\d)','['); % [ white-spaces digit
    txt = regexprep(txt,'[\s+(?=-)','['); % [ white-spaces minussign
    txt = regexprep(txt,'(?<=\d)\s+]',']'); % digit white-spaces ]

end