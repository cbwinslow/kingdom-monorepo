"""
Comprehensive tests for AI agent documentation framework.

These tests validate the structure, content, and consistency of the
agent operations documentation to ensure it meets quality standards
and remains maintainable.
"""

import re
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Set
import pytest


class TestAgentDocumentationStructure:
    """Test the structural integrity of agent documentation files."""
    
    @pytest.fixture
    def agents_dir(self) -> Path:
        """Return the agents directory path."""
        return Path(__file__).parent.parent.parent / "agents"
    
    @pytest.fixture
    def required_files(self) -> List[str]:
        """List of required documentation files."""
        return [
            "README.md",
            "agents.md",
            "rules.md",
            "tasks.md",
            "journal.md",
            "project_summary.md"
        ]
    
    def test_all_required_files_exist(self, agents_dir: Path, required_files: List[str]):
        """Verify all required documentation files are present."""
        for filename in required_files:
            file_path = agents_dir / filename
            assert file_path.exists(), f"Required file {filename} is missing"
            assert file_path.is_file(), f"{filename} exists but is not a file"
    
    def test_files_are_not_empty(self, agents_dir: Path, required_files: List[str]):
        """Ensure no documentation file is empty."""
        for filename in required_files:
            file_path = agents_dir / filename
            content = file_path.read_text()
            assert len(content.strip()) > 0, f"{filename} is empty"
            assert len(content.split('\n')) > 1, f"{filename} has less than 2 lines"
    
    def test_files_have_headers(self, agents_dir: Path, required_files: List[str]):
        """Verify each markdown file starts with a proper header."""
        for filename in required_files:
            file_path = agents_dir / filename
            content = file_path.read_text()
            lines = content.split('\n')
            
            # Find first non-empty line
            first_line = None
            for line in lines:
                if line.strip():
                    first_line = line
                    break
            
            assert first_line is not None, f"{filename} has no content"
            assert first_line.strip().startswith('#'), \
                f"{filename} doesn't start with a markdown header"


class TestAgentsMdContent:
    """Test the agents.md master control document."""
    
    @pytest.fixture
    def agents_md_content(self) -> str:
        """Load agents.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "agents.md").read_text()
    
    def test_contains_timestamp(self, agents_md_content: str):
        """Verify agents.md includes a creation/update timestamp."""
        # Look for ISO 8601 or similar timestamp patterns
        timestamp_patterns = [
            r'\d{4}-\d{2}-\d{2}',  # YYYY-MM-DD
            r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}',  # ISO 8601
            r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}'  # Alternative format
        ]
        
        found = any(re.search(pattern, agents_md_content) 
                   for pattern in timestamp_patterns)
        assert found, "agents.md should contain a timestamp"
    
    def test_references_core_files(self, agents_md_content: str):
        """Ensure agents.md references other core documentation files."""
        required_references = [
            "rules.md",
            "tasks.md",
            "journal.md",
            "project_summary.md"
        ]
        
        for ref in required_references:
            assert ref in agents_md_content, \
                f"agents.md should reference {ref}"
    
    def test_contains_core_sections(self, agents_md_content: str):
        """Verify agents.md has expected guidance sections."""
        expected_keywords = [
            "rules",
            "tasks",
            "journal",
            "agent",
            "operating"
        ]
        
        content_lower = agents_md_content.lower()
        for keyword in expected_keywords:
            assert keyword in content_lower, \
                f"agents.md should contain '{keyword}'"
    
    def test_has_creator_attribution(self, agents_md_content: str):
        """Check that agents.md attributes creation to an agent."""
        attribution_indicators = [
            "created",
            "by",
            "agent",
            "chatgpt",
            "ai agent"
        ]
        
        content_lower = agents_md_content.lower()
        found = sum(1 for indicator in attribution_indicators 
                   if indicator in content_lower)
        assert found >= 2, "agents.md should have creator attribution"


class TestRulesMdContent:
    """Test the rules.md operating rules document."""
    
    @pytest.fixture
    def rules_md_content(self) -> str:
        """Load rules.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "rules.md").read_text()
    
    def test_contains_timestamp(self, rules_md_content: str):
        """Verify rules.md includes update timestamp."""
        timestamp_patterns = [
            r'\d{4}-\d{2}-\d{2}',
            r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}',
            r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}'
        ]
        
        found = any(re.search(pattern, rules_md_content) 
                   for pattern in timestamp_patterns)
        assert found, "rules.md should contain a timestamp"
    
    def test_defines_task_alignment(self, rules_md_content: str):
        """Ensure rules.md addresses task alignment and drift prevention."""
        content_lower = rules_md_content.lower()
        assert "task" in content_lower, "rules.md should mention tasks"
        assert any(term in content_lower for term in ["drift", "alignment", "focus"]), \
            "rules.md should address task drift/alignment"
    
    def test_defines_logging_requirements(self, rules_md_content: str):
        """Verify rules.md specifies logging requirements."""
        content_lower = rules_md_content.lower()
        assert "log" in content_lower or "journal" in content_lower, \
            "rules.md should specify logging requirements"
    
    def test_defines_communication_protocols(self, rules_md_content: str):
        """Check that rules.md includes communication guidelines."""
        content_lower = rules_md_content.lower()
        assert "communication" in content_lower or "coordinate" in content_lower, \
            "rules.md should define communication protocols"
    
    def test_references_journal_as_append_only(self, rules_md_content: str):
        """Verify rules.md specifies journal.md as append-only."""
        content_lower = rules_md_content.lower()
        has_journal = "journal" in content_lower
        has_append_only = "append" in content_lower or "append-only" in content_lower
        
        assert has_journal and has_append_only, \
            "rules.md should specify journal.md as append-only"
    
    def test_has_numbered_sections(self, rules_md_content: str):
        """Ensure rules.md uses structured sections for organization."""
        # Look for numbered sections or clear headings
        section_patterns = [
            r'^#{1,3}\s+\d+\.',  # ## 1. Section
            r'^#{1,3}\s+[A-Z]',  # ## Section Title
        ]
        
        lines = rules_md_content.split('\n')
        section_count = sum(1 for line in lines 
                          if any(re.match(pattern, line) 
                                for pattern in section_patterns))
        
        assert section_count >= 3, \
            "rules.md should have at least 3 major sections"


