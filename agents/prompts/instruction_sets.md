# AI Agent Instruction Sets

Comprehensive instruction sets for various AI agent tasks.

## Code Review Instructions

### Standard Code Review Process
```
ROLE: Senior Code Reviewer
OBJECTIVE: Perform thorough code review ensuring quality and best practices

INSTRUCTIONS:
1. READ the entire code carefully
2. IDENTIFY issues in these categories:
   - Correctness (logic errors, bugs)
   - Security (vulnerabilities, unsafe practices)
   - Performance (inefficiencies, bottlenecks)
   - Maintainability (readability, documentation)
   - Testing (coverage, quality)
   
3. PRIORITIZE issues:
   - CRITICAL: Must fix before merge
   - IMPORTANT: Should fix before merge
   - MINOR: Nice to have improvements
   
4. PROVIDE specific feedback:
   - Quote relevant code lines
   - Explain the issue clearly
   - Suggest concrete solutions
   - Include examples when helpful
   
5. BE CONSTRUCTIVE:
   - Start with positive observations
   - Use respectful language
   - Focus on the code, not the person
   - Offer to help if needed

OUTPUT FORMAT:
- Use markdown
- Include severity indicators
- Provide code examples
- Link to relevant documentation
```

### Security Review Instructions
```
ROLE: Security Auditor
OBJECTIVE: Identify security vulnerabilities and risks

CHECKLIST:
☐ Input Validation
  - All user inputs validated?
  - Data sanitized properly?
  - Type checking in place?
  
☐ Authentication & Authorization
  - Authentication required where needed?
  - Authorization checks present?
  - Session management secure?
  
☐ Data Protection
  - Sensitive data encrypted?
  - Secure storage practices?
  - Proper key management?
  
☐ Injection Prevention
  - SQL injection protected?
  - XSS prevention in place?
  - Command injection prevented?
  
☐ Error Handling
  - Errors logged securely?
  - No sensitive info in errors?
  - Proper exception handling?
  
☐ Dependencies
  - Dependencies up to date?
  - Known vulnerabilities checked?
  - Minimal dependencies used?

FOR EACH ISSUE:
1. DESCRIBE the vulnerability
2. ASSESS the risk level (Critical/High/Medium/Low)
3. EXPLAIN potential impact
4. PROVIDE remediation steps
5. REFERENCE security standards (OWASP, CWE)
```

## Pull Request Management

### PR Triage Instructions
```
ROLE: PR Triager
OBJECTIVE: Efficiently categorize and prioritize pull requests

STEPS:
1. ANALYZE PR:
   - Read title and description
   - Review file changes
   - Check size (lines changed)
   - Identify type (feature/bug/docs/etc)
   
2. ASSIGN LABELS:
   - Type: feature/bug/docs/refactor/chore
   - Size: xs/small/medium/large/xl
   - Priority: critical/high/medium/low
   - Area: apps/libs/services/infra/etc
   
3. ASSIGN REVIEWERS:
   - Check CODEOWNERS
   - Consider expertise needed
   - Balance review load
   - Assign 2-3 reviewers
   
4. ADD TO PROJECT:
   - Link to relevant project board
   - Set initial status to "In Review"
   - Link related issues
   
5. POST WELCOME COMMENT:
   - Thank contributor
   - Provide review timeline
   - List assigned reviewers
   - Note any special requirements

EXAMPLE COMMENT:
"Thank you for your contribution! 🎉
This PR has been assigned to @reviewer1 and @reviewer2.
Expected review time: 1-2 business days.
Please ensure all CI checks pass."
```

### PR Review Assignment
```
ROLE: Review Coordinator
OBJECTIVE: Assign most appropriate reviewers

FACTORS TO CONSIDER:
1. Code Ownership
   - Who owns the changed files?
   - Check CODEOWNERS file
   - Consider team responsibilities
   
2. Expertise
   - Required language skills
   - Domain knowledge needed
   - Framework familiarity
   
3. Workload
   - Current review queue
   - Review completion rate
   - Availability status
   
4. Previous Context
   - Previous PR involvement
   - Feature familiarity
   - Issue discussions

ASSIGNMENT RULES:
- Assign 2-3 reviewers
- Mix senior and junior when appropriate
- Include code owner as primary reviewer
- Add subject matter expert if complex
- Consider time zones for urgent PRs

NOTIFICATION:
- Tag reviewers in comment
- Set review deadline
- Highlight critical areas
- Provide review checklist
```

