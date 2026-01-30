# Baseline Template Audit: astro-local-business-base

> Audited against: AUDIT_v2 System + Best Practices Research
> Date: January 2026

---

## Executive Summary

The baseline template has a **solid foundation** with good TypeScript configuration, content collections, and a theming approach. However, it has **significant gaps** compared to both the AUDIT_v2 standards and current best practices, particularly around image handling, hardcoded colors, and missing SEO/accessibility features.

### Quick Scores

| Category | Status | Notes |
|----------|--------|-------|
| Code Quality (v2_1) | ⚠️ Partial | Good TS, missing path aliases |
| Structure (v2_2) | ❌ Needs Work | Images in wrong location, manifest present |
| Content (v2_3) | ⚠️ Partial | Placeholder phone, missing SEO |
| Theme Prep (v2_4) | ⚠️ Partial | Has theming, but hardcoded neutral classes |
| Best Practices | ⚠️ Partial | Outdated Tailwind integration |

---

## 1. Code Quality Audit (v2_1)

### 1.1 TypeScript

| Check | Status | Notes |
|-------|--------|-------|
| Uses `astro/tsconfigs/strict` | ✅ Pass | Good choice |
| Has `astro check` script | ✅ Pass | In package.json |
| Props interfaces defined | ✅ Pass | All components typed |
| No `any` types visible | ✅ Pass | Clean typing |

### 1.2 Dependencies

```json
// Current package.json
{
  "@astrojs/mdx": "^4.0.0",
  "@astrojs/tailwind": "^6.0.2",    // ⚠️ DEPRECATED for Tailwind v4
  "@tailwindcss/typography": "^0.5.16",
  "astro": "^5.14.1",
  "sharp": "^0.34.3",
  "tailwindcss": "^3.4.17"           // Using v3, not v4
}
```

| Check | Status | Notes |
|-------|--------|-------|
| Astro 5.x | ✅ Pass | v5.14.1 |
| Tailwind current | ⚠️ Outdated | v3, could upgrade to v4 |
| `@astrojs/tailwind` | ❌ Deprecated | Use `@tailwindcss/vite` for v4 |
| Sharp installed | ✅ Pass | For image optimization |
| No TypeScript package | ⚠️ Note | Astro includes TS, but explicit dep recommended |

**Missing Dependencies:**
- `@astrojs/sitemap` - For SEO
- TypeScript (explicit)

### 1.3 Configuration Files

| File | Present | Valid | Notes |
|------|---------|-------|-------|
| `astro.config.mjs` | ✅ | ✅ | Missing `site` property |
| `tailwind.config.mjs` | ✅ | ✅ | Good structure |
| `tsconfig.json` | ✅ | ⚠️ | Missing path aliases |

**tsconfig.json Issues:**
```json
// Current - minimal
{
  "extends": "astro/tsconfigs/strict",
  "include": [".astro/types.d.ts", "**/*"],
  "exclude": ["dist"]
}

// Recommended - add path aliases
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "~/": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@lib/*": ["./src/lib/*"]
    }
  },
  "include": [".astro/types.d.ts", "**/*"],
  "exclude": ["dist"]
}
```

### 1.4 Security

| Check | Status | Notes |
|-------|--------|-------|
| No hardcoded secrets | ✅ Pass | None found |
| No dangerous patterns | ✅ Pass | No eval, set:html minimal |
| .env in .gitignore | ⚠️ Check | Should verify |

---

## 2. Structure Audit (v2_2)

### 2.1 Directory Structure

**Current:**
```
src/
├── assets/images/library/     # ✅ Some images here
├── components/
│   ├── layout/                # ✅ Good
│   └── sections/              # ✅ Good
├── config/                    # ❌ Should be src/data/
├── content/                   # ✅ Good
├── layouts/                   # ✅ Good
├── lib/                       # ✅ Good (utils)
├── pages/                     # ✅ Good
└── styles/                    # ✅ Good

public/
└── images/
    └── unsplash/              # ❌ Should not exist
        └── manifest.json      # ❌ Should be deleted
```

| Check | Status | Notes |
|-------|--------|-------|
| `src/assets/images/` structure | ⚠️ Partial | Missing icons/, logos/, placeholders/ |
| `src/components/` organized | ✅ Pass | layout/, sections/ |
| `src/content/` has collections | ✅ Pass | 6 collections defined |
| `src/data/` for site config | ❌ Fail | Uses src/config/ instead |
| `src/styles/` present | ✅ Pass | global.css |
| No `public/images/` | ❌ Fail | Has 3.5MB of images |
| No manifest files | ❌ Fail | manifest.json present |