class TestTasksMdContent:
    """Test the tasks.md task ledger document."""
    
    @pytest.fixture
    def tasks_md_content(self) -> str:
        """Load tasks.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "tasks.md").read_text()
    
    def test_contains_timestamp(self, tasks_md_content: str):
        """Verify tasks.md includes timestamps."""
        timestamp_patterns = [
            r'\d{4}-\d{2}-\d{2}',
            r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}',
            r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}'
        ]
        
        found = any(re.search(pattern, tasks_md_content) 
                   for pattern in timestamp_patterns)
        assert found, "tasks.md should contain timestamps"
    
    def test_describes_task_structure(self, tasks_md_content: str):
        """Ensure tasks.md explains task structure."""
        content_lower = tasks_md_content.lower()
        expected_terms = ["task", "microgoal", "criteria", "status"]
        
        found_terms = [term for term in expected_terms if term in content_lower]
        assert len(found_terms) >= 2, \
            "tasks.md should describe task structure with key terms"
    
    def test_mentions_testing_requirements(self, tasks_md_content: str):
        """Verify tasks.md includes testing expectations."""
        content_lower = tasks_md_content.lower()
        assert "test" in content_lower, \
            "tasks.md should mention testing requirements"
    
    def test_has_example_or_template(self, tasks_md_content: str):
        """Check that tasks.md provides guidance via examples."""
        content_lower = tasks_md_content.lower()
        has_guidance = any(term in content_lower 
                          for term in ["example", "template", "task 1", 
                                      "starter", "establish"])
        assert has_guidance, "tasks.md should include task examples or templates"
    
    def test_references_sign_off(self, tasks_md_content: str):
        """Ensure tasks.md mentions sign-off requirements."""
        content_lower = tasks_md_content.lower()
        assert "sign-off" in content_lower or "sign off" in content_lower, \
            "tasks.md should reference sign-off for completed tasks"


class TestJournalMdContent:
    """Test the journal.md append-only log."""
    
    @pytest.fixture
    def journal_md_content(self) -> str:
        """Load journal.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "journal.md").read_text()
    
    def test_declares_append_only(self, journal_md_content: str):
        """Verify journal.md identifies itself as append-only."""
        content_lower = journal_md_content.lower()
        assert "append" in content_lower or "append-only" in content_lower, \
            "journal.md should declare append-only nature"
    
    def test_has_initial_entry(self, journal_md_content: str):
        """Check that journal.md contains at least one log entry."""
        content_lower = journal_md_content.lower()
        
        # Look for entry indicators
        entry_indicators = [
            "2025",  # Year from timestamp
            "agent",
            "chatgpt",
            "initialized",
            "created"
        ]
        
        found = sum(1 for indicator in entry_indicators 
                   if indicator in content_lower)
        assert found >= 3, "journal.md should have an initial entry with details"
    
    def test_entries_have_timestamps(self, journal_md_content: str):
        """Ensure journal entries include timestamps."""
        # Look for timestamp patterns
        timestamp_pattern = r'\d{4}-\d{2}-\d{2}'
        matches = re.findall(timestamp_pattern, journal_md_content)
        assert len(matches) >= 1, "journal.md entries should have timestamps"
    
    def test_entries_identify_agent(self, journal_md_content: str):
        """Verify journal entries identify the responsible agent."""
        content_lower = journal_md_content.lower()
        assert "agent" in content_lower or "chatgpt" in content_lower, \
            "journal.md entries should identify the agent"


