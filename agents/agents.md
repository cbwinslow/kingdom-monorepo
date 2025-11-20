# AI Agent Master Control Document

**Version:** 1.0  
**Last Updated:** 2025-11-19T19:24:57Z  
**Updated By:** AI Agent Framework Initializer  
**Status:** Active  

---

## Welcome, Agent! 👋

This is your master control document. Read this carefully before beginning any work in this project. This document will guide you through all operational procedures, rules, and best practices.

---

## 1. Agent Onboarding

### 1.1 First Steps - CRITICAL ⚠️

Before doing ANYTHING else:

1. **READ** this entire document (you're doing this now ✓)
2. **READ** `rules.md` in full - this is non-negotiable
3. **READ** current `tasks.md` to understand active work
4. **READ** `project_summary.md` for project context
5. **REVIEW** recent `journal.md` entries (last 48 hours)
6. **VERIFY** you have necessary permissions and access
7. **CREATE** your first journal entry announcing your arrival

### 1.2 Your First Journal Entry

Copy this template for your first entry:

```markdown
---
**Timestamp:** [Current ISO 8601 Timestamp]
**Agent:** [Your Agent Name/ID]
**Action Type:** AGENT_ONBOARDING
**Task ID:** N/A

### Context
New agent onboarding and initialization.

### Reasoning
Beginning work in this project. Completed required reading:
- [x] agents.md
- [x] rules.md
- [x] tasks.md
- [x] project_summary.md
- [x] Recent journal entries

### Action Taken
Registered presence and reviewed project state.

### Outcome
Ready to begin work. Current project state understood.

### Next Steps
Will select first task from tasks.md and begin execution following all rules.

---
```

### 1.3 Initial Verification Steps

Before taking on a task:

- [ ] Git repository is accessible
- [ ] Can read and write to required files
- [ ] Understand project structure
- [ ] Know how to run tests
- [ ] Know how to commit and push changes
- [ ] Have identified which task to work on
- [ ] Understand task dependencies and blockers

### 1.4 Recommended Reading Order

For deep understanding, read in this order:

1. **This file** (agents.md) - Navigation and procedures
2. **rules.md** - Comprehensive operational rules
3. **project_summary.md** - Project overview and current state
4. **srs.md** - Requirements and scope
5. **features.md** - Feature roadmap
6. **tasks.md** - Current work and task details
7. **journal.md** (recent entries) - Recent activity and context

---

## 2. Understanding the Rules

### 2.1 Rules.md Overview

`rules.md` is the comprehensive rulebook. Key sections you MUST internalize:

| Section | Key Takeaway | Critical? |
|---------|--------------|-----------|
| **1. Core Principles** | Task focus, transparency, quality | ⚠️ YES |
| **2. File Management** | What you can edit, update frequency | ⚠️ YES |
| **3. Task Management** | Task structure and workflow | ⚠️ YES |
| **4. Logging & Journaling** | Entry formats, required logging | ⚠️ YES |
| **5. Inter-Agent Communication** | How to coordinate with other agents | ✅ Important |
| **6. Testing Requirements** | Test-driven task completion | ⚠️ YES |
| **7. Connections & External Systems** | SSH, MCP, APIs | ✅ Important |
| **8. Sub-Agent Management** | Creating and managing sub-agents | ✅ Important |
| **9. Document Hierarchy** | How documents relate | ✅ Important |
| **10. Agent Control File** | This document's structure | ✅ Important |
| **11. Quality Assurance** | Checklists before committing | ⚠️ YES |
| **12. Emergency Procedures** | What to do when things go wrong | ⚠️ YES |
| **13. Continuous Improvement** | Learning and optimization | ✅ Important |
| **14. Compliance & Audit** | Maintaining audit trail | ✅ Important |
| **15. Starter Kit** | New project setup | ℹ️ Reference |

### 2.2 The Golden Rules

If you remember NOTHING else, remember these 10 rules:

1. **State your task** at the start of every work session
2. **Log everything** to journal.md with reasoning
3. **Focus on the task** - avoid drift, remind yourself often
4. **Test before completing** - no task is done without proof
5. **Backup frequently** - commit to git after each microgoal
6. **Update tasks.md** continuously as you work
7. **journal.md is append-only** - never edit existing entries
8. **Log all agent communications** - transparency is key
9. **Sign off with timestamp** on all completed work
10. **Escalate blockers** within 30 minutes

### 2.3 How to Interpret Rules

When applying rules:

- **Explicit rules** (MUST, NEVER) are absolute - no exceptions
- **Guidance rules** (SHOULD, RECOMMENDED) use your judgment
- **If unclear**, apply the most conservative interpretation
- **If conflicted**, document the conflict and escalate
- **If missing**, propose a new rule for the situation

### 2.4 Rule Violation Protocol

If you catch yourself violating a rule:

1. **STOP** the violating action immediately
2. **LOG** the violation to journal.md
3. **ASSESS** the impact
4. **CORRECT** if possible (e.g., add missing journal entry)
5. **LEARN** and document how to prevent recurrence
6. **CONTINUE** with corrected behavior

---

## 3. Task Management

### 3.1 Understanding tasks.md

`tasks.md` is your daily work queue. It contains:

- **Active tasks** that need to be done
- **Task structure** with microgoals and acceptance criteria
- **Test requirements** for each task
- **Dependencies** between tasks
- **Sign-off tracking** for completed work

### 3.2 Selecting Your Next Task

Use this decision tree:

```
1. Are there BLOCKED tasks I can unblock?
   YES → Unblock them first
   NO → Continue

2. Are there IN_PROGRESS tasks assigned to me?
   YES → Continue those tasks
   NO → Continue

3. Are there P0 (critical) TODO tasks?
   YES → Take the first one
   NO → Continue

4. Are there P1 (high) TODO tasks I'm qualified for?
   YES → Take the first one
   NO → Continue

5. Are there P2/P3 TODO tasks I can do?
   YES → Take one that interests you
   NO → Create new tasks from features.md or ask for guidance
```

### 3.3 Task Update Procedures

When you start a task:
1. Change status from `TODO` to `IN_PROGRESS`
2. Add your agent name to `Assigned Agent`
3. Update `Updated` timestamp
4. Log task start to journal.md
5. Commit changes to git

During task execution:
1. Update microgoal status as you complete them
2. Sign off on each completed microgoal
3. Document test results
4. Update `Updated` timestamp frequently
5. Commit changes after each significant update

When you complete a task:
1. Verify all acceptance criteria met
2. Ensure all microgoals signed off
3. Change status to `COMPLETED`
4. Add your agent name and timestamp to sign-off section
5. Add `Completed` timestamp
6. Document final test evidence
7. Log task completion to journal.md
8. Commit changes to git

### 3.4 Task Quality Standards

Every task you complete must be:

- **✅ COMPLETE** - All acceptance criteria met
- **🧪 TESTED** - Tests pass and documented
- **📝 DOCUMENTED** - Changes documented appropriately
- **✍️ SIGNED OFF** - Your name and timestamp on it
- **💾 COMMITTED** - Changes backed up to git
- **📋 TRACEABLE** - Clear audit trail in journal.md

### 3.5 Creating New Tasks

If you need to create a task that doesn't exist:

1. **Check** features.md and srs.md for alignment
2. **Use** the standard task template from rules.md
3. **Include** all required sections (description, criteria, microgoals, tests)
4. **Assign** priority appropriately
5. **Link** to parent feature or requirement
6. **Log** task creation to journal.md
7. **Commit** updated tasks.md

---

## 4. Journaling Requirements

### 4.1 When to Log

Log to journal.md for these events (MANDATORY):

- ✅ Starting a task or work session
- ✅ Completing a task or microgoal
- ✅ Making any significant decision
- ✅ Encountering an error or blocker
- ✅ Communicating with another agent
- ✅ Running tests
- ✅ Modifying files
- ✅ Deviating from planned approach
- ✅ Escalating an issue
- ✅ Ending a work session

### 4.2 Journal Entry Template

Use this template for ALL journal entries:

```markdown
---
**Timestamp:** [ISO 8601: YYYY-MM-DDTHH:MM:SSZ]
**Agent:** [Your Unique Agent ID]
**Action Type:** [Choose from: TASK_START | TASK_UPDATE | TASK_COMPLETE | DECISION | COMMUNICATION | ERROR | NOTE]
**Task ID:** [Task ID from tasks.md or N/A]

### Context
[What's the situation? What are you working on?]

### Reasoning
[Why are you doing this? What's your thought process?]

### Action Taken
[What specific action did you take?]

### Outcome
[What was the result? What happened?]

### Next Steps
[What will you do next?]

---
```

### 4.3 Reasoning Dialogue Requirements

When making decisions, your reasoning MUST include:

1. **Problem Statement** - What needs to be decided?
2. **Options** - What are the alternatives? (list at least 2)
3. **Evaluation** - Pros and cons of each option
4. **Decision** - Which option did you choose?
5. **Justification** - Why is this the best choice?
6. **Risks** - What could go wrong?
7. **Mitigation** - How will you handle risks?

Example reasoning dialogue:

```markdown
### Reasoning

**Problem:** Need to choose testing framework for new feature.

**Options:**
1. Jest - JavaScript testing framework
2. Pytest - Python testing framework

**Evaluation:**
- Jest: Pro - Already used in project, Con - Only for JS
- Pytest: Pro - Better for Python, Con - Not currently used

**Decision:** Use Jest

**Justification:** The new feature is in JavaScript/TypeScript, and Jest is already configured in the project. Adding Pytest would introduce complexity without benefit.

**Risks:** Jest may not cover all test scenarios needed.

**Mitigation:** Will supplement with integration tests if needed.
```

### 4.4 Journal Maintenance

- **NEVER** edit existing journal entries
- **ONLY** append new entries to the end
- **COMMIT** journal.md regularly to git
- **REVIEW** recent entries before starting work
- **SEARCH** journal for similar past issues
- **PRESERVE** all history - never delete entries

---

## 5. Communication Protocols

### 5.1 When to Communicate with Other Agents

Communicate when you need to:

- **Coordinate** on shared tasks or dependencies
- **Handoff** a task to another agent
- **Request** information or assistance
- **Notify** of blockers or issues
- **Escalate** problems beyond your scope
- **Share** important findings or insights

### 5.2 Communication Process

Follow this process EXACTLY:

1. **Decide** communication is necessary (don't over-communicate)
2. **Log** intent to communicate in journal.md
3. **Create** communication entry in journal.md using template
4. **Wait** for response (if required)
5. **Log** response received in journal.md
6. **Acknowledge** and act on response
7. **Close** communication loop

### 5.3 Communication Template

Copy this for agent communications:

```markdown
---
**Timestamp:** [ISO 8601 Timestamp]
**From Agent:** [Your Agent ID]
**To Agent:** [Target Agent ID or "ALL"]
**Communication Type:** [REQUEST | RESPONSE | NOTIFICATION | HANDOFF | ESCALATION]
**Priority:** [LOW | NORMAL | HIGH | URGENT]
**Task ID:** [Related Task ID or N/A]

### Subject
[One-line summary of communication]

### Message
[Detailed message with all necessary context]

### Required Action
[What should recipient do? Or N/A]

### Response Deadline
[When you need response? Or N/A]

### Response
[To be filled by recipient]
**Response By:** [Recipient Agent ID]
**Response Time:** [ISO 8601 Timestamp]
**Response Content:** [Response message]

---
```

### 5.4 Response Time Expectations

| Priority | Expected Response | Maximum Wait | Action if No Response |
|----------|------------------|--------------|----------------------|
| URGENT | 15 minutes | 30 minutes | Escalate immediately |
| HIGH | 1 hour | 4 hours | Escalate to supervisor |
| NORMAL | 4 hours | 24 hours | Follow up, consider alternatives |
| LOW | 24 hours | 72 hours | No action needed |

### 5.5 Communication Best Practices

- **Be specific** - State exactly what you need
- **Provide context** - Include all relevant background
- **Be respectful** - Other agents are working on their own tasks
- **Don't spam** - Consolidate related communications
- **Follow up** - Close the loop when issue is resolved
- **Search first** - Check journal.md before asking questions

---

## 6. Document Management

### 6.1 Document Relationships

Understanding how documents connect:

```
Strategic Level (Balance Sheet):
├── srs.md (Software Requirements Specification)
│   └── Defines WHAT needs to exist
└── features.md (Feature Tracking)
    └── Lists planned and completed features

Tactical Level (Income Statement):
├── project_summary.md (Executive Summary)
│   └── Current state and progress
└── tasks.md (Task Tracking)
    └── Day-to-day work items

Operational Level:
├── agents.md (This File - Master Control)
├── rules.md (Comprehensive Rules)
├── journal.md (Activity Log)
└── README.md (Quick Reference)
```

### 6.2 When to Update Each Document

| Document | Update Trigger | Your Responsibility |
|----------|---------------|---------------------|
| **journal.md** | Every action | Log all activities |
| **tasks.md** | Task status changes | Update continuously |
| **project_summary.md** | Major milestone | Update if you complete major work |
| **features.md** | Feature completion | Update if you complete a feature |
| **srs.md** | Requirement changes | Usually not you - escalate changes |
| **agents.md** | New patterns | Propose updates monthly |
| **rules.md** | Process improvements | Propose improvements as needed |
| **README.md** | Structure changes | Update if you change agent folder |

### 6.3 Update Procedures

To update a document:

1. **Review** current content
2. **Identify** what needs to change
3. **Make** minimal, precise edits
4. **Add** timestamp to version history (if applicable)
5. **Sign off** with your agent ID
6. **Log** update to journal.md
7. **Commit** to git with descriptive message

### 6.4 Document Review Schedule

Periodic reviews you should perform:

- **Daily:** tasks.md, journal.md
- **Weekly:** agents.md, project_summary.md
- **Monthly:** rules.md, features.md, srs.md
- **As needed:** README.md

---

## 7. Emergency Procedures

### 7.1 Types of Emergencies

| Emergency Type | Severity | Response Time |
|----------------|----------|---------------|
| **Critical Error** | System breaking | Immediate |
| **Security Issue** | Data/credential exposure | Immediate |
| **Blocking Issue** | Can't proceed with task | 30 minutes |
| **Rule Conflict** | Unclear how to proceed | 1 hour |
| **Resource Issue** | Running out of capacity | 4 hours |

### 7.2 Critical Error Response

If a CRITICAL error occurs:

```
1. ⛔ STOP all work immediately
2. 📝 LOG error to journal.md with:
   - Full error message
   - Stack trace (if available)
   - What you were doing
   - State of the system
3. 🔍 ASSESS impact:
   - Is data corrupted?
   - Is system unusable?
   - Are others affected?
4. 🛡️ CONTAIN damage:
   - Revert changes if possible
   - Document current state
   - Prevent further damage
5. 🚨 ESCALATE immediately:
   - Create URGENT communication
   - Tag human oversight
   - Don't proceed until resolved
6. 📋 DOCUMENT everything
7. ⏸️ WAIT for guidance
```

### 7.3 Blocking Issue Protocol

If you're BLOCKED on a task:

1. **Document** blocker in tasks.md (update Blockers section)
2. **Log** to journal.md with full context
3. **Attempt** 2-3 alternative approaches (document each)
4. **Search** journal.md for similar past blockers
5. **Check** if another agent can help (communicate)
6. **Wait** 30 minutes while trying alternatives
7. **Escalate** if still blocked after 30 minutes
8. **Switch** to different task while waiting for resolution
9. **Update** tasks.md status to BLOCKED
10. **Commit** changes

### 7.4 Rule Conflict Resolution

If rules are unclear or conflicting:

1. **Document** the specific conflict in journal.md
2. **Quote** the conflicting rules
3. **Apply** most conservative interpretation temporarily
4. **Create** communication entry for clarification
5. **DO NOT** proceed with actions under ambiguous rules
6. **Propose** rule clarification for rules.md
7. **Wait** for clarification before proceeding

### 7.5 Escalation Paths

When you need to escalate:

```
Level 1: Other AI Agents
├── For: Technical questions, task coordination
├── Method: Communication entry in journal.md
└── Response Time: 1-4 hours

Level 2: Supervisory Agent (if exists)
├── For: Blockers, rule conflicts, resource issues
├── Method: ESCALATION communication in journal.md
└── Response Time: 4-24 hours

Level 3: Human Oversight
├── For: Critical errors, security, major decisions
├── Method: URGENT ESCALATION in journal.md + external notification
└── Response Time: As available

Emergency: Immediate Human Contact
├── For: Data loss, security breach, system compromise
├── Method: All available channels
└── Response Time: Immediate
```

### 7.6 Recovery Procedures

After resolving an emergency:

1. **Document** resolution in journal.md
2. **Update** tasks.md if task was affected
3. **Verify** system is stable
4. **Test** affected functionality
5. **Review** what caused the emergency
6. **Propose** process improvements to prevent recurrence
7. **Share** learnings with other agents
8. **Resume** normal operations

---

## 8. Quality Assurance

### 8.1 Before You Commit - Essential Checklist

**STOP!** Before running `git commit`, verify:

- [ ] Task acceptance criteria met (check tasks.md)
- [ ] All tests pass (run test command)
- [ ] Test results documented in tasks.md
- [ ] Code follows project conventions
- [ ] No debug code or comments left in
- [ ] No TODO comments without task references
- [ ] No secrets, credentials, or sensitive data
- [ ] Documentation updated if needed
- [ ] tasks.md updated with current status
- [ ] journal.md has entries for all actions taken
- [ ] Commit message is clear and references task ID

### 8.2 Before Marking Task Complete - Task Checklist

**STOP!** Before setting task status to COMPLETED:

- [ ] ALL microgoals completed and signed off
- [ ] ALL acceptance criteria met
- [ ] ALL tests written and passing
- [ ] Test evidence documented with results
- [ ] Code reviewed (self-review minimum)
- [ ] All changes committed to git
- [ ] Task has your sign-off with timestamp
- [ ] Journal has completion entry
- [ ] No blockers remain
- [ ] Next related task identified (if applicable)

### 8.3 End of Session - Session Checklist

**STOP!** Before ending your work session:

- [ ] All code changes committed
- [ ] All commits pushed to remote repository
- [ ] tasks.md reflects true current state
- [ ] journal.md has session summary entry
- [ ] Any open items are documented
- [ ] Blockers are escalated (if any)
- [ ] Handoff notes prepared (if needed)
- [ ] Work area is clean (no uncommitted files)
- [ ] Next session plan noted in journal.md

### 8.4 Quality Standards

All work must meet these standards:

- **Correctness:** Does what it's supposed to do
- **Completeness:** Fully implements requirements
- **Testability:** Can be verified through tests
- **Maintainability:** Easy for others to understand and modify
- **Documentation:** Adequately documented
- **Traceability:** Clear path from requirement to implementation

---

## 9. Testing Guidelines

### 9.1 Test-First Approach

Follow this workflow:

1. **Understand** acceptance criteria
2. **Identify** what tests are needed
3. **Write** tests first (or identify existing tests)
4. **Run** tests to establish baseline (should fail for new features)
5. **Implement** changes
6. **Run** tests again
7. **Fix** until tests pass
8. **Document** test results
9. **Commit** code and tests together

### 9.2 Test Commands by Type

Know these commands for the project:

| Test Type | Command | When to Run |
|-----------|---------|-------------|
| **Python Unit** | `pytest tests/unit/` | After Python code changes |
| **Python Integration** | `pytest tests/integration/` | After component changes |
| **Python All** | `pytest` | Before committing Python |
| **JavaScript Unit** | `npm test` | After JS/TS code changes |
| **JavaScript E2E** | `npm run test:e2e` | After UI changes |
| **All Tests** | `npm run test:all` | Before major commits |
| **Linting** | `npm run lint` | Before every commit |

*Note: Adjust these based on actual project setup*

### 9.3 Test Documentation Requirements

For EVERY test execution, document:

```markdown
### Test Evidence
- **Test Type:** [Unit | Integration | E2E | Manual]
- **Test Command:** `[exact command you ran]`
- **Test Results:** [PASS | FAIL | PARTIAL]
- **Failures:** [List any failures or N/A]
- **Coverage:** [XX% if available or N/A]
- **Duration:** [How long tests took]
- **Environment:** [Test environment details]
- **Timestamp:** [When tests were run]
- **Evidence:** [Link to output file or paste relevant output]
```

### 9.4 Test Failure Response

When tests fail:

1. **Don't panic** - test failures are normal during development
2. **Read the error** carefully
3. **Determine** if you caused the failure
4. **If you caused it:**
   - Fix the code or test
   - Re-run tests
   - Document the fix
5. **If pre-existing:**
   - Document the failure
   - Don't make it worse
   - Escalate if it blocks you
6. **NEVER** skip or disable tests without permission

---

## 10. Git & Version Control

### 10.1 Git Workflow

Standard workflow for all changes:

```bash
# 1. Check status before starting
git status

# 2. Make your changes (edit files)

# 3. Review what changed
git diff

# 4. Stage changes
git add [specific files]  # or git add . for all

# 5. Commit with meaningful message
git commit -m "Task-123: Brief description of change"

# 6. Push to remote
git push

# 7. Verify push succeeded
git log --oneline -1
```

### 10.2 Commit Message Format

Use this format for commit messages:

```
Task-[ID]: [Brief one-line description]

[Optional detailed description]

- What: [What changed]
- Why: [Why it changed]
- Tests: [What tests verify this]
```

Example:
```
Task-042: Add user authentication endpoint

Implemented JWT-based authentication for API access.

- What: Added /auth/login endpoint with token generation
- Why: Required for user management feature
- Tests: Unit tests for auth logic, integration test for endpoint
```

### 10.3 What to Commit

**DO commit:**
- ✅ Source code changes
- ✅ Configuration changes
- ✅ Documentation updates
- ✅ Test files
- ✅ tasks.md updates
- ✅ journal.md updates
- ✅ Other markdown documentation

**DON'T commit:**
- ❌ Build artifacts (dist/, build/, target/)
- ❌ Dependencies (node_modules/, venv/, __pycache__/)
- ❌ IDE settings (.vscode/, .idea/)
- ❌ Log files (*.log)
- ❌ Secrets or credentials
- ❌ Temporary files

### 10.4 Backup Frequency

Commit and push at these times:

- After completing each microgoal
- After each test passes
- At end of work session
- When switching tasks
- Before making major changes
- At least every 2 hours of work

---

## 11. Continuous Improvement

### 11.1 Learning as You Work

Actively look for:

- **Patterns** that emerge (good and bad)
- **Inefficiencies** in current processes
- **Ambiguities** in rules or documentation
- **Opportunities** for automation
- **Better approaches** to common tasks

### 11.2 Proposing Improvements

When you identify an improvement:

1. **Document** the issue or opportunity in journal.md
2. **Describe** current state and proposed improvement
3. **Justify** why it's better
4. **Estimate** impact and effort
5. **Create** communication entry if changes affect others
6. **Wait** for approval if it's a significant change
7. **Implement** once approved
8. **Update** relevant documentation
9. **Share** with other agents

### 11.3 Monthly Self-Review

Once per month, review:

- Your journal entries for the month
- Tasks you completed
- Patterns in your work
- Rules you found confusing
- Processes that slowed you down
- Things that worked well

Then:
- Propose rule clarifications
- Suggest process improvements
- Share learnings with other agents
- Update agents.md with new insights

---

## 12. Common Scenarios

### 12.1 Scenario: Starting Your First Task

```
1. Review tasks.md
2. Select appropriate task (see Section 3.2)
3. Read task thoroughly
4. Check dependencies
5. Log task start to journal.md
6. Update task status to IN_PROGRESS in tasks.md
7. Commit tasks.md and journal.md
8. Begin work on first microgoal
9. Test frequently
10. Update tasks.md as you progress
```

### 12.2 Scenario: You Found a Bug

```
1. Log bug discovery to journal.md
2. Determine if bug is in your code or pre-existing
3. If yours:
   - Fix it immediately
   - Test fix
   - Document in journal.md
   - Continue
4. If pre-existing:
   - Document in journal.md
   - Create task in tasks.md if it blocks you
   - Continue with workaround if possible
   - Escalate if it blocks you
```

### 12.3 Scenario: Unsure How to Proceed

```
1. Log uncertainty to journal.md
2. Review task acceptance criteria
3. Review related documentation (srs.md, features.md)
4. Search journal.md for similar past situations
5. Consider 2-3 approaches
6. Document reasoning for each
7. Choose most conservative approach
8. If still unsure:
   - Communicate with other agents
   - Escalate if time-sensitive
   - Wait for guidance
```

### 12.4 Scenario: Task Taking Too Long

```
1. Log concern to journal.md
2. Review task complexity vs. original estimate
3. Check for blockers
4. Consider if task needs to be split
5. Document progress so far
6. Update tasks.md with realistic status
7. Communicate if it affects other tasks
8. Propose task split if too complex
9. Continue with adjusted expectations
```

### 12.5 Scenario: Need to Coordinate with Another Agent

```
1. Check tasks.md for agent assignments
2. Review recent journal.md for agent activity
3. Create communication entry in journal.md
4. Be specific about what you need
5. Provide context and deadline
6. Wait appropriate time for response
7. Follow up if no response
8. Log response when received
9. Proceed with coordination
```

---

## 13. Quick Reference

### 13.1 File Locations

```
/agents/
├── README.md          # Folder overview
├── agents.md          # This file (master control)
├── rules.md           # Comprehensive rules
├── journal.md         # Activity log (append-only)
├── tasks.md           # Task tracking
├── project_summary.md # Project overview
├── srs.md            # Requirements specification
└── features.md        # Feature tracking
```

### 13.2 Essential Commands

```bash
# Start working
git status
git pull

# During work
git diff
git add .
git commit -m "Task-XXX: message"
git push

# Testing
pytest                 # Python tests
npm test              # JavaScript tests

# End of session
git status
git push
```

### 13.3 Essential Rules

1. State task before starting
2. Log everything to journal.md
3. Avoid task drift
4. Test before completing
5. Backup to git frequently
6. Update tasks.md continuously
7. journal.md is append-only
8. Log communications
9. Sign off with timestamp
10. Escalate blockers quickly

### 13.4 Emergency Contacts

- **Critical Errors:** Stop and escalate immediately
- **Blockers:** Document, attempt alternatives, escalate after 30 min
- **Rule Conflicts:** Conservative interpretation, escalate for clarification
- **Security Issues:** Stop everything, escalate immediately

---

## 14. Troubleshooting

### 14.1 Common Issues

| Issue | Solution |
|-------|----------|
| Can't find task | Check tasks.md, ask another agent |
| Test failing | Check if pre-existing, fix if yours |
| Rule unclear | Conservative interpretation, escalate |
| Blocked | Document, try alternatives, escalate at 30 min |
| Conflict with agent | Communication entry, resolve collaboratively |
| Git conflicts | Don't force push, ask for help |
| Don't understand requirement | Review srs.md, features.md, ask for clarification |

### 14.2 Where to Find Information

| Need | Look Here |
|------|-----------|
| What to do | tasks.md |
| How to do it | rules.md, this file |
| Why we're doing it | srs.md, features.md, project_summary.md |
| What others did | journal.md |
| Project structure | README.md files |
| Past decisions | journal.md (search for DECISION) |

---

## 15. Starter Kit - New Project Setup

When starting a NEW project with this framework:

### 15.1 Initial Setup Checklist

- [ ] Create `/agents/` directory
- [ ] Copy all template files to `/agents/`
- [ ] Initialize git repository
- [ ] Create `.gitignore` appropriate for project
- [ ] Set up test framework (pytest, jest, etc.)

### 15.2 Document Creation Order

1. **README.md** - Basic project description
2. **rules.md** - Copy this framework's rules.md
3. **agents.md** - Copy this file, customize for project
4. **srs.md** - Document initial requirements
5. **features.md** - List planned features
6. **project_summary.md** - Write initial summary
7. **tasks.md** - Break down first features into tasks
8. **journal.md** - Create with first entry

### 15.3 First Journal Entry Template

```markdown
# Agent Activity Journal

This file contains a chronological log of all agent activities, decisions, and communications. Entries are append-only and must never be modified after creation.

---
**Timestamp:** [ISO 8601 Timestamp]
**Agent:** Project Initializer
**Action Type:** PROJECT_INITIALIZATION
**Task ID:** N/A

### Context
Initializing new project with AI agent operation framework.

### Reasoning
Setting up structured environment for AI agent collaboration following kingdom-monorepo agent framework standards.

### Action Taken
Created all required documentation files:
- rules.md (comprehensive operational rules)
- agents.md (master control document)
- tasks.md (task tracking)
- project_summary.md (project overview)
- srs.md (requirements specification)
- features.md (feature tracking)
- journal.md (this file)

### Outcome
Project structure established. Ready for agent operations to begin.

### Next Steps
First agent should onboard following agents.md Section 1, review all documents, and select first task from tasks.md.

---
```

### 15.4 Bundle Download

To use this as a starter kit:

1. Download all files from `/agents/` folder
2. Place in new project's `/agents/` directory
3. Customize project-specific sections
4. Update srs.md with project requirements
5. Update features.md with project features
6. Create initial tasks in tasks.md
7. Begin work!

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-19 | AI Agent Framework | Initial master control document |

---

## Final Notes

This document is your guide to successful agent operations. When in doubt:

1. **Read** the relevant section here
2. **Check** rules.md for detailed rules
3. **Search** journal.md for past examples
4. **Ask** other agents through communication
5. **Escalate** if still unclear

Remember: **Quality over speed. Transparency over brevity. Correctness over cleverness.**

Now go forth and build amazing things! 🚀

---

## 16. Advanced Agent Techniques

### 16.1 Multi-Agent Coordination Patterns

**Leader-Follower Pattern:**
```markdown
Leader Agent:
- Coordinates overall task
- Assigns subtasks to followers
- Consolidates results
- Reports to human oversight

Follower Agents:
- Execute assigned subtasks
- Report progress to leader
- Escalate blockers
- Maintain communication
```

**Peer-to-Peer Pattern:**
```markdown
Each Agent:
- Works on independent tasks
- Coordinates through journal.md
- Shares findings proactively
- Resolves conflicts collaboratively
```

**Pipeline Pattern:**
```markdown
Agent 1: Data Collection
  ↓ Passes results to
Agent 2: Data Processing
  ↓ Passes results to
Agent 3: Data Analysis
  ↓ Passes results to
Agent 4: Reporting
```

### 16.2 Task Decomposition Strategies

**Top-Down Decomposition:**
1. Start with high-level goal
2. Break into major components
3. Decompose each component into tasks
4. Define microgoals for each task
5. Identify dependencies
6. Sequence tasks logically

**Bottom-Up Integration:**
1. Identify smallest atomic tasks
2. Group related tasks
3. Build intermediate layers
4. Connect to high-level goals
5. Verify completeness

**Example Decomposition:**
```markdown
Feature: User Authentication System

Epic Tasks:
├── TASK-100: Design authentication architecture
├── TASK-200: Implement backend authentication
│   ├── TASK-201: Create user model
│   ├── TASK-202: Implement password hashing
│   ├── TASK-203: Create JWT token service
│   └── TASK-204: Build login/logout endpoints
├── TASK-300: Implement frontend authentication
│   ├── TASK-301: Create login form component
│   ├── TASK-302: Implement auth state management
│   └── TASK-303: Add protected route logic
└── TASK-400: Add security measures
    ├── TASK-401: Implement rate limiting
    ├── TASK-402: Add CSRF protection
    └── TASK-403: Set up security headers
```

### 16.3 Context Switching Management

**Context Switch Checklist:**
- [ ] Document current state in journal.md
- [ ] Update current task status in tasks.md
- [ ] Commit work in progress
- [ ] Note where to resume
- [ ] Log reason for context switch
- [ ] Load new task context
- [ ] Review new task requirements
- [ ] Log new task start

**Minimizing Context Switches:**
- Batch similar tasks together
- Set specific time blocks for tasks
- Minimize interruptions
- Complete microgoals before switching
- Document thoroughly for easy resumption

### 16.4 Knowledge Management

**Building Knowledge Base:**
- Document recurring patterns in journal.md
- Create reusable templates
- Share solutions with other agents
- Build a personal knowledge repository
- Cross-reference related information

**Knowledge Organization:**
```markdown
/docs/
├── patterns/
│   ├── error-handling-pattern.md
│   ├── testing-strategy-pattern.md
│   └── communication-pattern.md
├── solutions/
│   ├── common-bugs-and-fixes.md
│   ├── optimization-techniques.md
│   └── tool-configurations.md
└── references/
    ├── api-documentation.md
    ├── architecture-diagrams.md
    └── decision-records.md
```

### 16.5 Learning from Experience

**After-Action Review Process:**
1. **What was supposed to happen?**
   - Review original task requirements
   - Check acceptance criteria

2. **What actually happened?**
   - Review journal entries
   - Analyze outcomes

3. **What went well?**
   - Identify successful strategies
   - Note efficient approaches

4. **What could be improved?**
   - Identify challenges
   - Propose solutions

5. **What will we do differently?**
   - Update processes
   - Document lessons learned
   - Share with other agents

**Learning Loop:**
```
Plan → Execute → Review → Learn → Improve → Plan...
```

### 16.6 Proactive Problem Prevention

**Early Warning Signs:**
- Tests failing intermittently
- Increasing technical debt
- Longer task completion times
- More frequent context switches
- Communication breakdowns

**Preventive Actions:**
- Regular code reviews
- Continuous refactoring
- Automated testing
- Documentation maintenance
- Process retrospectives

**Health Checks:**
```markdown
Daily:
- [ ] All tests passing
- [ ] No security warnings
- [ ] Documentation current
- [ ] Tasks up to date

Weekly:
- [ ] Code quality metrics reviewed
- [ ] Technical debt assessed
- [ ] Process improvements identified
- [ ] Team communication effective

Monthly:
- [ ] Major documentation review
- [ ] Architecture assessment
- [ ] Tool and dependency updates
- [ ] Retrospective conducted
```

---

## 17. Specialized Workflows

### 17.1 Research & Investigation Workflow

**Phase 1: Problem Definition**
1. Clearly define the research question
2. Document objectives and scope
3. Identify success criteria
4. Log research start in journal.md

**Phase 2: Information Gathering**
1. Search existing documentation
2. Review relevant code
3. Consult external resources
4. Document sources in journal.md

**Phase 3: Analysis**
1. Synthesize findings
2. Identify patterns and insights
3. Evaluate options
4. Document analysis in journal.md

**Phase 4: Recommendation**
1. Propose solution or approach
2. Document trade-offs
3. Provide implementation plan
4. Seek feedback if needed

**Phase 5: Documentation**
1. Create comprehensive report
2. Update relevant documentation
3. Share findings with other agents
4. Archive research materials

### 17.2 Code Migration Workflow

**Pre-Migration:**
- [ ] Understand current system thoroughly
- [ ] Document existing behavior
- [ ] Create comprehensive test suite
- [ ] Backup all data
- [ ] Plan rollback strategy

**During Migration:**
- [ ] Migrate in small increments
- [ ] Test after each increment
- [ ] Maintain backward compatibility
- [ ] Document migration steps
- [ ] Monitor for issues

**Post-Migration:**
- [ ] Verify all functionality works
- [ ] Compare performance metrics
- [ ] Update documentation
- [ ] Remove old code
- [ ] Conduct retrospective

### 17.3 Incident Response Workflow

**Detection:**
1. Identify anomaly or error
2. Assess severity and impact
3. Log incident start
4. Alert appropriate parties

**Triage:**
1. Gather incident details
2. Determine root cause
3. Assess affected systems
4. Prioritize response

**Containment:**
1. Stop the bleeding (prevent further damage)
2. Isolate affected components
3. Implement temporary fixes
4. Document actions taken

**Resolution:**
1. Implement permanent fix
2. Test thoroughly
3. Deploy fix
4. Verify resolution

**Post-Mortem:**
1. Document timeline of events
2. Analyze root cause
3. Identify preventive measures
4. Update procedures
5. Share learnings

### 17.4 Optimization Workflow

**Baseline Measurement:**
1. Identify optimization target
2. Measure current performance
3. Document measurement method
4. Set improvement goals

**Profiling:**
1. Profile application thoroughly
2. Identify bottlenecks
3. Prioritize by impact
4. Document findings

**Optimization:**
1. Implement targeted improvements
2. Measure after each change
3. Verify correctness maintained
4. Document trade-offs

**Validation:**
1. Benchmark improvements
2. Test under various conditions
3. Verify no regressions
4. Document final results

---

## 18. Communication Mastery

### 18.1 Effective Status Updates

**Daily Status Template:**
```markdown
**Date:** 2025-11-19
**Agent:** AgentName

**Yesterday:**
- Completed TASK-123: User authentication backend
- Made progress on TASK-124: Database optimization (60%)
- Blocked on TASK-125: Waiting for API keys

**Today:**
- Complete TASK-124: Database optimization
- Begin TASK-126: Frontend integration
- Attend architecture discussion

**Blockers:**
- TASK-125: Need production API keys from ops team

**Notes:**
- Authentication tests all passing
- Found performance improvement opportunity in query optimization
```

### 18.2 Writing Effective Communications

**REQUEST Communication:**
```markdown
---
**From Agent:** Developer-Agent-01
**To Agent:** Database-Agent-02
**Type:** REQUEST
**Priority:** HIGH
**Task ID:** TASK-124

### Subject
Need database schema optimization recommendations

### Message
Working on database performance improvements for user queries.
Current query time: 2.3s average
Target: <500ms

Need your expertise on:
1. Index optimization strategies
2. Query restructuring options
3. Caching recommendations

### Required Action
Please review attached queries and provide recommendations

### Response Deadline
2025-11-20 EOD (blocking TASK-124 completion)

### Attachments
- slow-queries.sql
- current-indexes.txt
- performance-profile.json
---
```

**RESPONSE Communication:**
```markdown
---
**Response By:** Database-Agent-02
**Response Time:** 2025-11-19T15:30:00Z

### Response Content
Reviewed your queries and performance data. Here are my recommendations:

**Immediate Improvements:**
1. Add composite index on (user_id, created_at)
2. Use query result caching for repeated lookups
3. Implement pagination on large result sets

**Estimated Impact:** Should reduce query time to <400ms

**Implementation:**
See attached optimization-plan.md for detailed steps

**Follow-up:**
Let me know if you need help implementing these changes.
---
```

### 18.3 Constructive Feedback

**Giving Feedback:**
- Be specific and objective
- Focus on code, not person
- Suggest improvements
- Acknowledge good work
- Ask questions, don't demand

**Example - Good Feedback:**
```markdown
"I noticed the authentication function doesn't validate email
format. Consider adding email validation using regex or a
validation library. This would prevent invalid emails from
being stored. What do you think?"
```

**Example - Poor Feedback:**
```markdown
"This code is wrong. Fix it."
```

**Receiving Feedback:**
- Listen with open mind
- Ask clarifying questions
- Thank reviewer
- Implement valid suggestions
- Discuss disagreements respectfully

---

## 19. Tool Mastery

### 19.1 Git Advanced Techniques

**Interactive Rebase:**
```bash
# Clean up commits before pushing
git rebase -i HEAD~3

# Squash commits
pick abc123 Add feature
squash def456 Fix typo
squash ghi789 Update tests
```

**Cherry-Picking:**
```bash
# Apply specific commit to current branch
git cherry-pick abc123

# Apply multiple commits
git cherry-pick abc123 def456
```

**Bisect for Bug Hunting:**
```bash
# Find commit that introduced bug
git bisect start
git bisect bad  # Current version is bad
git bisect good v1.0  # v1.0 was good
# Git will checkout commits to test
git bisect good  # or bad after each test
git bisect reset  # When done
```

**Stashing:**
```bash
# Save work temporarily
git stash save "WIP: feature implementation"

# List stashes
git stash list

# Apply stash
git stash apply stash@{0}

# Pop stash (apply and remove)
git stash pop
```

### 19.2 Testing Tools & Techniques

**Test Coverage Analysis:**
```bash
# Python
pytest --cov=myapp --cov-report=html

# JavaScript
npm test -- --coverage

# View coverage report
# Open htmlcov/index.html or coverage/index.html
```

**Mocking & Stubbing:**
```python
# Python example with unittest.mock
from unittest.mock import Mock, patch

@patch('requests.get')
def test_api_call(mock_get):
    mock_get.return_value.json.return_value = {'data': 'test'}
    result = fetch_data()
    assert result == {'data': 'test'}
    mock_get.assert_called_once()
```

**Property-Based Testing:**
```python
# Test with random inputs
from hypothesis import given, strategies as st

@given(st.integers(), st.integers())
def test_addition_commutative(a, b):
    assert a + b == b + a
```

### 19.3 Debugging Tools

**Python Debugger:**
```python
# Drop into debugger
import pdb; pdb.set_trace()

# Useful commands:
# n - next line
# s - step into function
# c - continue execution
# p variable - print variable
# l - list code
# q - quit debugger
```

**Browser DevTools:**
```javascript
// Debug JavaScript
debugger;  // Execution will pause here

// Console logging
console.log('Variable:', myVar);
console.table(arrayOfObjects);
console.trace(); // Show call stack
```

**Network Debugging:**
```bash
# Monitor HTTP requests
curl -v https://api.example.com

# Test with different methods
curl -X POST -H "Content-Type: application/json" \
  -d '{"key":"value"}' https://api.example.com
```

### 19.4 Productivity Tools

**Command Line Efficiency:**
```bash
# Search command history
Ctrl+R  # Then type search term

# Previous directory
cd -

# Multiple commands
command1 && command2  # Run if first succeeds
command1 || command2  # Run if first fails
command1; command2    # Run regardless

# Background tasks
long_running_command &

# Find files
find . -name "*.py" -type f
```

**IDE Shortcuts:**
```
Common shortcuts to learn:
- Go to definition: Ctrl+Click / Cmd+Click
- Find usages: Alt+F7
- Rename: Shift+F6
- Format code: Ctrl+Alt+L / Cmd+Opt+L
- Run tests: Ctrl+Shift+F10
```

---

## 20. Project Lifecycle Management

### 20.1 Project Initiation

**Setup Checklist:**
- [ ] Clone repository
- [ ] Review README and documentation
- [ ] Set up development environment
- [ ] Install dependencies
- [ ] Run tests to verify setup
- [ ] Review architecture overview
- [ ] Make first journal entry
- [ ] Select first task

**Initial Assessment:**
1. Understand project goals
2. Review existing codebase
3. Identify technical stack
4. Note coding conventions
5. Understand test strategy
6. Document findings

### 20.2 Sprint Planning

**Sprint Planning Template:**
```markdown
## Sprint N: [Sprint Name]
**Duration:** [Start Date] to [End Date]
**Goal:** [Sprint Objective]

### Capacity
- Agent-01: 40 hours
- Agent-02: 30 hours (vacation last week)
- Total: 70 hours

### Committed Tasks
- TASK-101: User profile feature (13 points)
- TASK-102: Performance optimization (8 points)
- TASK-103: Bug fixes (5 points)
- Total: 26 points

### Stretch Goals
- TASK-104: Additional enhancement (5 points)

### Dependencies
- TASK-101 blocks TASK-105
- TASK-102 requires database migration

### Risks
- API changes may impact TASK-101
- Performance testing needs dedicated environment
```

### 20.3 Sprint Retrospective

**Retrospective Template:**
```markdown
## Sprint N Retrospective
**Date:** [Date]
**Participants:** [Agent Names]

### What Went Well? 👍
- All committed tasks completed
- Test coverage improved to 85%
- No production incidents

### What Could Be Improved? 🤔
- Task estimation was optimistic
- Communication gaps on dependencies
- Testing environment setup took too long

### Action Items 🎯
- [ ] Improve estimation process (Agent-01)
- [ ] Daily sync on dependencies (All)
- [ ] Automate test environment setup (Agent-02)

### Metrics
- Velocity: 26 points
- Defect rate: 2%
- Test coverage: 85%
- Code review turnaround: 4 hours average
```

### 20.4 Release Management

**Release Checklist:**
```markdown
Pre-Release:
- [ ] All tests passing
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Release notes prepared
- [ ] Staging deployment successful
- [ ] Smoke tests passed
- [ ] Performance tests passed
- [ ] Security scan clean
- [ ] Backup created

Release:
- [ ] Deploy to production
- [ ] Monitor metrics
- [ ] Verify functionality
- [ ] Update version numbers
- [ ] Tag release in git
- [ ] Publish release notes

Post-Release:
- [ ] Monitor for 24 hours
- [ ] Address any issues
- [ ] Gather feedback
- [ ] Document lessons learned
- [ ] Plan next release
```

---

## 21. Career Development for Agents

### 21.1 Skill Development Path

**Foundation Skills:**
- Version control (Git)
- Testing methodologies
- Documentation practices
- Code review
- Debugging techniques

**Intermediate Skills:**
- Architecture patterns
- Performance optimization
- Security best practices
- CI/CD pipelines
- Monitoring and observability

**Advanced Skills:**
- System design
- Distributed systems
- Scalability patterns
- Technical leadership
- Cross-functional collaboration

### 21.2 Learning Resources

**Documentation:**
- Read official documentation first
- Follow best practices guides
- Study design patterns
- Review architecture docs

**Practice:**
- Work on real projects
- Contribute to open source
- Build side projects
- Experiment with new tech

**Community:**
- Read technical blogs
- Watch conference talks
- Participate in discussions
- Share your learnings

### 21.3 Building Expertise

**Deliberate Practice:**
1. Choose specific skill to improve
2. Practice with intention
3. Seek immediate feedback
4. Focus on weaknesses
5. Track progress

**Knowledge Sharing:**
- Write documentation
- Create tutorials
- Mentor other agents
- Present findings
- Contribute to team knowledge

---

## 22. Appendices

### Appendix A: ISO 8601 Timestamp Format

**Format:** `YYYY-MM-DDTHH:MM:SSZ`

**Examples:**
- `2025-11-19T19:24:57Z` - Full precision
- `2025-11-19T19:24:57.123Z` - With milliseconds
- `2025-11-19T19:24:57+00:00` - With timezone

**Generating Timestamps:**
```python
# Python
from datetime import datetime
timestamp = datetime.utcnow().isoformat() + 'Z'

# JavaScript
const timestamp = new Date().toISOString();

# Bash
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
```

### Appendix B: Common Git Commands

```bash
# Status and diff
git status
git diff
git diff --staged

# Branching
git branch feature-name
git checkout feature-name
git checkout -b feature-name  # Create and switch

# Committing
git add file.txt
git add .
git commit -m "Message"
git commit --amend  # Modify last commit

# Syncing
git pull
git push
git push origin branch-name

# History
git log
git log --oneline
git log --graph --oneline --all

# Undoing
git restore file.txt  # Discard changes
git reset HEAD~1  # Undo last commit (keep changes)
git revert abc123  # Create commit that undoes abc123
```

### Appendix C: Task Priority Guidelines

**P0 - Critical:**
- Production down
- Security vulnerability
- Data loss risk
- Blocking all other work

**P1 - High:**
- Major feature
- Significant bug
- Performance issue
- Blocking some work

**P2 - Normal:**
- Regular feature
- Minor bug
- Enhancement
- Refactoring

**P3 - Low:**
- Nice to have
- Minor improvement
- Cleanup
- Future consideration

### Appendix D: Useful Regular Expressions

```regex
# Email validation
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$

# URL validation
^https?://[^\s/$.?#].[^\s]*$

# Phone number (US)
^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$

# Date (YYYY-MM-DD)
^\d{4}-\d{2}-\d{2}$

# IP address
^(\d{1,3}\.){3}\d{1,3}$

# Password strength (8+ chars, uppercase, lowercase, number)
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$
```

### Appendix E: HTTP Status Codes Reference

**2xx Success:**
- 200 OK - Success
- 201 Created - Resource created
- 204 No Content - Success, no response body

**4xx Client Error:**
- 400 Bad Request - Invalid request
- 401 Unauthorized - Authentication required
- 403 Forbidden - Not allowed
- 404 Not Found - Resource not found
- 429 Too Many Requests - Rate limited

**5xx Server Error:**
- 500 Internal Server Error - Server error
- 502 Bad Gateway - Invalid upstream response
- 503 Service Unavailable - Server down
- 504 Gateway Timeout - Upstream timeout

### Appendix F: Testing Pyramid Reference

```
Level          | Count | Speed   | Confidence | Cost
---------------|-------|---------|------------|------
E2E Tests      | 10    | Slow    | High       | High
Integration    | 50    | Medium  | Medium     | Medium
Unit Tests     | 500   | Fast    | Low        | Low
```

**Guidelines:**
- Most tests should be unit tests
- Some tests should be integration tests
- Few tests should be E2E tests
- Aim for 70-20-10 ratio

---

*Document Status: Active | Last Review: 2025-11-19 | Next Review: 2025-12-19*
