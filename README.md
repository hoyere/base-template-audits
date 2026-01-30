# Template System Overhaul

Planning and documentation for rebuilding the Astro template system.

## Quick Summary

**Problem:** 40%+ of commits across 8 template repos were image-related fixes.

**Root Cause:** `astro-unsplash-integration` fetches images at runtime → non-deterministic builds.

**Solution:**
1. Deprecate runtime image fetching
2. Fix `image-studio` CLI for local downloads
3. Build new base template with correct architecture

## Documents

| Document | Purpose |
|----------|---------|
| [ACTION_PLAN.md](./ACTION_PLAN.md) | **Start here** - Full implementation plan |
| [UNIFIED_TEMPLATE_SYSTEM.md](./UNIFIED_TEMPLATE_SYSTEM.md) | Complete system specification |
| [EXTERNAL_RESOURCES.md](./EXTERNAL_RESOURCES.md) | Reference repos and articles |

### Research & Analysis

| Document | Purpose |
|----------|---------|
| [astro-tailwind-typescript-best-practices.md](./astro-tailwind-typescript-best-practices.md) | Official docs research |
| [CROSS_REPO_ANALYSIS.md](./CROSS_REPO_ANALYSIS.md) | 8 repo git history analysis |
| [ALIGNMENT_ANALYSIS.md](./ALIGNMENT_ANALYSIS.md) | Gap analysis vs best practices |

### Audits

| Document | Purpose |
|----------|---------|
| [BASELINE_TEMPLATE_AUDIT.md](./BASELINE_TEMPLATE_AUDIT.md) | Current base template issues |
| [IMAGE_STUDIO_AUDIT.md](./IMAGE_STUDIO_AUDIT.md) | CLI tool - minor fixes needed |
| [ASTRO_UNSPLASH_INTEGRATION_AUDIT.md](./ASTRO_UNSPLASH_INTEGRATION_AUDIT.md) | Runtime integration - deprecate |

### Process

| Document | Purpose |
|----------|---------|
| [GIT_HISTORY_AUDIT_PROCESS.md](./GIT_HISTORY_AUDIT_PROCESS.md) | How to audit repo histories |
| [analyze_repo.sh](./analyze_repo.sh) | Script for git history analysis |

## The Plan

```
Phase 1 (Day 1)     → Deprecate bad tool, fix good tool
Phase 2 (Weeks 1-4) → Build new base template
Phase 3 (Week 5)    → Documentation
```

## Key Decisions

- **Images:** Download locally with CLI, store in `src/assets/images/`
- **Tailwind:** v4 via `@tailwindcss/vite` (not `@astrojs/tailwind`)
- **Theming:** CSS variables with `@theme` block
- **Content:** Collections with `image()` schema validation
- **Architecture:** Modular sections, props-driven components
