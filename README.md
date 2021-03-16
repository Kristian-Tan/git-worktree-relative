# git-worktree-relative


## Background

- Feature request from 2016 but not implemented yet (as in 2021-03-01) https://public-inbox.org/git/CACsJy8AZVWNQNgsw21EF2UOk42oFeyHSRntw_rpeZz_OT1xdMw@mail.gmail.com/T/
- There are other solution which use go, but not everyone want to install go and compile their own tools (or maybe just cannot be bothered to) https://github.com/harobed/fix-git-worktree
- Even if this feature is not really popular https://stackoverflow.com/questions/66635437/git-worktree-with-relative-path only have 30-50 views (as in 2021-03-01)


## My solution

- Bash script to replace (with sed) the content of `{worktree}/.git file` and `{repo}/.git/worktrees/{wtname}/gitdir`
- Why bash: almost everyone who use git will use it in some kind of bash-shell-like environment (ex: bash shell in linux, git bash in windows)
- Requirements (should be available on every bash shell):
  - `cat`
  - `echo`
  - `readlink`
  - `realpath` (GNU utility)
  - `sed`
  - `pwd`
  - bash shell parameter expansion `${parameter/pattern/string}` and `${parameter%%word}` https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion


## Usage

- Execute the script in your worktree (or supply the worktree directory path in -w options)
- It will read path to repository from `{worktree}/.git` file
- Options:
  - `-v` = verbose
  - `-w worktree_target` = directory of worktree to be made relative (will default to current directory if not supplied)
  - `-r repository_target` = directory of repository (including worktree directory inside .git, will be read from {worktree_target}/.git file if not supplied)
  - `-h` = show help
- This solution works for broken link (ex: worktree directory moved OR parent git directory moved): just supply the repository path in `-r repositor_target` flag
- This solution works for worktree inside parent repository


## Installation

- installation for all users:
  - copy `git-worktree-relative.sh` to `/usr/bin` (you can also remove the extension)
  - give other user permission to execute it
  - example:
  ```bash
    cp git-worktree-relative.sh /usr/bin/git-worktree-relative
    chown root:root /usr/bin/git-worktree-relative
    chmod 0755 /usr/bin/git-worktree-relative
  ```
- installation for one user:
  - copy it to any directory that is added to your PATH variable


## TODO

- verbose output
- detect if the sed replace is a success or not (see exit code or just grep the file before and after replacement)
- automatic installation script
- revert back relative path to absolute path
- automated test with github runner

## Contributing

- Feel free to create issue, pull request, etc if there's anything that can be improved


## Credits

- [REMOVED] Bash implementation of strpos and substr by BR0kEN- (https://gist.github.com/BR0kEN-/a84b18717f8c67ece6f7)
- StackOverflow user `usretc` for advise in https://stackoverflow.com/q/66635437/3706717 

