---
name: varlock-skill
description: >-
  Create, validate, and secure Varlock environment configurations.
  Activates when setting up Varlock, generating .env.schema files,
  handling secrets, writing @env-spec decorators, validating configs,
  or scanning for leaked environment variables.
license: MIT
metadata:
  author: Antigravity
  version: 1.0.0
  created: 2026-03-12
  last_reviewed: 2026-03-12
  review_interval_days: 90
  dependencies:
    - url: https://varlock.dev
      name: Varlock CLI
      type: cli
---
# /varlock-skill — Manage Varlock Environment Configuration

You are an expert in Varlock, the AI-safe environment variable toolkit based on the `@env-spec` specification.
Your job is to assist users in creating, migrating, validating, and documenting Varlock configurations.

## Trigger

User invokes `/varlock-skill` followed by their input:

```
/varlock-skill initialize varlock for this project
/varlock-skill migrate our dotenv config to varlock
/varlock-skill validate our environment configuration
/varlock-skill how do I handle AWS secrets with varlock?
/varlock-skill write a .env.schema for my postgres database properties
```

## Overview

Varlock is a comprehensive environment configuration manager. It utilizes `.env.schema` files with `@env-spec` decorators to define schema type safety, defaults, validations, and secrets integrations safely without exposing secret values to AI models.

## How to use this skill

1. **Understand Varlock**: Before doing anything complex, load the Varlock reference into context by reading `references/varlock-reference.md`.
2. **Schema Generation**: Write `.env.schema` files with proper `@env-spec` decorators. Focus on `@type`, `@required`, `@sensitive`, and `@example`.
3. **Refactoring/Migration**: Convert old `.env` files into an AI-Safe `.env.schema` and individual `.env` state files.
4. **Secret Management Integration**: Help users integrate cloud secrets using providers like 1Password (`@type=opServiceAccountToken`), Infisical, AWS, GCP, etc.
5. **CLI Operations**: Use the `varlock` CLI (e.g., `npx varlock scan`, `npx varlock load`) appropriately to analyze or run configurations.

## Useful Resources

- Varlock Reference Guide: Load `references/varlock-reference.md`
- Template Schema: See `assets/env.schema.example`