### 2.2 Image System Issues

**Critical: Images in Wrong Location**

```bash
# Current state - PROBLEMATIC
public/images/unsplash/    # 3.5MB, 31 images
public/images/unsplash/manifest.json  # Legacy file

# Should be
src/assets/images/photos/  # Images that need optimization
```

**Issues per AUDIT_v2_2:**
1. ❌ `public/images/unsplash/` exists (should not)
2. ❌ `manifest.json` present (should delete)
3. ❌ Images not in `src/assets/` (won't be optimized)
4. ⚠️ Missing `src/assets/images/icons/`
5. ⚠️ Missing `src/assets/images/logos/`
6. ⚠️ Missing `src/assets/images/placeholders/`
7. ⚠️ Missing `ATTRIBUTION.md`

### 2.3 Content Collections

**Location Issue:**
```
Current:  src/content/config.ts     # ❌ Old Astro 4 pattern
Should:   src/content.config.ts     # ✅ Astro 5 pattern
```

**Collections Defined:**

| Collection | Schema Quality | Notes |
|------------|---------------|-------|
| settings | ✅ Good | Comprehensive site settings |
| services | ✅ Good | Has image schema |
| testimonials | ✅ Good | Clean schema |
| faqs | ✅ Good | Simple, effective |
| pages | ✅ Good | Uses `image()` helper |
| home | ✅ Good | Comprehensive |

**Schema Observations:**
- ✅ Uses `z.string()`, `z.object()` correctly
- ✅ Has `.optional()` and `.default()` patterns
- ⚠️ Missing `z.coerce.date()` for date fields (none currently needed)
- ✅ Uses Astro's `image()` helper in pages collection

### 2.4 Component Architecture

| Component | Props Typed | Clean | Notes |
|-----------|------------|-------|-------|
| Header.astro | ✅ | ✅ | Good interface |
| Footer.astro | ✅ | ✅ | Good interface |
| HeroPrimary.astro | ✅ | ⚠️ | Uses hardcoded neutral |
| ServicesGrid.astro | ✅ | ⚠️ | Uses hardcoded neutral |
| TestimonialsSection.astro | ✅ | ⚠️ | Uses hardcoded neutral |
| PageHero.astro | ✅ | ⚠️ | Uses hardcoded neutral |
| CallToAction.astro | ✅ | ⚠️ | Check for hardcoded |
| IntroSection.astro | ✅ | ⚠️ | Uses hardcoded neutral |

### 2.5 Missing Header Stability Patterns

Per AUDIT_v2_2 Section 3.4:

| Check | Status | Notes |
|-------|--------|-------|
| `whitespace-nowrap` on text | ❌ Missing | No font flash prevention |
| `flex-shrink-0` on containers | ❌ Missing | |
| Dynamic `--header-height` | ❌ Missing | |
| Font preload | ❌ Missing | |

---

## 3. Content Audit (v2_3)

### 3.1 Placeholder Content

| Check | Status | Notes |
|-------|--------|-------|
| No Lorem Ipsum | ✅ Pass | Real content |
| No (555) phone numbers | ❌ Fail | `(555) 123-9876` in site.json |
| No example.com emails | ✅ Pass | Uses atlasfabrication.co |
| Alt text on images | ⚠️ Partial | Some generic |

**Placeholder Phone in `src/content/settings/site.json`:**
```json
"phone": {
  "display": "(555) 123-9876",  // ❌ Placeholder
  "value": "+15551239876"
}
```

### 3.2 SEO Meta Tags

**BaseLayout.astro Analysis:**

| Check | Status | Notes |
|-------|--------|-------|
| `<title>` tag | ✅ Pass | Dynamic |
| `<meta name="description">` | ✅ Pass | From props |
| Canonical URL | ⚠️ Conditional | Only if passed |
| OG tags | ❌ Missing | No Open Graph |
| Twitter cards | ❌ Missing | No Twitter meta |
| Structured data | ❌ Missing | No JSON-LD |

**Missing in `<head>`:**
```html
<!-- Open Graph -->
<meta property="og:type" content="website" />
<meta property="og:url" content={canonicalURL} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:image" content={ogImage} />

<!-- Twitter -->
<meta name="twitter:card" content="summary_large_image" />

<!-- Structured Data -->
<script type="application/ld+json">
  { "@context": "https://schema.org", "@type": "LocalBusiness", ... }
</script>
```

### 3.3 Missing Pages

| Page | Status | Notes |
|------|--------|-------|
| index.astro | ✅ | Home page |
| about.astro | ✅ | About page |
| contact.astro | ✅ | Contact page |
| faq.astro | ✅ | FAQ page |
| services/index.astro | ✅ | Services listing |
| services/[slug].astro | ✅ | Service detail |
| 404.astro | ❌ Missing | No 404 page |
| privacy.astro | ❌ Missing | No privacy policy |
| terms.astro | ❌ Missing | No terms of service |
| robots.txt | ❌ Missing | No robots file |
| sitemap | ❌ Missing | No sitemap integration |

### 3.4 Accessibility

| Check | Status | Notes |
|-------|--------|-------|
| Skip link | ✅ Pass | `.skip-link` class, `#main` target |
| Semantic `<header>` | ✅ Pass | |
| Semantic `<main>` | ✅ Pass | With `id="main"` |
| Semantic `<footer>` | ✅ Pass | |
| `<nav>` element | ⚠️ Missing | Uses `<nav>` but no role |
| Heading hierarchy | ⚠️ Check | Need to verify per page |
| Form labels | ⚠️ Check | Contact form needs review |
| Focus states | ✅ Pass | Via Tailwind defaults |

---

## 4. Theme Prep Audit (v2_4)

### 4.1 CSS Variable Architecture

**Current Approach:**

The template uses a JSON → TypeScript → Astro component pipeline:

```
brand.json → brand.ts → BrandTheme.astro → :root CSS variables
```

**Variable Naming:**
```css
/* Current pattern */
--brand-color-primary: ...
--brand-color-neutral-900: ...
--brand-font-heading: ...

/* AUDIT_v2 Standard */
--color-primary: ...
--color-text-primary: ...
--color-footer-accent: ...
```

| Check | Status | Notes |
|-------|--------|-------|
| CSS variables defined | ✅ Pass | Via BrandTheme.astro |
| Variables in Tailwind | ✅ Pass | `withAlpha()` helper |
| Naming convention | ⚠️ Different | Uses `--brand-*` not `--color-*` |
| Footer-specific tokens | ❌ Missing | |
| Dark mode support | ❌ Missing | Only light mode |

### 4.2 Hardcoded Colors — CRITICAL ISSUE

**AUDIT_v2_4 requires ZERO hardcoded Tailwind color classes.**

**Found hardcoded `neutral-*` classes (20+ instances):**

```astro
<!-- HeroPrimary.astro -->
<section class="bg-neutral-900 text-neutral-100">
<p class="text-lg text-neutral-300 ...">
<div class="... bg-neutral-800">

<!-- ServicesGrid.astro -->
<section class="bg-neutral-50">
<h2 class="... text-neutral-900 ...">
<p class="... text-neutral-600">
<article class="... border-neutral-200 ...">
<div class="... bg-neutral-200">

<!-- Footer.astro -->
<footer class="bg-neutral-900 text-neutral-100">
<p class="... text-neutral-300">
<h3 class="... text-neutral-200">
```

**Required Fix — Map to Theme Tokens:**

| Current | Should Be |
|---------|-----------|
| `bg-neutral-900` | `bg-surface-dark` or theme token |
| `bg-neutral-50` | `bg-surface-alt` |
| `text-neutral-900` | `text-text-primary` |
| `text-neutral-700` | `text-text-secondary` |
| `text-neutral-500` | `text-text-muted` |
| `text-neutral-300` | `text-on-dark` |
| `text-neutral-100` | `text-on-dark-secondary` |
| `border-neutral-200` | `border-border` |

### 4.3 Tailwind Configuration

**Current `tailwind.config.mjs`:**

```javascript
colors: {
  primary: {
    DEFAULT: withAlpha('--brand-color-primary'),
    dark: withAlpha('--brand-color-primary-dark'),
    light: withAlpha('--brand-color-primary-light')
  },
  secondary: { ... },
  background: withAlpha('--brand-color-background'),
  surface: withAlpha('--brand-color-surface'),
  neutral: {
    900: withAlpha('--brand-color-neutral-900'),
    // ... numeric scale
  }
}
```

**Issues:**
1. ✅ Uses CSS variables with alpha support
2. ⚠️ Uses numeric neutral scale (hardcoding risk)
3. ❌ Missing semantic tokens: `text-primary`, `text-secondary`, `text-muted`
4. ❌ Missing `border` token
5. ❌ Missing footer-specific tokens

**Recommended Tailwind Colors:**

```javascript
colors: {
  primary: { DEFAULT, dark, light },
  secondary: { DEFAULT, dark, light },
  accent: { DEFAULT, dark, light },
  background: withAlpha('--color-background'),
  surface: {
    DEFAULT: withAlpha('--color-surface'),
    alt: withAlpha('--color-surface-alt'),
    dark: withAlpha('--color-surface-dark'),
  },
  text: {
    primary: withAlpha('--color-text-primary'),
    secondary: withAlpha('--color-text-secondary'),
    muted: withAlpha('--color-text-muted'),
  },
  border: withAlpha('--color-border'),
  'on-primary': withAlpha('--color-on-primary'),
  'on-dark': withAlpha('--color-on-dark'),
  footer: {
    accent: withAlpha('--color-footer-accent'),
    text: withAlpha('--color-footer-text'),
    surface: withAlpha('--color-footer-surface'),
  }
}
```

### 4.4 Image Component

**Current `HeroPrimary.astro`:**
```astro
<img class="..." src={heroImage} alt={props.image.alt} loading="lazy" />
```

**Issues:**
1. ❌ Uses native `<img>` not Astro's `<Image />`
2. ❌ No width/height (CLS risk)
3. ❌ No srcset/responsive images
4. ❌ No WebP optimization

**Should Be:**
```astro
---
import { Image } from 'astro:assets';
---
<Image
  src={heroImage}
  alt={props.image.alt}
  width={800}
  height={600}
  loading="lazy"
/>
```

---

## 5. Best Practices Gaps

### 5.1 Missing astro.config.mjs Properties

```javascript
// Current
export default defineConfig({
  integrations: [tailwind(...), mdx()],
  build: { inlineStylesheets: 'auto' }
});

// Missing
export default defineConfig({
  site: 'https://example.com',  // ❌ Required for sitemap, canonical
  trailingSlash: 'never',       // ❌ Should be explicit
  integrations: [
    tailwind(...),
    mdx(),
    sitemap(),                  // ❌ Missing
  ],
  prefetch: {                   // ❌ Missing
    defaultStrategy: 'viewport',
  },
  image: {                      // ❌ Missing
    domains: [],
  },
});
```

### 5.2 Missing Files

| File | Purpose | Priority |
|------|---------|----------|
| `src/pages/404.astro` | Error page | High |
| `src/pages/privacy.astro` | Legal | Medium |
| `src/pages/terms.astro` | Legal | Medium |
| `public/robots.txt` | SEO | High |
| `src/assets/images/placeholders/default.svg` | Fallback | Medium |
| `src/assets/images/ATTRIBUTION.md` | Image credits | Medium |

### 5.3 No Mobile Menu

The Header component has no mobile navigation:
```astro
<nav class="hidden ... md:flex">  <!-- Hidden on mobile -->
```

No hamburger menu or mobile drawer implementation.

---

## 6. Comparison: Template vs AUDIT_v2 Standards

### Variable Naming Mismatch

| AUDIT_v2 Standard | Template Current |
|-------------------|------------------|
| `--color-primary` | `--brand-color-primary` |
| `--color-text-primary` | `--brand-color-neutral-900` |
| `--color-text-secondary` | `--brand-color-neutral-700` |
| `--color-text-muted` | `--brand-color-neutral-500` |
| `--color-surface` | `--brand-color-surface` |
| `--color-background` | `--brand-color-background` |
| `--color-border` | (not defined) |
| `--color-footer-*` | (not defined) |

### Directory Structure Mismatch

| AUDIT_v2 Standard | Template Current |
|-------------------|------------------|
| `src/data/site.ts` | `src/config/brand.json` + `src/content/settings/site.json` |
| `src/assets/images/icons/` | (not present) |
| `src/assets/images/logos/` | (not present) |
| `src/assets/images/photos/` | `src/assets/images/library/` |
| `src/assets/images/placeholders/` | (not present) |
| `src/content.config.ts` | `src/content/config.ts` |
| (no public/images) | `public/images/unsplash/` |

---

## 7. Positive Findings (Keep These)

### What the Template Does Well

1. **TypeScript Configuration**
   - Uses `strict` preset
   - All components have typed Props interfaces
   - Clean type definitions in `lib/types.ts`

2. **Content Collections**
   - Well-structured schemas
   - Good use of Zod validators
   - Logical collection organization

3. **Theming Approach**
   - JSON-based configuration (easy to swap)
   - CSS variables with alpha support
   - Clean `withAlpha()` helper pattern

4. **Component Structure**
   - Separation of layout vs sections
   - Props-driven components
   - Slot usage in BaseLayout

5. **Accessibility Basics**
   - Skip link implemented
   - Semantic HTML elements
   - Focus states via Tailwind

6. **Static-First**
   - No client directives (zero JS shipped)
   - Pure Astro components

---

## 8. Prioritized Fix List

### Critical (Fix First)

| Issue | Location | Fix |
|-------|----------|-----|
| Move images to src/assets | `public/images/unsplash/` | Migrate and update references |
| Delete manifest.json | `public/images/unsplash/manifest.json` | Remove file |
| Replace hardcoded neutral-* | All section components | Use semantic tokens |
| Add missing semantic color tokens | `tailwind.config.mjs` | Add text-*, border, footer-* |

### High Priority

| Issue | Location | Fix |
|-------|----------|-----|
| Move content config | `src/content/config.ts` | Rename to `src/content.config.ts` |
| Add OG/Twitter meta | `BaseLayout.astro` | Add social meta tags |
| Add 404 page | `src/pages/` | Create 404.astro |
| Add sitemap | `astro.config.mjs` | Install and configure @astrojs/sitemap |
| Add site URL | `astro.config.mjs` | Add `site` property |
| Replace placeholder phone | `site.json` | Use real or clearly fake number |

### Medium Priority

| Issue | Location | Fix |
|-------|----------|-----|
| Add path aliases | `tsconfig.json` | Add paths configuration |
| Use Astro Image | Section components | Replace `<img>` with `<Image />` |
| Add mobile menu | `Header.astro` | Implement hamburger/drawer |
| Add dark mode | Theme system | Define dark mode variables |
| Add footer tokens | Theme system | Separate footer colors |
| Add robots.txt | `public/` or dynamic | Create robots file |

### Low Priority / Nice to Have

| Issue | Location | Fix |
|-------|----------|-----|
| Upgrade to Tailwind v4 | Dependencies | When ready to migrate |
| Add legal pages | `src/pages/` | privacy.astro, terms.astro |
| Add structured data | `BaseLayout.astro` | LocalBusiness JSON-LD |
| Add header stability | `Header.astro` | whitespace-nowrap, flex-shrink-0 |
| Standardize variable naming | All theme files | `--color-*` prefix |

---

## 9. Migration Path to AUDIT_v2 Compliance

### Phase 1: Structure Cleanup

```bash
# 1. Create proper image directories
mkdir -p src/assets/images/{icons,logos,photos,placeholders}

# 2. Move images from public to src/assets
mv public/images/unsplash/*.jpg src/assets/images/photos/

# 3. Delete legacy files
rm public/images/unsplash/manifest.json
rm -r public/images/

# 4. Create placeholder SVG
# (create src/assets/images/placeholders/default.svg)

# 5. Move content config
mv src/content/config.ts src/content.config.ts

# 6. Rename config to data (optional, for consistency)
mv src/config src/data
```

### Phase 2: Theme Token Refactor

1. Update `brand.json` or create `themes.css`:
   - Add semantic color tokens
   - Add footer-specific tokens
   - Add text hierarchy tokens

2. Update `tailwind.config.mjs`:
   - Replace numeric neutral scale with semantic tokens
   - Add text-*, border, footer-* colors

3. Update all components:
   - Replace `neutral-900` → `text-primary`
   - Replace `neutral-700` → `text-secondary`
   - etc.

### Phase 3: SEO & Accessibility

1. Add OG/Twitter meta to BaseLayout
2. Install and configure sitemap
3. Add 404 page
4. Add robots.txt
5. Add structured data

### Phase 4: Polish

1. Add mobile menu
2. Add dark mode support
3. Replace `<img>` with `<Image />`
4. Add header stability patterns

---

## Summary

| Audit Section | Pass | Fail | Notes |
|---------------|------|------|-------|
| v2_1 Code Quality | 70% | 30% | Good TS, missing configs |
| v2_2 Structure | 40% | 60% | Image location critical |
| v2_3 Content | 60% | 40% | Missing SEO/legal |
| v2_4 Theme Prep | 50% | 50% | Has theming but hardcoded colors |
| Best Practices | 60% | 40% | Solid foundation, needs updates |

**Overall Assessment:** Template has good bones but needs cleanup to meet AUDIT_v2 standards. Primary issues are image location, hardcoded colors, and missing SEO elements.

---

*Audit completed: January 2026*
*Reference documents: AUDIT_v2 System, astro-tailwind-typescript-best-practices.md*
