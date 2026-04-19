# Postman CLI Skill

A complete skill for utilizing the Postman CLI in workflows, including running collections, testing API governance, monitoring performance, and integrating with GitHub Actions.

## Installation

You can install this skill locally for any supported agent (Claude Code, Antigravity, Cursor, Windsurf, etc.) using the included installer:

```bash
./install.sh
```

Or just copy the directory to your standard `.agents/skills/postman-cli-skill` directory.

## Usage

Simply invoke the skill in your IDE or conversational agent:

```
/postman-cli-skill Show me how to run a collection and output a junit test report
```

```
/postman-cli-skill Assist me in writing a GitHub Action to lint our OpenAPI definition
```

## Features

- **Authentication**: Easy commands to handle `postman login`.
- **Collection Running**: Everything from handling local JSON data to integration with the Postman Cloud.
- **Reporting**: JSON, JUnit CLI and custom reporter setups.
- **CI/CD Integrations**: Ready-to-go GitHub Action setups.
- **Governance**: Commands for `postman api lint`.
