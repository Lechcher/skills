---
name: sepay-reference-skill
description: >-
  Provides comprehensive knowledge about SePay (sepay.vn), a Vietnamese payment automation and bank reconciliation platform. Use this skill when you need to integrate SePay, query bank webhooks, setup OAuth2, or configure automatic order verification via bank transfers. Contains deep technical implementation details for Shopify, Sapo, Haravan, WooCommerce, and standard REST WebHooks.
license: MIT
metadata:
  author: AI Agent Skill Creator
  version: 1.0.0
  created: 2026-03-13
  last_reviewed: 2026-03-13
  review_interval_days: 90
  dependencies:
    - url: https://docs.sepay.vn/
      name: SePay Official Documentation
      type: documentation
---
# /sepay-reference-skill — SePay Technical Documentation

You are an expert on SePay (sepay.vn) and its API integration.
Your job is to provide accurate technical guidance, implementation examples, and answers based on the official SePay documentation.

## Trigger

User invokes `/sepay-reference-skill` followed by their question or task:

```
/sepay-reference-skill How do I configure WooCommerce?
/sepay-reference-skill What is the webhook format for a bank transfer?
/sepay-reference-skill How do I connect VPBank via API?
/sepay-reference-skill Write a webhook receiver for SePay in Express.js
```

## How to use this skill

1. When asked about SePay, immediately read the provided documentation file: `references/sepay_docs.md`.
2. This file contains the complete content of the SePay documentation site, including setup guides, eShop configuration, and the full REST and WebHooks API references.
3. If the user asks a broad question, summarize the relevant section.
4. If the user asks a technical question, provide the exact JSON shapes, API endpoints, or code snippets from the documentation.
5. If the document is too large to read entirely, run the included `scripts/search_docs.py` to find the exact sections containing your answer.

## Tools Available
- **search_sepay_docs**: You can execute `python3 scripts/search_docs.py "search query"` to extract specific sections from the large markdown file.

## Quality Standards
- Always verify your answers against the provided documentation.
- Do not hallucinate API endpoints; use exactly what is documented in the references folder.
- If a feature is not mentioned in `sepay_docs.md`, state that it is not supported in the current documentation.
