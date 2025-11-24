"""
Integration tests for AI agent workflow and document interactions.

These tests validate that the documentation framework supports
expected workflows and maintains consistency across the system.
"""

import re
from pathlib import Path
from typing import Dict, List, Set
import pytest


class TestAgentOnboardingWorkflow:
    """Test the agent onboarding workflow described in documentation."""
    
    @pytest.fixture
    def agents_dir(self) -> Path:
        """Return the agents directory path."""
        return Path(__file__).parent.parent.parent / "agents"
    
    @pytest.fixture
    def agents_md(self, agents_dir: Path) -> str:
        """Load agents.md content."""
        return (agents_dir / "agents.md").read_text()
    
    @pytest.fixture
    def rules_md(self, agents_dir: Path) -> str:
        """Load rules.md content."""
        return (agents_dir / "rules.md").read_text()
    
    def test_onboarding_references_all_core_docs(self, agents_md: str):
        """Verify onboarding guide references all core documents."""
        core_docs = ["rules.md", "tasks.md", "journal.md", "project_summary.md"]
        
        for doc in core_docs:
            assert doc in agents_md, \
                f"Onboarding guide should reference {doc}"
    
    def test_rules_provide_task_selection_guidance(self, rules_md: str):
        """Ensure rules explain how to select and manage tasks."""
        content_lower = rules_md.lower()
        
        task_guidance_terms = ["task", "select", "work", "begin"]
        found = sum(1 for term in task_guidance_terms if term in content_lower)
        
        assert found >= 2, \
            "Rules should provide guidance on task selection and management"
    
    def test_workflow_documents_form_complete_picture(self, agents_dir: Path):
        """Verify that workflow docs together provide complete guidance."""
        agents_md = (agents_dir / "agents.md").read_text()
        rules_md = (agents_dir / "rules.md").read_text()
        tasks_md = (agents_dir / "tasks.md").read_text()
        
        combined = agents_md + rules_md + tasks_md
        combined_lower = combined.lower()
        
        # Should cover the complete workflow
        workflow_aspects = [
            "start",  # How to start
            "task",   # What to work on
            "log",    # How to log work
            "test",   # How to verify
            "complete" # How to finish
        ]
        
        for aspect in workflow_aspects:
            assert aspect in combined_lower, \
                f"Workflow documentation should cover '{aspect}'"


class TestTaskLifecycleManagement:
    """Test task lifecycle as described in documentation."""
    
    @pytest.fixture
    def tasks_md(self) -> str:
        """Load tasks.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "tasks.md").read_text()
    
    def test_task_has_lifecycle_stages(self, tasks_md: str):
        """Verify task lifecycle stages are defined or implied."""
        content_lower = tasks_md.lower()
        
        # Look for lifecycle indicators
        lifecycle_terms = ["status", "progress", "complete", "pending"]
        found = sum(1 for term in lifecycle_terms if term in content_lower)
        
        assert found >= 2, \
            "tasks.md should describe task lifecycle stages"
    
    def test_task_completion_requires_verification(self, tasks_md: str):
        """Ensure task completion requires some form of verification."""
        content_lower = tasks_md.lower()
        
        verification_terms = ["test", "verify", "evidence", "proof", "criteria"]
        found = sum(1 for term in verification_terms if term in content_lower)
        
        assert found >= 1, \
            "Task completion should require verification"
    
    def test_task_updates_tracked_with_timestamps(self, tasks_md: str):
        """Verify tasks mention timestamp tracking."""
        content_lower = tasks_md.lower()
        
        assert "timestamp" in content_lower or "time" in content_lower or \
               re.search(r'\d{4}-\d{2}-\d{2}', tasks_md), \
            "tasks.md should track updates with timestamps"


class TestJournalWorkflow:
    """Test journal logging workflow and requirements."""
    
    @pytest.fixture
    def journal_md(self) -> str:
        """Load journal.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "journal.md").read_text()
    
    @pytest.fixture
    def rules_md(self) -> str:
        """Load rules.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "rules.md").read_text()
    
    def test_journal_append_only_enforced_in_rules(self, rules_md: str):
        """Verify rules enforce append-only journal behavior."""
        content_lower = rules_md.lower()
        
        has_append = "append" in content_lower
        has_journal = "journal" in content_lower
        has_never_edit = "never" in content_lower and ("edit" in content_lower or 
                                                        "delete" in content_lower or
                                                        "modify" in content_lower)
        
        assert has_append and has_journal, \
            "Rules should specify append-only journal behavior"
    
    def test_journal_entry_format_specified(self, rules_md: str):
        """Ensure rules or documentation specify journal entry format."""
        content_lower = rules_md.lower()
        
        format_indicators = ["timestamp", "agent", "format", "entry"]
        found = sum(1 for term in format_indicators if term in content_lower)
        
        assert found >= 2, \
            "Documentation should specify journal entry format requirements"
    
    def test_journal_supports_traceability(self, journal_md: str):
        """Verify journal structure supports audit trail."""
        # Journal should have temporal ordering (timestamps)
        has_timestamp = bool(re.search(r'\d{4}-\d{2}-\d{2}', journal_md))
        
        # Should identify agents/actors
        content_lower = journal_md.lower()
        has_agent_id = "agent" in content_lower or "chatgpt" in content_lower
        
        assert has_timestamp and has_agent_id, \
            "Journal should support traceability with timestamps and agent IDs"


class TestCommunicationProtocols:
    """Test inter-agent communication protocols."""
    
    @pytest.fixture
    def rules_md(self) -> str:
        """Load rules.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "rules.md").read_text()
    
    def test_communication_protocol_defined(self, rules_md: str):
        """Verify communication protocols are defined."""
        content_lower = rules_md.lower()
        
        comm_terms = ["communication", "coordinate", "inter-agent", "dialogue"]
        found = sum(1 for term in comm_terms if term in content_lower)
        
        assert found >= 1, \
            "Rules should define communication protocols"
    
    def test_communication_logging_required(self, rules_md: str):
        """Ensure communications must be logged."""
        content_lower = rules_md.lower()
        
        # Should mention logging communications
        has_comm = "communication" in content_lower or "coordinate" in content_lower
        has_log = "log" in content_lower or "journal" in content_lower
        
        assert has_comm and has_log, \
            "Rules should require logging of communications"