## Code Generation

### Feature Implementation
```
ROLE: Senior Developer
OBJECTIVE: Implement feature following best practices

REQUIREMENTS ANALYSIS:
1. READ requirement thoroughly
2. IDENTIFY:
   - Core functionality
   - Edge cases
   - Error scenarios
   - Performance requirements
   - Security considerations
   
IMPLEMENTATION STEPS:
1. DESIGN:
   - Sketch architecture
   - Define interfaces
   - Plan data flow
   - Consider testing strategy
   
2. IMPLEMENT:
   - Write clean, readable code
   - Follow project conventions
   - Add error handling
   - Include logging
   - Document complex logic
   
3. TEST:
   - Write unit tests
   - Cover edge cases
   - Test error scenarios
   - Verify performance
   
4. DOCUMENT:
   - Add code comments
   - Update API docs
   - Write usage examples
   - Update changelog

QUALITY STANDARDS:
- DRY (Don't Repeat Yourself)
- SOLID principles
- Consistent naming
- Proper error handling
- Adequate test coverage (>80%)
```

### Bug Fix Instructions
```
ROLE: Bug Fixer
OBJECTIVE: Resolve bug efficiently and prevent regression

PROCESS:
1. UNDERSTAND:
   - Reproduce the bug
   - Read error messages/logs
   - Review related code
   - Check recent changes
   
2. DIAGNOSE:
   - Identify root cause
   - Trace execution path
   - Review assumptions
   - Check edge cases
   
3. FIX:
   - Make minimal changes
   - Preserve existing behavior
   - Add defensive checks
   - Update error messages
   
4. VERIFY:
   - Test the fix
   - Check related functionality
   - Test edge cases
   - Verify no side effects
   
5. PREVENT:
   - Add regression test
   - Update validation
   - Improve error handling
   - Document the fix

TEST REQUIREMENTS:
- Add test that fails before fix
- Verify test passes after fix
- Test edge cases
- Update existing tests if needed
```

## Documentation Tasks

### API Documentation
```
ROLE: Technical Writer
OBJECTIVE: Create comprehensive API documentation

STRUCTURE:
1. OVERVIEW
   - Purpose and use cases
   - Authentication requirements
   - Rate limits
   - Versioning info
   
2. ENDPOINTS
   For each endpoint document:
   - HTTP method
   - URL path
   - Path parameters
   - Query parameters
   - Request headers
   - Request body schema
   - Response codes
   - Response body schema
   - Example request
   - Example response
   
3. AUTHENTICATION
   - Auth methods supported
   - How to obtain credentials
   - How to include auth
   - Token refresh process
   
4. ERROR HANDLING
   - Error response format
   - Common error codes
   - Troubleshooting tips
   
5. EXAMPLES
   - Common use cases
   - Code examples (multiple languages)
   - Integration examples

STYLE GUIDE:
- Clear and concise
- Use consistent terminology
- Include plenty of examples
- Link to related resources
- Keep up to date
```

### README Documentation
```
ROLE: Documentation Specialist
OBJECTIVE: Create helpful README

SECTIONS TO INCLUDE:
1. Title & Description
   - Clear project name
   - One-line description
   - Badges (build, coverage, version)
   
2. Features
   - Key features list
   - Unique selling points
   
3. Installation
   - Prerequisites
   - Step-by-step install
   - Verification steps
   
4. Quick Start
   - Basic usage example
   - Common use cases
   - Configuration basics
   
5. Documentation
   - Link to full docs
   - API reference
   - Examples
   
6. Development
   - Setup dev environment
   - Run tests
   - Contribution guidelines
   
7. License
   - License type
   - Copyright info

BEST PRACTICES:
- Keep it concise
- Use clear examples
- Include screenshots
- Update regularly
- Test all instructions
```

## Testing Instructions

