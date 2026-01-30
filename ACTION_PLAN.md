# Action Plan: Template System Overhaul

> Consolidated plan for fixing existing tools and building an ideal base template
> Based on: 8 repo analysis (1,121 commits), best practices research, tool audits
> January 2026

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Phase 1: Fix Image Tools](#phase-1-fix-image-tools)
3. [Phase 2: Deprecate & Clean Up](#phase-2-deprecate--clean-up)
4. [Phase 3: Build New Base Template](#phase-3-build-new-base-template)
5. [Phase 4: Documentation & Process](#phase-4-documentation--process)
6. [New Template Specification](#new-template-specification)
7. [Implementation Checklist](#implementation-checklist)

---

## Executive Summary

### The Problem (Quantified)
- **40%+ of all fixes** across 8 repos were image-related
- **Root cause:** `astro-unsplash-integration` fetches at runtime, non-deterministic
- **Secondary issues:** Wrong image locations, deprecated Tailwind setup, header instability

### The Solution (Overview)
1. Fix `image-studio` CLI (minor path fixes)
2. Deprecate `astro-unsplash-integration` (replace with download-first workflow)
3. Build new base template with correct architecture
4. Document the workflow for future templates

### Expected Outcome
- **75% reduction** in image-related fix commits
- **Deterministic builds** - same input = same output every time
- **Full Astro optimization** - WebP, srcset, lazy loading
- **Maintainable codebase** - modular sections, CSS variables

---

## Phase 1: Fix Image Tools

### 1.1 Fix `image-studio` CLI

**Priority:** High
**Effort:** Small (2-3 hours)
**Repository:** `unsplash-image-fetcher`

#### Tasks

| Task | File | Change |
|------|------|--------|
| Fix localPath format | `src/fetcher.ts:109` | Use relative path, not `~/assets/...` |
| Fix localPath format | `src/generator.ts:96` | Same fix |
| Fix localPath format | `src/server/api.ts:331` | Same fix |
| Fix deprecated substr | `src/analyzer.ts:25-26` | Change to `substring()` |
| Add return type distinction | `src/fetcher.ts` | Return `{status, metadata}` not just `null` |

#### Code Changes

**fetcher.ts:109** - Change:
```typescript
// Before
localPath: `~/assets/images/photos/${localFileName}`,

// After
localPath: path.join('src/assets/images/photos', localFileName),
```

**analyzer.ts:25-26** - Change:
```typescript
// Before
const r = parseInt(fullHex.substr(0, 2), 16);

// After
const r = parseInt(fullHex.substring(0, 2), 16);
```

**fetcher.ts** - Add better return type:
```typescript
interface FetchResult {
  status: 'downloaded' | 'skipped' | 'failed';
  metadata?: UnsplashImageMetadata;
  path?: string;
}

async fetchImage(query: string, saveAs: string): Promise<FetchResult> {
  if (fs.existsSync(fullPath)) {
    return { status: 'skipped', path: fullPath };
  }
  // ... rest of logic
  return { status: 'downloaded', metadata, path: fullPath };
}
```

#### Verification
- [ ] `npm run build` succeeds
- [ ] `image-studio fetch landscaping` downloads to correct path
- [ ] Returned `localPath` matches actual file location
- [ ] No TypeScript errors

---

### 1.2 Consider `astro-preload` Integration

**Priority:** Medium
**Effort:** Evaluation (1 hour), Integration if chosen (2-3 hours)

#### Evaluation Criteria

| Criteria | astro-preload | image-studio |
|----------|---------------|--------------|
| Downloads at build time | ✓ | ✗ (CLI only) |
| Saves to src/assets | ✗ (public/) | ✓ (configurable) |
| Active maintenance | ✗ (1yr old) | ✓ (yours) |
| Astro integration | ✓ | ✗ |

#### Decision
**Recommendation:** Keep `image-studio` as primary tool, but study `astro-preload`'s patterns for potential features:
- Build-time URL fetching
- Dev mode bypass (forward URLs directly)

#### Optional Enhancement to image-studio
Add an Astro integration that downloads images referenced by URL during build:

```typescript
// Future: astro-image-studio integration
import { defineConfig } from 'astro/config';
import imageStudio from 'image-studio/astro';

export default defineConfig({
  integrations: [
    imageStudio({
      outputDir: 'src/assets/images/photos',
      cacheManifest: true  // Track URL → local file mappings
    })
  ]
});
```

---

## Phase 2: Deprecate & Clean Up

### 2.1 Deprecate `astro-unsplash-integration`

**Priority:** High
**Effort:** Small (1 hour)

#### Tasks

1. **Add deprecation notice to README:**
```markdown
# ⚠️ DEPRECATED

This package is deprecated. It fetches images at runtime, causing non-deterministic builds.

**Use instead:**
- [image-studio](https://github.com/hoyere/unsplash-image-fetcher) - Download images during development
- Then use Astro's built-in `<Image />` component

See [Migration Guide](#migration) below.
```

2. **Archive the repository** (optional, after migration complete)

3. **Create migration script** for existing projects:
```bash
#!/bin/bash
# migrate-unsplash-images.sh

# Find all UnsplashImage usages
grep -r "UnsplashImage" src/ --include="*.astro" -l

# For each file, extract queries and download
# (Manual step - review each usage)
```

---

### 2.2 Clean Up Template Audit Docs

**Priority:** Low
**Effort:** Small (1 hour)

Update your AUDIT_v2 docs with learnings:
- Add image system verification section
- Update Tailwind setup to v4
- Update content config path to `src/content.config.ts`
- Add header stability checks

---

## Phase 3: Build New Base Template

### 3.1 Template Specification

See [New Template Specification](#new-template-specification) below for full details.

### 3.2 Build Sequence

#### Week 1: Foundation

| Day | Task | Deliverable |
|-----|------|-------------|
| 1 | Project setup | Astro 5.x, Tailwind v4, TypeScript strict |
| 2 | Directory structure | All folders, placeholder files |
| 3 | CSS system | global.css with variables, @theme block |
| 4 | Layout components | BaseLayout, Header, Footer |
| 5 | Header stability | All stability patterns applied |

#### Week 2: Components

| Day | Task | Deliverable |
|-----|------|-------------|
| 1 | Image utilities | lib/images.ts, OptimizedImage component |
| 2 | Section: Hero | Props-driven, multiple variants |
| 3 | Section: Services | Grid layout, icon support |
| 4 | Section: About | Image + text, reversible |
| 5 | Section: Contact | Form component, validation ready |

#### Week 3: Content & Pages

| Day | Task | Deliverable |
|-----|------|-------------|
| 1 | Content collections | Schemas for services, team, testimonials |
| 2 | Page: Home | Composed from sections |
| 3 | Page: About | Team section, company info |
| 4 | Page: Services | Dynamic from collection |
| 5 | Page: Contact | Form, map placeholder |

#### Week 4: Polish & Documentation

| Day | Task | Deliverable |
|-----|------|-------------|
| 1 | 404 page | Styled error page |
| 2 | SEO components | OG tags, sitemap, robots.txt |
| 3 | Dark mode | Toggle, persistence, view transitions |
| 4 | Documentation | README, customization guide |
| 5 | Testing | Lighthouse audit, cross-browser |

---

## Phase 4: Documentation & Process

### 4.1 Create Workflow Documentation

**Files to create:**

1. `TEMPLATE_CUSTOMIZATION.md` - How to customize for a new client
2. `IMAGE_WORKFLOW.md` - How to add/change images
3. `COMMON_EDITS.md` - Patterns for frequent changes

### 4.2 Create Template Generator (Future)

Consider a CLI that scaffolds new projects:
```bash
npx create-local-business-site my-client-site --type=landscaping
```

---

## New Template Specification

### Directory Structure

```
astro-base-template/
├── .vscode/
│   └── settings.json           # Recommended extensions, format on save
│
├── public/
│   ├── fonts/                  # Self-hosted fonts (if any)
│   ├── favicon.ico
│   ├── favicon.svg
│   └── robots.txt
│
├── src/
│   ├── assets/
│   │   └── images/
│   │       ├── photos/         # Unsplash/stock photos (downloaded)
│   │       │   ├── hero.jpg
│   │       │   ├── about.jpg
│   │       │   ├── team-1.jpg
│   │       │   └── ...
│   │       ├── icons/          # SVG icons
│   │       ├── brand/          # Logo files
│   │       │   ├── logo.svg
│   │       │   ├── logo-dark.svg
│   │       │   └── logo-mark.svg
│   │       └── placeholder.jpg # Fallback image
│   │
│   ├── components/
│   │   ├── common/             # Reusable UI primitives
│   │   │   ├── Button.astro
│   │   │   ├── Card.astro
│   │   │   ├── OptimizedImage.astro
│   │   │   ├── Icon.astro
│   │   │   └── Container.astro
│   │   │
│   │   ├── sections/           # Page sections (modular, props-driven)
│   │   │   ├── Hero.astro
│   │   │   ├── Services.astro
│   │   │   ├── About.astro
│   │   │   ├── Team.astro
│   │   │   ├── Testimonials.astro
│   │   │   ├── Gallery.astro
│   │   │   ├── CTA.astro
│   │   │   ├── Contact.astro
│   │   │   └── FAQ.astro
│   │   │
│   │   ├── layout/             # Layout-specific components
│   │   │   ├── Header.astro
│   │   │   ├── Footer.astro
│   │   │   ├── Navigation.astro
│   │   │   ├── MobileMenu.astro
│   │   │   └── ThemeToggle.astro
│   │   │
│   │   └── seo/                # SEO components
│   │       ├── BaseHead.astro
│   │       ├── OpenGraph.astro
│   │       └── Schema.astro
│   │
│   ├── content/                # Content collections data
│   │   ├── services/
│   │   │   ├── service-1.md
│   │   │   └── service-2.md
│   │   ├── team/
│   │   │   └── member-1.md
│   │   └── testimonials/
│   │       └── testimonial-1.md
│   │
│   ├── layouts/
│   │   └── BaseLayout.astro
│   │
│   ├── lib/                    # Utilities and helpers
│   │   ├── images.ts           # Image loading utilities
│   │   ├── utils.ts            # General utilities
│   │   └── navigation.ts       # Nav link definitions
│   │
│   ├── pages/
│   │   ├── index.astro
│   │   ├── about.astro
│   │   ├── services/
│   │   │   ├── index.astro
│   │   │   └── [slug].astro
│   │   ├── contact.astro
│   │   └── 404.astro
│   │
│   ├── styles/
│   │   ├── global.css          # CSS variables, base styles
│   │   └── fonts.css           # @font-face definitions
│   │
│   ├── content.config.ts       # Content collection schemas
│   └── site.config.ts          # Site-wide configuration
│
├── astro.config.mjs
├── tailwind.config.js          # If customization needed beyond @theme
├── tsconfig.json
├── package.json
├── ATTRIBUTION.md              # Image credits
└── README.md
```

---

### Key File Contents

#### `src/site.config.ts`

```typescript
export const siteConfig = {
  name: "Business Name",
  tagline: "Your tagline here",
  description: "SEO description for the business",
  url: "https://example.com",

  contact: {
    phone: "(555) 123-4567",
    email: "info@example.com",
    address: {
      street: "123 Main St",
      city: "Anytown",
      state: "ST",
      zip: "12345",
    },
  },

  social: {
    facebook: "https://facebook.com/example",
    instagram: "https://instagram.com/example",
    twitter: "https://twitter.com/example",
  },

  hours: [
    { days: "Monday - Friday", hours: "8:00 AM - 6:00 PM" },
    { days: "Saturday", hours: "9:00 AM - 4:00 PM" },
    { days: "Sunday", hours: "Closed" },
  ],
};

export type SiteConfig = typeof siteConfig;
```

---

#### `src/styles/global.css`

```css
@import "tailwindcss";

/* ============================================
   Theme Configuration (Tailwind v4)
   ============================================ */

@theme {
  /* Colors */
  --color-primary: oklch(0.55 0.2 250);
  --color-primary-light: oklch(0.65 0.18 250);
  --color-primary-dark: oklch(0.45 0.22 250);

  --color-secondary: oklch(0.55 0.05 250);

  --color-text: oklch(0.2 0.02 250);
  --color-text-muted: oklch(0.45 0.02 250);
  --color-text-inverse: oklch(0.98 0 0);

  --color-background: oklch(1 0 0);
  --color-surface: oklch(0.97 0.005 250);
  --color-border: oklch(0.9 0.01 250);

  /* Spacing */
  --header-height: 80px;
  --header-height-scrolled: 64px;
  --section-padding-y: 5rem;
  --container-max: 1280px;

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-display: 'Inter', system-ui, sans-serif;

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-base: 250ms ease;
  --transition-slow: 400ms ease;
}

/* Dark mode overrides */
[data-theme="dark"] {
  --color-text: oklch(0.95 0.01 250);
  --color-text-muted: oklch(0.7 0.02 250);
  --color-text-inverse: oklch(0.15 0.02 250);

  --color-background: oklch(0.15 0.02 250);
  --color-surface: oklch(0.2 0.02 250);
  --color-border: oklch(0.3 0.02 250);
}

/* ============================================
   Base Styles
   ============================================ */

html {
  scroll-behavior: smooth;
  scroll-padding-top: var(--header-height);
}

body {
  font-family: var(--font-sans);
  color: var(--color-text);
  background-color: var(--color-background);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
}

/* ============================================
   Header Stability
   ============================================ */

.site-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: var(--header-height);
  z-index: 50;
  background-color: var(--color-background);
  border-bottom: 1px solid var(--color-border);
  transition: height var(--transition-base),
              background-color var(--transition-base),
              box-shadow var(--transition-base);
}

.site-header.scrolled {
  height: var(--header-height-scrolled);
  box-shadow: 0 1px 3px oklch(0 0 0 / 0.1);
}

.header-container {
  height: 100%;
  max-width: var(--container-max);
  margin: 0 auto;
  padding: 0 1.5rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

/* Prevent layout shift */
.header-logo {
  flex-shrink: 0;
}

.header-nav {
  white-space: nowrap;
}

.header-cta {
  flex-shrink: 0;
}

/* Main content offset */
main {
  padding-top: var(--header-height);
}

/* ============================================
   Section Defaults
   ============================================ */

.section {
  padding: var(--section-padding-y) 0;
}

.section-alt {
  background-color: var(--color-surface);
}

.container {
  max-width: var(--container-max);
  margin: 0 auto;
  padding: 0 1.5rem;
}

/* ============================================
   Typography
   ============================================ */

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-display);
  font-weight: 700;
  line-height: 1.2;
  color: var(--color-text);
}

h1 { font-size: clamp(2.5rem, 5vw, 4rem); }
h2 { font-size: clamp(2rem, 4vw, 3rem); }
h3 { font-size: clamp(1.5rem, 3vw, 2rem); }

.text-muted {
  color: var(--color-text-muted);
}
```

---

#### `src/content.config.ts`

```typescript
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const services = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/services' }),
  schema: ({ image }) => z.object({
    title: z.string(),
    description: z.string(),
    icon: z.string().optional(),
    image: image().optional(),
    features: z.array(z.string()).optional(),
    order: z.number().default(0),
    featured: z.boolean().default(false),
  }),
});

const team = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/team' }),
  schema: ({ image }) => z.object({
    name: z.string(),
    role: z.string(),
    photo: image(),
    bio: z.string().optional(),
    social: z.object({
      linkedin: z.string().url().optional(),
      twitter: z.string().url().optional(),
      email: z.string().email().optional(),
    }).optional(),
    order: z.number().default(0),
  }),
});

const testimonials = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/testimonials' }),
  schema: z.object({
    author: z.string(),
    company: z.string().optional(),
    role: z.string().optional(),
    rating: z.number().min(1).max(5).default(5),
    featured: z.boolean().default(false),
  }),
});

export const collections = { services, team, testimonials };
```

---

#### `src/lib/images.ts`

```typescript
import type { ImageMetadata } from 'astro';

/**
 * Import all images from src/assets/images
 */
const imageModules = import.meta.glob<{ default: ImageMetadata }>(
  '/src/assets/images/**/*.{jpeg,jpg,png,gif,webp,svg}',
  { eager: true }
);

/**
 * Get a specific image by path relative to src/assets/images/
 * @example getImage('photos/hero.jpg')
 */
export function getImage(relativePath: string): ImageMetadata | undefined {
  const fullPath = `/src/assets/images/${relativePath}`;
  return imageModules[fullPath]?.default;
}

/**
 * Get all images from a specific folder
 * @example getImages('photos') // Returns all images in photos/
 */
export function getImages(folder: string): ImageMetadata[] {
  const prefix = `/src/assets/images/${folder}/`;
  return Object.entries(imageModules)
    .filter(([path]) => path.startsWith(prefix))
    .map(([, module]) => module.default);
}

/**
 * Get image or fallback to placeholder
 */
export function getImageOrPlaceholder(relativePath: string): ImageMetadata {
  const image = getImage(relativePath);
  if (image) return image;

  const placeholder = getImage('placeholder.jpg');
  if (placeholder) return placeholder;

  throw new Error(`Image not found: ${relativePath} and no placeholder available`);
}
```

---

#### `src/components/common/OptimizedImage.astro`

```astro
---
import { Image } from 'astro:assets';
import type { ImageMetadata } from 'astro';
import { getImageOrPlaceholder } from '@lib/images';

interface Props {
  src: ImageMetadata | string;
  alt: string;
  width?: number;
  height?: number;
  class?: string;
  loading?: 'lazy' | 'eager';
  sizes?: string;
  aspectRatio?: '16:9' | '4:3' | '1:1' | '3:4' | 'auto';
}

const {
  src,
  alt,
  width,
  height,
  class: className = '',
  loading = 'lazy',
  sizes = '100vw',
  aspectRatio = 'auto',
} = Astro.props;

// Resolve string paths to ImageMetadata
const resolvedSrc = typeof src === 'string'
  ? getImageOrPlaceholder(src)
  : src;

// Calculate dimensions based on aspect ratio if needed
let finalWidth = width || resolvedSrc.width;
let finalHeight = height || resolvedSrc.height;

if (aspectRatio !== 'auto' && width && !height) {
  const [w, h] = aspectRatio.split(':').map(Number);
  finalHeight = Math.round(width * (h / w));
}
---

<Image
  src={resolvedSrc}
  alt={alt}
  width={finalWidth}
  height={finalHeight}
  class={className}
  loading={loading}
  format="webp"
  quality={80}
  sizes={sizes}
/>
```

---

#### `src/components/sections/Hero.astro`

```astro
---
import { Image } from 'astro:assets';
import type { ImageMetadata } from 'astro';
import Container from '@components/common/Container.astro';
import Button from '@components/common/Button.astro';

interface Props {
  title: string;
  subtitle?: string;
  description?: string;
  image: ImageMetadata;
  imageAlt?: string;
  primaryCta?: {
    text: string;
    href: string;
  };
  secondaryCta?: {
    text: string;
    href: string;
  };
  variant?: 'centered' | 'split' | 'overlay';
  imagePosition?: 'left' | 'right';
}

const {
  title,
  subtitle,
  description,
  image,
  imageAlt = title,
  primaryCta,
  secondaryCta,
  variant = 'overlay',
  imagePosition = 'right',
} = Astro.props;
---

<section class:list={['hero', `hero--${variant}`]}>
  {variant === 'overlay' && (
    <div class="hero__background">
      <Image
        src={image}
        alt=""
        width={1920}
        height={1080}
        format="webp"
        quality={80}
        loading="eager"
        class="hero__bg-image"
      />
      <div class="hero__overlay" />
    </div>
  )}

  <Container>
    <div class:list={['hero__content', { 'hero__content--reverse': imagePosition === 'left' }]}>
      <div class="hero__text">
        {subtitle && <span class="hero__subtitle">{subtitle}</span>}
        <h1 class="hero__title">{title}</h1>
        {description && <p class="hero__description">{description}</p>}

        {(primaryCta || secondaryCta) && (
          <div class="hero__actions">
            {primaryCta && (
              <Button href={primaryCta.href} variant="primary" size="lg">
                {primaryCta.text}
              </Button>
            )}
            {secondaryCta && (
              <Button href={secondaryCta.href} variant="outline" size="lg">
                {secondaryCta.text}
              </Button>
            )}
          </div>
        )}
      </div>

      {variant === 'split' && (
        <div class="hero__image">
          <Image
            src={image}
            alt={imageAlt}
            width={800}
            height={600}
            format="webp"
            quality={85}
            loading="eager"
            class="hero__img"
          />
        </div>
      )}
    </div>
  </Container>
</section>

<style>
  .hero {
    position: relative;
    min-height: 80vh;
    display: flex;
    align-items: center;
  }

  .hero--overlay {
    color: var(--color-text-inverse);
  }

  .hero__background {
    position: absolute;
    inset: 0;
    z-index: -1;
  }

  .hero__bg-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .hero__overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(
      to right,
      oklch(0.1 0.02 250 / 0.9),
      oklch(0.1 0.02 250 / 0.6)
    );
  }

  .hero__content {
    display: grid;
    gap: 3rem;
    align-items: center;
  }

  @media (min-width: 768px) {
    .hero--split .hero__content {
      grid-template-columns: 1fr 1fr;
    }

    .hero__content--reverse {
      direction: rtl;
    }

    .hero__content--reverse > * {
      direction: ltr;
    }
  }

  .hero__subtitle {
    display: inline-block;
    font-size: 0.875rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: var(--color-primary-light);
    margin-bottom: 1rem;
  }

  .hero__title {
    margin-bottom: 1.5rem;
  }

  .hero--overlay .hero__title {
    color: var(--color-text-inverse);
  }

  .hero__description {
    font-size: 1.25rem;
    line-height: 1.6;
    margin-bottom: 2rem;
    opacity: 0.9;
  }

  .hero__actions {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
  }

  .hero__img {
    border-radius: 0.5rem;
    box-shadow: 0 20px 40px oklch(0 0 0 / 0.15);
  }
</style>
```

---

#### `astro.config.mjs`

```javascript
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://example.com', // Update for each project

  vite: {
    plugins: [tailwindcss()],
  },

  integrations: [
    sitemap(),
  ],

  image: {
    // Allow remote images from these domains if needed
    domains: ['images.unsplash.com'],
  },
});
```

---

#### `tsconfig.json`

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@layouts/*": ["src/layouts/*"],
      "@assets/*": ["src/assets/*"],
      "@lib/*": ["src/lib/*"],
      "@content/*": ["src/content/*"]
    }
  }
}
```

---

## Implementation Checklist

### Phase 1: Fix Image Tools (COMPLETED 2026-01-30)

- [x] **1.1 Clone image-studio repo locally**
- [x] **1.2 Fix localPath in fetcher.ts**
  - [x] Change line 109 to use relative path
  - [ ] Test with `image-studio fetch landscaping`
  - [ ] Verify returned path matches actual file
- [x] **1.3 Fix localPath in generator.ts**
  - [x] Change line 96
- [x] **1.4 Fix localPath in api.ts**
  - [x] Change line 331
- [x] **1.5 Fix deprecated substr in analyzer.ts**
  - [x] Change lines 25-26, 54-56
- [ ] **1.6 Add better return types to fetchImage** (deferred - nice to have)
- [x] **1.7 Run tests / verify build**
- [x] **1.8 Commit and push fixes**

### Phase 2: Deprecation (COMPLETED 2026-01-30)

- [x] **2.1 Add deprecation notice to astro-unsplash-integration README**
- [ ] **2.2 Update AUDIT_v2 docs with new patterns**
- [x] **2.3 Create migration guide for existing projects** (included in README)

### Phase 3: New Base Template

#### Week 1: Foundation
- [ ] **3.1 Create new repo: astro-local-business-v2**
- [ ] **3.2 Initialize Astro 5.x project**
- [ ] **3.3 Install dependencies**
  - [ ] `@tailwindcss/vite`
  - [ ] `@astrojs/sitemap`
- [ ] **3.4 Create directory structure**
- [ ] **3.5 Set up tsconfig.json with path aliases**
- [ ] **3.6 Create global.css with @theme block**
- [ ] **3.7 Create site.config.ts**
- [ ] **3.8 Create BaseLayout.astro**
- [ ] **3.9 Create Header.astro with stability patterns**
- [ ] **3.10 Create Footer.astro**
- [ ] **3.11 Test: Header doesn't shift on scroll**

#### Week 2: Components
- [ ] **3.12 Create lib/images.ts utilities**
- [ ] **3.13 Create OptimizedImage.astro**
- [ ] **3.14 Create Button.astro**
- [ ] **3.15 Create Container.astro**
- [ ] **3.16 Create Hero.astro (3 variants)**
- [ ] **3.17 Create Services.astro**
- [ ] **3.18 Create About.astro**
- [ ] **3.19 Create Team.astro**
- [ ] **3.20 Create Testimonials.astro**
- [ ] **3.21 Create Contact.astro**
- [ ] **3.22 Create CTA.astro**

#### Week 3: Content & Pages
- [ ] **3.23 Create content.config.ts with schemas**
- [ ] **3.24 Add sample content (services, team, testimonials)**
- [ ] **3.25 Download sample images with image-studio**
- [ ] **3.26 Create index.astro**
- [ ] **3.27 Create about.astro**
- [ ] **3.28 Create services/index.astro**
- [ ] **3.29 Create services/[slug].astro**
- [ ] **3.30 Create contact.astro**
- [ ] **3.31 Create 404.astro**

#### Week 4: Polish
- [ ] **3.32 Create BaseHead.astro (SEO)**
- [ ] **3.33 Add OpenGraph component**
- [ ] **3.34 Create ThemeToggle.astro**
- [ ] **3.35 Add dark mode with view transition support**
- [ ] **3.36 Create ATTRIBUTION.md**
- [ ] **3.37 Create README.md with customization guide**
- [ ] **3.38 Run Lighthouse audit (target: 95+)**
- [ ] **3.39 Test in multiple browsers**
- [ ] **3.40 Final commit and push**

### Phase 4: Documentation

- [ ] **4.1 Create TEMPLATE_CUSTOMIZATION.md**
- [ ] **4.2 Create IMAGE_WORKFLOW.md**
- [ ] **4.3 Create COMMON_EDITS.md**
- [ ] **4.4 Update this repo's README with links**

---

## Success Criteria

### Quantitative
- [ ] Lighthouse Performance: 95+
- [ ] Lighthouse Accessibility: 100
- [ ] Lighthouse Best Practices: 100
- [ ] Lighthouse SEO: 100
- [ ] Build time: < 30 seconds
- [ ] No TypeScript errors
- [ ] No console warnings

### Qualitative
- [ ] Images load correctly on all pages
- [ ] Dark mode works without flash
- [ ] Header doesn't shift on scroll or resize
- [ ] All content is editable via content collections
- [ ] Colors change by editing only global.css
- [ ] New pages can be added by composing sections

---

## Timeline Summary

| Phase | Duration | Key Deliverable |
|-------|----------|-----------------|
| Phase 1: Fix Tools | 1 day | Working image-studio CLI |
| Phase 2: Deprecation | 0.5 day | Deprecated astro-unsplash-integration |
| Phase 3: New Template | 4 weeks | Production-ready base template |
| Phase 4: Documentation | 1 week | Complete workflow docs |

**Total: ~5-6 weeks**

---

*Plan created: January 2026*
*Based on analysis of 8 repositories, 1,121 commits*
