function [trl, event] = pilot_definetrial_va(cfg);
    
    % read the header information and the events from the data
    hdr   = ft_read_header(cfg.dataset);
    event = ft_read_event(cfg.dataset);
    
    run = cfg.run;
    ses = cfg.ses;
    sub = cfg.sub;
    
    % search for "trigger" events
    mask = find(strcmp('UPPT001', {event.type}));
    value  = [event(mask).value]';

    % Look for the first occurence of the "initial-trigger" = 1.
    % We need a heuristic to deal with multiple subsequent (at failed init)
    mask_start_events = find(value == 1);

    % Look for the greatest jump in inital triggers to find the seperation
    % between runs
    if numel(mask_start_events) > 2
        dif = mask_start_events(2:end) - mask_start_events(1:end-1);
        start_run_2_idx = mask_start_events(circshift(dif == max(dif),1));
    else
        start_run_2_idx = mask_start_events(2);
    end

    sample = [event(mask).sample]';
    
    % determine the number of samples before and after the trigger
    pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
    posttrig =  round(cfg.trialdef.post * hdr.Fs);


    % Load the enriched BIDS events file from raw2
    meg_dir = fullfile(cfg.dataset, '..');
    bids_events = readtable(fullfile(meg_dir, ...
        sprintf('sub-%s_ses-00%d_task-flicker_events.tsv', sub, ses)), ...
        "FileType","text",'Delimiter', '\t');
    bids_events = bids_events(mask, :);

    % Make map from string-represented condition to integer
    stim_map = dictionary(["con", "isf", "strobe"], [1, 2, 3]);
    task_map = dictionary(["left", "right"], [1, 2]);
    
    % look for the combination of a trigger "5" followed by a trigger "6"
    % for each trigger except the last one
    trl = [];
    for j = 1:(length(value)-1)
        if run == 1
            if j >= start_run_2_idx
                break
            end
        elseif run == 2
            if j < start_run_2_idx
                continue
            end
        else
            error('Value error: Run must be an integer in {1,2}.')
        end
        trg1 = value(j);
        trg2 = value(j+1);
        if trg1==5 && (trg2==6 || trg2==2 || trg2==8 || trg2==9 || trg2==10)
          trlbegin = sample(j) + pretrig;
          
          trlend = sample(j+1) + posttrig;
          

          offset   = pretrig;
          python_trial_number = str2double(bids_events.trial_number{j});
          block_number = str2double(bids_events.block_number{j});
          condition = stim_map(bids_events.stimulus_condition{j});
          task = task_map(bids_events.task{j});
          task_congruence = str2double(bids_events.task_congruence{j});
          response  = str2double(bids_events.response{j});
          rt  = bids_events.reaction_time(j);
          rt_meg  = bids_events.rt_meg(j);
          newtrl   = [trlbegin trlend, offset, python_trial_number, ...
                    block_number, condition, task, task_congruence, ...
                    response, rt, rt_meg];

          trl      = [trl; newtrl];
        end
    end

    % Add trial number (matlab 1-indexed - remember python 0-indexed)
    (1:size(trl, 1))';
    