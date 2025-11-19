# AI Agent Operation Rules

**Version:** 1.0  
**Last Updated:** 2025-11-19  
**Status:** Active  

This document defines the comprehensive operational rules for all AI agents working within this repository. All agents MUST follow these rules without exception.

---

## 1. Core Principles

### 1.1 Task Focus & Drift Prevention
- **ALWAYS** state the current task at the beginning of each work session
- **REMIND** yourself of the primary objective every 15 minutes of work
- **LOG** any deviation from the planned task path to `journal.md`
- **VERIFY** task alignment before starting any new subtask
- **ESCALATE** to human oversight if task scope expands beyond original requirements
- **REFERENCE** `tasks.md` continuously to maintain alignment with planned work

### 1.2 Transparency & Accountability
- **ALL** reasoning, thoughts, and decisions MUST be logged to `journal.md`
- **EVERY** agent action must include a timestamp and agent identifier
- **SIGN OFF** on completed work with agent name and timestamp
- **DOCUMENT** failures, blockers, and unexpected behaviors immediately
- **MAINTAIN** an audit trail of all file modifications

### 1.3 Quality & Verification
- **TEST** all changes before marking tasks as complete
- **VALIDATE** against acceptance criteria defined in `tasks.md`
- **RUN** all relevant automated tests (pytest, jest, unit tests)
- **DOCUMENT** test results with pass/fail status and evidence
- **NEVER** mark a task complete without demonstrable proof of completion

---

## 2. File Management & Permissions

### 2.1 File Access Rules

#### Editable Files (Read/Write)
- `rules.md` - Operational rules (update frequency: as needed, minimum monthly review)
- `agents.md` - Master agent control file (update with each new pattern or rule)
- `tasks.md` - Task list and tracking (update continuously during work)
- `project_summary.md` - High-level project overview (update on major milestones)
- `srs.md` - Software Requirements Specification (update when requirements change)
- `features.md` - Feature tracking (update when features are added/modified/completed)
- `README.md` - Agent folder documentation (update when structure changes)

#### Append-Only Files
- `journal.md` - Activity log (NEVER edit existing entries, only append new ones)

#### Protected Files
- `.git/` - Version control system (managed through git commands only)
- Configuration files in parent directories (require explicit permission)

### 2.2 File Update Frequency

| File | Minimum Frequency | Trigger Events |
|------|------------------|----------------|
| `journal.md` | Every action | Any agent activity, decision, or communication |
| `tasks.md` | Daily | Task completion, new task creation, status changes |
| `agents.md` | Weekly | New patterns identified, rule clarifications needed |
| `rules.md` | Monthly | Process improvements, new requirements, lessons learned |
| `project_summary.md` | Per milestone | Major feature completion, architecture changes |
| `srs.md` | Per sprint/iteration | Requirement changes, stakeholder feedback |
| `features.md` | Per feature change | Feature added, modified, completed, or deprecated |

### 2.3 Git Backup Procedures
- **COMMIT** all changes to `tasks.md` at the end of each work session
- **BACKUP** to git after completing any task or subtask
- **PUSH** changes to remote repository at least once per session
- **CREATE** meaningful commit messages that reference task IDs
- **TAG** major milestones with semantic version numbers
- **NEVER** commit sensitive data, credentials, or secrets

---

## 3. Task Management

### 3.1 Task Structure in tasks.md

Each task MUST include:

```markdown
## Task ID: [UNIQUE_ID]
**Status:** [TODO | IN_PROGRESS | BLOCKED | COMPLETED]
**Priority:** [P0 | P1 | P2 | P3]
**Assigned Agent:** [Agent Name/ID]
**Created:** [ISO 8601 Timestamp]
**Updated:** [ISO 8601 Timestamp]
**Completed:** [ISO 8601 Timestamp or N/A]

### Description
[Clear, concise description of what needs to be done]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Microgoals
1. **Microgoal 1:** [Description]
   - **Completion Criteria:** [Specific, measurable criteria]
   - **Tests:** [Test file path or test command]
   - **Status:** [TODO | DONE]
   - **Signed Off:** [Agent Name, Timestamp]

2. **Microgoal 2:** [Description]
   - **Completion Criteria:** [Specific, measurable criteria]
   - **Tests:** [Test file path or test command]
   - **Status:** [TODO | DONE]
   - **Signed Off:** [Agent Name, Timestamp]

### Test Evidence
- **Test Type:** [Unit | Integration | E2E | Manual]
- **Test Command:** `[command to run tests]`
- **Test Results:** [Link to test output or inline results]
- **Coverage:** [Coverage percentage if applicable]

### Dependencies
- [List of dependent tasks or external dependencies]

### Blockers
- [Current blockers or N/A]

### Agent Sign-Off
**Completed By:** [Agent Name/ID]
**Timestamp:** [ISO 8601 Timestamp]
**Verification Method:** [How completion was verified]
**Notes:** [Any additional context or observations]
```

### 3.2 Task Quality Requirements

