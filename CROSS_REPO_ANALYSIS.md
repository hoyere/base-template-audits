# Cross-Repository Git History Analysis

> Analysis of 8 template repositories to identify common patterns and issues
> Generated: January 2026

---

## Executive Summary

### Key Finding: Images Are The #1 Problem

Across all 8 repositories, **image-related issues dominate**:
- "image" appears in **top 3 commit words** in 7/8 repos
- `manifest.json` is a **hotspot file** in 4/8 repos
- `public/images/unsplash/` appears in fix commits repeatedly
- Image-related fixes account for **40-60%** of all fix commits

### Second Finding: Same Pages Keep Changing

These files are hotspots across nearly every repo:
1. `index.astro` (home page)
2. `services.astro`
3. `about.astro`
4. `gallery.astro`

### Third Finding: Header Issues Recur

Header-related commits appear in multiple repos, particularly:
- Header sizing/height
- Header stability
- Header layout

---

## Repository Summary Table

| Repository | Commits | Fix % | Top Hotspot | Top Issue |
|------------|---------|-------|-------------|-----------|
| astro-law-dctm | 28 | **17.8%** | HeroSection.astro (13) | Header sizing |
| astro-hvac-template | 156 | 5.1% | homeMain.ts (29) | Images |
| astro-landscaping-greenova | 133 | 3.0% | manifest.json (46) | Images |
| astro-handyman-houzfix | 179 | **11.1%** | services.astro (42) | Images |
| astro-carpenter-craftmax | 214 | 1.4% | index.astro (65) | Images, dark mode |
| astro-automobile-autorex | 162 | 1.8% | index.astro (58) | Images, mobile |
| astro-barber-qutter | 78 | 1.2% | FeatureHighlights.astro (14) | Images |
| astro-restaurant-template | 171 | 3.5% | TestimonialsCarousel.astro (30) | Images |

**Average Fix Rate:** 5.6%
**Highest Fix Rate:** astro-law-dctm (17.8%) - Header issues
**Second Highest:** astro-handyman-houzfix (11.1%) - Image issues

---

## Pattern Analysis

### 1. Most Common Words in Commit Messages

Aggregated across all repos:

| Rank | Word | Repos Appearing | Insight |
|------|------|-----------------|---------|
| 1 | **follow** | 8/8 | Instruction-following pattern |
| 2 | **instruction(s)** | 8/8 | Instruction-following pattern |
| 3 | **image(s)** | 8/8 | **IMAGE ISSUES** |
| 4 | **section** | 7/8 | Component-level changes |
| 5 | **background** | 5/8 | Background image issues |
| 6 | **improve** | 6/8 | Iterative improvements |
| 7 | **header** | 4/8 | Header problems |
| 8 | **needed** | 5/8 | Missing functionality |
| 9 | **fix** | 5/8 | Bug fixes |
| 10 | **changes** | 5/8 | Modifications |

**Key Insight:** "follow" and "instruction" dominating suggests AI-assisted development workflow. The high frequency of "image" confirms images are the primary pain point.

### 2. File Churn Analysis (Hotspot Files)

Files that appear in **top 10 hotspots across multiple repos**:

| File Pattern | Repos | Changes | Issue Type |
|--------------|-------|---------|------------|
| `index.astro` | 7/8 | 200+ total | Core page instability |
| `services.astro` | 6/8 | 150+ total | Service page changes |
| `about.astro` | 6/8 | 100+ total | About page changes |
| `gallery.astro` | 5/8 | 80+ total | Gallery issues |
| `manifest.json` | 4/8 | 150+ total | **Image system** |
| `contact.astro` | 4/8 | 50+ total | Contact form |
| `.claude/settings.local.json` | 6/8 | 60+ total | Dev tooling |
| `global.css` | 3/8 | 30+ total | Style changes |

### 3. Fix Commit Analysis

#### What Gets Fixed Most?

Aggregating fix commits across all repos:

