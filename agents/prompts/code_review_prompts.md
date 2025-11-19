# Code Review Prompts Library

This library contains reusable prompts for AI-powered code review tasks.

## General Code Review

### Basic Code Review
```
Review the following code and provide feedback on:
1. Code correctness and logic
2. Potential bugs or edge cases
3. Code style and readability
4. Best practices adherence
5. Suggested improvements

Code:
{code}
```

### Security-Focused Review
```
Perform a security review of the following code. Focus on:
1. Input validation and sanitization
2. Authentication and authorization
3. SQL injection vulnerabilities
4. XSS (Cross-Site Scripting) risks
5. CSRF protection
6. Sensitive data handling
7. Cryptography usage
8. Third-party dependencies security

Code:
{code}
```

### Performance Review
```
Analyze the following code for performance issues:
1. Time complexity analysis
2. Space complexity analysis
3. Database query optimization
4. Caching opportunities
5. Unnecessary computations
6. Resource usage
7. Scalability concerns

Code:
{code}
```

## Language-Specific Reviews

### Python Review
```
Review this Python code considering:
1. PEP 8 style compliance
2. Pythonic idioms and patterns
3. Type hints usage
4. Exception handling
5. Generator vs list usage
6. Context managers
7. Dependency management

Code:
{code}
```

### JavaScript/TypeScript Review
```
Review this JavaScript/TypeScript code considering:
1. ES6+ features usage
2. TypeScript type safety
3. Async/await vs promises
4. Memory leaks (closures, event listeners)
5. Bundle size impact
6. Browser compatibility
7. React/Node.js best practices

Code:
{code}
```

### Go Review
```
Review this Go code considering:
1. Idiomatic Go patterns
2. Error handling
3. Goroutine and channel usage
4. Interface design
5. Memory allocation
6. Testing practices
7. Package organization

Code:
{code}
```

## Specialized Reviews

### API Review
```
Review this API implementation:
1. RESTful design principles
2. HTTP methods usage
3. Status codes appropriateness
4. Request/response validation
5. Error handling and messages
6. API versioning
7. Rate limiting
8. Documentation completeness

Code:
{code}
```

### Database Review
```
Review this database-related code:
1. Query efficiency and optimization
2. Index usage
3. Transaction handling
4. Connection pooling
5. N+1 query problems
6. Data integrity constraints
7. Migration safety

Code:
{code}
```

### Test Review
```
Review these tests for:
1. Test coverage
2. Test isolation
3. Arrange-Act-Assert pattern
4. Edge cases coverage
5. Mock usage appropriateness
6. Test naming clarity
7. Test maintainability
8. Performance testing

Code:
{code}
```

## Pull Request Reviews

### PR Summary
```
Analyze this pull request and provide:
1. High-level summary of changes (2-3 sentences)
2. Type of change (feature, bugfix, refactor, etc.)
3. Complexity assessment (simple, moderate, complex)
4. Risk level (low, medium, high)
5. Recommended reviewers based on expertise needed
6. Estimated review time

PR Title: {title}
PR Description: {description}
Files Changed: {files}
Diff: {diff}
```

### PR Checklist
```
Create a review checklist for this PR:
1. Code quality items to verify
2. Testing requirements
3. Documentation updates needed
4. Breaking changes to note
5. Security considerations
6. Performance implications
7. Deployment considerations

PR: {pr_url}
```

### Merge Readiness
```
Evaluate if this PR is ready to merge:
1. All review comments addressed?
2. CI/CD passing?
3. Conflicts resolved?
4. Tests adequate?
5. Documentation updated?
6. Breaking changes documented?
7. Changelog updated?

Provide a merge recommendation: READY / NOT READY / CONDITIONALLY READY
```

## Code Improvement Prompts

### Refactoring Suggestions
```
Suggest refactoring opportunities for:
1. Code duplication reduction
2. Function decomposition
3. Design pattern application
4. Abstraction improvements
5. Naming improvements
6. Code organization

Code:
{code}
```

### Code Modernization
```
Suggest how to modernize this code:
1. Use newer language features
2. Replace deprecated APIs
3. Improve async handling
4. Update dependencies
5. Enhance type safety
6. Improve error handling

Code:
{code}

Current Version: {version}
Target Version: {target_version}
```

## Documentation Review

### Documentation Completeness
```
Review documentation for:
1. Completeness and accuracy
2. Examples provided
3. API documentation
4. Usage instructions
5. Configuration options
6. Troubleshooting guides
7. Architecture diagrams

Documentation:
{docs}
```

### README Review
```
Review this README for:
1. Clear project description
2. Installation instructions
3. Usage examples
4. Contributing guidelines
5. License information
6. Badges and status indicators
7. Links to documentation

README:
{readme}
```

## Architecture Review

### Architecture Assessment
```
Review this architectural design:
1. System architecture overview
2. Component interactions
3. Data flow analysis
4. Scalability considerations
5. Security architecture
6. Performance characteristics
7. Maintainability concerns
8. Technology choices

Design:
{design}
```

### Microservices Review
```
Review this microservice design:
1. Service boundaries
2. API contracts
3. Data ownership
4. Communication patterns
5. Error handling and resilience
6. Monitoring and observability
7. Deployment strategy

Service:
{service_description}
```

## Usage Examples

### Example 1: Quick Code Review
```
I need a quick review of this function:

{code}

Focus on correctness and any obvious issues.
```

### Example 2: Comprehensive Review
```
Please perform a comprehensive review of this PR:

PR: {pr_url}

Include:
- Code quality assessment
- Security analysis
- Performance considerations
- Test coverage review
- Documentation review

Priority: High
Estimated size: {lines_changed} lines changed
```

### Example 3: Follow-up Review
```
This code was previously reviewed. Please verify that the following concerns were addressed:

Previous Issues:
{previous_issues}

Updated Code:
{updated_code}
```

## Tips for Effective Prompts

1. **Be Specific**: Clearly state what aspect you want reviewed
2. **Provide Context**: Include relevant background information
3. **Set Priorities**: Indicate what's most important
4. **Include Examples**: Show what good looks like
5. **Define Scope**: Limit the review to manageable size
6. **Request Format**: Specify desired output format
7. **Set Tone**: Indicate desired feedback style (constructive, detailed, etc.)

## Customization

These prompts can be customized by:
- Adding project-specific guidelines
- Including coding standards
- Referencing style guides
- Adding domain-specific requirements
- Incorporating team preferences