Tasks must be:
- **COMPREHENSIVE:** Cover all aspects of the requirement
- **REPEATABLE:** Another agent can execute the task with the same results
- **MEASURABLE:** Clear success criteria that can be objectively verified
- **TESTABLE:** Associated with automated or manual tests
- **WELL-FORMED:** Follow the structure template exactly
- **ATOMIC:** Focused on a single, coherent objective

### 3.3 Task Workflow

1. **Review** `tasks.md` to identify next task
2. **Log** task start in `journal.md`
3. **Execute** microgoals sequentially
4. **Test** after each microgoal completion
5. **Document** test results in `tasks.md`
6. **Sign off** on each completed microgoal
7. **Verify** all acceptance criteria met
8. **Update** task status to COMPLETED
9. **Sign off** on overall task
10. **Commit** changes to git
11. **Log** task completion in `journal.md`

---

## 4. Logging & Journaling

### 4.1 Journal Entry Format

All entries to `journal.md` must follow this format:

```markdown
---
**Timestamp:** [ISO 8601 Timestamp]
**Agent:** [Agent Name/ID]
**Action Type:** [TASK_START | TASK_UPDATE | TASK_COMPLETE | DECISION | COMMUNICATION | ERROR | NOTE]
**Task ID:** [Related Task ID or N/A]

### Context
[Brief description of the situation or action]

### Reasoning
[Detailed explanation of thought process and decision-making]

### Action Taken
[Specific action performed or decision made]

### Outcome
[Result of the action or expected outcome]

### Next Steps
[What will happen next or what needs to happen]

---
```

### 4.2 Required Logging Events

MUST log:
- Task start and completion
- All inter-agent communications
- Major decisions and reasoning
- Errors, exceptions, and blockers
- Test execution and results
- File modifications
- Rule interpretations or clarifications
- Deviations from planned approach

SHOULD log:
- Intermediate progress updates
- Resource usage concerns
- Performance observations
- Suggestions for process improvement

### 4.3 Reasoning Dialogue

All reasoning MUST be explicit and logged:
- **STATE** the problem or decision point
- **LIST** available options or approaches
- **EVALUATE** pros and cons of each option
- **CHOOSE** the selected approach with justification
- **DOCUMENT** assumptions made
- **IDENTIFY** risks and mitigation strategies

---

## 5. Inter-Agent Communication

### 5.1 Communication Protocol

When agents need to communicate:

1. **LOG** intent to communicate in `journal.md`
2. **CREATE** communication entry with clear purpose
3. **ADDRESS** specific agent or broadcast to all
4. **INCLUDE** all necessary context
5. **SPECIFY** expected response or action
6. **WAIT** for response before proceeding (if required)
7. **LOG** received response in `journal.md`
8. **ACKNOWLEDGE** receipt and planned action

### 5.2 Communication Entry Format

```markdown
---
**Timestamp:** [ISO 8601 Timestamp]
**From Agent:** [Sender Agent Name/ID]
**To Agent:** [Recipient Agent Name/ID or "ALL"]
**Communication Type:** [REQUEST | RESPONSE | NOTIFICATION | HANDOFF | ESCALATION]
**Priority:** [LOW | NORMAL | HIGH | URGENT]
**Task ID:** [Related Task ID or N/A]

### Subject
[Brief subject line]

### Message
[Detailed message content]

### Required Action
[What the recipient should do, or N/A]

### Response Deadline
[When response is needed, or N/A]

### Response
[To be filled by recipient agent]
**Response By:** [Agent Name/ID]
**Response Time:** [ISO 8601 Timestamp]
**Response Content:** [Response message]

---
```

### 5.3 Communication Best Practices

- **BE SPECIFIC:** Clearly state what you need
- **PROVIDE CONTEXT:** Include relevant background information
- **SET EXPECTATIONS:** Define response timeframe if time-sensitive
- **CONFIRM UNDERSTANDING:** Verify critical information is received correctly
- **CLOSE LOOP:** Confirm when communication objective is achieved
- **AVOID DUPLICATION:** Check journal.md before re-asking questions

---

## 6. Testing Requirements

### 6.1 Test-Driven Task Completion

ALL tasks must have associated tests:

1. **IDENTIFY** test type needed (unit, integration, E2E, manual)
2. **CREATE** or identify existing tests
3. **RUN** tests before making changes (baseline)
4. **MAKE** changes incrementally
5. **RUN** tests after each change
6. **FIX** failing tests immediately
7. **DOCUMENT** test results in `tasks.md`
8. **COMMIT** code and tests together

### 6.2 Test Types & When to Use

| Test Type | When to Use | Example Command |
|-----------|-------------|-----------------|
| **Unit Tests** | Individual functions/methods | `pytest tests/unit/` or `npm test` |
| **Integration Tests** | Component interactions | `pytest tests/integration/` |
| **End-to-End Tests** | Full user workflows | `npm run test:e2e` |
| **Manual Tests** | UI/UX, complex scenarios | Document steps and results |
| **Performance Tests** | Speed, resource usage | `pytest tests/performance/` |
| **Security Tests** | Vulnerabilities, auth | `npm run test:security` |

### 6.3 Test Documentation