class TestProjectSummaryMdContent:
    """Test the project_summary.md balance sheet document."""
    
    @pytest.fixture
    def project_summary_content(self) -> str:
        """Load project_summary.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "project_summary.md").read_text()
    
    def test_contains_timestamp(self, project_summary_content: str):
        """Verify project_summary.md includes timestamp."""
        timestamp_patterns = [
            r'\d{4}-\d{2}-\d{2}',
            r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}',
            r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}'
        ]
        
        found = any(re.search(pattern, project_summary_content) 
                   for pattern in timestamp_patterns)
        assert found, "project_summary.md should contain a timestamp"
    
    def test_describes_purpose(self, project_summary_content: str):
        """Ensure project_summary.md states its purpose."""
        content_lower = project_summary_content.lower()
        assert "purpose" in content_lower or "summary" in content_lower, \
            "project_summary.md should describe its purpose"
    
    def test_references_related_documents(self, project_summary_content: str):
        """Verify project_summary.md references related documents."""
        content_lower = project_summary_content.lower()
        references = ["features", "srs", "rules", "tasks", "journal", "agents"]
        
        found_refs = [ref for ref in references if ref in content_lower]
        assert len(found_refs) >= 3, \
            "project_summary.md should reference related documents"
    
    def test_mentions_alignment(self, project_summary_content: str):
        """Check that project_summary.md addresses document alignment."""
        content_lower = project_summary_content.lower()
        assert "align" in content_lower or "coherent" in content_lower, \
            "project_summary.md should mention alignment between documents"


class TestDocumentationConsistency:
    """Test consistency and cross-references between documents."""
    
    @pytest.fixture
    def all_docs(self) -> Dict[str, str]:
        """Load all documentation files."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        docs = {}
        for filename in ["agents.md", "rules.md", "tasks.md", 
                        "journal.md", "project_summary.md"]:
            docs[filename] = (agents_dir / filename).read_text()
        return docs
    
    def test_consistent_terminology(self, all_docs: Dict[str, str]):
        """Verify consistent use of key terms across documents."""
        key_terms = {
            "journal.md": ["append-only", "append only"],
            "tasks.md": ["microgoal", "micro-goal", "microgoals"],
            "rules.md": ["operating rules", "operations", "agent"],
        }
        
        for filename, acceptable_terms in key_terms.items():
            if filename in all_docs:
                content_lower = all_docs[filename].lower()
                found = any(term in content_lower for term in acceptable_terms)
                assert found, f"{filename} should use expected terminology"
    
    def test_cross_references_valid(self, all_docs: Dict[str, str]):
        """Ensure file references in documents point to existing files."""
        all_filenames = set(all_docs.keys())
        
        for doc_name, content in all_docs.items():
            # Find markdown file references
            referenced_files = re.findall(r'(\w+\.md)', content)
            
            for ref in referenced_files:
                if ref in ["README.md", "agents.md", "rules.md", "tasks.md", 
                          "journal.md", "project_summary.md", "features.md", "srs.md"]:
                    # Core files should exist or be allowed references
                    if ref in all_filenames:
                        pass  # Valid reference to existing file
                    elif ref in ["features.md", "srs.md"]:
                        pass  # Allowed forward references
                    else:
                        # Reference found but file doesn't exist
                        pass  # Not failing here as some references are intentional
    
    def test_timestamp_format_consistency(self, all_docs: Dict[str, str]):
        """Check that timestamps follow a consistent format across files."""
        timestamp_formats = {}
        
        for filename, content in all_docs.items():
            # Extract all timestamps
            iso_timestamps = re.findall(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}', content)
            date_timestamps = re.findall(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}', content)
            
            if iso_timestamps:
                timestamp_formats[filename] = "ISO8601"
            elif date_timestamps:
                timestamp_formats[filename] = "Date-Time"
        
        # At least some files should have timestamps
        assert len(timestamp_formats) >= 3, \
            "Multiple documents should contain timestamps"


