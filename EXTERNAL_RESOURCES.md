# External Resources & Modern Implementations

> Curated resources from official docs, GitHub repos, and community patterns
> Compiled: January 2026

---

## Table of Contents

1. [Key Discoveries](#key-discoveries)
2. [Reference Repositories](#reference-repositories)
3. [Image Handling Solutions](#image-handling-solutions)
4. [Official Documentation](#official-documentation)
5. [Patterns & Techniques](#patterns--techniques)
6. [Tools to Consider](#tools-to-consider)

---

## Key Discoveries

### 1. `astro-preload` - Download Images at Build Time

**This solves our exact problem.** The [`astro-preload`](https://github.com/LyonSyonII/astro-preload) package downloads remote images during build and saves them locally.

```javascript
// astro.config.mjs
import preload from "astro-preload";

export default defineConfig({
  integrations: [preload()]  // Must be FIRST
});
```

```astro
---
import { Image } from "astro-preload/components";
---
<!-- Downloads at build, saves to public/assets/preloaded/ -->
<Image url="https://images.unsplash.com/photo-xxx" />
```

**Key behavior:**
- Build time: Downloads and saves locally
- Dev mode: Forwards URLs directly (no re-downloading)
- Works with `astro-compress` for optimization

**Consideration:** Last updated ~1 year ago. May need to fork/maintain.

---

### 2. Unpic - Universal Image CDN

[Unpic](https://unpic.pics/img/astro/) auto-detects image CDNs and generates optimal `srcset`/`sizes`. Used by AstroWind (5.4k stars).

```bash
npm install @unpic/astro
```

```astro
---
import { Image } from "@unpic/astro";
---
<Image
  src="https://cdn.example.com/image.jpg"
  width={800}
  height={600}
  alt="Description"
/>
```

**Features:**
- Auto-detects 30+ CDNs (Cloudinary, Imgix, Contentful, etc.)
- Generates responsive srcset automatically
- No client-side JavaScript
- Placeholder generation (blurhash, dominant color)
- Works with Netlify/Vercel image CDNs

**Best for:** Projects using external CDN images or CMS-hosted images.

---

### 3. AstroWind's Image Approach

[AstroWind](https://github.com/onwidget/astrowind) (5.4k stars) combines multiple strategies:

**Directory structure:**
```
src/
├── assets/
│   └── images/          # Imported images (processed)
├── utils/
│   └── images.ts        # Dynamic image loading utilities
```

**Key pattern - `getImageMetas` utility:**
```typescript
// src/utils/images.ts
// Dynamically searches src/assets for images
export async function getImageMetas(names: string[]) {
  const images = await Astro.glob('/src/assets/images/**/*');
  return images.filter(img => names.some(n => img.includes(n)));
}
```

**Configuration via YAML:**
```yaml
# src/config.yaml
ui:
  theme: 'system'  # system | light | dark | light:only | dark:only
```

---

### 4. Content Collection Image Schema

The proper way to validate images in content collections:

```typescript
// src/content.config.ts
import { defineCollection, z } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: ({ image }) => z.object({
    title: z.string(),
    // Validated image reference
    cover: image(),
    coverAlt: z.string(),
    // Optional image
    thumbnail: image().optional(),
    // With dimension validation
    hero: image().refine(
      (img) => img.width >= 1080,
      { message: "Hero must be at least 1080px wide" }
    ),
  }),
});
```

**Usage in component:**
```astro
---
import { Image } from 'astro:assets';
import { getCollection } from 'astro:content';

const posts = await getCollection('blog');
---
{posts.map(post => (
  <Image src={post.data.cover} alt={post.data.coverAlt} />
))}
```

---

## Reference Repositories

### Tier 1: Most Popular & Well-Maintained

| Repository | Stars | Key Features | Link |
|------------|-------|--------------|------|
| **AstroWind** | 5.4k | Tailwind, Unpic images, YAML config, MDX blog | [GitHub](https://github.com/onwidget/astrowind) |
| **Astroship** | ~1k | Startup/marketing focus, TailwindCSS | [GitHub](https://github.com/surjithctly/astroship) |
| **Odyssey Theme** | ~500 | Business marketing, themeable, Landing pages | [GitHub](https://github.com/treefarmstudio/odyssey-theme) |

### Tier 2: Specialized Templates

| Repository | Focus | Link |
|------------|-------|------|
| **Astroplate** | General starter, TypeScript | [GitHub](https://github.com/zeon-studio/astroplate) |
| **Play Astro** | SaaS/Startup | [GitHub](https://github.com/TailGrids/play-astro) |
| **Netlify Astro Starter** | Edge functions, Image CDN | [GitHub](https://github.com/netlify-templates/astro-platform-starter) |

### What to Learn From Each

**AstroWind:**
- `src/utils/images.ts` - Dynamic image utilities
- `src/config.yaml` - Centralized configuration
- Component organization in `widgets/` folder

**Odyssey Theme:**
- CSS-based theming without framework lock-in
- Component architecture (58% Astro, 18% MDX)
- Perfect Lighthouse scores approach

---

## Image Handling Solutions

### Option A: Local-First (Recommended for Your Use Case)

**Workflow:**
1. Download images during development with CLI
2. Store in `src/assets/images/`
3. Import and use with Astro `<Image />`

**Tools:**
- Your `image-studio` CLI (with fixes)
- Or `astro-preload` for URL-based fetching

**Pros:** Deterministic, full optimization, offline builds
**Cons:** Manual download step

---

### Option B: Build-Time Download with `astro-preload`

**Workflow:**
1. Reference remote URLs in components
2. `astro-preload` downloads at build
3. Saved to `public/assets/preloaded/`

**Pros:** Automatic, URL-based
**Cons:** Still in `public/` not `src/assets/`, less maintained

---

### Option C: Universal CDN with Unpic

**Workflow:**
1. Host images on CDN (Cloudinary, Imgix, etc.)
2. Use Unpic `<Image />` component
3. Auto-generates responsive srcset

**Pros:** No local storage, CDN optimization
**Cons:** External dependency, costs for CDN

---

### Option D: Hybrid (AstroWind Approach)

**Workflow:**
1. Local images in `src/assets/` for known content
2. Unpic for dynamic/CMS images
3. Utility functions for dynamic loading

**Pros:** Flexible, handles multiple sources
**Cons:** More complexity

---

## Official Documentation

### Must-Read Pages

| Topic | URL | Key Takeaway |
|-------|-----|--------------|
| **Images Guide** | [docs.astro.build/guides/images](https://docs.astro.build/en/guides/images/) | `src/` for optimization, `public/` for as-is |
| **Content Collections** | [docs.astro.build/guides/content-collections](https://docs.astro.build/en/guides/content-collections/) | `image()` schema helper |
| **Tailwind v4 Setup** | [tailwindcss.com/docs/installation/framework-guides/astro](https://tailwindcss.com/docs/installation/framework-guides/astro) | Use `@tailwindcss/vite` not `@astrojs/tailwind` |
| **Image Assets API** | [docs.astro.build/reference/modules/astro-assets](https://docs.astro.build/en/reference/modules/astro-assets/) | `getImage()`, responsive layouts |

### Recent Updates (December 2025 / Astro 5.x)

- **Live Content Collections** (5.10+) - Runtime data fetching
- **Responsive Image Layouts** (5.10+) - `objectFit` and `layout` props
- **Astro 6 Alpha** - Coming early 2026

Source: [What's new in Astro - December 2025](https://astro.build/blog/whats-new-december-2025/)

---

## Patterns & Techniques

### 1. Tailwind v4 Setup (Current Best Practice)

```bash
npm install tailwindcss @tailwindcss/vite
```

```javascript
// astro.config.mjs
import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
  },
});
```

```css
/* src/styles/global.css */
@import "tailwindcss";

@theme {
  --color-primary: #2563eb;
  --color-secondary: #64748b;
}
```

Source: [Tailkits Astro + Tailwind v4 Guide](https://tailkits.com/blog/astro-tailwind-setup/)

---

### 2. Dark Mode with View Transitions

```astro
<!-- src/components/ThemeToggle.astro -->
<script is:inline>
  // Runs before first paint - no flash
  const theme = localStorage.getItem('theme') ||
    (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  document.documentElement.dataset.theme = theme;

  // Handle view transitions
  document.addEventListener('astro:after-swap', () => {
    const theme = localStorage.getItem('theme') || 'light';
    document.documentElement.dataset.theme = theme;
  });
</script>
```

Source: [Interactive dark mode with Astro View Transitions](https://namoku.dev/blog/darkmode-tailwind-astro/)

---

### 3. Modular Component Architecture

From [Astro Components Docs](https://docs.astro.build/en/basics/astro-components/):

```astro
---
// Props interface for type safety
interface Props {
  title: string;
  items: Array<{ name: string; url: string }>;
  variant?: 'primary' | 'secondary';
}

const { title, items, variant = 'primary' } = Astro.props;
---

<section class:list={['section', `section--${variant}`]}>
  <h2>{title}</h2>
  <ul>
    {items.map(item => (
      <li><a href={item.url}>{item.name}</a></li>
    ))}
  </ul>
</section>
```

**Key principles:**
- Props for all data (no internal fetching)
- TypeScript interfaces
- `class:list` for conditional classes
- Small, composable components

---

### 4. Dynamic Image Loading Utility

Pattern from AstroWind:

```typescript
// src/lib/images.ts
import type { ImageMetadata } from 'astro';

const images = import.meta.glob<{ default: ImageMetadata }>(
  '/src/assets/images/**/*.{jpeg,jpg,png,gif,webp,svg}'
);

export async function getImage(path: string): Promise<ImageMetadata | undefined> {
  const key = `/src/assets/images/${path}`;
  if (images[key]) {
    const module = await images[key]();
    return module.default;
  }
  return undefined;
}

export async function getAllImages(folder: string): Promise<ImageMetadata[]> {
  const results: ImageMetadata[] = [];
  for (const [path, resolver] of Object.entries(images)) {
    if (path.includes(`/${folder}/`)) {
      const module = await resolver();
      results.push(module.default);
    }
  }
  return results;
}
```

---

## Tools to Consider

### Definite Adds

| Tool | Purpose | Why |
|------|---------|-----|
| **@tailwindcss/vite** | Tailwind v4 | Official, replaces @astrojs/tailwind |
| **astro:assets** | Image optimization | Built-in, best practice |

### Worth Evaluating

| Tool | Purpose | Consideration |
|------|---------|---------------|
| **@unpic/astro** | Universal image CDN | If using external images |
| **astro-preload** | Build-time download | May need fork for maintenance |
| **astro-compress** | Asset compression | Pairs with preload |

### Skip / Replace

| Tool | Why Skip |
|------|----------|
| **astro-unsplash-integration** | Non-deterministic, runtime fetching |
| **@astrojs/tailwind** | Deprecated for Tailwind v4 |

---

## Summary: Recommended Stack

Based on research, here's the modern stack for your templates:

```
Framework:        Astro 5.x
Styling:          Tailwind CSS v4 via @tailwindcss/vite
Images:           src/assets/ + Astro <Image />
Image Download:   image-studio CLI (fixed) OR astro-preload
Content:          Content Collections with image() schema
Theming:          CSS variables + @theme block
TypeScript:       Strict mode with path aliases
```

**Key insight from AstroWind:** Use a combination approach:
1. Local images for known/fixed content
2. Utility functions for dynamic image loading
3. YAML/JSON config for site-wide settings

---

## Sources

### Official
- [Astro Images Guide](https://docs.astro.build/en/guides/images/)
- [Astro Content Collections](https://docs.astro.build/en/guides/content-collections/)
- [Tailwind CSS Astro Installation](https://tailwindcss.com/docs/installation/framework-guides/astro)
- [Astro Components](https://docs.astro.build/en/basics/astro-components/)

### Repositories
- [AstroWind](https://github.com/onwidget/astrowind) - 5.4k stars
- [Odyssey Theme](https://github.com/treefarmstudio/odyssey-theme)
- [astro-preload](https://github.com/LyonSyonII/astro-preload)
- [Unpic](https://github.com/ascorbic/unpic-img)

### Articles & Guides
- [Tailkits: Astro + Tailwind v4 Setup](https://tailkits.com/blog/astro-tailwind-setup/)
- [How to Use Tailwind CSS v4 in Astro](https://dev.to/dipankarmaikap/how-to-use-tailwind-css-v4-in-astro-31og)
- [Dark Mode with Astro View Transitions](https://namoku.dev/blog/darkmode-tailwind-astro/)
- [Unpic Astro Image Service](https://unpic.pics/blog/unpic-astro-image-service/)
- [Complete Guide to Astro Content Collections](https://eastondev.com/blog/en/posts/dev/20251124-astro-content-collections-guide/)

### Community
- [Astro Roadmap: Even Better Images Discussion](https://github.com/withastro/roadmap/discussions/597)
- [Astro Themes Directory](https://astro.build/themes/)

---

*Compiled: January 2026*