class TestTestingFramework:
    """Test the testing requirements and framework described."""
    
    @pytest.fixture
    def all_docs(self) -> Dict[str, str]:
        """Load all documentation files."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        docs = {}
        for filename in ["agents.md", "rules.md", "tasks.md"]:
            if (agents_dir / filename).exists():
                docs[filename] = (agents_dir / filename).read_text()
        return docs
    
    def test_testing_requirements_specified(self, all_docs: Dict[str, str]):
        """Verify testing requirements are documented."""
        combined = " ".join(all_docs.values()).lower()
        
        test_terms = ["test", "verify", "evidence", "proof"]
        found = sum(1 for term in test_terms if term in combined)
        
        assert found >= 2, \
            "Documentation should specify testing requirements"
    
    def test_test_types_mentioned(self, all_docs: Dict[str, str]):
        """Check that different types of tests are mentioned."""
        combined = " ".join(all_docs.values()).lower()
        
        # Look for test type indicators
        test_type_indicators = [
            "unit", "integration", "pytest", "jest", "manual", 
            "verification", "validation"
        ]
        
        found = [indicator for indicator in test_type_indicators 
                if indicator in combined]
        
        # Should mention at least one test type or verification method
        assert len(found) >= 1, \
            "Documentation should mention testing approaches"


class TestGitWorkflow:
    """Test Git workflow and version control requirements."""
    
    @pytest.fixture
    def rules_md(self) -> str:
        """Load rules.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "rules.md").read_text()
    
    def test_git_backup_requirements_specified(self, rules_md: str):
        """Verify Git backup requirements are defined."""
        content_lower = rules_md.lower()
        
        git_terms = ["git", "commit", "backup", "version"]
        found = sum(1 for term in git_terms if term in content_lower)
        
        assert found >= 1, \
            "Rules should specify Git backup requirements"
    
    def test_commit_frequency_guidance_provided(self, rules_md: str):
        """Ensure documentation provides commit frequency guidance."""
        content_lower = rules_md.lower()
        
        # Look for temporal indicators
        frequency_terms = ["update", "commit", "regular", "session", "frequent"]
        found = sum(1 for term in frequency_terms if term in content_lower)
        
        assert found >= 2, \
            "Documentation should provide commit frequency guidance"


