#! /bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

# default argument value
worktree_target=""
verbose=0

# read arguments from getopts https://wiki.bash-hackers.org/howto/getopts_tutorial https://stackoverflow.com/a/14203146/3706717
while getopts "w:v" opt; do
    case "$opt" in
    h)
        echo "usage: [-w worktree_target] [-v]"
        echo "  -w worktree_target = directory of worktree to be made relative (will default to current directory if not supplied"
        echo "  -v = verbose"
        exit 0
        ;;
    w)  worktree_target=$OPTARG
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





repository_target="$(cat $worktree_target/.git)" # read content of file in "$worktree_target/.git", it should contain "gitdir: /home/kristian/repos/myrepo/.git/worktrees/myrepo_worktree1"
repository_target="${repository_target/gitdir: /}" # replace "gitdir: " with ""
repository_target=`readlink -f $repository_target` # get absolute path
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