For each test execution, document:
- **Test command:** Exact command run
- **Test results:** Pass/fail status
- **Test output:** Relevant output or log file reference
- **Coverage:** Code coverage metrics if available
- **Duration:** How long tests took to run
- **Environment:** Test environment details
- **Timestamp:** When tests were executed

### 6.4 Test Failure Protocol

When tests fail:
1. **LOG** failure immediately to `journal.md`
2. **ANALYZE** failure cause
3. **DETERMINE** if failure is related to your changes
4. **FIX** if caused by your changes
5. **ESCALATE** if pre-existing or blocking
6. **DOCUMENT** resolution approach
7. **VERIFY** fix with test re-run
8. **NEVER** disable or skip failing tests without explicit permission

---

## 7. Connection & External Systems

### 7.1 SSH Connections

When SSH access is required:
- **LOG** connection intent and purpose to `journal.md`
- **VERIFY** connection is necessary for task
- **USE** configured SSH keys (never generate new ones without permission)
- **DOCUMENT** commands executed on remote systems
- **CLOSE** connections when complete
- **NEVER** store credentials in code or logs

### 7.2 MCP (Model Context Protocol) Servers

When using MCP servers:
- **IDENTIFY** required MCP server capabilities
- **VERIFY** server availability before relying on it
- **LOG** all MCP server interactions to `journal.md`
- **HANDLE** connection failures gracefully
- **DOCUMENT** server endpoints and configurations used
- **CACHE** responses when appropriate to reduce load

### 7.3 External API Integration

For external APIs:
- **DOCUMENT** API usage in project documentation
- **STORE** API keys in secure credential management (never in code)
- **IMPLEMENT** rate limiting and retry logic
- **LOG** API calls and responses (sanitize sensitive data)
- **HANDLE** errors and timeouts appropriately
- **MONITOR** usage against quotas

---

## 8. Sub-Agent Management

### 8.1 Sub-Agent Creation

When creating or invoking sub-agents:
- **DEFINE** clear scope and objectives
- **ASSIGN** specific task from `tasks.md`
- **PROVIDE** necessary context and resources
- **ESTABLISH** communication protocol
- **SET** check-in frequency
- **LOG** sub-agent creation to `journal.md`

### 8.2 Sub-Agent Communication

- **ALL** sub-agent communications MUST be logged to `journal.md`
- **USE** structured communication format (see Section 5.2)
- **MAINTAIN** parent-child relationship clarity
- **ESCALATE** blockers from sub-agent to parent
- **CONSOLIDATE** sub-agent reports in parent task updates

### 8.3 Sub-Agent Coordination

For multiple sub-agents:
- **ASSIGN** non-overlapping responsibilities
- **COORDINATE** dependencies between sub-agents
- **MONITOR** progress of all sub-agents
- **SYNCHRONIZE** at defined checkpoints
- **CONSOLIDATE** results before task completion

---

## 9. Document Hierarchy & Relationships

### 9.1 Strategic Documents (Balance Sheet View)

These documents define WHERE the project should be:

- **`srs.md`** - Software Requirements Specification
  - Defines WHAT needs to be built
  - Requirements are numbered and traceable
  - Updated when project scope changes
  - High-level, not implementation details

- **`features.md`** - Feature Tracking
  - Lists all planned, in-progress, and completed features
  - Links features to SRS requirements
  - Tracks feature status and acceptance
  - High-level feature descriptions

### 9.2 Tactical Documents (Income/Cash Flow View)

These documents define HOW we get there:

- **`tasks.md`** - Task Tracking
  - Breaks down features into executable tasks
  - Includes microgoals and test criteria
  - Tracks day-to-day progress
  - Implementation-focused details

- **`project_summary.md`** - Executive Summary
  - Current state of the project
  - Progress against strategic goals
  - Active initiatives and priorities
  - Bridges strategic and tactical views

### 9.3 Operational Documents

These documents define HOW we work:

- **`agents.md`** - Master control file (see Section 10)
- **`rules.md`** - This document
- **`journal.md`** - Activity log
- **`README.md`** - Quick reference and getting started

### 9.4 Document Abstraction

- **SRS and Features** are fully abstracted by Tasks and Project Summary
- **Tasks** translate high-level features into concrete actions
- **Project Summary** translates task progress into strategic status
- **Never duplicate** information between documents; use references
- **Maintain bidirectional traceability** (task → feature → requirement)

---

## 10. Agent Control File (agents.md)

The `agents.md` file is the MASTER control document. It MUST:

### 10.1 Required Sections

1. **Agent Onboarding**
   - How to start working in this project
   - Required reading (this file, tasks.md, etc.)
   - Initial setup and verification steps

2. **Rules Reference**
   - Pointer to `rules.md` with key highlights
   - How to interpret and apply rules
   - Escalation procedures for rule ambiguity

3. **Task Management**
   - How to use `tasks.md`
   - Task selection criteria
   - Task update procedures

4. **Journaling Requirements**
   - Mandatory logging events
   - Journal entry formats
   - How to search/reference journal history

5. **Communication Protocols**
   - How to communicate with other agents
   - Response time expectations
   - Escalation paths

6. **Document Management**
   - When and how to update each document
   - Document review schedule
   - Approval requirements

