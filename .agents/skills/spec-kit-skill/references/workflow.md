# Spec-Driven Development Workflow

This reference detailed the exact sequence of commands and rationale for Spec Kit.

## 1. /speckit.constitution
Establishes project's governing principles. 
Example: `/speckit.constitution Create principles focused on code quality, testing standards, UX, and performance requirements.`
Output: `.specify/memory/constitution.md`

## 2. /speckit.specify
Creates project specifications. Focus on the what and why, not the tech stack.
Example: `/speckit.specify Build a team productivity platform. Focus on Kanban boards without login.`
Output: `specs/[feature-branch]/spec.md`

## 3. /speckit.clarify (Optional)
Clarifies the requirements before creating a technical plan.
Uses sequential, coverage-based questioning that records answers in a Clarifications section.

## 4. /speckit.plan
Generates a technical plan with exact tech stack and architecture.
Example: `/speckit.plan Use React on the frontend and Node.js with Postgres on the backend.`
Output: `specs/[feature-branch]/plan.md` and related contracts or data models.

## 5. /speckit.tasks
Breaks down the plan into a series of actionable steps.
Output: `specs/[feature-branch]/tasks.md` with sequence logic and `[P]` parallel markers.

## 6. /speckit.implement
Executes all tasks. Validates that the constitution, spec, plan, and tasks are in place, then builds the production code using the agent.
