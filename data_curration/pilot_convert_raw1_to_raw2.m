%% Add util dir to path
addpath('/project/3031004.01/meg-ahat/util')

%% Set pilot data directory
raw2_dir = '/project/3031004.01/pilot-data/raw2';
raw1_dir = '/project/3031004.01/pilot-data/raw1';
%%
copyfile (raw1_dir, raw2_dir);

%% Set up logging
diaryfile = strcat(raw2_dir, '/raw1_to_raw2.log');
diary (diaryfile)

%% Setup Fieldtrip
configure_ft

% Sebject (defined as cell array for future compatibility)
subj = {
  '099'
  };

ses = 1;
runindx = 1;

% Tasks in the two runs
tasks = {
  'visualattention';
  'workingmemory'
};

dataset_dir = sprintf('%s/sub-%s/ses-00%d/meg/sub-%s_ses-00%d_task-flicker_meg.ds', raw2_dir, subj{1}, ses, subj{1}, ses);
cfg = [];
cfg.dataset = dataset_dir;

%%
% read the header information and the events from the meg data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "trigger" events
mask = find(strcmp('UPPT001', {event.type}));
value  = [event(mask).value]';
mask_start_events = find(value == 1);
timestamp = [event(mask).timestamp]';
sample = [event(mask).sample]';

% look for the combination of a trigger "5" followed by a trigger "6"
% for each trigger except the last one
sample_list = [];
onset_list = [];
duration_list = [];
rt_list = [];
for j = 1:(length(value)-1)
    if not(j>1)
        continue
    end

    trg1 = value(j-1);
    trg2 = value(j);
    
    if trg1==4 && trg2==5
      trlbegin = sample(j);
      onset = timestamp(j);

      % Look ahead for the "rest" trigger (2) or final trigger (8)
      for i = 1:20
          try
            trg3 = value(j+i);
            if trg3==2 || trg3==8
                end_index = j + i;
                break
            end
          catch ME
            if (strcmp(ME.identifier, 'MATLAB:badsubscript'))
                end_index = j + i - 1;
                break
            end
          end
      end

      % find response and calculate rt
      try
          trg4 = value(j+1);
          trg5 = value(j+2);
      catch ME
          if (strcmp(ME.identifier, 'MATLAB:badsubscript'))
            break
          end
      end
      if trg4==6 % discrimination grating
        rt = -1;
        if trg5==7 % response given
            rt = timestamp(j+2) - timestamp(j+1);
        end
      else % catch trial
        rt = -2;
      end

      duration = timestamp(end_index) - onset;

      sample_list = [sample_list; trlbegin];
      onset_list = [onset_list; onset];
      duration_list = [duration_list; duration];
      rt_list = [rt_list; rt];
    end
end

%% Load behavioural data events
% Specify source path
beh_dir = sprintf('%s/sub-%s/ses-00%d/beh/', raw2_dir, subj{1}, ses);
filename = sprintf('sub-%s_ses-00%d_run-00%d_task-%s_events.tsv', subj{1}, ses, runindx, tasks{runindx});
d = dir(strcat(beh_dir, filename));
% Load the behavioural data as a table
beh_log = readtable(fullfile(d.folder, d.name), "FileType","text",'Delimiter', '\t');
beh_log.rt_meg = repmat(-3, size(beh_log, 1), 1);
beh_log.sample = repmat(-1, size(beh_log, 1), 1);
% reorder columns
beh_log = beh_log(:, [1:2 end 3:end-1]);

beh_log.onset = onset_list(1:height(beh_log));
beh_log.duration = duration_list(1:height(beh_log));
beh_log.sample = sample_list(1:height(beh_log));
beh_log.rt_meg = rt_list(1:height(beh_log));

% Save updated table
writetable(beh_log, fullfile(d.folder, d.name), 'filetype','text', 'delimiter','\t')

%% Iterate over MEG _events.tsv and enrich with BEH info

meg_events_fname = sprintf('%s/sub-%s/ses-00%d/meg/sub-%s_ses-00%d_task-flicker_events.tsv', raw2_dir, subj{1}, ses, subj{1}, ses);
meg_events = readtable(meg_events_fname, "FileType","text",'Delimiter', '\t');