7. **Emergency Procedures**
   - What to do when blocked
   - How to handle critical errors
   - Who to escalate to and how

### 10.2 Maintenance Requirements

- **UPDATE** `agents.md` when new patterns emerge
- **REVIEW** monthly for accuracy and completeness
- **VERSION** major changes with timestamps
- **NEVER DELETE** historical sections; archive them
- **TIMESTAMP** all updates with agent sign-off

---

## 11. Quality Assurance

### 11.1 Pre-Commit Checklist

Before committing any work:
- [ ] All acceptance criteria met
- [ ] Tests written and passing
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] `tasks.md` updated with completion status
- [ ] `journal.md` updated with activities
- [ ] No debug code or comments left in
- [ ] No secrets or credentials in code
- [ ] Git commit message is descriptive

### 11.2 Task Completion Checklist

Before marking a task as COMPLETED:
- [ ] All microgoals completed and signed off
- [ ] All tests pass
- [ ] Test evidence documented
- [ ] Code reviewed (if applicable)
- [ ] Documentation updated
- [ ] Changes committed to git
- [ ] Task sign-off completed with timestamp
- [ ] Journal entries updated
- [ ] Next task identified

### 11.3 Session End Checklist

At the end of each work session:
- [ ] All changes committed
- [ ] All changes pushed to remote
- [ ] `tasks.md` reflects current state
- [ ] `journal.md` has session summary
- [ ] Open items documented
- [ ] Blockers escalated
- [ ] Handoff notes prepared (if needed)

---

## 12. Emergency Procedures

### 12.1 Critical Errors

If a critical error occurs:
1. **STOP** current work immediately
2. **LOG** error to `journal.md` with full details
3. **ASSESS** impact and severity
4. **CONTAIN** damage if possible
5. **ESCALATE** to human oversight immediately
6. **DOCUMENT** steps taken and current state
7. **WAIT** for guidance before proceeding

### 12.2 Blocking Issues

If blocked on a task:
1. **DOCUMENT** blocker in `tasks.md` and `journal.md`
2. **ATTEMPT** alternative approaches (document attempts)
3. **SEARCH** journal history for similar issues
4. **COMMUNICATE** with other agents if relevant
5. **ESCALATE** if blocked for >30 minutes
6. **MOVE** to different task while waiting

### 12.3 Rule Conflicts

If rules conflict or are unclear:
1. **DOCUMENT** the conflict in `journal.md`
2. **APPLY** the most conservative interpretation
3. **ESCALATE** for clarification
4. **DO NOT** proceed with ambiguous actions
5. **PROPOSE** rule clarification for `rules.md`

---

## 13. Continuous Improvement

### 13.1 Learning from Experience

- **CAPTURE** lessons learned in `journal.md`
- **PROPOSE** rule improvements based on experience
- **SHARE** successful patterns with other agents
- **DOCUMENT** failure modes and preventions
- **UPDATE** `agents.md` with new best practices

### 13.2 Rule Updates

To propose a rule update:
1. **DOCUMENT** current limitation or issue
2. **PROPOSE** specific rule change or addition
3. **JUSTIFY** why change improves operations
4. **LOG** proposal to `journal.md`
5. **WAIT** for approval before applying
6. **UPDATE** `rules.md` once approved
7. **COMMUNICATE** change to all agents

### 13.3 Process Optimization

Continuously look for:
- Repetitive manual tasks that could be automated
- Ambiguous processes that cause confusion
- Bottlenecks in the workflow
- Opportunities to reduce overhead
- Ways to improve communication efficiency

---

## 14. Compliance & Audit

### 14.1 Audit Trail

Every action must be traceable:
- **WHO:** Agent identifier in all logs
- **WHAT:** Specific action taken
- **WHEN:** ISO 8601 timestamp
- **WHY:** Reasoning and context
- **HOW:** Method and approach used

### 14.2 Periodic Review

Monthly review requirements:
- Review all journal entries for patterns
- Verify all completed tasks have proper sign-off
- Check all documents are up to date
- Validate git backup integrity
- Audit rule compliance
- Identify improvement opportunities

### 14.3 Compliance Verification

Randomly verify:
- Journal entries follow format
- Task structure matches template
- Test evidence is documented
- Git commits are meaningful
- Communication is logged
- Rules are being followed

---

## 15. Starter Kit Checklist

When starting a new project with this framework:

- [ ] Copy all template files to project
- [ ] Initialize git repository
- [ ] Create initial `project_summary.md`
- [ ] Create initial `srs.md` with requirements
- [ ] Create initial `features.md` with planned features
- [ ] Create `tasks.md` with first tasks
- [ ] Create `journal.md` with first entry
- [ ] Create `agents.md` with project-specific guidance
- [ ] Copy `rules.md` (this file)
- [ ] Update `README.md` with quick start
- [ ] Set up test framework
- [ ] Configure git hooks (if applicable)
- [ ] Document project-specific conventions
- [ ] Perform initial commit
- [ ] Begin first task

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-19 | Initial comprehensive ruleset | AI Agent Framework |

---

## Quick Reference Card

