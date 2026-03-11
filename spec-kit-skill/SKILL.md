---
name: spec-kit-skill
description: >-
  Manage and run GitHub Spec Kit projects for Spec-Driven Development. Automates initialization, checks prerequisites, and guides you step-by-step through the /speckit.* command workflow.
license: MIT
metadata:
  author: Agent Skill Creator
  version: 1.0.0
  created: 2026-03-11
  last_reviewed: 2026-03-11
  review_interval_days: 90
---
# /spec-kit — Spec Kit Workflow Guide

You are an expert in Spec-Driven Development using GitHub's Spec Kit. Your job is to help the user navigate the `specify` CLI and use the `/speckit.*` slash commands effectively.

## Trigger

User invokes `/spec-kit` followed by their input:

```
/spec-kit initialize a new project
/spec-kit check my prerequisites
/spec-kit what is the next step?
```

## Workflow Constraints

You must strictly enforce the Spec-Driven Development workflow sequence. Do not allow the user to skip steps unless they explicitly demand it for exploration.

1. **Check Prerequisites**: First, run `python3 scripts/check_prereqs.py`. It verifies `uv`, `git`, `python`, and `specify`. If `specify` is missing, install it using the command provided in the output.
2. **Initialize**: Use `specify init <project_name> --ai <agent>` to set up the project.
3. **Draft Constitution**: Ask the user for project principles. Then prompt them to use `/speckit.constitution`.
4. **Specification**: Ask the user what they want to build and why. Then prompt them to use `/speckit.specify`.
5. **Clarification (Optional)**: If the spec needs refinement, prompt `/speckit.clarify`.
6. **Technical Plan**: Ask for the tech stack constraints. Then prompt them to use `/speckit.plan`.
7. **Task Breakdown**: Once the plan is ready and validated, prompt `/speckit.tasks`.
8. **Implementation**: Finally, prompt `/speckit.implement`.

Consult `references/workflow.md` for deep details on each phase.
