#!/usr/bin/env bash
# Git Operations and Shortcuts

# Git status with branch info
gs() {
    git status "$@"
}

# Git add all
gaa() {
    git add --all
}

# Git commit with message
gc() {
    git commit -m "$*"
}

# Git add and commit
gac() {
    git add --all && git commit -m "$*"
}

# Git add, commit, and push
gacp() {
    git add --all && git commit -m "$*" && git push
}

# Git push
gp() {
    git push "$@"
}

# Git pull
gpl() {
    git pull "$@"
}

# Git pull with rebase
gpr() {
    git pull --rebase "$@"
}

# Git checkout
gco() {
    git checkout "$@"
}

# Git checkout new branch
gcb() {
    git checkout -b "$@"
}

# Git branch
gb() {
    git branch "$@"
}

# Git branch delete
gbd() {
    git branch -d "$@"
}

# Git branch delete force
gbD() {
    git branch -D "$@"
}

# Git diff
gd() {
    git diff "$@"
}

# Git diff cached
gdc() {
    git diff --cached "$@"
}

# Git log pretty
gl() {
    git log --oneline --graph --decorate --all "$@"
}

# Git log with stats
gls() {
    git log --stat "$@"
}

# Git stash
gst() {
    git stash "$@"
}

# Git stash pop
gstp() {
    git stash pop
}

# Git stash list
gstl() {
    git stash list
}

# Git remote
gr() {
    git remote -v
}

# Git fetch
gf() {
    git fetch --all --prune
}

# Git merge
gm() {
    git merge "$@"
}

# Git rebase
grb() {
    git rebase "$@"
}

# Git rebase interactive
grbi() {
    git rebase -i "$@"
}

# Git reset
grs() {
    git reset "$@"
}

# Git reset hard
grsh() {
    git reset --hard "$@"
}

# Git clean
gclean() {
    git clean -fd
}

# Git clone and cd
gcl() {
    git clone "$1" && cd "$(basename "$1" .git)" || return
}

# Undo last commit (keep changes)
gundo() {
    git reset --soft HEAD~1
}

# Amend last commit
gamend() {
    git commit --amend --no-edit
}

# Amend last commit with new message
gamendm() {
    git commit --amend -m "$*"
}

# Show current branch
gcurrent() {
    git branch --show-current
}

# List all branches
gba() {
    git branch -a
}

# Delete merged branches
gcleanup() {
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d
}

# Create and push new branch
gnewbranch() {
    git checkout -b "$1" && git push -u origin "$1"
}

# Git log search
glsearch() {
    git log --all --grep="$1"
}

# Show files changed in last commit
glast() {
    git diff-tree --no-commit-id --name-only -r HEAD
}

# Show authors statistics
gauthors() {
    git log --format='%aN' | sort -u
}

# Show commit count by author
gstats() {
    git shortlog -sn --all --no-merges
}

# Find commit by message
gfind() {
    git log --all --oneline --grep="$1"
}

# Show file history
ghistory() {
    git log --follow -p -- "$1"
}

# List tags
gtags() {
    git tag -l
}

# Create annotated tag
gtag() {
    git tag -a "$1" -m "$2"
}

# Push tags
gpush_tags() {
    git push --tags
}

# Show changes between branches
gcompare() {
    git diff "$1".."$2"
}

# Show files in conflict
gconflicts() {
    git diff --name-only --diff-filter=U
}

# Abort merge
gabort() {
    git merge --abort
}

# Continue rebase
gcontinue() {
    git rebase --continue
}

# Skip rebase
gskip() {
    git rebase --skip
}

# Show remote URLs
gremotes() {
    git remote -v
}

# Add remote
gaddremote() {
    git remote add "$1" "$2"
}

# Remove remote
grmremote() {
    git remote remove "$1"
}

# Sync fork with upstream
gsyncfork() {
    git fetch upstream && git checkout main && git merge upstream/main && git push
}

# Create GitHub PR (requires gh CLI)
gpr_create() {
    gh pr create "$@"
}

# List GitHub PRs
gpr_list() {
    gh pr list
}

# View GitHub PR
gpr_view() {
    gh pr view "$@"
}

# Create GitHub issue
gissue() {
    gh issue create "$@"
}

# List uncommitted changes
gchanges() {
    git status --porcelain
}

# Show ignored files
gignored() {
    git ls-files --others --ignored --exclude-standard
}

# Git blame
gblame() {
    git blame "$@"
}

# Show commit details
gshow() {
    git show "$@"
}

# Cherry pick
gcp() {
    git cherry-pick "$@"
}

# Initialize git repo
ginit() {
    git init && git add . && git commit -m "Initial commit"
}

# Clone with submodules
gclsub() {
    git clone --recurse-submodules "$@"
}

# Update submodules
gsubupdate() {
    git submodule update --init --recursive
}

# Git worktree add
gwt_add() {
    git worktree add "$@"
}

# Git worktree list
gwt_list() {
    git worktree list
}

# Git worktree remove
gwt_rm() {
    git worktree remove "$@"
}

# Show unpushed commits
gunpushed() {
    git log --branches --not --remotes --oneline
}

# Show unmerged commits
gunmerged() {
    git log --no-merges "$1"..HEAD --oneline
}

# Prune remote branches
gprune() {
    git remote prune origin
}

# Git bisect start
gbisect_start() {
    git bisect start
}

# Git bisect good
gbisect_good() {
    git bisect good
}

# Git bisect bad
gbisect_bad() {
    git bisect bad
}

# Git bisect reset
gbisect_reset() {
    git bisect reset
}

# Show config
gconfig() {
    git config --list
}

# Set user email
gemail() {
    git config user.email "$1"
}

# Set user name
gname() {
    git config user.name "$1"
}

# Show repo size
gsize() {
    git count-objects -vH
}

# Archive branch
garchive() {
    git tag "archive/$1" "$1" && git branch -d "$1"
}

# List archived branches
garchived() {
    git tag -l "archive/*"
}

# Create patch
gpatch() {
    git format-patch -1 HEAD
}

# Apply patch
gapply() {
    git apply "$1"
}

# Show commit graph
ggraph() {
    git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all
}

# Quick commit
qcommit() {
    git add . && git commit -m "Quick commit: $(date)"
}

# Save work in progress
gwip() {
    git add -A && git commit -m "WIP: work in progress"
}

# Undo work in progress
gunwip() {
    git log -1 --pretty=%B | grep -q "^WIP:" && git reset HEAD~1
}