**Key Rules to Remember:**
1. ✅ Always state current task before starting work
2. 📝 Log ALL actions and reasoning to journal.md
3. 🎯 Focus on task completion, avoid drift
4. ✅ Test everything before marking complete
5. 💾 Backup to git frequently
6. 📋 Update tasks.md continuously
7. 🔒 journal.md is append-only
8. 👥 Log all inter-agent communications
9. ⏰ Timestamp and sign off all work
10. 🚨 Escalate blockers quickly

**Document Update Frequencies:**
- journal.md: Every action
- tasks.md: Daily minimum
- agents.md: Weekly minimum
- rules.md: Monthly review

**Emergency Contact:**
- Critical errors: STOP and escalate immediately
- Blockers: Document and escalate after 30 minutes
- Rule conflicts: Conservative interpretation, then escalate

---

## 16. Advanced Topics & Best Practices

### 16.1 Performance Optimization

**Code Efficiency:**
- Profile code before optimizing (measure, don't guess)
- Document optimization decisions with benchmarks
- Consider readability vs. performance trade-offs
- Log performance improvements in journal.md

**Resource Management:**
- Monitor memory usage for long-running processes
- Clean up temporary files and resources
- Close file handles, database connections properly
- Document resource constraints in tasks.md

**Parallel Processing:**
- Identify tasks that can run concurrently
- Document parallelization strategies in journal.md
- Test parallel code thoroughly for race conditions
- Use appropriate synchronization mechanisms

### 16.2 Error Handling Strategies

**Defensive Programming:**
- Validate all inputs before processing
- Check return values and handle errors explicitly
- Use appropriate exception types
- Document error handling patterns in journal.md

**Error Recovery:**
- Implement graceful degradation where possible
- Log all errors with full context (stack traces, variables)
- Provide actionable error messages
- Document recovery procedures in tasks.md

**Error Categories:**

| Category | Response | Example | Documentation |
|----------|----------|---------|---------------|
| **Transient** | Retry with backoff | Network timeout | Log retry attempts |
| **User Error** | Return clear message | Invalid input | Document validation rules |
| **System Error** | Log and escalate | Out of memory | Document system requirements |
| **Logic Error** | Fix immediately | Off-by-one | Document fix and test |

### 16.3 Code Style & Conventions

**Naming Conventions:**
- Use descriptive, intention-revealing names
- Follow language-specific conventions (PEP 8, ESLint, etc.)
- Be consistent within each codebase
- Document project-specific conventions

**Code Organization:**
- Group related functionality together
- Keep functions/methods focused and small
- Use appropriate abstraction levels
- Document architectural decisions in journal.md

**Comments & Documentation:**
- Write self-documenting code when possible
- Add comments for "why" not "what"
- Document complex algorithms and business logic
- Keep documentation synchronized with code

**Example - Good vs. Poor Naming:**
```python
# Poor
def calc(x, y):
    return x * y * 0.08

# Good
def calculate_sales_tax(subtotal, quantity):
    TAX_RATE = 0.08
    return subtotal * quantity * TAX_RATE
```

### 16.4 Security Best Practices

**Input Validation:**
- Never trust user input
- Validate, sanitize, and escape all inputs
- Use parameterized queries for databases
- Document validation rules in code

**Authentication & Authorization:**
- Never hardcode credentials
- Use environment variables or secret managers
- Implement principle of least privilege
- Log authentication attempts (without credentials)

**Data Protection:**
- Encrypt sensitive data at rest and in transit
- Use secure communication protocols (HTTPS, TLS)
- Implement proper session management
- Document security measures in srs.md

**Security Checklist:**
- [ ] No credentials in code or logs
- [ ] Input validation implemented
- [ ] SQL injection prevented
- [ ] XSS attacks prevented
- [ ] CSRF protection enabled
- [ ] Dependencies regularly updated
- [ ] Security headers configured

### 16.5 Testing Strategies

**Test Pyramid:**
```
         /\
        /E2E\      <- Few (slow, expensive)
       /------\
      /Integr.\   <- Some (medium speed/cost)
     /----------\
    /   Unit     \ <- Many (fast, cheap)
   /--------------\
```

**Unit Testing Best Practices:**
- Test one thing per test
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Mock external dependencies
- Aim for high coverage (>80%)

**Integration Testing:**
- Test component interactions
- Use test databases/services
- Clean up test data after each test
- Document integration test setup

**End-to-End Testing:**
- Test critical user workflows
- Use realistic test data
- Test against staging environment
- Document E2E test scenarios

**Example Test Structure:**
```python
def test_calculate_sales_tax_returns_correct_amount():
    # Arrange
    subtotal = 100.00
    quantity = 2
    expected_tax = 16.00
    
    # Act
    actual_tax = calculate_sales_tax(subtotal, quantity)
    
    # Assert
    assert actual_tax == expected_tax
```

### 16.6 Debugging Techniques

**Systematic Debugging:**
1. **Reproduce** the issue consistently
2. **Isolate** the failing component
3. **Hypothesize** the root cause
4. **Test** the hypothesis
5. **Fix** the issue
6. **Verify** the fix works
7. **Document** in journal.md

**Debugging Tools:**
- Use debuggers (pdb, gdb, Chrome DevTools)
- Add strategic logging statements
- Use print statements sparingly
- Remove debug code before committing

**Common Debugging Patterns:**

| Problem | Technique | Example |
|---------|-----------|---------|
| **Crash** | Stack trace analysis | Check exception message and line |
| **Wrong output** | Print intermediate values | Log calculation steps |
| **Performance** | Profiling | Use cProfile, Chrome Profiler |
| **Intermittent** | Logging + reproduction | Add extensive logging |

### 16.7 Refactoring Guidelines

**When to Refactor:**
- Code is duplicated in multiple places
- Functions are too long (>50 lines)
- Classes have too many responsibilities
- Code is difficult to understand
- Before adding new features to messy code

**Refactoring Process:**
1. **Ensure tests pass** before refactoring
2. **Make small changes** incrementally
3. **Run tests** after each change
4. **Commit frequently** with clear messages
5. **Document** refactoring decisions in journal.md

**Common Refactorings:**
- Extract Method: Pull code into new function
- Extract Variable: Name magic numbers/strings
- Rename: Use more descriptive names
- Remove Duplication: Create shared functions
- Simplify Conditionals: Use guard clauses

**Example - Extract Method:**
```python
# Before
def process_order(order):
    total = 0
    for item in order.items:
        total += item.price * item.quantity
    tax = total * 0.08
    shipping = 10 if total < 100 else 0
    return total + tax + shipping

# After
def process_order(order):
    subtotal = calculate_subtotal(order.items)
    tax = calculate_tax(subtotal)
    shipping = calculate_shipping(subtotal)
    return subtotal + tax + shipping

def calculate_subtotal(items):
    return sum(item.price * item.quantity for item in items)

def calculate_tax(subtotal):
    TAX_RATE = 0.08
    return subtotal * TAX_RATE

def calculate_shipping(subtotal):
    FREE_SHIPPING_THRESHOLD = 100
    STANDARD_SHIPPING = 10
    return 0 if subtotal >= FREE_SHIPPING_THRESHOLD else STANDARD_SHIPPING
```

### 16.8 Code Review Best Practices

**As Code Author:**
- Self-review before requesting review
- Provide context in PR description
- Keep changes focused and small
- Respond to feedback professionally
- Document decisions in journal.md

**As Code Reviewer:**
- Review promptly (within 24 hours)
- Be constructive and specific
- Ask questions, don't make demands
- Approve when acceptable, not perfect
- Focus on important issues

**Code Review Checklist:**
- [ ] Code follows project style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No obvious bugs or security issues
- [ ] Changes are necessary and minimal
- [ ] Error handling is appropriate
- [ ] Performance impact is acceptable

### 16.9 Dependency Management

**Adding Dependencies:**
1. **Evaluate necessity** - Is it really needed?
2. **Check security** - Any known vulnerabilities?
3. **Check license** - Compatible with project?
4. **Check maintenance** - Recently updated?
5. **Document reason** in journal.md
6. **Update lock files** (package-lock.json, Pipfile.lock)

**Dependency Security:**
- Run security audits regularly (`npm audit`, `safety check`)
- Update dependencies on schedule
- Pin versions for reproducibility
- Document security updates in journal.md

**Dependency Hygiene:**
- Remove unused dependencies
- Keep direct dependencies minimal
- Prefer well-maintained libraries
- Document dependencies in README

### 16.10 Documentation Practices

**Code Documentation:**
- Document public APIs thoroughly
- Include usage examples in docstrings
- Document assumptions and constraints
- Keep documentation close to code

**Project Documentation:**
- Maintain up-to-date README
- Document setup and installation
- Provide troubleshooting guide
- Include architecture overview

**Documentation Format:**
```python
def calculate_discount(price, discount_percent, customer_type):
    """
    Calculate final price after applying discount.
    
    Args:
        price (float): Original price before discount
        discount_percent (float): Discount percentage (0-100)
        customer_type (str): Type of customer ('regular', 'premium')
        
    Returns:
        float: Final price after discount
        
    Raises:
        ValueError: If discount_percent is not between 0 and 100
        
    Examples:
        >>> calculate_discount(100, 10, 'regular')
        90.0
        >>> calculate_discount(100, 20, 'premium')
        80.0
    """
    if not 0 <= discount_percent <= 100:
        raise ValueError("Discount must be between 0 and 100")
    
    discount = price * (discount_percent / 100)
    return price - discount
```

### 16.11 Collaboration Workflows

**Feature Branches:**
- Create branch per feature/fix
- Use descriptive branch names
- Keep branches short-lived
- Merge frequently to avoid conflicts

**Branch Naming Convention:**
```
feature/add-user-authentication
bugfix/fix-login-timeout
hotfix/critical-security-patch
refactor/simplify-payment-logic
docs/update-api-documentation
```

**Pull Request Process:**
1. Create feature branch
2. Make changes with tests
3. Self-review changes
4. Create PR with description
5. Address review feedback
6. Merge when approved
7. Delete feature branch

**Merge Conflicts:**
- Pull latest changes regularly
- Resolve conflicts locally
- Test after resolving conflicts
- Commit resolution clearly
- Document complex resolutions

### 16.12 Environment Management

**Environment Types:**

| Environment | Purpose | Data | Updates |
|-------------|---------|------|---------|
| **Development** | Active coding | Synthetic | Continuous |
| **Testing** | QA testing | Synthetic | Per feature |
| **Staging** | Pre-production | Production-like | Per release |
| **Production** | Live system | Real | Scheduled |

**Environment Variables:**
- Never commit .env files
- Document required variables
- Use different values per environment
- Provide .env.example file

**Configuration Management:**
- Separate config from code
- Use environment-specific configs
- Document configuration options
- Validate configuration on startup

### 16.13 Monitoring & Observability

**Logging Levels:**
- **DEBUG**: Detailed diagnostic information
- **INFO**: General informational messages
- **WARNING**: Warning messages for potentially harmful situations
- **ERROR**: Error messages for serious problems
- **CRITICAL**: Critical issues requiring immediate action

**What to Log:**
- Application startup/shutdown
- User authentication attempts
- API requests and responses
- Errors and exceptions
- Performance metrics
- Business events

**What NOT to Log:**
- Passwords or credentials
- Credit card numbers
- Personal identifiable information (PII)
- Session tokens
- Full stack traces in production

**Structured Logging Example:**
```json
{
  "timestamp": "2025-11-19T19:24:57Z",
  "level": "INFO",
  "service": "payment-service",
  "event": "payment_processed",
  "user_id": "user_123",
  "amount": 99.99,
  "currency": "USD",
  "transaction_id": "txn_abc123"
}
```

### 16.14 Performance Monitoring

**Key Metrics:**
- Response time (average, p50, p95, p99)
- Throughput (requests per second)
- Error rate (percentage of failed requests)
- Resource utilization (CPU, memory, disk)

**Performance Testing:**
- Load testing (normal traffic)
- Stress testing (peak traffic)
- Soak testing (sustained traffic)
- Spike testing (sudden traffic increase)

**Performance Optimization Cycle:**
1. **Measure** baseline performance
2. **Identify** bottlenecks
3. **Optimize** critical paths
4. **Measure** improvement
5. **Document** changes in journal.md

### 16.15 Disaster Recovery

**Backup Strategy:**
- Regular automated backups
- Test restore procedures
- Store backups off-site
- Document backup schedule

**Incident Response:**
1. **Detect** incident
2. **Assess** impact
3. **Contain** damage
4. **Resolve** issue
5. **Review** post-mortem
6. **Document** in journal.md

**Recovery Procedures:**
- Document recovery steps
- Test recovery regularly
- Assign recovery responsibilities
- Update procedures based on incidents

### 16.16 Technical Debt Management

**Identifying Technical Debt:**
- Code smells (long methods, large classes)
- Outdated dependencies
- Missing tests
- Poor documentation
- Temporary workarounds

**Managing Technical Debt:**
- Track debt in tasks.md
- Allocate time for debt reduction
- Prioritize critical debt
- Prevent new debt accumulation
- Document debt decisions

**Debt Prioritization:**

| Priority | Type | Impact | Action |
|----------|------|--------|--------|
| **High** | Security vulnerabilities | Critical | Fix immediately |
| **High** | System instability | High | Fix next sprint |
| **Medium** | Performance issues | Medium | Schedule fix |
| **Low** | Code quality | Low | Opportunistic fix |

---

## 17. Domain-Specific Guidelines

### 17.1 Web Development

**Frontend Best Practices:**
- Use semantic HTML
- Ensure accessibility (WCAG compliance)
- Optimize assets (images, CSS, JS)
- Implement responsive design
- Test across browsers

**Backend Best Practices:**
- Validate all inputs
- Use prepared statements
- Implement rate limiting
- Handle errors gracefully
- Log important events

**API Design:**
- Use RESTful conventions
- Version your APIs
- Document endpoints clearly
- Implement proper authentication
- Return appropriate status codes

### 17.2 Data Science & ML

**Data Pipeline Best Practices:**
- Validate data quality
- Handle missing values appropriately
- Document data transformations
- Version datasets
- Track data lineage

**Model Development:**
- Start with baseline model
- Track experiments systematically
- Validate on holdout set
- Document model assumptions
- Version models and code

**Model Deployment:**
- Monitor model performance
- Implement A/B testing
- Plan for model retraining
- Document deployment process
- Handle model failures gracefully

### 17.3 DevOps & Infrastructure

**Infrastructure as Code:**
- Version all infrastructure
- Use declarative configuration
- Test infrastructure changes
- Document infrastructure decisions
- Implement least privilege access

**CI/CD Best Practices:**
- Automate testing
- Implement staged deployments
- Use feature flags
- Monitor deployments
- Plan rollback procedures

**Container Best Practices:**
- Use official base images
- Minimize layer count
- Don't run as root
- Scan for vulnerabilities
- Document container setup

### 17.4 Mobile Development

**Mobile-Specific Considerations:**
- Optimize for battery life
- Handle offline scenarios
- Minimize app size
- Test on real devices
- Follow platform guidelines

**Performance Optimization:**
- Lazy load images
- Cache network responses
- Minimize network requests
- Optimize animations
- Profile app performance

---

## 18. Workflow Examples

### 18.1 Daily Agent Workflow

**Morning Routine:**
```markdown
1. Pull latest changes from git
2. Review journal.md (last 24 hours)
3. Review tasks.md for priorities
4. Check for communications in journal.md
5. Select next task based on priority
6. Log session start to journal.md
7. Begin work on selected task
```

**During Work:**
```markdown
1. State current task every 15 minutes
2. Log significant decisions to journal.md
3. Commit changes after each microgoal
4. Run tests frequently
5. Update tasks.md with progress
6. Document blockers immediately
```

**End of Day:**
```markdown
1. Complete current microgoal or document status
2. Update all task statuses in tasks.md
3. Log session summary to journal.md
4. Commit and push all changes
5. Review tomorrow's priorities
6. Close any open resources
```

### 18.2 Feature Development Workflow

**Planning Phase:**
1. Review feature requirements in features.md
2. Break down into tasks in tasks.md
3. Identify dependencies and blockers
4. Estimate effort and set timeline
5. Log planning decisions to journal.md

**Implementation Phase:**
1. Create feature branch
2. Write failing tests first
3. Implement minimal code to pass tests
4. Refactor for quality
5. Document changes
6. Log progress to journal.md

**Review Phase:**
1. Self-review all changes
2. Run full test suite
3. Update documentation
4. Create pull request
5. Address review feedback
6. Merge when approved

**Deployment Phase:**
1. Deploy to staging
2. Perform smoke tests
3. Monitor for issues
4. Deploy to production
5. Monitor production metrics
6. Document deployment in journal.md

### 18.3 Bug Fix Workflow

**Bug Report:**
1. Create task in tasks.md
2. Gather reproduction steps
3. Document expected vs. actual behavior
4. Assign priority
5. Log bug details to journal.md

**Investigation:**
1. Reproduce bug locally
2. Add failing test
3. Debug to find root cause
4. Log findings to journal.md
5. Document in task

**Fix Implementation:**
1. Implement fix
2. Verify tests pass
3. Test manually
4. Document fix approach
5. Log fix to journal.md

**Verification:**
1. Test in staging environment
2. Verify fix doesn't break other features
3. Update task status
4. Deploy to production
5. Monitor for regression

---

## 19. Anti-Patterns to Avoid

### 19.1 Code Anti-Patterns

**God Object:**
❌ One class/module doing everything
✅ Separate concerns into focused components

**Spaghetti Code:**
❌ Tangled, difficult-to-follow logic
✅ Clear structure with logical flow

**Magic Numbers:**
❌ Unexplained literal values
✅ Named constants with clear meaning

**Copy-Paste Programming:**
❌ Duplicating code everywhere
✅ Extract common functionality

**Premature Optimization:**
❌ Optimizing before measuring
✅ Profile first, then optimize

### 19.2 Process Anti-Patterns

**Big Bang Integration:**
❌ Integrating everything at once
✅ Integrate incrementally and test

**No Testing:**
❌ Skipping tests to save time
✅ Write tests to save future time

**Cowboy Coding:**
❌ Coding without planning or collaboration
✅ Plan, communicate, review

**Analysis Paralysis:**
❌ Over-analyzing without action
✅ Make progress iteratively

**Feature Creep:**
❌ Adding features beyond scope
✅ Stay focused on requirements

### 19.3 Communication Anti-Patterns

**Silent Failure:**
❌ Not reporting problems
✅ Report issues immediately

**Information Hoarding:**
❌ Not sharing knowledge
✅ Document and share findings

**Assuming Understanding:**
❌ Not verifying comprehension
✅ Confirm understanding explicitly

**Passive Aggressive:**
❌ Indirect criticism
✅ Direct, constructive feedback

---

## 20. Glossary of Terms

**Acceptance Criteria:** Conditions that must be met for a task to be considered complete

**Agent:** AI entity performing work on project tasks

**Append-Only:** File that can only have new content added, never edited

**Balance Sheet View:** Strategic perspective showing where we want to be

**Blocker:** Issue preventing progress on a task

**CI/CD:** Continuous Integration/Continuous Deployment

**Code Smell:** Indicator of potential problems in code

**Income Statement View:** Tactical perspective showing how we get there

**Integration Test:** Test verifying components work together

**ISO 8601:** International date/time format (YYYY-MM-DDTHH:MM:SSZ)

**Journal:** Append-only log of all agent activities

**MCP:** Model Context Protocol for agent communication

**Microgoal:** Measurable sub-component of a task

**P0/P1/P2/P3:** Priority levels (0=Critical, 1=High, 2=Normal, 3=Low)

**Pull Request (PR):** Request to merge code changes

**Refactoring:** Improving code structure without changing behavior

**Regression:** Bug reintroduced after previously being fixed

**SRS:** Software Requirements Specification

**Technical Debt:** Code quality issues that slow future development

**Unit Test:** Test verifying a single component works correctly

---

*This document is the source of truth for all AI agent operations. When in doubt, refer to this document. If this document is unclear, log the ambiguity and escalate for clarification.*
