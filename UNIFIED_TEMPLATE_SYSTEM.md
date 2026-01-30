# Unified Template System

> Synthesis of all audits into a cohesive process for building stable, maintainable Astro templates
> January 2026

---

## Table of Contents

1. [What We Learned](#what-we-learned)
2. [The Three Big Problems](#the-three-big-problems)
3. [Base Template Architecture](#base-template-architecture)
4. [Image System](#image-system)
5. [Common Edit Patterns](#common-edit-patterns)
6. [New Template Workflow](#new-template-workflow)
7. [Checklists](#checklists)

---

## What We Learned

### From 8 Repository Git Histories (1,121 commits analyzed)

| Finding | Evidence | Impact |
|---------|----------|--------|
| **Images = 40%+ of all fixes** | 356 "image" mentions, manifest.json hotspot in 4/8 repos | Highest priority |
| **Headers = 15% of fixes** | 42 header mentions, dedicated fix commits | Second priority |
| **Same pages always change** | index.astro, services.astro, about.astro hotspots | Need modular sections |
| **"follow instruction" pattern** | Top commit words across all repos | AI-assisted workflow confirmed |

### From Best Practices Research

| Topic | Current State | Best Practice |
|-------|---------------|---------------|
| Images | `public/images/` + runtime fetch | `src/assets/` + Astro `<Image />` |
| Content Config | `src/content/config.ts` | `src/content.config.ts` (Astro 5.x) |
| Tailwind | `@astrojs/tailwind` | `@tailwindcss/vite` (v4) |
| Color Variables | `--brand-color-*` / `neutral-*` | `--color-*` with CSS variables |
| TypeScript | Loose | Strict mode with path aliases |

### From Tool Audits

| Tool | Problem | Solution |
|------|---------|----------|
| `astro-unsplash-integration` | Runtime fetch = non-deterministic builds | **Deprecate** - use download-first |
| `image-studio` | Good architecture, minor path issues | Fix `localPath` format, keep using |

---

## The Three Big Problems

### Problem 1: Images (40%+ of issues)

**Root Cause:** `astro-unsplash-integration` fetches images at build time from Unsplash API. Same query returns different images on different builds.

**Symptoms:**
- "fix image" commits everywhere
- manifest.json files as workarounds
- Images suddenly change after rebuild
- "use imageKey instead of query" fixes

**Solution:** Two-phase image workflow (see [Image System](#image-system))

---

### Problem 2: Headers (15% of issues)

**Root Cause:** No standardized header height system, font loading causes reflow, missing stability CSS.

**Symptoms:**
- "FIX HEADER SIZE" commits
- "Fix: Ensure consistent header heights (220px-320px)"
- Header jumps on page load

**Solution:** Header stability patterns in base template:

```css
/* Header Stability */
:root {
  --header-height: 80px;
  --header-height-scrolled: 64px;
}

.site-header {
  height: var(--header-height);
  transition: height 0.2s ease;
}

/* Prevent text wrap causing height changes */
.header-text {
  white-space: nowrap;
}

/* Prevent flex shrink */
.header-logo,
.header-cta {
  flex-shrink: 0;
}
```

---

### Problem 3: Page Churn (20% of issues)

**Root Cause:** Pages contain too many inline sections. Changes cascade.

**Symptoms:**
- index.astro with 65 changes
- services.astro with 42 changes
- Same sections edited repeatedly

**Solution:** Modular section components:

```
src/components/sections/
├── Hero.astro           # Standalone, props-driven
├── Services.astro       # Standalone, props-driven
├── About.astro
├── Testimonials.astro
├── Contact.astro
└── Gallery.astro
```

Pages become composition only:
```astro
---
import Hero from '../components/sections/Hero.astro';
import Services from '../components/sections/Services.astro';
---
<Hero title="Welcome" image={heroImage} />
<Services items={services} />
```

---

## Base Template Architecture

### Directory Structure

```
src/
├── assets/
│   └── images/
│       ├── photos/           # Downloaded Unsplash images
│       │   ├── hero.jpg
│       │   ├── about.jpg
│       │   └── ...
│       ├── icons/            # SVG icons
│       └── brand/            # Logo, favicon
│
├── components/
│   ├── common/               # Reusable UI components
│   │   ├── Button.astro
│   │   ├── Card.astro
│   │   └── Image.astro       # Wrapper around Astro Image
│   │
│   ├── sections/             # Page sections (modular)
│   │   ├── Hero.astro
│   │   ├── Services.astro
│   │   ├── About.astro
│   │   ├── Testimonials.astro
│   │   ├── Contact.astro
│   │   └── Gallery.astro
│   │
│   └── layout/               # Layout components
│       ├── Header.astro
│       ├── Footer.astro
│       ├── Navigation.astro
│       └── MobileMenu.astro
│
├── content/                  # Content collections
│   ├── services/
│   ├── team/
│   └── testimonials/
│
├── layouts/
│   └── BaseLayout.astro
│
├── pages/
│   ├── index.astro
│   ├── about.astro
│   ├── services.astro
│   ├── contact.astro
│   └── 404.astro
│
├── styles/
│   ├── global.css            # Global styles + CSS variables
│   └── typography.css        # Font definitions
│
├── lib/
│   ├── images.ts             # Image utilities
│   └── utils.ts              # General utilities
│
└── content.config.ts         # Content collection schemas (Astro 5.x path)

public/
├── fonts/                    # Self-hosted fonts
├── favicon.ico
└── robots.txt
```

### Key Files

#### `src/content.config.ts` (Astro 5.x)

```typescript
import { defineCollection, z } from 'astro:content';

const services = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    icon: z.string().optional(),
    order: z.number().default(0),
  }),
});

const team = defineCollection({
  type: 'content',
  schema: ({ image }) => z.object({
    name: z.string(),
    role: z.string(),
    photo: image(),  // Validated image reference
    order: z.number().default(0),
  }),
});

const testimonials = defineCollection({
  type: 'content',
  schema: z.object({
    author: z.string(),
    company: z.string().optional(),
    rating: z.number().min(1).max(5).default(5),
    featured: z.boolean().default(false),
  }),
});

export const collections = { services, team, testimonials };
```

#### `src/styles/global.css`

```css
/* ============================================
   CSS Variables - Theme Configuration
   ============================================ */

:root {
  /* Colors - Using --color-* convention */
  --color-primary: #2563eb;
  --color-primary-dark: #1d4ed8;
  --color-secondary: #64748b;

  --color-text: #1e293b;
  --color-text-muted: #64748b;
  --color-background: #ffffff;
  --color-surface: #f8fafc;
  --color-border: #e2e8f0;

  /* Header Stability */
  --header-height: 80px;
  --header-height-scrolled: 64px;

  /* Spacing */
  --section-padding: 5rem;
  --container-max: 1280px;

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-display: 'Inter', system-ui, sans-serif;
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --color-text: #f1f5f9;
    --color-text-muted: #94a3b8;
    --color-background: #0f172a;
    --color-surface: #1e293b;
    --color-border: #334155;
  }
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
}

/* ============================================
   Header Stability Patterns
   ============================================ */

.site-header {
  height: var(--header-height);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 50;
  transition: height 0.2s ease, background-color 0.2s ease;
}

.site-header.scrolled {
  height: var(--header-height-scrolled);
}

.header-container {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.header-logo {
  flex-shrink: 0;
}

.header-nav {
  white-space: nowrap;
}

.header-cta {
  flex-shrink: 0;
}

/* Main content offset for fixed header */
main {
  padding-top: var(--header-height);
}
```

#### `astro.config.mjs`

```javascript
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';  // Tailwind v4

export default defineConfig({
  site: 'https://example.com',  // Required for sitemap
  vite: {
    plugins: [tailwindcss()],
  },
  image: {
    // Image optimization settings
    domains: ['images.unsplash.com'],  // If any remote images needed
  },
});
```

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
      "@lib/*": ["src/lib/*"]
    }
  }
}
```

---

## Image System

### The Two-Phase Workflow

**Phase 1: Download (Development/Setup)**
```bash
# Use image-studio CLI to download images
image-studio fetch landscaping -o src/assets/images/photos/

# Or fetch individual images
image-studio fetch "modern office interior" --save-as hero
image-studio fetch "team meeting collaboration" --save-as team
```

**Phase 2: Use (Build)**
```astro
---
import { Image } from 'astro:assets';
import heroImage from '@assets/images/photos/hero.jpg';
---

<Image
  src={heroImage}
  alt="Modern office interior"
  width={1200}
  height={800}
  format="webp"
  quality={80}
/>
```

### Image Component Wrapper

Create `src/components/common/OptimizedImage.astro`:

```astro
---
import { Image } from 'astro:assets';
import type { ImageMetadata } from 'astro';

interface Props {
  src: ImageMetadata;
  alt: string;
  width?: number;
  height?: number;
  class?: string;
  loading?: 'lazy' | 'eager';
  sizes?: string;
}

const {
  src,
  alt,
  width,
  height,
  class: className = '',
  loading = 'lazy',
  sizes = '100vw'
} = Astro.props;
---

<Image
  src={src}
  alt={alt}
  width={width || src.width}
  height={height || src.height}
  class={className}
  loading={loading}
  format="webp"
  quality={80}
  sizes={sizes}
/>
```

### Image Utilities

Create `src/lib/images.ts`:

```typescript
/**
 * Get all images from a directory
 * Usage: const photos = await getImages('photos');
 */
export async function getImages(folder: string) {
  const images = import.meta.glob<{ default: ImageMetadata }>(
    '/src/assets/images/**/*.{jpeg,jpg,png,gif,webp}'
  );

  const filtered = Object.entries(images).filter(([path]) =>
    path.includes(`/images/${folder}/`)
  );

  const resolved = await Promise.all(
    filtered.map(async ([path, resolver]) => ({
      path,
      image: (await resolver()).default,
    }))
  );

  return resolved;
}

/**
 * Get a specific image by name
 * Usage: const hero = await getImage('photos', 'hero');
 */
export async function getImage(folder: string, name: string) {
  const images = await getImages(folder);
  return images.find(img => img.path.includes(name))?.image;
}
```

### Placeholder/Fallback System

Create `src/components/common/ImageWithFallback.astro`:

```astro
---
import { Image } from 'astro:assets';
import type { ImageMetadata } from 'astro';
import placeholderImage from '@assets/images/placeholder.jpg';

interface Props {
  src?: ImageMetadata;
  alt: string;
  width: number;
  height: number;
  class?: string;
}

const { src, alt, width, height, class: className } = Astro.props;
const imageToUse = src || placeholderImage;
---

<Image
  src={imageToUse}
  alt={alt}
  width={width}
  height={height}
  class={className}
  format="webp"
/>
```

### ATTRIBUTION.md

image-studio auto-generates this. Keep it in the repo root:

```markdown
# Image Attribution

All photos are used under the [Unsplash License](https://unsplash.com/license).

## Photos

### hero.jpg
- **Photographer**: [John Doe](https://unsplash.com/@johndoe)
- **Source**: [Unsplash](https://unsplash.com/photos/abc123)
- **Downloaded**: 2026-01-15
```

---

## Common Edit Patterns

### Pattern 1: Changing Colors/Theme

**Location:** `src/styles/global.css`

**Edit the CSS variables:**
```css
:root {
  --color-primary: #2563eb;      /* Change this */
  --color-primary-dark: #1d4ed8; /* And this */
}
```

**DO NOT:** Edit individual Tailwind classes throughout components.

---

### Pattern 2: Changing Business Content

**Location:** Content collections in `src/content/`

**Example - Adding a service:**
```markdown
<!-- src/content/services/new-service.md -->
---
title: "New Service"
description: "Description of the new service"
icon: "wrench"
order: 4
---

Detailed content about the service...
```

**DO NOT:** Edit page files to add content.

---

### Pattern 3: Changing Images

**Step 1:** Download new image
```bash
image-studio fetch "new image query" --save-as new-image
```

**Step 2:** Update import in component
```astro
---
import newImage from '@assets/images/photos/new-image.jpg';
---
<Image src={newImage} alt="Description" width={1200} />
```

**DO NOT:**
- Use `<UnsplashImage query="..." />`
- Put images in `public/`
- Use native `<img>` tags

---

### Pattern 4: Changing Header/Footer

**Location:** `src/components/layout/Header.astro` and `Footer.astro`

**Key stability rules:**
1. Keep `flex-shrink: 0` on logo and CTA
2. Keep `white-space: nowrap` on nav text
3. Use `--header-height` CSS variable
4. Test on mobile

---

### Pattern 5: Adding a New Page

**Step 1:** Create page file
```astro
<!-- src/pages/new-page.astro -->
---
import BaseLayout from '@layouts/BaseLayout.astro';
import Hero from '@components/sections/Hero.astro';
---

<BaseLayout title="New Page" description="Page description">
  <Hero title="New Page" />
  <!-- Add sections -->
</BaseLayout>
```

**Step 2:** Add to navigation (if needed)
```typescript
// src/lib/navigation.ts
export const navLinks = [
  { href: '/', label: 'Home' },
  { href: '/new-page', label: 'New Page' },  // Add here
];
```

---

### Pattern 6: Modifying a Section

**Location:** `src/components/sections/[SectionName].astro`

**Key rules:**
1. Sections receive data via props
2. Sections don't fetch their own data
3. Keep styling within section or use global CSS variables

```astro
---
interface Props {
  title: string;
  items: Array<{ name: string; description: string }>;
  background?: 'light' | 'dark';
}

const { title, items, background = 'light' } = Astro.props;
---

<section class:list={['section', `bg-${background}`]}>
  <h2>{title}</h2>
  {items.map(item => (
    <div>
      <h3>{item.name}</h3>
      <p>{item.description}</p>
    </div>
  ))}
</section>
```

---

## New Template Workflow

### Phase 1: Setup Base (Once)

```bash
# 1. Clone base template
git clone https://github.com/yourorg/astro-base-template new-client-site
cd new-client-site

# 2. Install dependencies
npm install

# 3. Verify build works
npm run build
```

### Phase 2: Customize Content

```bash
# 1. Update site config
# Edit astro.config.mjs: site URL
# Edit src/lib/siteConfig.ts: business name, contact info

# 2. Download images for this client
image-studio fetch "client industry hero" --save-as hero
image-studio fetch "client industry team" --save-as team
# ... etc

# 3. Update content collections
# Edit src/content/services/*.md
# Edit src/content/team/*.md
# Edit src/content/testimonials/*.md
```

### Phase 3: Customize Theme

```bash
# 1. Update colors in src/styles/global.css
# 2. Update fonts if needed
# 3. Test dark mode
```

### Phase 4: Verify & Deploy

```bash
# 1. Run build
npm run build

# 2. Preview
npm run preview

# 3. Check accessibility
# Run Lighthouse audit

# 4. Deploy
git add .
git commit -m "Initial client customization"
git push
```

---

## Checklists

### New Template Creation Checklist

- [ ] Cloned from base template
- [ ] Site config updated (URL, business name)
- [ ] Images downloaded locally to `src/assets/images/photos/`
- [ ] No `public/images/` directory
- [ ] No `<UnsplashImage>` components
- [ ] All images use `<Image />` from `astro:assets`
- [ ] Content collections populated
- [ ] Colors customized in `global.css`
- [ ] Build succeeds
- [ ] Lighthouse score > 90

### Pre-Commit Checklist

- [ ] No hardcoded image URLs
- [ ] No inline styles for colors (use CSS variables)
- [ ] Images have alt text
- [ ] New images added to ATTRIBUTION.md
- [ ] Build succeeds locally

### Template Audit Checklist

Use this when reviewing existing templates:

**Images**
- [ ] All images in `src/assets/images/`
- [ ] No manifest.json files
- [ ] Uses Astro `<Image />` component
- [ ] ATTRIBUTION.md present

**Structure**
- [ ] Content config at `src/content.config.ts`
- [ ] Modular section components
- [ ] CSS variables for colors
- [ ] Header stability patterns applied

**Build**
- [ ] No TypeScript errors
- [ ] Build succeeds
- [ ] No console warnings

---

## Migration Guide: Existing Templates

For templates using the old patterns:

### Step 1: Move Images

```bash
# Create correct directory
mkdir -p src/assets/images/photos

# Move from public
mv public/images/unsplash/* src/assets/images/photos/

# Remove old directory
rm -rf public/images/unsplash
```

### Step 2: Update Image References

Find all image imports and update:

```astro
<!-- Before -->
<img src="/images/unsplash/hero.jpg" alt="Hero" />

<!-- After -->
---
import { Image } from 'astro:assets';
import heroImage from '@assets/images/photos/hero.jpg';
---
<Image src={heroImage} alt="Hero" width={1200} />
```

### Step 3: Remove Runtime Fetching

```bash
# Uninstall problematic integration
npm uninstall astro-unsplash-integration

# Remove UnsplashImage components
grep -r "UnsplashImage" src/  # Find usages
# Replace each with local Image imports
```

### Step 4: Update Content Config Path

```bash
# Move config to new location
mv src/content/config.ts src/content.config.ts
```

### Step 5: Update Color Variables

In `global.css`, rename:
```css
/* Before */
--brand-color-primary: #2563eb;

/* After */
--color-primary: #2563eb;
```

Update Tailwind classes in components:
```astro
<!-- Before -->
<div class="bg-neutral-100 text-neutral-900">

<!-- After -->
<div class="bg-surface text-foreground">
<!-- Or use CSS variables directly -->
<div style="background: var(--color-surface); color: var(--color-text)">
```

---

## Summary

### The System at a Glance

```
┌─────────────────────────────────────────────────────────┐
│                    DEVELOPMENT                          │
├─────────────────────────────────────────────────────────┤
│  1. image-studio fetch → src/assets/images/photos/     │
│  2. Edit content collections → src/content/             │
│  3. Customize CSS variables → src/styles/global.css     │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      BUILD                              │
├─────────────────────────────────────────────────────────┤
│  • Astro optimizes images (WebP, srcset)               │
│  • Content collections type-checked                     │
│  • CSS variables applied                                │
│  • Deterministic output (same every time)              │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                     DEPLOY                              │
├─────────────────────────────────────────────────────────┤
│  • Static files served from your CDN                   │
│  • No runtime API dependencies                          │
│  • Fast, reliable, consistent                          │
└─────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Download, don't fetch** - Images are downloaded during development, not fetched at build time
2. **Local, not remote** - All assets in `src/assets/`, never external URLs at build time
3. **Deterministic builds** - Same input always produces same output
4. **Modular sections** - Pages compose sections, sections are standalone
5. **CSS variables for theming** - One place to change colors, not scattered classes
6. **Content collections for data** - Type-safe, validated, separate from presentation

---

*Document created: January 2026*
*Based on analysis of 8 template repositories (1,121 commits)*