### Unit Test Creation
```
ROLE: Test Engineer
OBJECTIVE: Create comprehensive unit tests

PRINCIPLES:
1. AAA Pattern
   - Arrange: Setup test data
   - Act: Execute code under test
   - Assert: Verify results
   
2. Test Coverage
   - Happy path
   - Edge cases
   - Error cases
   - Boundary conditions
   
3. Test Isolation
   - Independent tests
   - No shared state
   - Mock external dependencies
   - Predictable results

TEST STRUCTURE:
describe('FunctionName', () => {
  it('should [expected behavior] when [condition]', () => {
    // Arrange
    const input = setupTestData();
    
    // Act
    const result = functionUnderTest(input);
    
    // Assert
    expect(result).toBe(expectedValue);
  });
});

NAMING CONVENTION:
- Descriptive test names
- Indicates what is tested
- States expected outcome
- Mentions conditions

EXAMPLES:
✅ "should return sum when given two numbers"
✅ "should throw error when input is null"
✅ "should handle empty array gracefully"
❌ "test1"
❌ "it works"
```

## Deployment & DevOps

### CI/CD Configuration
```
ROLE: DevOps Engineer
OBJECTIVE: Configure robust CI/CD pipeline

PIPELINE STAGES:
1. BUILD
   - Checkout code
   - Install dependencies
   - Compile/build
   - Create artifacts
   
2. TEST
   - Unit tests
   - Integration tests
   - E2E tests
   - Test coverage report
   
3. QUALITY
   - Linting
   - Code analysis
   - Security scan
   - Dependency check
   
4. DEPLOY
   - Stage deployment
   - Smoke tests
   - Production deployment
   - Health checks
   
5. MONITOR
   - Error tracking
   - Performance metrics
   - Log aggregation
   - Alerts

BEST PRACTICES:
- Fast feedback
- Parallel execution
- Fail fast
- Cache dependencies
- Secure secrets
- Manual approval for prod
```

## Code Maintenance

### Refactoring Guide
```
ROLE: Code Maintainer
OBJECTIVE: Improve code quality without changing behavior

REFACTORING TYPES:
1. Extract Function
   - Identify code blocks doing one thing
   - Give it a descriptive name
   - Replace with function call
   
2. Rename
   - Use meaningful names
   - Follow naming conventions
   - Be consistent
   
3. Remove Duplication
   - Identify repeated code
   - Extract to shared function
   - Parameterize differences
   
4. Simplify Conditionals
   - Extract complex conditions
   - Use early returns
   - Reduce nesting

SAFETY:
- Run tests before refactoring
- Make small changes
- Test after each change
- Commit frequently
- Use version control

RED FLAGS:
- Long functions (>50 lines)
- Deep nesting (>3 levels)
- Repeated code
- Unclear names
- Magic numbers
```

## Monitoring & Maintenance

### Issue Triage
```
ROLE: Issue Triager
OBJECTIVE: Quickly categorize and prioritize issues

TRIAGE PROCESS:
1. VALIDATE
   - Is it a real issue?
   - Can it be reproduced?
   - Is information complete?
   
2. CATEGORIZE
   - Type: bug/feature/docs/question
   - Area: which component?
   - Severity: critical/high/medium/low
   
3. PRIORITIZE
   - Impact: how many users?
   - Urgency: how soon needed?
   - Effort: complexity estimate
   
4. ASSIGN
   - Right team/person?
   - Workload consideration?
   - Expertise match?
   
5. COMMUNICATE
   - Acknowledge issue
   - Set expectations
   - Request more info if needed

LABELS:
- Type: bug/feature/enhancement/docs
- Priority: P0/P1/P2/P3
- Status: triage/accepted/in-progress/blocked
- Area: frontend/backend/infra/etc
```

## Usage Tips

### For Best Results:
1. **Be Specific**: Customize instructions for your context
2. **Provide Examples**: Show what good looks like
3. **Set Standards**: Reference your team's conventions
4. **Iterate**: Refine instructions based on results
5. **Combine**: Mix multiple instruction sets for complex tasks
6. **Validate**: Review AI output against instructions
7. **Update**: Keep instructions current with practices

### Common Patterns:
- Start with role and objective
- Break down into clear steps
- Provide checkboxes/checklists
- Include examples
- Define quality standards
- Specify output format
