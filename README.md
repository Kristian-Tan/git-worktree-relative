# git-worktree-relative


## Background

- Feature request from 2016 but not implemented yet (as in 2021-03-01) https://public-inbox.org/git/CACsJy8AZVWNQNgsw21EF2UOk42oFeyHSRntw_rpeZz_OT1xdMw@mail.gmail.com/T/
- There are other solution which use go, but not everyone want to install go and compile their own tools (or maybe just cannot be bothered to) https://github.com/harobed/fix-git-worktree
- Even if this feature is not really popular https://stackoverflow.com/questions/66635437/git-worktree-with-relative-path only have 30-50 views (as in 2021-03-01)


## My solution

- Bash script to replace (with sed) the content of `{worktree}/.git file` and `{repo}/.git/worktrees/{wtname}/gitdir`
- Why bash: almost everyone who use git will use it in some kind of bash-shell-like environment (ex: bash shell in linux, git bash in windows)
- Requirements: 
  - `cat`
  - `echo`
  - `readlink`
  - `realpath` (GNU utility)
  - `sed`
  - `pwd`
  - bash shell parameter expansion `"${variablename/replacefrom/replaceto}"` https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion


## Usage

- Execute the script in your worktree (or supply the worktree directory path in -w options)
- It will read path to repository from `{worktree}/.git` file
- Options:
  - `-v` = verbose
  - `-w worktree_target` = worktree directory to be made relative, if not set, it will default to current directory
  - `-h` = show help


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


## Contributing

- Feel free to create issue, pull request, etc if there's anything that can be improved


## Credits

- Bash implementation of strpos and substr by BR0kEN- (https://gist.github.com/BR0kEN-/a84b18717f8c67ece6f7)