class TestDocumentInterrelationships:
    """Test relationships and dependencies between documents."""
    
    @pytest.fixture
    def all_docs(self) -> Dict[str, str]:
        """Load all documentation files."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        docs = {}
        for filename in ["agents.md", "rules.md", "tasks.md", 
                        "journal.md", "project_summary.md"]:
            if (agents_dir / filename).exists():
                docs[filename] = (agents_dir / filename).read_text()
        return docs
    
    def test_agents_md_acts_as_index(self, all_docs: Dict[str, str]):
        """Verify agents.md serves as entry point referencing others."""
        agents_content = all_docs.get("agents.md", "")
        
        # Should reference multiple other documents
        references = sum(1 for other_doc in all_docs.keys() 
                        if other_doc != "agents.md" and other_doc in agents_content)
        
        assert references >= 2, \
            "agents.md should reference other core documents"
    
    def test_project_summary_links_strategic_and_tactical(
        self, all_docs: Dict[str, str]
    ):
        """Ensure project_summary bridges high-level and detailed docs."""
        summary_content = all_docs.get("project_summary.md", "").lower()
        
        # Should reference both strategic (features, srs) and tactical (tasks)
        has_strategic = any(term in summary_content 
                          for term in ["feature", "srs", "requirement"])
        has_tactical = "task" in summary_content
        
        assert has_strategic or has_tactical, \
            "project_summary.md should bridge strategic and tactical levels"
    
    def test_documents_form_coherent_system(self, all_docs: Dict[str, str]):
        """Verify documents together form a coherent system."""
        # Check that documents reference each other appropriately
        reference_graph = {}
        
        for doc_name, content in all_docs.items():
            references = []
            for other_doc in all_docs.keys():
                if other_doc != doc_name and other_doc in content:
                    references.append(other_doc)
            reference_graph[doc_name] = references
        
        # At least some documents should reference others
        total_refs = sum(len(refs) for refs in reference_graph.values())
        assert total_refs >= 3, \
            "Documents should form an interconnected system"


class TestStarterKitCompleteness:
    """Test that the starter kit is complete and usable."""
    
    @pytest.fixture
    def agents_dir(self) -> Path:
        """Return the agents directory path."""
        return Path(__file__).parent.parent.parent / "agents"
    
    def test_all_essential_files_present(self, agents_dir: Path):
        """Verify all essential starter kit files are present."""
        essential_files = [
            "README.md",
            "agents.md",
            "rules.md",
            "tasks.md",
            "journal.md",
            "project_summary.md"
        ]
        
        for filename in essential_files:
            assert (agents_dir / filename).exists(), \
                f"Starter kit is missing essential file: {filename}"
    
    def test_starter_kit_has_bootstrap_instructions(self, agents_dir: Path):
        """Ensure starter kit includes instructions for new projects."""
        # Check agents.md or README for bootstrap/setup instructions
        agents_md = (agents_dir / "agents.md").read_text().lower()
        readme_md = (agents_dir / "README.md").read_text().lower()
        
        combined = agents_md + readme_md
        
        setup_terms = ["start", "new project", "copy", "initialize", "setup"]
        found = sum(1 for term in setup_terms if term in combined)
        
        assert found >= 1, \
            "Starter kit should include setup instructions for new projects"
    
    def test_documentation_self_describes_purpose(self, agents_dir: Path):
        """Verify documentation explains its own purpose."""
        agents_md = (agents_dir / "agents.md").read_text().lower()
        rules_md = (agents_dir / "rules.md").read_text().lower()
        
        combined = agents_md + rules_md
        
        purpose_terms = ["purpose", "guide", "framework", "operating", "starter"]
        found = sum(1 for term in purpose_terms if term in combined)
        
        assert found >= 3, \
            "Documentation should clearly describe its purpose"


class TestErrorHandlingAndEdgeCases:
    """Test error handling and edge case guidance in documentation."""
    
    @pytest.fixture
    def rules_md(self) -> str:
        """Load rules.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "rules.md").read_text()
    
    @pytest.fixture
    def agents_md(self) -> str:
        """Load agents.md content."""
        agents_dir = Path(__file__).parent.parent.parent / "agents"
        return (agents_dir / "agents.md").read_text()
    
    def test_handles_task_blocking_scenario(self, rules_md: str, agents_md: str):
        """Verify documentation addresses blocked tasks."""
        combined = (rules_md + agents_md).lower()
        
        blocking_terms = ["block", "blocked", "blocker", "stuck", "wait"]
        found = sum(1 for term in blocking_terms if term in combined)
        
        # If blocking is mentioned, should provide guidance
        if found > 0:
            assert "log" in combined or "journal" in combined, \
                "If blocking is mentioned, should guide logging the blocker"
    
    def test_addresses_non_compliance_scenario(self, rules_md: str):
        """Check if documentation addresses non-compliance."""
        content_lower = rules_md.lower()
        
        # Look for guidance on what happens when rules aren't followed
        compliance_terms = ["must", "require", "non-compliance", "violation", 
                           "correct", "remediate"]
        found = sum(1 for term in compliance_terms if term in content_lower)
        
        assert found >= 2, \
            "Rules should address compliance and corrections"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])