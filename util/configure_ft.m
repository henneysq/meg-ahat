%%
fieldtrip_dir = '~/matlab/fieldtrip';
addpath(fieldtrip_dir);
ft_defaults
%%
repo = gitrepo(fieldtrip_dir);
fprintf('OBS.: Load Fieldtrip at Commit: %s\n', repo.CurrentBranch.LastCommit.ID)