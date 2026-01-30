# Phase 5: Code Refinements & Modern Conventions

> Research plan for identifying and implementing modern code patterns, efficiency improvements, and elegant conventions for Astro local business templates.

---

## Objectives

1. Identify minor but recurring issues from git history analysis
2. Research modern 2025/2026 conventions for Astro, Tailwind, TypeScript
3. Document best practices as a style guide
4. Apply findings to `astro-local-business-v2` template
5. Create reusable patterns for future templates

---

## Research Methods

### Method 1: Git History Mining
Extract patterns from the 1,121 commits across 8 repos that weren't critical but appeared frequently.

### Method 2: Web Research
Search for current best practices, style guides, and modern techniques.

### Method 3: Reference Repo Analysis
Study high-quality open source Astro templates for patterns.

### Method 4: Official Documentation
Review official recommendations from Astro, Tailwind, TypeScript teams.

---

## Research Checklist

### 5.1 Git History Review (COMPLETED 2026-01-30)

**Output:** [GIT_HISTORY_MINOR_PATTERNS.md](./GIT_HISTORY_MINOR_PATTERNS.md)

#### 5.1.1 Review Existing Analysis
- [x] Re-read CROSS_REPO_ANALYSIS.md for non-image issues
- [x] Categorize minor recurring patterns
- [x] List CSS/styling issues that appeared multiple times
- [x] List component structure issues
- [x] List accessibility fixes that were made
- [x] List performance optimizations that were applied

#### 5.1.2 Identify Pattern Categories
- [x] Create list of "code smell" patterns to avoid
- [x] Create list of "good patterns" that solved problems
- [x] Note any refactoring patterns that improved code

#### 5.1.3 Findings Summary

**9 Minor Pattern Categories Identified:**

| Category | Mentions | Priority |
|----------|----------|----------|
| Typography/Text | 9+ | P1 |
| Mobile/Responsive | 18 | P2 |
| Color/Theme | 36 | Done |
| Layout | 7 | P1 |
| SEO | 9 | Done |
| Footer | 8 | P3 |
| Deployment | 6+ | P1 |
| Background Images | 25+ | P2 |
| Component-specific | Various | P2 |

**P1 Quick Wins to Implement:**
1. Typography scale in CSS variables
2. Spacing scale standardization
3. Background image utilities
4. Deployment config templates (netlify.toml, vercel.json)

---

### 5.2 Web Research - Astro Patterns

#### 5.2.1 Astro Component Conventions
- [ ] Search: "Astro component best practices 2025"
- [ ] Search: "Astro 5 patterns and conventions"
- [ ] Research: Props interface patterns
- [ ] Research: Slot usage patterns
- [ ] Research: Client directive best practices (`client:load` vs `client:idle` vs `client:visible`)

#### 5.2.2 Astro Project Structure
- [ ] Search: "Astro project structure 2025"
- [ ] Research: File naming conventions
- [ ] Research: Component organization patterns
- [ ] Research: Utility function organization

#### 5.2.3 Astro Performance
- [ ] Search: "Astro performance optimization 2025"
- [ ] Research: Island architecture best practices
- [ ] Research: Partial hydration patterns
- [ ] Research: Build optimization techniques

---

### 5.3 Web Research - Tailwind CSS v4

#### 5.3.1 Tailwind Conventions
- [ ] Search: "Tailwind CSS v4 best practices 2025"
- [ ] Search: "Tailwind CSS class organization"
- [ ] Research: `@theme` block patterns
- [ ] Research: Custom utility patterns
- [ ] Research: When to use `@apply` vs inline classes

#### 5.3.2 CSS Architecture
- [ ] Search: "modern CSS architecture 2025"
- [ ] Research: CSS custom properties patterns
- [ ] Research: Container queries usage
- [ ] Research: `:has()` selector patterns
- [ ] Research: CSS nesting best practices

#### 5.3.3 Responsive Design
- [ ] Search: "responsive design patterns 2025"
- [ ] Research: Mobile-first vs desktop-first conventions
- [ ] Research: Breakpoint organization
- [ ] Research: Fluid typography patterns

---

### 5.4 Web Research - TypeScript

#### 5.4.1 TypeScript Patterns
- [ ] Search: "TypeScript best practices 2025"
- [ ] Research: Interface vs Type conventions
- [ ] Research: Strict mode patterns
- [ ] Research: Utility type usage