| Fix Category | Occurrences | Example Commits |
|--------------|-------------|-----------------|
| **Image issues** | 25+ | "fix image", "FIXING IMAGES", "fix image loading" |
| **Header issues** | 8+ | "FIX HEADER SIZE", "Fix: Ensure consistent header heights" |
| **Deployment** | 6+ | "Fix deployment", "fix: correct base directory in netlify.toml" |
| **Text/Content** | 5+ | "FIXING TEXTS ALIGNMENT", "Fix content" |
| **Build errors** | 4+ | "fixed build error", "Fix deployment" |
| **Spacing/Layout** | 4+ | "fixed spacing issue", "FIX TEXT ALIGNMENT" |

#### Repos with Most Fixes

| Repo | Fix Commits | Fix Types |
|------|-------------|-----------|
| astro-handyman-houzfix | 20 | Images (12), Build (3), Misc (5) |
| astro-hvac-template | 8 | Images (5), Text (2), Footer (1) |
| astro-restaurant-template | 6 | Images (3), Content (2), Config (1) |
| astro-law-dctm | 5 | Header (4), Content (1) |

### 4. Component Mention Analysis

How often components are mentioned in commits:

| Component | Total Mentions | Repos |
|-----------|---------------|-------|
| Image | **356** | 8/8 |
| Header | 42 | 7/8 |
| Section | 35+ | 7/8 |
| Footer | 8 | 4/8 |
| Hero | 11 | 5/8 |
| Mobile | 18 | 4/8 |
| Color/Theme | 17 | 5/8 |
| Layout | 7 | 4/8 |
| SEO | 9 | 5/8 |
| Navigation | 2 | 2/8 |

---

## Root Cause Analysis

### Why Are Images The #1 Problem?

Based on the commit patterns:

1. **Image System Complexity**
   - `manifest.json` files track image metadata
   - Images in `public/images/unsplash/` need manual management
   - No automated optimization pipeline
   - Image references break when paths change

2. **Common Image Fix Patterns:**
   ```
   "fix image loading - use imageKey instead of query"
   "FIXING IMAGES"
   "fix the image in profile icon"
   "fixed images for headshots"
   "FIX IMAGE IN THE BOX"
   ```

3. **Image Issues Span:**
   - Wrong image displayed
   - Missing images
   - Image path resolution
   - Image sizing/cropping
   - Background vs foreground images
   - Headshot/profile images

### Why Do Headers Keep Breaking?

From astro-law-dctm commits (highest fix rate):
```
FIX THE HEADER SECTION
FIX HEADER SECTION SIZE
Fix: Ensure consistent header heights across all pages (220px-320px)
FIX HEADER SIZE
```

**Root Causes:**
- No standardized header height system
- Font loading causes reflow
- Missing `whitespace-nowrap` / `flex-shrink-0`
- Inconsistent hero/header interaction

### Why Do The Same Pages Keep Changing?

`index.astro`, `services.astro`, `about.astro`, `gallery.astro` are hotspots because:
- They contain the most sections
- They have the most images
- They're the most visible pages
- Content changes cascade through them

---

## Patterns to Address in Base Template

### Critical (Fix in Base Template)

| Issue | Evidence | Recommended Fix |
|-------|----------|-----------------|
| Image system fragility | 356 image mentions, manifest.json hotspots | Move to src/assets/, use Astro Image |
| manifest.json churn | Top hotspot in 4/8 repos | Eliminate manifest pattern |
| Header instability | 42 header mentions, dedicated fix commits | Add stability patterns to base |
| public/images/unsplash/ | Appears in fix files repeatedly | Migrate to src/assets/images/ |

### High Priority

| Issue | Evidence | Recommended Fix |
|-------|----------|-----------------|
| Page section churn | index/services/about hotspots | Modular section components |
| Background images | 25+ "background" mentions | Standardize background handling |
| Deployment issues | 6+ deployment fix commits | Include netlify.toml in base |
| Text alignment | Multiple "alignment" fixes | Typography system |

### Medium Priority

| Issue | Evidence | Recommended Fix |
|-------|----------|-----------------|
| Gallery component | gallery.astro hotspot | Robust gallery component |
| Testimonials | TestimonialsCarousel hotspot | Stable carousel component |
| Contact form | contact.astro appears often | Form component in base |
| Dark mode | 19 dark mode mentions | Theme system support |

---