meg_events.trial_number = repmat("n/a", height(meg_events), 1);
meg_events.block_number = repmat("n/a", height(meg_events), 1);
meg_events.stimulus_condition = repmat("n/a", height(meg_events), 1);
meg_events.task = repmat("n/a", height(meg_events), 1);
meg_events.task_congruence = repmat("n/a", height(meg_events), 1);
meg_events.response = repmat("n/a", height(meg_events), 1);
meg_events.reaction_time = repmat(-3, height(meg_events), 1);
meg_events.rt_meg = repmat(-3, height(meg_events), 1);


meg_iterator = 0;
beh_iterator = 1;
while beh_iterator <= height(beh_log)
    meg_iterator = meg_iterator + 1;
    
    if not(meg_events.type(meg_iterator) == "UPPT001")
        continue
    end

    beh_sample = beh_log.sample(beh_iterator);
    meg_sample = meg_events.sample(meg_iterator);

    if (beh_sample == meg_sample)
        meg_events.trial_number(meg_iterator) = beh_log.trial_number(beh_iterator);
        meg_events.block_number(meg_iterator) = beh_log.block_number(beh_iterator);
        meg_events.stimulus_condition(meg_iterator) = beh_log.stimulus_condition(beh_iterator);
        meg_events.task(meg_iterator) = beh_log.task(beh_iterator);
        meg_events.task_congruence(meg_iterator) = beh_log.task_congruence(beh_iterator);
        meg_events.response(meg_iterator) = beh_log.response(beh_iterator);
        meg_events.reaction_time(meg_iterator) = beh_log.reaction_time(beh_iterator);
        meg_events.rt_meg(meg_iterator) = beh_log.rt_meg(beh_iterator);
        meg_events.duration{meg_iterator} = beh_log.duration(beh_iterator);
        
        beh_iterator = beh_iterator + 1;
    end

end

%meg_events.trial_number = cell2mat(meg_events.trial_number);
%meg_events.block_number = cell2mat(meg_events.block_number);
%meg_events.stimulus_condition = cell2mat(meg_events.stimulus_condition);
%meg_events.task = cell2mat(meg_events.task);
%meg_events.task_congruence = cell2mat(meg_events.task_congruence);
%meg_events.response = cell2mat(meg_events.response);
%meg_events.reaction_time = cell2mat(meg_events.reaction_time);
%meg_events.rt_meg = cell2mat(meg_events.rt_meg);
%meg_events.duration = cell2mat(meg_events.duration);

% Save updated table
meg_events_fname = sprintf('%s/sub-%s/ses-00%d/meg/sub-%s_ses-00%d_task-flicker_events.tsv', raw2_dir, subj{1}, ses, subj{1}, ses);
writetable(meg_events, meg_events_fname, 'filetype','text', 'delimiter','\t')


%% Add BIDS required columns to behavioural
%log_len = size(log, 1);
%log.onset = repmat("n/a", log_len, 1);
%log.duration = repmat("n/a", log_len, 1);
%log = log(:, [end-1:end 1:end-3]);

% Specify the output path in the raw1 directory
%filename = sprintf('sub-%s_ses-00%d_run-00%d_task-%s_events', subj{1}, sesindx, runindx, tasks{runindx});
%out_file = strcat(filename, '.tsv');
%out_d = fullfile(strcat(beh_dir, out_file));
% Write the behavioural data to destination
%writetable(log,out_d, 'filetype','text', 'delimiter','\t')


%%

diary off

%%
%cfg.trialfun = 'definetrial_va';
%cfg.trialdef.pre  = 0.5;
%cfg.trialdef.post =1;
%cfg.continuous = 'yes';
%cfg = ft_definetrial(cfg);%

%%
%cfg.demean = 'yes';
%cfg.channel = 'meggrad';
%data_meg = ft_preprocessing(cfg);
%%
%cfg          = [];
%cfg.method   = 'trial';
% cfg.ylim     = [-1e-12 1e-12];
%dummy        = ft_rejectvisual(cfg, data_meg);

%%
%cfg = [];
%cfg.continuous = 'yes';
%artf = ft_databrowser(cfg, data_meg);