#### 5.4.2 Type Safety in Astro
- [ ] Search: "Astro TypeScript patterns"
- [ ] Research: Props typing patterns
- [ ] Research: Content collection type usage
- [ ] Research: Import type patterns

---

### 5.5 Web Research - Accessibility

#### 5.5.1 Modern A11y Patterns
- [ ] Search: "web accessibility best practices 2025"
- [ ] Search: "ARIA patterns 2025"
- [ ] Research: Focus management patterns
- [ ] Research: Screen reader optimization
- [ ] Research: Keyboard navigation patterns

#### 5.5.2 Component A11y
- [ ] Research: Accessible modal patterns
- [ ] Research: Accessible navigation patterns
- [ ] Research: Accessible form patterns
- [ ] Research: Accessible image patterns

---

### 5.6 Web Research - Performance

#### 5.6.1 Core Web Vitals
- [ ] Search: "Core Web Vitals optimization 2025"
- [ ] Research: LCP optimization techniques
- [ ] Research: CLS prevention patterns
- [ ] Research: INP optimization

#### 5.6.2 Asset Optimization
- [ ] Research: Modern image formats (AVIF adoption)
- [ ] Research: Font loading strategies
- [ ] Research: CSS/JS optimization patterns

---

### 5.7 Reference Repo Analysis

#### 5.7.1 AstroWind Template
- [ ] Clone/review AstroWind repository
- [ ] Document component patterns used
- [ ] Document CSS organization approach
- [ ] Document utility function patterns
- [ ] Note any unique/clever solutions

#### 5.7.2 Other Quality Templates
- [ ] Search: "best Astro templates 2025"
- [ ] Identify 2-3 well-maintained templates
- [ ] Review their code organization
- [ ] Note patterns worth adopting

#### 5.7.3 Non-Astro References
- [ ] Review Next.js/Nuxt patterns that could apply
- [ ] Review general component library patterns (Radix, Shadcn)

---

### 5.8 Official Documentation Review

#### 5.8.1 Astro Docs
- [ ] Review Astro official best practices page
- [ ] Review Astro style guide (if exists)
- [ ] Check Astro Discord/GitHub for conventions

#### 5.8.2 Tailwind Docs
- [ ] Review Tailwind v4 migration guide patterns
- [ ] Review Tailwind recommended patterns
- [ ] Check Tailwind blog for convention posts

#### 5.8.3 TypeScript Docs
- [ ] Review TypeScript do's and don'ts
- [ ] Review strict mode recommendations

---

## Deliverables

### 5.9 Documentation

- [ ] **5.9.1 CODE_STYLE_GUIDE.md** - Conventions for Astro/Tailwind/TS
- [ ] **5.9.2 COMPONENT_PATTERNS.md** - Reusable component patterns
- [ ] **5.9.3 CSS_CONVENTIONS.md** - CSS/Tailwind organization rules
- [ ] **5.9.4 ACCESSIBILITY_CHECKLIST.md** - A11y patterns to follow

### 5.10 Template Updates

- [ ] **5.10.1** Apply findings to `astro-local-business-v2`
- [ ] **5.10.2** Refactor any code that doesn't follow new conventions
- [ ] **5.10.3** Add code comments explaining pattern choices
- [ ] **5.10.4** Update README with style guide reference

---

## Research Log

| Date | Task | Findings | Action |
|------|------|----------|--------|
| | | | |

---

## Priority Matrix

After research, categorize findings:

| Priority | Impact | Effort | Examples |
|----------|--------|--------|----------|
| P1 - Must Have | High | Low | Obvious improvements |
| P2 - Should Have | High | Medium | Significant but more work |
| P3 - Nice to Have | Low | Low | Polish items |
| P4 - Defer | Low | High | Future consideration |

---

## Success Criteria

- [ ] All research sections completed
- [ ] At least 20 actionable conventions documented
- [ ] CODE_STYLE_GUIDE.md created with clear rules
- [ ] Template updated with at least 10 improvements
- [ ] No regressions (build still works, Lighthouse still 90+)

---

## Timeline

| Week | Focus |
|------|-------|
| Week 1 | Git history review + Web research (5.1-5.4) |
| Week 2 | Web research continued + Reference repos (5.5-5.7) |
| Week 3 | Documentation review + Compile findings (5.8) |
| Week 4 | Create deliverables + Apply to template (5.9-5.10) |

---

## Notes

*Add research notes, interesting findings, and links here as work progresses*

---

*Phase 5 Plan Created: January 2026*
