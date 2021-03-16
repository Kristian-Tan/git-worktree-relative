#! /bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# default argument value
worktree_target=""
repository_target=""
verbose=0

# read arguments from getopts https://wiki.bash-hackers.org/howto/getopts_tutorial https://stackoverflow.com/a/14203146/3706717
while getopts "w:r:v" opt; do
    case "$opt" in
    h)
        echo "usage: [-w worktree_target] [-r repository_target] [-v]"
        echo "  -w worktree_target = directory of worktree to be made relative (will default to current directory if not supplied)"
        echo "  -r repository_target = directory of repository (including worktree directory inside .git, will be read from {worktree_target}/.git file if not supplied)"
        echo "  -v = verbose"
        echo "example:"
        echo "  1) repository in /home/myuser/repo/myproject ; worktree in /home/myuser/www/myproject ; worktree is connected with repository (link is not broken)"
        echo "    cd /home/myuser/www/myproject"
        echo "    git-worktree-relative"
        echo "    OR"
        echo "    git-worktree-relative -w /home/myuser/www/myproject"
        echo "  2) repository in /home/myuser/repo/myproject ; worktree in /home/myuser/www/myproject ; worktree is NOT connected with repository (link broken)"
        echo "    cd /home/myuser/www/myproject"
        echo "    git-worktree-relative -r /home/myuser/repo/myproject/.git/worktrees/myproject"
        echo "    OR"
        echo "    git-worktree-relative -w /home/myuser/www/myproject -r /home/myuser/repo/myproject/.git/worktrees/myproject"
        echo "  to detect if link is broken, run command 'git status' in worktree directory"
        echo ""
        echo "IMPORTANT: if -r option is used, make sure to include worktree directory inside .git directory"
        echo "  CORRECT EXAMPLE: -r /home/myuser/repo/myproject/.git/worktrees/myprojectworktree"
        echo "  WRONG EXAMPLE: -r /home/myuser/repo/myproject"
        echo "  WHY IS IT IMPORTANT: a git worktree may have different name in .git directory, for example consider this setup"
        echo "    main repository: /home/myuser/repo/myproject (contains .git directory)"
        echo "    worktree 1 (for development, checked out for branch 'development'): /home/myuser/www/myproject (contains .git file)"
        echo "    worktree 2 (for production, checked out for branch 'production'): /var/www/html/myproject (contains .git file)"
        echo "  RESULT:"
        echo "    file /home/myuser/www/myproject/.git  contains 'gitdir: /home/myuser/repo/myproject' (development branch) "
        echo "    file /var/www/html/myproject/.git     contains 'gitdir: /home/myuser/repo/myproject' (production branch) "
        echo "    directory /home/myuser/repo/myproject/.git/worktrees contains 2 directory called 'myproject' and 'myproject1' "
        echo "    file /home/myuser/repo/myproject/.git/worktrees/myproject/gitdir   contains '/home/myuser/www/myproject/.git' "
        echo "    file /home/myuser/repo/myproject/.git/worktrees/myproject1/gitdir  contains '/var/www/html/myproject/.git' "
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


# substring and strpos function

# @param string $1
#   Input string.
# @param int $2
#   Cut an amount of characters from left side of string.
# @param int [$3]
#   Leave an amount of characters in the truncated string.
substr()
{
    local length=${3}

    if [ -z "${length}" ]; then
        length=$((${#1} - ${2}))
    fi

    local str=${1:${2}:${length}}

    if [ "${#str}" -eq "${#1}" ]; then
        echo "${1}"
    else
        echo "${str}"
    fi
}

# @param string $1
#   Input string.
# @param string $2
#   String that will be searched in input string.
# @param int [$3]
#   Offset of an input string.
strpos()
{
    local str=${1}
    local offset=${3}

    if [ -n "${offset}" ]; then
        str=`substr "${str}" ${offset}`
    else
        offset=0
    fi

    str=${str/${2}*/}

    if [ "${#str}" -eq "${#1}" ]; then
        return 0
    fi

    echo $((${#str}+${offset}))
}




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
string_index=`strpos "$worktree_link_content" "/.git/"` # locate index of "/.git/" in worktree_link_content string
string_cut=`substr "$worktree_link_content" "0" "$string_index"` # substring from pos 0 (start) to "/.git/"
repository_target="$string_cut" # repository_target should contain "/home/kristian/repos/myrepo"

absolute_repository=`readlink -f $repository_target` # get absolute path of repository
absolute_worktree=`readlink -f $worktree_target` # get absolute path of worktree

path_worktree_to_repo=`realpath --relative-to="$absolute_worktree" "$absolute_repository"` # get relative path from worktree to repo
path_repo_to_worktree=`realpath --relative-to="$absolute_repository" "$absolute_worktree"` # get relative path from repo to worktree

sed -i "s+$absolute_repository+$path_worktree_to_repo+g" "$absolute_worktree/.git" # replace with sed: before=absolute path to repository, after=relative path to repository, location={worktree}/.git file
sed -i "s+$absolute_worktree+$path_repo_to_worktree+g" "$worktree_link_content/gitdir" # replace with sed: before=absolute path to worktree, after=relative path to worktree, location={repo}/.git/worktrees/{wtname}/gitdir file


