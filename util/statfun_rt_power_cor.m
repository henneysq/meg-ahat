function [s, cfg] = statfun_rt_power_cor(cfg, dat)
    
    % For now, let DAT be the struct of single trial source power estimates,
    % and reshape that into a matrix
    n_trials = length(dat.trial);
    n_voxels = size(dat.trial(1).pow,1);
    pow = zeros(n_voxels, n_trials);
    for t = 1:n_trials
        pow(:, t) = dat.trial(t).pow;
    end
    
    % Get reaction times
    rt = dat.trialinfo(:, 7);
    
    % Remove reaction times == -2 (did not respond in time)
    msk = rt ~= -2;
    rt = rt(msk);
    % Also remove them from the pow, then mask the inside
    pow = pow(:,msk);
    % tmp = pow(dat.inside,:);
    
    
    % Regress source power to reaction time
    s = [];
    s.stat = NaN(n_voxels,1);
    x = rt;
    for i = 1:n_voxels
        if not(dat.inside(i))
            continue
        end
        y = pow(i,:);
        X = [ones(length(x), 1) x];
        b = X\y';
        s.stat(i) = b(2);
    end