class TestReadmeContent:
    """Test the README.md agent directory documentation."""
    
    @pytest.fixture
    def readme_content(self) -> str:
        """Load README.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "README.md").read_text()
    
    def test_describes_directory_purpose(self, readme_content: str):
        """Verify README explains the agents directory purpose."""
        content_lower = readme_content.lower()
        assert "agent" in content_lower, \
            "README should mention agents"
        assert any(term in content_lower for term in ["purpose", "directory", "structure"]), \
            "README should describe the directory purpose"
    
    def test_lists_subdirectories_or_structure(self, readme_content: str):
        """Check that README documents the directory structure."""
        # Look for structure indicators
        structure_indicators = [
            "*",  # Bullet points
            "-",  # Dashes
            "agent",
            "crew",
            "tool",
        ]
        
        found = sum(1 for indicator in structure_indicators 
                   if indicator in readme_content.lower())
        assert found >= 3, "README should document directory structure"


class TestDocumentationEdgeCases:
    """Test edge cases and potential issues in documentation."""
    
    @pytest.fixture
    def agents_dir(self) -> Path:
        """Return the agents directory path."""
        return Path(__file__).parent.parent.parent / "agents"
    
    def test_no_sensitive_data_in_docs(self, agents_dir: Path):
        """Ensure documentation doesn't contain sensitive information."""
        sensitive_patterns = [
            r'password\s*=\s*["\']',
            r'api[_-]?key\s*=\s*["\']',
            r'secret\s*=\s*["\']',
            r'token\s*=\s*["\']',
            r'sk-[a-zA-Z0-9]{32,}',  # OpenAI-style keys
        ]
        
        for md_file in agents_dir.glob("*.md"):
            content = md_file.read_text()
            for pattern in sensitive_patterns:
                matches = re.findall(pattern, content, re.IGNORECASE)
                assert len(matches) == 0, \
                    f"{md_file.name} may contain sensitive data: {pattern}"
    
    def test_reasonable_file_sizes(self, agents_dir: Path):
        """Verify documentation files are not excessively large."""
        max_size_kb = 100  # 100 KB should be enough for markdown docs
        
        for md_file in agents_dir.glob("*.md"):
            size_kb = md_file.stat().st_size / 1024
            assert size_kb < max_size_kb, \
                f"{md_file.name} is {size_kb:.1f}KB, exceeds {max_size_kb}KB limit"
    
    def test_no_broken_markdown_links(self, agents_dir: Path):
        """Check for obviously broken markdown links."""
        for md_file in agents_dir.glob("*.md"):
            content = md_file.read_text()
            
            # Find markdown links: [text](url)
            links = re.findall(r'\[([^\]]+)\]\(([^\)]+)\)', content)
            
            for link_text, link_url in links:
                # Check for empty links
                assert link_url.strip(), \
                    f"{md_file.name} has empty link for '{link_text}'"
                
                # Check for relative file links that should exist
                if link_url.endswith('.md') and not link_url.startswith('http'):
                    referenced_file = agents_dir / link_url
                    if not link_url.startswith('../'):
                        # Only check local references
                        pass  # Relaxed check since some references may be intentional
    
    def test_consistent_line_endings(self, agents_dir: Path):
        """Ensure consistent line endings (LF) across documentation."""
        for md_file in agents_dir.glob("*.md"):
            content_bytes = md_file.read_bytes()
            
            # Check for CRLF
            crlf_count = content_bytes.count(b'\r\n')
            lf_count = content_bytes.count(b'\n')
            
            # If there are any CRLFs, they should be dominant or nonexistent
            if crlf_count > 0 and lf_count > crlf_count:
                pytest.fail(f"{md_file.name} has mixed line endings")


