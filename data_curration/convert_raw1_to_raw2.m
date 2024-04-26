function convert_source_to_raw1(sub, general_cfg, raw1_dir, raw2_dir, overwrite_cfg)

    sub_str = sprintf('sub-%03d', sub);
    ses_str = 'ses-001';
    sub_raw1_dir = fullfile(raw1_dir, sub_str);
    sub_raw2_dir = fullfile(raw2_dir, sub_str);
        
    % First, copy the entire subject directory to raw2; then make
    % modifications there
    copyfile (sub_raw1_dir, sub_raw2_dir);


    % Specify the missing subject specific details
    general_cfg.sub = sprintf('%03d', sub);

    % Evaluate details
    data_details
    
    % #################################
    % ############## MEG ##############

    % Tasks in the two runs
    tasks = {
      'visualattention';
      'workingmemory'
    };
    
    dataset_dir = fullfile(sub_raw2_dir, ses_str, 'meg', ...
        sprintf('%s_%s_task-flicker_meg.ds', sub_str, ses_str))
    
    cfg = [];
    cfg.dataset = dataset_dir;
    
    % read the header information and the events from the meg data
    hdr   = ft_read_header(cfg.dataset);
    event = ft_read_event(cfg.dataset, 'readbids', 'yes');
    
    % search for "trigger" events
    mask = find(strcmp('UPPT001', {event.type}));
    event = event(mask);

    % Remove duplicate neighbouring events
    event = remove_duplicate_events(event);

    % Fix staircasing of trigger 1 and 2
    event = fix_initial_staircase(event);

    % Calculate timestamp
    %event.timestamp = repmat(-1, size(event, 1), 1);
    %timestamp = event.sample / hdr.Fs;


    % get the event contets
    value  = [event.value]';
    %timestamp = [event.timestamp]';
    sample = [event.sample]';
    timestamp = sample / hdr.Fs;

    if sum(data_details_cfg.old_trigger_subs == sub)

        mask_start_events = find(value == 1);
        mask_end_events = find(bitor(value==8, value==11));
        
        
        % Look for the greatest jump in inital triggers to find the seperation
        % between runs
        if numel(mask_start_events) > 2
            dif = mask_start_events(2:end) - mask_start_events(1:end-1);
            indices = 1:numel(mask_start_events)-1;
            
            start_run_1_idx = mask_start_events(indices(dif == max(dif)));
            start_run_2_idx = mask_start_events(end); %indices(dif == max(dif)) + 1);%mask_start_events(circshift(dif == max(dif),1));
        else
            start_run_1_idx = mask_start_events(1);
            start_run_2_idx = mask_start_events(2);
        end
        
        end_run1_candidates = mask_end_events(mask_end_events > start_run_1_idx);
        end_run_1_idx = end_run1_candidates(1);
        
        end_run2_candidates = mask_end_events(mask_end_events > start_run_2_idx);
        if isempty(end_run2_candidates)
            end_run_2_idx = length(event);
        else
            end_run_2_idx = end_run2_candidates(1);
        end
    else
        start_run_1_idx = find(value == 1);
        start_run_2_idx = find(value == 21);
        end_run_1_idx = find(bitor(value==8, value==11));
        end_run_2_idx = find(bitor(value==28, value==31));

    end

    assert(start_run_1_idx < start_run_2_idx && end_run_1_idx < end_run_2_idx)

    % Some recordings were missing the final trigger for run2;
    % in that case, use the final element of the events as indicator
    % if sum(value==8) == 2
    %     end_run_1_idx = mask_end_events(1);
    %     end_run_2_idx = mask_end_events(2);
    % elseif sum(value==8) == 1
    %     end_run_1_idx = mask_end_events(1);
    %     end_run_2_idx = length(event);
    % end

    % For subject 19, reverse the index order, as WM experiment was run
    % before the VA experiment
    if sub == 19
        tmp = start_run_1_idx;
        start_run_1_idx = start_run_2_idx;
        start_run_2_idx = tmp;
        tmp = end_run_1_idx;
        end_run_1_idx = end_run_2_idx;
        end_run_2_idx = tmp;
    end

    
    % Iterate over the two runs
    for run = [1 2]

        % Prepare some lists for book keeping
        sample_list = [];       % Sample no
        onset_list = [];        % Onset time
        duration_list = [];     % Duration
        rt_list = [];           % reaction time (dummy for now)
        valid_trial_list = [];  % keep track of skipped trials

        for j = 3:(length(value)-3)
            % Manage the scope based on run number
            if run == 1
                if j < start_run_1_idx
                    continue
                elseif j > end_run_1_idx
                    break
                end
            elseif run == 2
                if j < start_run_2_idx
                    continue
                elseif j > end_run_2_idx
                    break
                end
            else
                error('Value error: Run must be an integer in {1,2}.')
            end
        
            % % Trial trigger structure
            % try
            %     trg0 = value(j - 1); % quick / Catch trial (9/10)
            % catch ME
            %     if (strcmp(ME.identifier, 'MATLAB:badsubscript'))
            %         trg0 = 0;
            %     end
            % end
            trg_qc = value (j - 2); % quick / Catch trial (9/10) - or initial trigger (1)
            trg0 = value(j - 1); % rest trigger (2)
            trg1 = value(j); % start_of_trial (3)
            trg2 = value(j + 1); % cue / sum (4)
            trg3 = value(j + 2); % fixation grating / fixation cross (5)
            trg4 = value(j + 3); % discrimination grating / result (6)
            
            
            if not(trg1 == 3)
                % Fix events to start-of-trial trigger (3)
                continue
            end

            if trg_qc == 9
                % Ignore quick trials
                valid_trial_list = [valid_trial_list 0];
                continue
            else
                valid_trial_list = [valid_trial_list 1];
            end

            % Assert that the trial / event structure is correct -
            % otherwise we want to figure out why not
            if (trg0 == 2 && trg2==4 && trg3==5 && xor(trg_qc == 10, trg4 == 6))
                %
            else
                error("This part of the code should not be reached")
            end
            % Set the trial to begin at the cue / sum (4) 
            trlbegin = sample(j + 1);
            onset = timestamp(j + 1);

            % .. and end at the discrimination grating / results,
            % thus getting the duration
            duration = timestamp(j + 3) - onset;
            
            % Calculate response time if relevant
            % Let's ignore this for now and query it from the behavioural
            % log instead
            rt = -3; % Set it to a random nonsensical dummy value for now.
        
            % Append the lists for book keeping
            sample_list = [sample_list; trlbegin];
            onset_list = [onset_list; onset];
            duration_list = [duration_list; duration];
            rt_list = [rt_list; rt];
        end

        % Load behavioural data events
        % Specify source path
        beh_dir = fullfile(sub_raw2_dir, ses_str, 'beh');
        filename = sprintf('%s_%s_run-00%d_task-%s_events.tsv', sub_str, ...
            ses_str, run, tasks{run});
        beh_log_path = fullfile(beh_dir, filename);

        % Load the behavioural data as a table
        beh_log = readtable(beh_log_path, "FileType","text",'Delimiter', '\t');
        beh_log.onset = repmat(-1, size(beh_log, 1), 1);
        beh_log.duration = repmat(-1, size(beh_log, 1), 1);

        % Add a reaction time column with a dummy value (same as above)
        beh_log.rt_meg = repmat(-3, size(beh_log, 1), 1);

        %  Add sample column with dummy value
        beh_log.sample = repmat(-1, size(beh_log, 1), 1);

        % reorder columns
        beh_log = beh_log(:, [1:2 end 3:end-1]);
        
        % Create mask for non-quick trials (i.e. valid trials)
        valid_trial_list = boolean(valid_trial_list);
        masked_beh_log = beh_log(valid_trial_list, :);

        % Replace column values
        masked_beh_log.onset = onset_list; % (1:height(beh_log));
        masked_beh_log.duration = duration_list; % (1:height(beh_log));
        masked_beh_log.sample = sample_list; % (1:height(beh_log));
        masked_beh_log.rt_meg = rt_list; % (1:height(beh_log));

        % Put masked table back in main table
        beh_log(valid_trial_list, :) = masked_beh_log;
        
        % Save updated table
        writetable(beh_log, beh_log_path, 'filetype','text', 'delimiter','\t')

    end


    % Iterate over MEG _events.tsv and enrich with BEH info
    event = struct2table(event);

    event.trial_number = repmat(-1, height(event), 1);
    event.block_number = repmat(-1, height(event), 1);
    event.stimulus_condition = repmat("n/a", height(event), 1);
    event.task = repmat("n/a", height(event), 1);
    event.task_congruence = repmat("n/a", height(event), 1);
    event.task_difficulty = repmat("n/a", height(event), 1);
    event.sum_correctnes = repmat("n/a", height(event), 1);
    event.response = repmat("n/a", height(event), 1);
    event.reaction_time = repmat(-3, height(event), 1);
    event.rt_meg = repmat(-3, height(event), 1);
    event.duration = repmat(-3, height(event), 1);


    for run = [1 2]
        filename = sprintf('%s_%s_run-00%d_task-%s_events.tsv', sub_str, ...
            ses_str, run, tasks{run});
        beh_log_path = fullfile(beh_dir, filename);
        beh_log = readtable(beh_log_path, "FileType","text",'Delimiter', '\t');
    
        meg_iterator = 1;
        beh_iterator = 1;

        while beh_iterator <= height(beh_log)
            beh_sample = beh_log.sample(beh_iterator);
            meg_sample = event.sample(meg_iterator);

            if beh_sample == -1
                beh_iterator = beh_iterator + 1;
            elseif (beh_sample == meg_sample)
                event.trial_number(meg_iterator) = beh_log.trial_number(beh_iterator);
                event.block_number(meg_iterator) = beh_log.block_number(beh_iterator);
                event.stimulus_condition(meg_iterator) = beh_log.stimulus_condition(beh_iterator);
                event.response(meg_iterator) = beh_log.response(beh_iterator);
                event.reaction_time(meg_iterator) = beh_log.reaction_time(beh_iterator);
                event.rt_meg(meg_iterator) = beh_log.rt_meg(beh_iterator);
                event.duration(meg_iterator) = beh_log.duration(beh_iterator);
                
                if run == 1
                    event.task(meg_iterator) = beh_log.task(beh_iterator);
                    event.task_congruence(meg_iterator) = beh_log.task_congruence(beh_iterator);
                elseif run == 2
                    event.task_difficulty(meg_iterator) = beh_log.task_difficulty(beh_iterator);
                    event.sum_correctnes(meg_iterator) = beh_log.presented_sum_correctness(beh_iterator);
                end

                beh_iterator = beh_iterator + 1;
            end

            meg_iterator = meg_iterator + 1;
    
        end
    end

    % Save updated table
    event = renamevars(event, ["timestamp"], ["onset"]);
    event = event(:, [6 5 3 1 2 4 7:end]);

    meg_events_fname = fullfile(sub_raw2_dir, ses_str, 'meg', ...
        sprintf('%s_%s_task-flicker_events.tsv', sub_str, ses_str));

    writetable(event, meg_events_fname, 'filetype','text', 'delimiter','\t')

end

function event = fix_initial_staircase(event)
    inits = find([event.value]==1);

    for init=inits
        if sum([event(init:init+2).value] == [1 2 3]) == 2
            event(init+1).value = 2;
        elseif sum([event(init:init+2).value] == [1 2 3]) == 3
            % pass
        elseif sum([event(init:init+3).value] == [1 9 2 3]) == 4
            % pass
        elseif sum([event(init:init+3).value] == [1 9 3 3]) == 4
            event(init+2).value = 2;
        elseif sum([event(init:init+3).value] == [1 10 2 3]) == 4
            % pass
        elseif sum([event(init:init+3).value] == [1 10 3 3]) == 4
            event(init+2).value = 2;
        else
            error("Unexpected initail trigger configuration")
        end
    end
end

function event = remove_duplicate_events(event)
    % tolerance for neighbours
    tol = 3; % [ssamples]

    mask = ones(numel(event), 1);

    for i = 2:numel(event)
        if event(i).value == event(i - 1).value && (event(i).sample - event(i - 1).sample) < tol
            mask(i + -1) = 0;
        end
    end

    mask = boolean(mask);
    event = event(mask);
end
