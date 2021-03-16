#! /bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# default argument value
worktree_target=""
repository_target=""
verbose=0

# read arguments from getopts
while getopts "hw:r:v" opt; do
    case "$opt" in
    h)
      cat << EOF
usage: [-w worktree_target] [-r repository_target] [-v]
  -w worktree_target = directory of worktree to be made relative (will default to current directory if not supplied)"
  -r repository_target = directory of repository (including worktree directory inside .git, will be read from {worktree_target}/.git file if not supplied)"
  -v = verbose"
example:"
  1) repository in /home/myuser/repo/myproject ; worktree in /home/myuser/www/myproject ; worktree is connected with repository (link is not broken)"
    cd /home/myuser/www/myproject"
    git-worktree-relative"
    OR"
    git-worktree-relative -w /home/myuser/www/myproject"
  2) repository in /home/myuser/repo/myproject ; worktree in /home/myuser/www/myproject ; worktree is NOT connected with repository (link broken)"
    cd /home/myuser/www/myproject"
    git-worktree-relative -r /home/myuser/repo/myproject/.git/worktrees/myproject"
    OR"
    git-worktree-relative -w /home/myuser/www/myproject -r /home/myuser/repo/myproject/.git/worktrees/myproject"
  to detect if link is broken, run command 'git status' in worktree directory"

IMPORTANT: if -r option is used, make sure to include worktree directory inside .git directory"
  CORRECT EXAMPLE: -r /home/myuser/repo/myproject/.git/worktrees/myprojectworktree"
  WRONG EXAMPLE: -r /home/myuser/repo/myproject"
  WHY IS IT IMPORTANT: a git worktree may have different name in .git directory, for example consider this setup"
    main repository: /home/myuser/repo/myproject (contains .git directory)"
    worktree 1 (for development, checked out for branch 'development'): /home/myuser/www/myproject (contains .git file)"
    worktree 2 (for production, checked out for branch 'production'): /var/www/html/myproject (contains .git file)"
  RESULT:"
    file /home/myuser/www/myproject/.git  contains 'gitdir: /home/myuser/repo/myproject' (development branch) "
    file /var/www/html/myproject/.git     contains 'gitdir: /home/myuser/repo/myproject' (production branch) "
    directory /home/myuser/repo/myproject/.git/worktrees contains 2 directory called 'myproject' and 'myproject1' "
    file /home/myuser/repo/myproject/.git/worktrees/myproject/gitdir   contains '/home/myuser/www/myproject/.git' "
    file /home/myuser/repo/myproject/.git/worktrees/myproject1/gitdir  contains '/var/www/html/myproject/.git' "
EOF
        exit 0
        ;;
    w)  worktree_target=$OPTARG
        ;;
    r)  repository_target=$OPTARG
        ;;
    v)  verbose=1
        ;;
    esac
done


# fill argument with default value if empty
if test "$worktree_target" = ""; then
    worktree_target=`pwd`
fi




if test "$repository_target" = ""; then
    repository_target="$(cat $worktree_target/.git)" # read content of file in "$worktree_target/.git", it should contain "gitdir: /home/kristian/repos/myrepo/.git/worktrees/myrepo_worktree1"
    repository_target="${repository_target/gitdir: /}" # replace "gitdir: " with ""
    repository_target=`readlink -f $repository_target` # get absolute path of repository (with .git/{wtname})
fi

worktree_link_content=$repository_target # worktree_link_content should contain "/home/kristian/repos/myrepo/.git/worktrees/myrepo_worktree1"
string_slash_dot_git_slash="/.git/"
repository_target="${worktree_link_content%%$string_slash_dot_git_slash*}" # remove all string after "/.git/"

absolute_repository=`readlink -f $repository_target` # get absolute path of repository
absolute_worktree=`readlink -f $worktree_target` # get absolute path of worktree

path_worktree_to_repo=`realpath --relative-to="$absolute_worktree" "$absolute_repository"` # get relative path from worktree to repo
path_repo_to_worktree=`realpath --relative-to="$absolute_repository" "$absolute_worktree"` # get relative path from repo to worktree

sed -i "s+$absolute_repository+$path_worktree_to_repo+g" "$absolute_worktree/.git" # replace with sed: before=absolute path to repository, after=relative path to repository, location={worktree}/.git file
sed -i "s+$absolute_worktree+$path_repo_to_worktree+g" "$worktree_link_content/gitdir" # replace with sed: before=absolute path to worktree, after=relative path to worktree, location={repo}/.git/worktrees/{wtname}/gitdir file