## Recommendations for AUDIT_v2 Updates

### Add These Checks to AUDIT_v2_2 (Structure)

```markdown
### Image System Verification

| Check | Status | Notes |
|-------|--------|-------|
| No `manifest.json` files | | Should be 0 |
| No `public/images/` directory | | All in src/assets |
| Images use Astro `<Image />` component | | Not native <img> |
| All images have width/height | | CLS prevention |
| Placeholder fallback exists | | For missing images |
```

### Add These Checks to AUDIT_v2_4 (Theme Prep)

```markdown
### Header Stability (Expanded)

| Check | Status | Notes |
|-------|--------|-------|
| Header height consistent (CSS var) | | `--header-height` |
| Font preloading configured | | Prevents reflow |
| `whitespace-nowrap` on text elements | | 4+ instances |
| `flex-shrink-0` on containers | | Logo, CTA |
| Height recalculated on font load | | JS listener |
| Mobile menu uses dynamic height | | Not hardcoded |
```

### New Section: Deployment Readiness

```markdown
## Deployment Verification

| Check | Status | Notes |
|-------|--------|-------|
| `netlify.toml` present | | Correct base path |
| `.gitignore` includes node_modules | | |
| No localhost URLs in code | | |
| Build succeeds locally | | `npm run build` |
| Site URL configured | | astro.config.mjs |
```

---

## Component Stability Ranking

Based on churn analysis, rank components by stability needs:

### Most Unstable (Need Rework)

1. **Image handling system** - 356 mentions, constant fixes
2. **Hero/Header sections** - 50+ mentions, sizing issues
3. **Gallery components** - Appears in hotspots in 5/8 repos
4. **Testimonial carousels** - High churn in multiple repos

### Moderately Stable

5. Services pages/components
6. About pages/sections
7. Team sections
8. Contact forms

### Most Stable (Reference These)

9. Footer (low mention count)
10. Navigation (rarely mentioned)
11. Legal pages (minimal churn)

---

## Action Items

### For Base Template v2

1. **Eliminate manifest.json pattern entirely**
   - Move all images to `src/assets/images/`
   - Use Astro's `<Image />` component
   - Create `imageResolver.ts` that doesn't need manifest

2. **Standardize header component**
   - Fixed CSS variable `--header-height`
   - Font preloading built-in
   - Stability classes pre-applied
   - Mobile menu with dynamic positioning

3. **Create robust gallery component**
   - Handles missing images gracefully
   - Responsive grid built-in
   - Lazy loading standard

4. **Include deployment config**
   - `netlify.toml` template
   - Vercel config template
   - Proper `.gitignore`

### For Audit System

1. Add "Image System" verification section
2. Add "Header Stability" expanded checks
3. Add "Deployment Readiness" section
4. Create "Component Stability Score" metric

---

## Data Files Generated

```
git-audit-data/
├── astro-law-dctm/
├── astro-hvac-template/
├── astro-landscaping-greenova/
├── astro-handyman-houzfix/
├── astro-carpenter-craftmax/
├── astro-automobile-repair-autorex/
├── astro-barber-qutter/
└── astro-restaurant-template/
    ├── stats.txt
    ├── commits_full.csv
    ├── commit_messages.txt
    ├── file_churn.txt
    ├── fix_commits.txt
    ├── fix_files.txt
    └── common_words.txt
```

---

## Summary

### The Big Three Problems

1. **Images** (40%+ of all issues)
   - Fragile manifest system
   - Wrong locations (public vs src)
   - Missing optimization

2. **Headers** (15% of issues)
   - Inconsistent heights
   - Font-loading reflow
   - Missing stability patterns

3. **Core Pages** (20% of issues)
   - index, services, about, gallery
   - Too many changes per page
   - Section coupling

### Fixing These Will Reduce Fix Commits by ~75%

If the base template addresses:
- ✅ Image system → Eliminates 40%+ of fixes
- ✅ Header stability → Eliminates 15% of fixes
- ✅ Modular sections → Reduces page churn by 20%

---

*Analysis completed: January 2026*
*Repositories analyzed: 8*
*Total commits analyzed: 1,121*
*Total fix commits: 50*