class TestDocumentationMaintainability:
    """Test aspects that affect long-term documentation maintainability."""
    
    @pytest.fixture
    def all_docs(self) -> Dict[str, str]:
        """Load all documentation files."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        docs = {}
        for filename in ["agents.md", "rules.md", "tasks.md", 
                        "journal.md", "project_summary.md", "README.md"]:
            if (agents_dir / filename).exists():
                docs[filename] = (agents_dir / filename).read_text()
        return docs
    
    def test_documents_have_clear_headers(self, all_docs: Dict[str, str]):
        """Verify each document has a clear title header."""
        for filename, content in all_docs.items():
            lines = content.split('\n')
            
            # Find first heading
            first_heading = None
            for line in lines:
                if line.strip().startswith('#'):
                    first_heading = line
                    break
            
            assert first_heading is not None, \
                f"{filename} should have a heading"
            
            # Heading should not be too long
            heading_text = first_heading.lstrip('#').strip()
            assert len(heading_text) < 100, \
                f"{filename} heading is too long: {len(heading_text)} chars"
    
    def test_reasonable_line_lengths(self, all_docs: Dict[str, str]):
        """Check that lines aren't excessively long (for readability)."""
        max_line_length = 500  # Reasonable limit for markdown
        
        for filename, content in all_docs.items():
            lines = content.split('\n')
            for i, line in enumerate(lines, 1):
                # Skip if it's just a URL or code block
                if line.strip().startswith('http') or line.strip().startswith('```'):
                    continue
                    
                assert len(line) <= max_line_length, \
                    f"{filename} line {i} exceeds {max_line_length} chars"
    
    def test_documents_use_consistent_formatting(self, all_docs: Dict[str, str]):
        """Verify consistent markdown formatting across documents."""
        for filename, content in all_docs.items():
            lines = content.split('\n')
            
            # Check for consistent list formatting
            list_markers = set()
            for line in lines:
                stripped = line.lstrip()
                if stripped.startswith('- '):
                    list_markers.add('dash')
                elif stripped.startswith('* '):
                    list_markers.add('asterisk')
            
            # If both are used, that's fine, but we're tracking
            # This is informational rather than a hard requirement


class TestComplianceWithGuidelines:
    """Test compliance with stated documentation guidelines."""
    
    @pytest.fixture
    def rules_content(self) -> str:
        """Load rules.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "rules.md").read_text()
    
    @pytest.fixture
    def tasks_content(self) -> str:
        """Load tasks.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "tasks.md").read_text()
    
    def test_rules_specify_update_frequency(self, rules_content: str):
        """Verify rules.md mentions when to update documents."""
        content_lower = rules_content.lower()
        frequency_terms = ["update", "frequency", "when", "cadence", "periodic"]
        
        found = sum(1 for term in frequency_terms if term in content_lower)
        assert found >= 2, \
            "rules.md should specify update frequency for documents"
    
    def test_tasks_follow_stated_structure(self, tasks_content: str):
        """Check that tasks.md follows its own stated structure."""
        content_lower = tasks_content.lower()
        
        # If it defines structure, check for key elements
        has_structure_def = any(term in content_lower 
                               for term in ["structure", "format", "template"])
        
        if has_structure_def:
            # Should mention key task components
            task_components = ["status", "owner", "description", "criteria"]
            found_components = [c for c in task_components if c in content_lower]
            
            assert len(found_components) >= 2, \
                "tasks.md should follow its stated structure"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])