# AstroJS + Tailwind + TypeScript + Markdown Best Practices Reference

> Compiled from official documentation and authoritative sources (January 2026)
> Use this document to audit existing templates and identify improvements for new versions.

---

## Table of Contents

1. [Project Architecture & Structure](#1-project-architecture--structure)
2. [TypeScript Configuration](#2-typescript-configuration)
3. [Content Collections & Markdown](#3-content-collections--markdown)
4. [Tailwind CSS Integration](#4-tailwind-css-integration)
5. [Component Patterns](#5-component-patterns)
6. [Layout Patterns](#6-layout-patterns)
7. [Performance Optimization](#7-performance-optimization)
8. [Image Optimization](#8-image-optimization)
9. [SEO Best Practices](#9-seo-best-practices)
10. [Accessibility (a11y)](#10-accessibility-a11y)
11. [Configuration Best Practices](#11-configuration-best-practices)
12. [Common Pitfalls to Avoid](#12-common-pitfalls-to-avoid)
13. [Audit Checklist](#13-audit-checklist)

---

## 1. Project Architecture & Structure

### Core Principle: Islands Architecture

Astro's fundamental design philosophy is the **islands architecture**:
- Components render as static HTML by default
- JavaScript loads only for interactive "islands"
- Zero client-side JavaScript shipped unless explicitly needed

### Recommended Directory Structure

```
project-root/
├── astro.config.mjs          # Astro configuration (use .mjs or .ts)
├── tsconfig.json             # TypeScript configuration
├── tailwind.config.mjs       # Tailwind configuration (if using v3)
├── package.json
├── public/                   # Static assets (NOT processed by Astro)
│   ├── favicon.svg
│   ├── robots.txt            # Or generate dynamically
│   └── fonts/
├── src/
│   ├── assets/               # Assets processed by Astro (images, etc.)
│   ├── components/           # Reusable UI components
│   │   ├── common/           # Buttons, Cards, Form elements
│   │   ├── layout/           # Header, Footer, Navigation
│   │   └── [feature]/        # Feature-specific components
│   ├── content/              # Content collections (if using glob loader)
│   │   ├── blog/
│   │   └── [collection]/
│   ├── content.config.ts     # Content collection definitions
│   ├── layouts/              # Page layout templates
│   │   ├── BaseLayout.astro
│   │   └── BlogLayout.astro
│   ├── pages/                # File-based routing (REQUIRED)
│   │   ├── index.astro
│   │   ├── blog/
│   │   └── [...slug].astro
│   ├── styles/               # Global styles
│   │   └── global.css
│   └── utils/                # Helper functions, constants
│       └── index.ts
└── .gitignore
```

### File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `Button.astro`, `PostCard.astro` |
| Pages | kebab-case | `about-us.astro`, `contact.astro` |
| Layouts | PascalCase | `BaseLayout.astro` |
| Utilities | camelCase | `formatDate.ts` |
| Content files | kebab-case | `my-first-post.md` |

### Directory Rules

- **`src/pages/`**: Only required directory - defines routes via file structure
- **`src/components/`**: Convention, not required - group by feature or type
- **`src/layouts/`**: Convention, not required - shared page structures
- **`public/`**: Static files served as-is (never processed)
- **`src/assets/`**: Files Astro will optimize (images, etc.)

**Sources:**
- [Project Structure | Astro Docs](https://docs.astro.build/en/basics/project-structure/)
- [Best Practices for File Organization](https://tillitsdone.com/blogs/astro-js-file-organization-guide/)

---

## 2. TypeScript Configuration

### Recommended Preset: `strict` or `strictest`

Astro provides three TypeScript presets:
- **base**: Modern JS features only
- **strict**: Type checking + modern JS (recommended for most projects)
- **strictest**: Maximum type safety (may have edge-case issues)

### Recommended `tsconfig.json`

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@layouts/*": ["src/layouts/*"],
      "@utils/*": ["src/utils/*"],
      "@content/*": ["src/content/*"]
    },
    "strictNullChecks": true
  },
  "include": ["src/**/*", "astro.config.mjs"],
  "exclude": ["node_modules", "dist"]
}
```

### Path Aliases Best Practice

Use path aliases to avoid relative import hell:

```typescript
// ❌ Avoid
import Button from '../../../components/common/Button.astro';

// ✅ Prefer
import Button from '@components/common/Button.astro';
```

### Type Checking Commands

```bash
# Check .astro files for type errors
npx astro check

# Sync content collection types
npx astro sync
```

### Component Props Typing

```astro
---
// Use interface Props for automatic type inference
interface Props {
  title: string;
  description?: string;
  tags: string[];
}

const { title, description = 'Default description', tags } = Astro.props;
---
```

### Known Issues

- Using `strictest` preset with `astro:db` can cause DrizzleORM import errors
- If types aren't generated for content collections, run `npx astro sync`

**Sources:**
- [TypeScript | Astro Docs](https://docs.astro.build/en/guides/typescript/)
- [How to Adapt Astro to TypeScript](https://borjalofe.com/blog/how-to-adapt-astro-to-typescript/)

---

## 3. Content Collections & Markdown

### When to Use Content Collections

Use collections when you have:
- Multiple files sharing the same structure (blog posts, products, team members)
- Need for type-safe frontmatter validation
- Want optimized querying APIs

### Configuration File: `src/content.config.ts`

```typescript
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    heroImage: z.string().optional(),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
  }),
});

export const collections = { blog };
```

### Schema Best Practices

```typescript
// Use z.coerce for dates (handles string/Date input)
pubDate: z.coerce.date(),

// Provide defaults for optional fields
tags: z.array(z.string()).default([]),
draft: z.boolean().default(false),

// Use enum for constrained values
category: z.enum(['tech', 'lifestyle', 'tutorial']),

// Make fields optional with .optional()
heroImage: z.string().optional(),
```

### Querying Collections

```typescript
import { getCollection, getEntry } from 'astro:content';

// Get all entries (filter drafts in production)
const posts = await getCollection('blog', ({ data }) => {
  return import.meta.env.PROD ? data.draft !== true : true;
});

// Get single entry
const post = await getEntry('blog', 'my-post-slug');

// Sort by date
const sortedPosts = posts.sort(
  (a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf()
);
```

### Rendering Content

```astro
---
import { getEntry } from 'astro:content';

const post = await getEntry('blog', Astro.params.slug);
const { Content } = await post.render();
---

<article>
  <h1>{post.data.title}</h1>
  <Content />
</article>
```

### MDX Support

Install `@astrojs/mdx` for JSX in Markdown:

```bash
npx astro add mdx
```

Benefits:
- Import and use components in content
- Use variables and expressions
- Better for interactive content pages

**Sources:**
- [Content Collections | Astro Docs](https://docs.astro.build/en/guides/content-collections/)
- [Markdown in Astro | Astro Docs](https://docs.astro.build/en/guides/markdown-content/)
- [Content Collections API Reference](https://docs.astro.build/en/reference/modules/astro-content/)

---

## 4. Tailwind CSS Integration

### Tailwind v4 (Current - 2025+)

**Important:** The `@astrojs/tailwind` integration is deprecated for Tailwind v4. Use the Vite plugin instead.

#### Installation

```bash
npm install @tailwindcss/vite tailwindcss
```

#### Configuration (`astro.config.mjs`)

```javascript
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
  },
});
```

#### Global CSS (`src/styles/global.css`)

```css
@import "tailwindcss";

/* Tailwind v4: CSS-first configuration */
@theme {
  --color-brand: #3b82f6;
  --font-display: "Inter", sans-serif;
}

/* Optional plugins via CSS */
@plugin "@tailwindcss/typography";
```

#### Import Once in Layout

```astro
---
// src/layouts/BaseLayout.astro
import '../styles/global.css';
---
```

### Tailwind v3 (Legacy)

If using Tailwind v3, configure `content` paths correctly:

```javascript
// tailwind.config.mjs
export default {
  content: [
    './src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}',
    './public/**/*.html',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

### Best Practices

1. **Extract repeated patterns** to components, not `@apply`
2. **Use consistent spacing/color scales** via theme configuration
3. **Verify content paths** include all file extensions using Tailwind classes
4. **Avoid inline styles** when Tailwind utilities exist

### Common Issue: Missing Styles

If styles aren't appearing:
- Check `content` array includes all file paths/extensions
- Ensure global CSS is imported in a layout
- Verify plugin is added to Vite config

**Sources:**
- [Install Tailwind CSS with Astro](https://tailwindcss.com/docs/installation/framework-guides/astro)
- [Astro + Tailwind v4 Setup Guide](https://tailkits.com/blog/astro-tailwind-setup/)
- [@astrojs/tailwind Integration](https://docs.astro.build/en/guides/integrations-guide/tailwind/)

---

## 5. Component Patterns

### Basic Component Structure

```astro
---
// 1. Imports
import Button from '@components/common/Button.astro';

// 2. Props interface
interface Props {
  title: string;
  variant?: 'primary' | 'secondary';
}

// 3. Destructure with defaults
const { title, variant = 'primary' } = Astro.props;

// 4. Component logic
const classes = variant === 'primary' ? 'bg-blue-500' : 'bg-gray-500';
---

<!-- 5. Template -->
<div class={classes}>
  <h2>{title}</h2>
  <slot />
</div>

<!-- 6. Scoped styles (optional) -->
<style>
  div {
    padding: 1rem;
  }
</style>
```

### Slots for Composition

```astro
---
// Card.astro
interface Props {
  title: string;
}
const { title } = Astro.props;
---

<article class="card">
  <header>
    <slot name="header">
      <h2>{title}</h2>
    </slot>
  </header>

  <div class="content">
    <slot />  <!-- Default slot -->
  </div>

  <footer>
    <slot name="footer" />
  </footer>
</article>
```

Usage:

```astro
<Card title="Default Title">
  <span slot="header">Custom Header</span>
  <p>This goes in the default slot</p>
  <div slot="footer">Footer content</div>
</Card>
```

### Conditional Rendering

```astro
---
const { showBanner = false, items = [] } = Astro.props;
---

{showBanner && <Banner />}

{items.length > 0 ? (
  <ul>
    {items.map(item => <li>{item}</li>)}
  </ul>
) : (
  <p>No items found</p>
)}
```

### Extending HTML Attributes

```astro
---
import type { HTMLAttributes } from 'astro/types';

interface Props extends HTMLAttributes<'button'> {
  variant?: 'primary' | 'secondary';
}

const { variant = 'primary', class: className, ...attrs } = Astro.props;
---

<button class:list={[variant, className]} {...attrs}>
  <slot />
</button>
```

**Sources:**
- [Components | Astro Docs](https://docs.astro.build/en/basics/astro-components/)
- [How To Make Reusable Components](https://www.kristiannielsen.com/blog/how-to-make-reusable-components-with-astro)

---

## 6. Layout Patterns

### Base Layout Template

```astro
---
// src/layouts/BaseLayout.astro
import '../styles/global.css';
import Header from '@components/layout/Header.astro';
import Footer from '@components/layout/Footer.astro';
import SEO from '@components/SEO.astro';

interface Props {
  title: string;
  description?: string;
  image?: string;
}

const {
  title,
  description = 'Default site description',
  image = '/og-default.jpg'
} = Astro.props;

const canonicalURL = new URL(Astro.url.pathname, Astro.site);
---

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />

    <SEO
      title={title}
      description={description}
      image={image}
      canonicalURL={canonicalURL}
    />

    <slot name="head" />
  </head>
  <body>
    <Header />
    <main>
      <slot />
    </main>
    <Footer />

    <slot name="scripts" />
  </body>
</html>
```

### Nested Layout Pattern

```astro
---
// src/layouts/BlogLayout.astro
import BaseLayout from './BaseLayout.astro';

interface Props {
  title: string;
  pubDate: Date;
  author: string;
}

const { title, pubDate, author } = Astro.props;
---

<BaseLayout title={title}>
  <article class="prose mx-auto">
    <header>
      <h1>{title}</h1>
      <p>By {author} on <time>{pubDate.toLocaleDateString()}</time></p>
    </header>

    <slot />
  </article>
</BaseLayout>
```

### Key Rules

1. **Single `<head>` per page** - Place in base layout only
2. **Use slots for flexibility** - Named slots for head/scripts
3. **Nest layouts** for specialized pages (blog, docs, etc.)
4. **Keep layouts minimal** - Extract reusable parts to components

**Sources:**
- [Layouts | Astro Docs](https://docs.astro.build/en/basics/layouts/)
- [Astro Layouts: Shared Headers, Footers and Meta](https://cloudcannon.com/tutorials/astro-beginners-tutorial-series/astro-layouts/)

---

## 7. Performance Optimization

### Core Principle: Static by Default

```astro
<!-- ❌ Don't add client directives without reason -->
<InteractiveWidget client:load />

<!-- ✅ Only add when truly needed -->
<StaticCard />  <!-- No directive = zero JS -->
<LikeButton client:visible />  <!-- JS loads when visible -->
```

### Client Directives Reference

| Directive | When JS Loads | Use Case |
|-----------|---------------|----------|
| `client:load` | Immediately on page load | Critical interactive components |
| `client:idle` | After page becomes idle | Lower priority interactions |
| `client:visible` | When component enters viewport | Below-fold content |
| `client:media` | When media query matches | Responsive interactivity |
| `client:only` | Only renders on client | No SSR needed |

### Bundle Size Optimization

```javascript
// ❌ Heavy dependencies
import moment from 'moment';  // 200KB+

// ✅ Native alternatives
const formatted = new Intl.DateTimeFormat('en-US').format(date);
```

### Prefetching (Experimental)

```javascript
// astro.config.mjs
export default defineConfig({
  experimental: {
    clientPrerender: true,
  },
  prefetch: {
    prefetchAll: true,  // or configure per-link
  },
});
```

### Performance Checklist

- [ ] No unnecessary `client:*` directives
- [ ] Heavy libraries replaced with lighter alternatives
- [ ] Images optimized (see next section)
- [ ] CSS inlined for small stylesheets
- [ ] Third-party scripts deferred

**Sources:**
- [Complete Guide to Astro Performance Optimization](https://eastondev.com/blog/en/posts/dev/20251202-astro-performance-optimization/)
- [The Rise of AstroJS in 2025](https://dev.to/fahim_shahrier_4a003786e0/the-rise-of-astrojs-in-2025-m4k)

---

## 8. Image Optimization

### Built-in `<Image />` Component

```astro
---
import { Image } from 'astro:assets';
import heroImage from '../assets/hero.jpg';
---

<!-- Local images (in src/assets) -->
<Image
  src={heroImage}
  alt="Hero description"
  width={800}
  height={600}
/>

<!-- Remote images (configure in astro.config.mjs) -->
<Image
  src="https://example.com/image.jpg"
  alt="Remote image"
  width={800}
  height={600}
/>
```

### Configuration for Remote Images

```javascript
// astro.config.mjs
export default defineConfig({
  image: {
    domains: ['example.com', 'images.unsplash.com'],
    remotePatterns: [{ protocol: 'https' }],
  },
});
```

### Responsive Images

```astro
<Image
  src={heroImage}
  alt="Hero"
  widths={[320, 640, 1280]}
  sizes="(max-width: 640px) 100vw, 50vw"
/>
```

### Key Features

- **Automatic WebP conversion** (default format)
- **CLS prevention** via auto width/height
- **Lazy loading** built-in
- **Sharp** for processing (default), Squoosh available

### Important Notes

- Images in `public/` are **never optimized**
- Use `src/assets/` for images that need processing
- Always provide `alt` text for accessibility

**Sources:**
- [Images | Astro Docs](https://docs.astro.build/en/guides/images/)
- [Better Images in Astro](https://astro.build/blog/images/)
- [Mastering Image Optimization in Astro.js](https://caisy.io/blog/astro-js-images)

---

## 9. SEO Best Practices

### SEO Component Template

```astro
---
// src/components/SEO.astro
interface Props {
  title: string;
  description: string;
  image?: string;
  canonicalURL: URL;
  type?: 'website' | 'article';
}

const {
  title,
  description,
  image = '/og-default.jpg',
  canonicalURL,
  type = 'website'
} = Astro.props;

const ogImage = new URL(image, Astro.site);
---

<!-- Primary Meta Tags -->
<title>{title}</title>
<meta name="title" content={title} />
<meta name="description" content={description} />
<link rel="canonical" href={canonicalURL} />

<!-- Open Graph / Facebook -->
<meta property="og:type" content={type} />
<meta property="og:url" content={canonicalURL} />
<meta property="og:title" content={title} />
<meta property="og:description" content={description} />
<meta property="og:image" content={ogImage} />

<!-- Twitter -->
<meta property="twitter:card" content="summary_large_image" />
<meta property="twitter:url" content={canonicalURL} />
<meta property="twitter:title" content={title} />
<meta property="twitter:description" content={description} />
<meta property="twitter:image" content={ogImage} />
```

### Sitemap Setup

```bash
npx astro add sitemap
```

```javascript
// astro.config.mjs
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://example.com',  // REQUIRED for sitemap
  integrations: [sitemap()],
});
```

### Dynamic robots.txt

```typescript
// src/pages/robots.txt.ts
import type { APIRoute } from 'astro';

export const GET: APIRoute = ({ site }) => {
  const sitemapURL = new URL('sitemap-index.xml', site);

  return new Response(
`User-agent: *
Allow: /

Sitemap: ${sitemapURL.href}
`
  );
};
```

### Structured Data (JSON-LD)

```astro
<script type="application/ld+json" set:html={JSON.stringify({
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": title,
  "datePublished": pubDate.toISOString(),
  "author": {
    "@type": "Person",
    "name": author
  }
})} />
```

### SEO Checklist

- [ ] `site` configured in `astro.config.mjs`
- [ ] Unique `<title>` and `<meta name="description">` per page
- [ ] Canonical URLs set
- [ ] Open Graph tags for social sharing
- [ ] Sitemap generated and submitted
- [ ] robots.txt configured
- [ ] Structured data where appropriate

**Sources:**
- [SEO for Astro Guide](https://dev.to/cookieduster_n/seo-for-astro-how-to-make-the-fastest-framework-also-the-smartest-501o)
- [@astrojs/sitemap](https://docs.astro.build/en/guides/integrations-guide/sitemap/)
- [Complete Guide to Astro SEO Optimization](https://astrojs.dev/articles/astro-seo-optimization/)

---

## 10. Accessibility (a11y)

### WCAG 2.2 Compliance Goals

Target **Level AA** minimum:
- **4.5:1** contrast ratio for normal text
- **3:1** contrast ratio for large text (18pt+ or 14pt bold)
- **3:1** contrast ratio for non-text elements (icons, buttons)

### Essential Accessibility Features

```astro
<!-- Skip link for keyboard navigation -->
<a href="#main-content" class="sr-only focus:not-sr-only">
  Skip to main content
</a>

<!-- Proper landmarks -->
<header role="banner">...</header>
<nav role="navigation" aria-label="Main">...</nav>
<main id="main-content" role="main">...</main>
<footer role="contentinfo">...</footer>

<!-- Focus indicators -->
<style>
  :focus-visible {
    outline: 2px solid var(--color-focus);
    outline-offset: 2px;
  }
</style>
```

### Accessible Component Patterns

```astro
---
// Accessible Button
interface Props {
  label: string;
  disabled?: boolean;
}
const { label, disabled = false } = Astro.props;
---

<button
  type="button"
  disabled={disabled}
  aria-disabled={disabled}
>
  {label}
</button>
```

### Image Accessibility

```astro
<!-- Informative image -->
<Image src={chart} alt="Sales increased 25% in Q4 2024" />

<!-- Decorative image -->
<Image src={decorative} alt="" role="presentation" />
```

### Form Accessibility

```astro
<label for="email">Email Address</label>
<input
  type="email"
  id="email"
  name="email"
  required
  aria-describedby="email-hint"
/>
<span id="email-hint" class="hint">We'll never share your email</span>
```

### Testing Tools

- **Lighthouse** accessibility audit
- **axe DevTools** browser extension
- **WAVE** evaluation tool
- Manual keyboard navigation testing
- Screen reader testing (NVDA, VoiceOver)

### Recommended Package

```bash
npm install accessible-astro-components
```

Provides pre-built accessible components (Accordion, Modal, etc.)

**Sources:**
- [Accessible Astro Starter](https://astro.build/themes/details/accessible-astro-starter/)
- [Accessible Astro Components](https://github.com/markteekman/accessible-astro-components)
- [Accessibility in Your Astro.js Site](https://accessibilityaid.com/platforms/astro)

---

## 11. Configuration Best Practices

### Recommended `astro.config.mjs`

```javascript
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';
import mdx from '@astrojs/mdx';

export default defineConfig({
  // Required for sitemap and canonical URLs
  site: 'https://example.com',

  // Trailing slash handling (match your host)
  trailingSlash: 'never',  // or 'always', 'ignore'

  // Build output
  output: 'static',  // or 'server', 'hybrid'

  // Integrations
  integrations: [
    mdx(),
    sitemap({
      filter: (page) => !page.includes('/draft/'),
    }),
  ],

  // Vite configuration
  vite: {
    plugins: [tailwindcss()],
  },

  // Image optimization
  image: {
    domains: ['images.unsplash.com'],
  },

  // Prefetching (optional)
  prefetch: {
    defaultStrategy: 'viewport',
  },
});
```

### Environment Variables

```bash
# .env
PUBLIC_SITE_URL=https://example.com
API_SECRET=secret-key
```

```astro
---
// Access in components
const siteUrl = import.meta.env.PUBLIC_SITE_URL;
// API_SECRET only available server-side
---
```

### Configuration Checklist

- [ ] `site` property set for production URL
- [ ] `trailingSlash` matches deployment host
- [ ] Image domains configured for remote sources
- [ ] All integrations added via `integrations` array
- [ ] Environment variables prefixed correctly (`PUBLIC_` for client)

**Sources:**
- [Configuration Overview](https://docs.astro.build/en/guides/configuring-astro/)
- [Configuration Reference](https://docs.astro.build/en/reference/configuration-reference/)

---

## 12. Common Pitfalls to Avoid

### ❌ Client Directive Overuse

```astro
<!-- ❌ Don't add client:load everywhere -->
<Card client:load />
<Header client:load />

<!-- ✅ Only where needed -->
<Card />  <!-- Static is fine -->
<SearchBar client:idle />  <!-- Actually interactive -->
```

**Rule:** Start static, add interactivity only when required.

### ❌ Multiple `<head>` Tags

```astro
<!-- ❌ Don't put <head> in components -->
// Component.astro
<head><title>Page</title></head>

<!-- ✅ Single <head> in base layout only -->
// BaseLayout.astro
<head>
  <slot name="head" />
</head>
```

### ❌ Heavy Dependencies

```javascript
// ❌ Moment.js = 200KB+
import moment from 'moment';

// ✅ Native APIs
new Intl.DateTimeFormat('en-US', {
  dateStyle: 'medium'
}).format(date);
```

### ❌ Missing Peer Dependencies

```bash
# ❌ Missing React packages
npm install @astrojs/react

# ✅ Install all peer dependencies
npm install @astrojs/react react react-dom
```

### ❌ Images in public/ Expecting Optimization

```astro
<!-- ❌ public/ images are NOT optimized -->
<img src="/images/hero.jpg" />

<!-- ✅ Use src/assets/ with Image component -->
import heroImage from '../assets/hero.jpg';
<Image src={heroImage} alt="Hero" />
```

### ❌ loadEnv Issues

```javascript
// ❌ Can cause Vite client/server confusion
import { loadEnv } from 'vite';
const env = loadEnv(mode, process.cwd());

// ✅ Use import.meta.env
const apiUrl = import.meta.env.API_URL;
```

### ❌ Forgetting astro sync

If content collection types aren't working:

```bash
npx astro sync
```

### ❌ Yarn Berry (PnP) Problems

```yaml
# .yarnrc.yml - Use node_modules linker
nodeLinker: node-modules
```

**Sources:**
- [Troubleshooting | Astro Docs](https://docs.astro.build/en/guides/troubleshooting/)
- [Error Reference | Astro Docs](https://docs.astro.build/en/reference/error-reference/)

---

## 13. Audit Checklist

Use this checklist to review existing templates:

### Project Structure
- [ ] `src/pages/` exists and uses file-based routing correctly
- [ ] Components organized logically (`components/`, `layouts/`)
- [ ] Path aliases configured in `tsconfig.json`
- [ ] Assets in `src/assets/` (not `public/`) for optimization
- [ ] Consistent file naming conventions

### TypeScript
- [ ] Using `strict` or `strictest` preset
- [ ] `interface Props` defined for all components
- [ ] Path aliases working (`@components/`, etc.)
- [ ] No type errors from `npx astro check`

### Content Collections
- [ ] Schema defined with Zod validation
- [ ] Appropriate defaults for optional fields
- [ ] Draft filtering in production
- [ ] Types generated (`npx astro sync`)

### Tailwind CSS
- [ ] Using v4 Vite plugin (not deprecated integration)
- [ ] Global CSS imported in base layout
- [ ] Content paths correct (if v3)
- [ ] Theme tokens configured

### Components & Layouts
- [ ] Single `<head>` in base layout only
- [ ] Slots used for flexibility
- [ ] Props typed with interfaces
- [ ] No unnecessary client directives

### Performance
- [ ] `client:*` directives used sparingly
- [ ] No heavy dependencies where native APIs work
- [ ] Images use `<Image />` component
- [ ] Lazy loading enabled

### SEO
- [ ] `site` configured in `astro.config.mjs`
- [ ] Meta tags on all pages (title, description)
- [ ] Open Graph tags for social sharing
- [ ] Sitemap generated
- [ ] robots.txt present
- [ ] Canonical URLs set

### Accessibility
- [ ] Skip link present
- [ ] Semantic HTML landmarks
- [ ] Focus indicators visible
- [ ] Images have alt text
- [ ] Forms properly labeled
- [ ] Color contrast meets WCAG AA

### Configuration
- [ ] `astro.config.mjs` uses `defineConfig()`
- [ ] `trailingSlash` configured for host
- [ ] Image domains configured
- [ ] Environment variables prefixed correctly

---

## Quick Reference Cards

### Essential Integrations

```bash
# Core
npx astro add mdx
npx astro add sitemap
npx astro add tailwind  # v3 only

# For Tailwind v4
npm install @tailwindcss/vite tailwindcss
```

### Common Commands

```bash
npx astro dev          # Development server
npx astro build        # Production build
npx astro preview      # Preview build locally
npx astro check        # TypeScript checking
npx astro sync         # Sync content types
```

### File Templates

Quick-start templates for common files are provided throughout this document.

---

*Document compiled from official Astro documentation and authoritative community resources. Last updated: January 2026.*
