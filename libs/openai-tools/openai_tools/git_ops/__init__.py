"""
Git operations tools for AI agents.

Provides Git version control operations including cloning, committing,
pushing, pulling, branching, and viewing diffs and logs.
"""

from typing import List, Dict, Any, Optional
import os


def git_clone(repository_url: str, destination_path: str, branch: Optional[str] = None) -> str:
    """
    Clone a Git repository.
    
    Args:
        repository_url: URL of the Git repository to clone
        destination_path: Local path to clone the repository to
        branch: Optional specific branch to clone (default: default branch)
        
    Returns:
        Success message with the cloned repository path
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If clone fails
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    if branch:
        Repo.clone_from(repository_url, destination_path, branch=branch)
    else:
        Repo.clone_from(repository_url, destination_path)
    
    return f"Repository cloned to {destination_path}"


def git_status(repository_path: str) -> Dict[str, Any]:
    """
    Get the status of a Git repository.
    
    Args:
        repository_path: Path to the Git repository
        
    Returns:
        Dictionary containing status information (branch, modified, untracked, staged files)
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If repository is invalid
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    return {
        "branch": repo.active_branch.name,
        "is_dirty": repo.is_dirty(),
        "modified_files": [item.a_path for item in repo.index.diff(None)],
        "untracked_files": repo.untracked_files,
        "staged_files": [item.a_path for item in repo.index.diff("HEAD")],
    }


def git_commit(repository_path: str, message: str, author: Optional[str] = None) -> str:
    """
    Commit changes in a Git repository.
    
    Args:
        repository_path: Path to the Git repository
        message: Commit message
        author: Optional author name and email (format: "Name <email@example.com>")
        
    Returns:
        Success message with the commit hash
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If commit fails
    """
    try:
        from git import Repo, Actor
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    # Stage all changes
    repo.git.add(A=True)
    
    if author:
        # Parse author string
        if "<" in author and ">" in author:
            name = author.split("<")[0].strip()
            email = author.split("<")[1].split(">")[0].strip()
            actor = Actor(name, email)
            commit = repo.index.commit(message, author=actor, committer=actor)
        else:
            commit = repo.index.commit(message)
    else:
        commit = repo.index.commit(message)
    
    return f"Committed changes with hash: {commit.hexsha}"


def git_push(repository_path: str, remote: str = "origin", branch: Optional[str] = None) -> str:
    """
    Push commits to a remote Git repository.
    
    Args:
        repository_path: Path to the Git repository
        remote: Name of the remote (default: origin)
        branch: Branch to push (default: current branch)
        
    Returns:
        Success message
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If push fails
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    if branch is None:
        branch = repo.active_branch.name
    
    origin = repo.remote(name=remote)
    origin.push(branch)
    
    return f"Pushed {branch} to {remote}"


def git_pull(repository_path: str, remote: str = "origin", branch: Optional[str] = None) -> str:
    """
    Pull changes from a remote Git repository.
    
    Args:
        repository_path: Path to the Git repository
        remote: Name of the remote (default: origin)
        branch: Branch to pull (default: current branch)
        
    Returns:
        Success message with pull information
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If pull fails
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    if branch is None:
        branch = repo.active_branch.name
    
    origin = repo.remote(name=remote)
    info = origin.pull(branch)
    
    return f"Pulled changes from {remote}/{branch}"


def git_branch(
    repository_path: str,
    action: str = "list",
    branch_name: Optional[str] = None,
) -> Any:
    """
    Manage Git branches.
    
    Args:
        repository_path: Path to the Git repository
        action: Action to perform (list, create, delete, checkout)
        branch_name: Name of the branch (required for create, delete, checkout)
        
    Returns:
        List of branches for list action, success message for other actions
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If branch operation fails
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    if action == "list":
        return [branch.name for branch in repo.branches]
    elif action == "create":
        if not branch_name:
            raise ValueError("branch_name is required for create action")
        repo.create_head(branch_name)
        return f"Created branch: {branch_name}"
    elif action == "delete":
        if not branch_name:
            raise ValueError("branch_name is required for delete action")
        repo.delete_head(branch_name, force=True)
        return f"Deleted branch: {branch_name}"
    elif action == "checkout":
        if not branch_name:
            raise ValueError("branch_name is required for checkout action")
        repo.git.checkout(branch_name)
        return f"Checked out branch: {branch_name}"
    else:
        raise ValueError(f"Invalid action: {action}")


def git_diff(
    repository_path: str,
    ref1: Optional[str] = None,
    ref2: Optional[str] = None,
) -> str:
    """
    View differences in a Git repository.
    
    Args:
        repository_path: Path to the Git repository
        ref1: First reference (commit, branch, tag) to compare
        ref2: Second reference to compare (if None, compares with working directory)
        
    Returns:
        Diff output as a string
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If diff fails
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    if ref1 and ref2:
        diff = repo.git.diff(ref1, ref2)
    elif ref1:
        diff = repo.git.diff(ref1)
    else:
        diff = repo.git.diff()
    
    return diff


def git_log(
    repository_path: str,
    max_count: int = 10,
    branch: Optional[str] = None,
) -> List[Dict[str, Any]]:
    """
    View commit history in a Git repository.
    
    Args:
        repository_path: Path to the Git repository
        max_count: Maximum number of commits to return (default: 10)
        branch: Optional branch to view log for (default: current branch)
        
    Returns:
        List of commit dictionaries containing hash, author, date, and message
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If log retrieval fails
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    if branch:
        commits = list(repo.iter_commits(branch, max_count=max_count))
    else:
        commits = list(repo.iter_commits(max_count=max_count))
    
    return [
        {
            "hash": commit.hexsha,
            "short_hash": commit.hexsha[:7],
            "author": f"{commit.author.name} <{commit.author.email}>",
            "date": commit.committed_datetime.isoformat(),
            "message": commit.message.strip(),
        }
        for commit in commits
    ]


def git_remote(repository_path: str, action: str = "list") -> Any:
    """
    Manage Git remotes.
    
    Args:
        repository_path: Path to the Git repository
        action: Action to perform (list, show)
        
    Returns:
        List of remote names or detailed remote information
        
    Raises:
        ImportError: If GitPython is not installed
        Exception: If remote operation fails
    """
    try:
        from git import Repo
    except ImportError:
        raise ImportError(
            "GitPython is required for Git operations. "
            "Install with: pip install gitpython"
        )
    
    repo = Repo(repository_path)
    
    if action == "list":
        return [remote.name for remote in repo.remotes]
    elif action == "show":
        remotes = []
        for remote in repo.remotes:
            remotes.append({
                "name": remote.name,
                "url": list(remote.urls)[0] if remote.urls else None,
            })
        return remotes
    else:
        raise ValueError(f"Invalid action: {action}")


__all__ = [
    "git_clone",
    "git_status",
    "git_commit",
    "git_push",
    "git_pull",
    "git_branch",
    "git_diff",
    "git_log",
    "git_remote",
]
