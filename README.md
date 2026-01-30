# Template System Overhaul

Planning and documentation for rebuilding the Astro template system.

## Quick Summary

**Problem:** 40%+ of commits across 8 template repos were image-related fixes.

**Root Cause:** `astro-unsplash-integration` fetches images at runtime → non-deterministic builds.

**Solution:**
1. ✅ Deprecate runtime image fetching
2. ✅ Fix `image-studio` CLI for local downloads
3. ✅ Build new base template with correct architecture
4. ✅ Document the workflow

## New Base Template

**Repository:** [astro-local-business-v2](https://github.com/hoyere/astro-local-business-v2)

Built with:
- Astro 5.x + Tailwind CSS v4
- TypeScript strict mode
- Content Collections with Zod validation
- Dark mode + View Transitions
- LocalBusiness schema (SEO)
- Modular section components

---

## Documentation

### Workflow Guides

| Document | Purpose |
|----------|---------|
| [TEMPLATE_CUSTOMIZATION.md](./TEMPLATE_CUSTOMIZATION.md) | **Start here** - Step-by-step client setup |
| [IMAGE_WORKFLOW.md](./IMAGE_WORKFLOW.md) | Two-phase image workflow |
| [COMMON_EDITS.md](./COMMON_EDITS.md) | Quick reference for frequent changes |

### Planning & Analysis

| Document | Purpose |
|----------|---------|
| [ACTION_PLAN.md](./ACTION_PLAN.md) | Full implementation plan with checklist |
| [UNIFIED_TEMPLATE_SYSTEM.md](./UNIFIED_TEMPLATE_SYSTEM.md) | Complete system specification |
| [EXTERNAL_RESOURCES.md](./EXTERNAL_RESOURCES.md) | Reference repos and articles |

### Research

| Document | Purpose |
|----------|---------|
| [astro-tailwind-typescript-best-practices.md](./astro-tailwind-typescript-best-practices.md) | Official docs research |
| [CROSS_REPO_ANALYSIS.md](./CROSS_REPO_ANALYSIS.md) | 8 repo git history analysis |
| [ALIGNMENT_ANALYSIS.md](./ALIGNMENT_ANALYSIS.md) | Gap analysis vs best practices |

### Audits

| Document | Purpose |
|----------|---------|
| [BASELINE_TEMPLATE_AUDIT.md](./BASELINE_TEMPLATE_AUDIT.md) | Old base template issues |
| [IMAGE_STUDIO_AUDIT.md](./IMAGE_STUDIO_AUDIT.md) | CLI tool - fixed |
| [ASTRO_UNSPLASH_INTEGRATION_AUDIT.md](./ASTRO_UNSPLASH_INTEGRATION_AUDIT.md) | Runtime integration - deprecated |

### Process

| Document | Purpose |
|----------|---------|
| [GIT_HISTORY_AUDIT_PROCESS.md](./GIT_HISTORY_AUDIT_PROCESS.md) | How to audit repo histories |
| [analyze_repo.sh](./analyze_repo.sh) | Script for git history analysis |

### Legacy Audit System

| Document | Purpose |
|----------|---------|
| [template-audit-docs/AUDIT_v2_INDEX.md](./template-audit-docs/AUDIT_v2_INDEX.md) | Theme-agnostic audit checklist |

---

## Key Architecture Decisions

### Images
- **Download locally** with `image-studio` CLI during development
- **Store in** `src/assets/images/` (not public/)
- **Use** Astro's `<Image />` component for optimization
- **No runtime fetching** - all images exist before build

### Tailwind CSS
- **v4** via `@tailwindcss/vite` plugin
- **Not** `@astrojs/tailwind` (deprecated pattern)
- **Theme** via `@theme` block in CSS, not tailwind.config.js

### Content
- **Collections** with Zod schemas in `src/content.config.ts`
- **Glob loader** for markdown files
- **Image validation** with `image()` schema function

### Components
- **Section-based** architecture (Hero, Services, About, etc.)
- **Props-driven** for customization
- **CSS scoped** to components

---

## Quick Start (New Project)

```bash
# Clone the new base template
git clone https://github.com/hoyere/astro-local-business-v2.git client-site
cd client-site

# Remove template git history
rm -rf .git && git init

# Install and run
npm install
npm run dev

# Follow TEMPLATE_CUSTOMIZATION.md for setup
```

---

## Project Status

### Completed ✅
- Phase 1: Fix image-studio CLI
- Phase 2: Deprecate astro-unsplash-integration
- Phase 3: Build astro-local-business-v2 template
- Phase 4: Documentation

### Manual Testing Needed
- Header scroll stability (visual)
- Lighthouse audit (browser)
- Cross-browser testing

---

*Last updated: January 2026*
