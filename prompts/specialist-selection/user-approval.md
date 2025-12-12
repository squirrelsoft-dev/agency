# Specialist Selection: User Approval

Present specialist selection to user for confirmation.

## Single Specialist

```
Use AskUserQuestion tool:

"I've analyzed the plan and selected **[SPECIALIST]** based on these keywords: [KEYWORD_LIST].

Proceed with [SPECIALIST] for implementation?"

Options:
- Yes, proceed with [SPECIALIST] (Recommended)
- No, use a different specialist
```

**If user selects "Other"**: Ask which specialist they prefer from the available list.

---

## Multi-Specialist

```
Use AskUserQuestion tool:

"**Multi-Specialist Work Detected**

Specialists Needed:
- ✅ [SPECIALIST_1] (Score: [X.X]) - [KEY_RESPONSIBILITIES]
- ✅ [SPECIALIST_2] (Score: [Y.Y]) - [KEY_RESPONSIBILITIES]
[... additional specialists ...]

Execution Strategy: [Sequential/Parallel]
- Reason: [DEPENDENCY_REASON or INDEPENDENCE_REASON]
[IF Sequential]
- Order: [SPECIALIST_1] → [SPECIALIST_2] → ...

Proceed with this plan?"

Options:
- Yes, proceed (Recommended)
- Run in parallel instead (faster, riskier) [IF currently sequential]
- Run sequentially instead (safer) [IF currently parallel]
- Modify specialist selection
```

**If user selects "Modify"**: Ask:
1. Which specialists to add/remove?
2. Change execution order (if sequential)?

---

## Validation

Before proceeding:
- ✅ At least one specialist selected
- ✅ User confirmed selection
- ✅ Execution strategy determined (if multi-specialist)
- ✅ Dependencies understood (if sequential)
