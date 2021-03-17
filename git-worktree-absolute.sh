#! /bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# default argument value
worktree_target=""
repository_target=""
verbose=0
dry_run=0

# read arguments from getopts
while getopts "hw:r:vd" opt; do
    case "$opt" in
    h)
      cat << EOF
usage: [-w worktree_target] [-r repository_target] [-v]
  -w worktree_target = directory of worktree to be made absolute (will default to current directory if not supplied)
  -r repository_target = directory of repository (including worktree directory inside .git, will be read from {worktree_target}/.git file if not supplied)
  -v = verbose
  -d = dry_run (do not write any change, use with verbose to show what this script do)
example:
  1) repository in /home/myuser/repo/myproject ; worktree in /home/myuser/www/myproject ; worktree is connected with repository (link is not broken)
    cd /home/myuser/www/myproject
    git-worktree-absolute
    OR
    git-worktree-absolute -w /home/myuser/www/myproject
  2) repository in /home/myuser/repo/myproject ; worktree in /home/myuser/www/myproject ; worktree is NOT connected with repository (link broken)
    cd /home/myuser/www/myproject
    git-worktree-absolute -r /home/myuser/repo/myproject/.git/worktrees/myproject
    OR
    git-worktree-absolute -w /home/myuser/www/myproject -r /home/myuser/repo/myproject/.git/worktrees/myproject
  to detect if link is broken, run command 'git status' in worktree directory

IMPORTANT: if -r option is used, make sure to include worktree directory inside .git directory
  CORRECT EXAMPLE: -r /home/myuser/repo/myproject/.git/worktrees/myprojectworktree
  WRONG EXAMPLE: -r /home/myuser/repo/myproject
  WHY IS IT IMPORTANT: a git worktree may have different name in .git directory, for example consider this setup
    main repository: /home/myuser/repo/myproject (contains .git directory)
    worktree 1 (for development, checked out for branch 'development'): /home/myuser/www/myproject (contains .git file)
    worktree 2 (for production, checked out for branch 'production'): /var/www/html/myproject (contains .git file)
  RESULT:
    file /home/myuser/www/myproject/.git  contains 'gitdir: /home/myuser/repo/myproject' (development branch) 
    file /var/www/html/myproject/.git     contains 'gitdir: /home/myuser/repo/myproject' (production branch) 
    directory /home/myuser/repo/myproject/.git/worktrees contains 2 directory called 'myproject' and 'myproject1' 
    file /home/myuser/repo/myproject/.git/worktrees/myproject/gitdir   contains '/home/myuser/www/myproject/.git' 
    file /home/myuser/repo/myproject/.git/worktrees/myproject1/gitdir  contains '/var/www/html/myproject/.git' 
EOF
        exit 0
        ;;
    w)  worktree_target=$OPTARG
        ;;
    r)  repository_target=$OPTARG
        ;;
    d)  dry_run=1
        ;;
    v)  verbose=1
        ;;
    esac
done



# declare verbose output function

# @param string $1
#   Input string that should be printed if verbose is on
verbose_output()
{
    if test $verbose -eq 1; then
        { printf '%s ' "$@"; echo; } 1>&2
    fi
}


if test "$worktree_target" = ""; then
    verbose_output
    verbose_output "fill argument with default value if empty"
    worktree_target=`pwd`
fi


if test "$repository_target" = ""; then
    verbose_output
    verbose_output 'read content of file in "$worktree_target/.git", it should contain "gitdir: /home/kristian/repos/myrepo/.git/worktrees/myrepo_worktree1"'
    verbose_output "  \$ repository_target=\"\$(cat "$worktree_target"/.git)\""
    if ! repository_target=$(cat "$worktree_target"/.git); then
        echo 1>&2 "Could not read $worktree_target/.git, is this a worktree?"
        exit 1
    fi

    verbose_output
    verbose_output 'replace "gitdir: " with ""'
    verbose_output "  \$ repository_target=\"\${repository_target/gitdir: /}\""
    repository_target="${repository_target/gitdir: /}"

    verbose_output
    verbose_output 'get absolute path of repository (with .git/{wtname})'
    verbose_output "  \$ repository_target=\`readlink -f "$repository_target"\`"
    repository_target=`readlink -f "$repository_target"`
fi

verbose_output
verbose_output 'worktree_link_content should contain "/home/kristian/repos/myrepo/.git/worktrees/myrepo_worktree1"'
verbose_output "  \$ worktree_link_content=\$repository_target"
worktree_link_content=$repository_target

string_slash_dot_git_slash="/.git/"

verbose_output
verbose_output 'remove all string after "/.git/", should contain "/home/kristian/repos/myrepo"'
verbose_output "  \$ repository_target=\"\${worktree_link_content%%$string_slash_dot_git_slash*}\""
repository_target="${worktree_link_content%%$string_slash_dot_git_slash*}"

verbose_output
verbose_output 'reverse string for worktree_link_content'
verbose_output "  \$ worktree_link_content_reversed=\`echo \"$worktree_link_content\" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta'\`"
worktree_link_content_reversed=`echo "$worktree_link_content" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta'`

verbose_output
verbose_output 'reverse string for string_slash_dot_git_slash'
verbose_output "  \$ string_slash_dot_git_slash_reversed=\`echo \"$string_slash_dot_git_slash\" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta'\`"
string_slash_dot_git_slash_reversed=`echo "$string_slash_dot_git_slash" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta'`

verbose_output
verbose_output 'remove all string after (reversed)'
verbose_output "  \$ worktree_name_inside_repository_reversed=\"\${worktree_link_content_reversed%%$string_slash_dot_git_slash_reversed*}\""
worktree_name_inside_repository_reversed="${worktree_link_content_reversed%%$string_slash_dot_git_slash_reversed*}"

verbose_output
verbose_output 'reverse back: should contain "worktrees/myrepo_worktree1"'
verbose_output "  \$ worktree_name_inside_repository=\`echo \"$worktree_name_inside_repository_reversed\" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta'\`"
worktree_name_inside_repository=`echo "$worktree_name_inside_repository_reversed" | sed 's/./&\n/g' | tac | sed -e :a -e 'N;s/\n//g;ta'`

verbose_output
verbose_output 'get absolute path of repository'
verbose_output "  \$ absolute_repository=\`readlink -f "$repository_target"\`"
absolute_repository=`readlink -f "$repository_target"`

verbose_output
verbose_output 'get absolute path of worktree'
verbose_output "  \$ absolute_worktree=\`readlink -f "$worktree_target"\`"
absolute_worktree=`readlink -f "$worktree_target"`

# use echo instead of sed to write directly into file content

verbose_output
verbose_output 'overwrite {worktree_target}/.git file'
verbose_output "  \$ echo \"gitdir: $absolute_repository/.git/$worktree_name_inside_repository\" > \"$absolute_worktree/.git\""
if test $dry_run -eq 0; then
    echo "gitdir: $absolute_repository/.git/$worktree_name_inside_repository" > "$absolute_worktree/.git"
else
    verbose_output "dry run: not running operation"
fi

verbose_output
verbose_output 'overwrite {repo}/.git/worktrees/{wtname}/gitdir file'
verbose_output "  \$ echo \"$absolute_worktree/.git\" > \"$worktree_link_content/gitdir\""
if test $dry_run -eq 0; then
    echo "$absolute_worktree/.git" > "$worktree_link_content/gitdir"
else
    verbose_output "dry run: not running operation"
fi


