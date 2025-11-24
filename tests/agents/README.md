# Agent Documentation Test Suite

This directory contains comprehensive tests for the AI agents documentation framework. The tests validate structure, content, consistency, and workflow compliance of the agent operations documentation.

## Test Organization

### `test_agent_documentation.py`
Core structural and content validation tests:
- **TestAgentDocumentationStructure**: Validates file existence, headers, and basic structure
- **TestAgentsMdContent**: Tests the agents.md master control document
- **TestRulesMdContent**: Tests the rules.md operating rules
- **TestTasksMdContent**: Tests the tasks.md task ledger
- **TestJournalMdContent**: Tests the journal.md append-only log
- **TestProjectSummaryMdContent**: Tests the project_summary.md balance sheet
- **TestDocumentationConsistency**: Cross-document consistency checks
- **TestReadmeContent**: README documentation tests
- **TestDocumentationEdgeCases**: Edge cases and potential issues
- **TestDocumentationMaintainability**: Long-term maintainability checks
- **TestComplianceWithGuidelines**: Compliance with stated guidelines

### `test_agent_workflow_integration.py`
Workflow and integration tests:
- **TestAgentOnboardingWorkflow**: Agent onboarding process validation
- **TestTaskLifecycleManagement**: Task lifecycle management tests
- **TestJournalWorkflow**: Journal logging workflow tests
- **TestCommunicationProtocols**: Inter-agent communication tests
- **TestTestingFramework**: Testing requirements validation
- **TestGitWorkflow**: Version control workflow tests
- **TestDocumentInterrelationships**: Document relationship tests
- **TestStarterKitCompleteness**: Starter kit completeness validation
- **TestErrorHandlingAndEdgeCases**: Error handling guidance tests

## Running Tests

### Run all agent documentation tests:
```bash
make test-agents
# or
pytest tests/agents/ -v
```

### Run specific test files:
```bash
pytest tests/agents/test_agent_documentation.py -v
pytest tests/agents/test_agent_workflow_integration.py -v
```

### Run specific test classes:
```bash
pytest tests/agents/test_agent_documentation.py::TestAgentsMdContent -v
```

### Run specific test methods:
```bash
pytest tests/agents/test_agent_documentation.py::TestAgentsMdContent::test_contains_timestamp -v
```

### Run with coverage:
```bash
pytest tests/agents/ --cov=agents --cov-report=html
```

## Test Categories

Tests are organized into several categories:

1. **Structural Tests**: Validate file existence, format, and basic structure
2. **Content Tests**: Check for required sections, keywords, and information
3. **Consistency Tests**: Ensure terminology and references are consistent
4. **Workflow Tests**: Validate documented workflows are complete
5. **Integration Tests**: Check inter-document relationships
6. **Edge Case Tests**: Handle error conditions and unusual scenarios
7. **Maintainability Tests**: Ensure long-term quality

## What These Tests Validate

### File Structure
- ✅ All required files exist
- ✅ Files are not empty
- ✅ Files have proper headers
- ✅ File sizes are reasonable

### Content Quality
- ✅ Timestamps are present and properly formatted
- ✅ Required sections are included
- ✅ Cross-references between documents are valid
- ✅ Terminology is consistent
- ✅ No sensitive data is exposed

### Workflow Compliance
- ✅ Onboarding workflow is complete
- ✅ Task lifecycle is well-defined
- ✅ Journal is append-only
- ✅ Communication protocols are specified
- ✅ Testing requirements are clear
- ✅ Git workflow is documented

### Maintainability
- ✅ Documents have clear structure
- ✅ Line lengths are reasonable
- ✅ Formatting is consistent
- ✅ Documents form a coherent system

## Adding New Tests

When adding new tests:

1. **Choose the appropriate test file** based on what you're testing
2. **Follow existing test patterns** for consistency
3. **Use descriptive test names** that explain what is being tested
4. **Include docstrings** explaining the test purpose
5. **Use fixtures** to avoid code duplication
6. **Make assertions clear** with helpful error messages

Example:
```python
def test_new_feature(self, agents_md_content: str):
    """Verify new feature is documented properly."""
    assert "new feature" in agents_md_content.lower(), \
        "agents.md should document the new feature"
```

## Test Fixtures

Common fixtures available in tests:

- `agents_dir`: Path to the agents directory
- `agents_md_content`: Content of agents.md
- `rules_md_content`: Content of rules.md  
- `tasks_md_content`: Content of tasks.md
- `journal_md_content`: Content of journal.md
- `project_summary_content`: Content of project_summary.md
- `all_docs`: Dictionary of all documentation files

## Continuous Integration

These tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Test agent documentation
  run: |
    pip install pytest
    pytest tests/agents/ -v
```

## Requirements

- Python 3.11+
- pytest 7.0+
- No additional dependencies required (tests use only standard library)

## Contributing

When modifying the agent documentation:

1. **Run tests before committing**: `make test-agents`
2. **Update tests if changing structure**: Modify tests to match new structure
3. **Add tests for new features**: Cover new documentation with appropriate tests
4. **Ensure all tests pass**: Don't commit with failing tests

## Philosophy

These tests treat documentation as first-class code:

- Documentation should be validated like source code
- Structure and consistency matter
- Tests catch regressions in documentation quality
- Automated validation reduces review burden
- Clear tests document expectations

The tests embody a "bias for action" by:
- Providing extensive coverage even for simple documentation
- Validating multiple aspects of each document
- Checking edge cases and potential issues
- Ensuring long-term maintainability

## Troubleshooting

### Tests fail after editing documentation
- Review error messages carefully
- Check if your changes violate stated structure
- Update tests if you intentionally changed structure
- Ensure timestamps are updated

### New file not recognized
- Add the file to appropriate fixtures
- Update `required_files` fixture if it's a core file
- Add specific tests for the new file's purpose

### False positives
- Review test assertions
- Consider if the test is too strict
- Update test to be more flexible if appropriate
- Document exceptions in test comments

## Future Enhancements

Potential test improvements:

- [ ] Schema validation for structured content
- [ ] Link checking for external references
- [ ] Spell checking integration
- [ ] Style guide enforcement
- [ ] Automated formatting checks
- [ ] Performance tests for large documents
- [ ] Accessibility checks for documentation