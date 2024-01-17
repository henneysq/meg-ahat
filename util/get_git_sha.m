function git_sha = get_git_sha
    repo = gitrepo('/project/3031004.01/meg-ahat/');
    git_sha_long = char(repo.LastCommit.ID);
    git_sha = git_sha_long(1:8);
end