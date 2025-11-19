"""
GitHub Tools for AI Agents
Provides utilities for interacting with GitHub API
"""

import os
from typing import Dict, List, Optional
from github import Github, GithubException
from dataclasses import dataclass


@dataclass
class PullRequest:
    """Pull Request data class"""
    number: int
    title: str
    body: str
    state: str
    author: str
    created_at: str
    updated_at: str
    merged: bool
    mergeable: bool
    files: List[str]
    additions: int
    deletions: int
    changed_files: int


@dataclass
class Issue:
    """Issue data class"""
    number: int
    title: str
    body: str
    state: str
    author: str
    created_at: str
    updated_at: str
    labels: List[str]
    assignees: List[str]


class GitHubTools:
    """Tools for interacting with GitHub"""
    
    def __init__(self, token: Optional[str] = None):
        """
        Initialize GitHub tools
        
        Args:
            token: GitHub access token (defaults to GITHUB_TOKEN env var)
        """
        self.token = token or os.getenv('GITHUB_TOKEN')
        if not self.token:
            raise ValueError("GitHub token is required")
        
        self.github = Github(self.token)
    
    def get_repository(self, repo_name: str):
        """
        Get repository object
        
        Args:
            repo_name: Repository name in format "owner/repo"
            
        Returns:
            Repository object
        """
        try:
            return self.github.get_repo(repo_name)
        except GithubException as e:
            raise Exception(f"Failed to get repository {repo_name}: {str(e)}")
    
    def get_pull_request(self, repo_name: str, pr_number: int) -> PullRequest:
        """
        Get pull request details
        
        Args:
            repo_name: Repository name in format "owner/repo"
            pr_number: Pull request number
            
        Returns:
            PullRequest object with details
        """
        repo = self.get_repository(repo_name)
        pr = repo.get_pull(pr_number)
        
        files = [f.filename for f in pr.get_files()]
        
        return PullRequest(
            number=pr.number,
            title=pr.title,
            body=pr.body or "",
            state=pr.state,
            author=pr.user.login,
            created_at=pr.created_at.isoformat(),
            updated_at=pr.updated_at.isoformat(),
            merged=pr.merged,
            mergeable=pr.mergeable or False,
            files=files,
            additions=pr.additions,
            deletions=pr.deletions,
            changed_files=pr.changed_files
        )
    
    def get_pr_diff(self, repo_name: str, pr_number: int) -> str:
        """
        Get pull request diff
        
        Args:
            repo_name: Repository name
            pr_number: Pull request number
            
        Returns:
            Diff as string
        """
        repo = self.get_repository(repo_name)
        pr = repo.get_pull(pr_number)
        
        diff_text = ""
        for file in pr.get_files():
            diff_text += f"\n{'='*80}\n"
            diff_text += f"File: {file.filename}\n"
            diff_text += f"{'='*80}\n"
            if file.patch:
                diff_text += file.patch + "\n"
        
        return diff_text
    
    def comment_on_pr(self, repo_name: str, pr_number: int, comment: str) -> bool:
        """
        Add comment to pull request
        
        Args:
            repo_name: Repository name
            pr_number: Pull request number
            comment: Comment text
            
        Returns:
            True if successful
        """
        try:
            repo = self.get_repository(repo_name)
            pr = repo.get_pull(pr_number)
            pr.create_issue_comment(comment)
            return True
        except GithubException as e:
            print(f"Failed to comment on PR: {str(e)}")
            return False
    
    def add_labels_to_pr(self, repo_name: str, pr_number: int, labels: List[str]) -> bool:
        """
        Add labels to pull request
        
        Args:
            repo_name: Repository name
            pr_number: Pull request number
            labels: List of label names
            
        Returns:
            True if successful
        """
        try:
            repo = self.get_repository(repo_name)
            issue = repo.get_issue(pr_number)
            issue.add_to_labels(*labels)
            return True
        except GithubException as e:
            print(f"Failed to add labels: {str(e)}")
            return False
    
    def request_reviewers(self, repo_name: str, pr_number: int, reviewers: List[str]) -> bool:
        """
        Request reviewers for pull request
        
        Args:
            repo_name: Repository name
            pr_number: Pull request number
            reviewers: List of reviewer usernames
            
        Returns:
            True if successful
        """
        try:
            repo = self.get_repository(repo_name)
            pr = repo.get_pull(pr_number)
            pr.create_review_request(reviewers=reviewers)
            return True
        except GithubException as e:
            print(f"Failed to request reviewers: {str(e)}")
            return False
    
    def get_issue(self, repo_name: str, issue_number: int) -> Issue:
        """
        Get issue details
        
        Args:
            repo_name: Repository name
            issue_number: Issue number
            
        Returns:
            Issue object with details
        """
        repo = self.get_repository(repo_name)
        issue = repo.get_issue(issue_number)
        
        return Issue(
            number=issue.number,
            title=issue.title,
            body=issue.body or "",
            state=issue.state,
            author=issue.user.login,
            created_at=issue.created_at.isoformat(),
            updated_at=issue.updated_at.isoformat(),
            labels=[label.name for label in issue.labels],
            assignees=[assignee.login for assignee in issue.assignees]
        )
    
    def create_issue(self, repo_name: str, title: str, body: str, 
                    labels: Optional[List[str]] = None,
                    assignees: Optional[List[str]] = None) -> int:
        """
        Create a new issue
        
        Args:
            repo_name: Repository name
            title: Issue title
            body: Issue body
            labels: Optional list of labels
            assignees: Optional list of assignees
            
        Returns:
            Issue number
        """
        try:
            repo = self.get_repository(repo_name)
            issue = repo.create_issue(
                title=title,
                body=body,
                labels=labels or [],
                assignees=assignees or []
            )
            return issue.number
        except GithubException as e:
            raise Exception(f"Failed to create issue: {str(e)}")
    
    def close_issue(self, repo_name: str, issue_number: int) -> bool:
        """
        Close an issue
        
        Args:
            repo_name: Repository name
            issue_number: Issue number
            
        Returns:
            True if successful
        """
        try:
            repo = self.get_repository(repo_name)
            issue = repo.get_issue(issue_number)
            issue.edit(state='closed')
            return True
        except GithubException as e:
            print(f"Failed to close issue: {str(e)}")
            return False
    
    def list_open_prs(self, repo_name: str, limit: int = 10) -> List[PullRequest]:
        """
        List open pull requests
        
        Args:
            repo_name: Repository name
            limit: Maximum number of PRs to return
            
        Returns:
            List of PullRequest objects
        """
        repo = self.get_repository(repo_name)
        prs = repo.get_pulls(state='open', sort='created', direction='desc')
        
        result = []
        for pr in prs[:limit]:
            files = [f.filename for f in pr.get_files()]
            result.append(PullRequest(
                number=pr.number,
                title=pr.title,
                body=pr.body or "",
                state=pr.state,
                author=pr.user.login,
                created_at=pr.created_at.isoformat(),
                updated_at=pr.updated_at.isoformat(),
                merged=pr.merged,
                mergeable=pr.mergeable or False,
                files=files,
                additions=pr.additions,
                deletions=pr.deletions,
                changed_files=pr.changed_files
            ))
        
        return result
    
    def get_file_content(self, repo_name: str, file_path: str, ref: str = "main") -> str:
        """
        Get file content from repository
        
        Args:
            repo_name: Repository name
            file_path: Path to file in repository
            ref: Git reference (branch, tag, or commit)
            
        Returns:
            File content as string
        """
        try:
            repo = self.get_repository(repo_name)
            content = repo.get_contents(file_path, ref=ref)
            return content.decoded_content.decode('utf-8')
        except GithubException as e:
            raise Exception(f"Failed to get file content: {str(e)}")


def main():
    """Example usage"""
    tools = GitHubTools()
    
    # Example: Get PR details
    # pr = tools.get_pull_request("owner/repo", 123)
    # print(f"PR #{pr.number}: {pr.title}")
    
    # Example: Comment on PR
    # tools.comment_on_pr("owner/repo", 123, "Great work! 🎉")
    
    # Example: Add labels
    # tools.add_labels_to_pr("owner/repo", 123, ["approved", "ready-to-merge"])
    
    print("GitHub tools initialized successfully")


if __name__ == "__main__":
    main()
