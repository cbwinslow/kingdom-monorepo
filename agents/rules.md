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

*This document is the source of truth for all AI agent operations. When in doubt, refer to this document. If this document is unclear, log the ambiguity and escalate for clarification.*
