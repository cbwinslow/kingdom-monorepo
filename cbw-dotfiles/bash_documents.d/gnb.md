# gnb - Git new branch

## Description
Creates a new git branch and switches to it in one command.

## Usage
```
gnb <branch_name>
```

## Parameters
- `branch_name` (required): Name of the new branch to create

## Examples
```
# Create and switch to feature branch
gnb feature/user-auth

# Create bugfix branch
gnb bugfix/login-error

# Create development branch
gnb dev/new-feature
```

## Notes
- Equivalent to: git checkout -b <branch_name>
- Creates branch from current HEAD

## See Also
- gcm - Quick commit
- gcp - Commit and push
- glog - View commit history
- gb - List branches (alias)
