# Astro Unsplash Integration Audit Report

> Audit of `astro-unsplash-integration` - Runtime image fetching library
> Date: January 2026
> Context: Cross-repo analysis identified images as #1 problem (40%+ of issues)

---

## Executive Summary

**Assessment: This is Likely THE Source of Image Problems**

This integration fetches images directly from Unsplash URLs at build time without downloading them locally. This architecture causes several critical issues that directly explain the image problems found in the cross-repo analysis.

### Critical Issues

| Issue | Impact | Severity |
|-------|--------|----------|
| Images not downloaded locally | No Astro optimization, external dependency | **Critical** |
| Search results change between builds | Same query returns different images | **Critical** |
| Uses native `<img>` not Astro `<Image />` | No optimization, no width/height enforcement | **High** |
| No rate limiting | Can hit Unsplash API limits during batch builds | **High** |
| API failures break build or show placeholder | Unreliable production builds | **High** |

### Root Cause

The fundamental architecture is flawed for production use. Images should be:
1. Downloaded locally during development/setup
2. Stored in `src/assets/images/`
3. Referenced via Astro's `<Image />` component

Instead, this tool:
1. Searches Unsplash on every build
2. Uses first search result (non-deterministic)
3. Embeds remote Unsplash URLs in output
4. Uses native `<img>` tags

---

## File Analysis

### `/src/index.ts`

**Status: Problematic Architecture**

```typescript
export async function searchUnsplashImages(
  query: string,
  perPage: number = 10,
  accessKey?: string
): Promise<UnsplashPhoto[]> {
  const client = new UnsplashClient({ accessKey });
  const result = await client.searchPhotos(query, { perPage });
  return result.results;  // Returns remote URLs, not local files
}
```

**Issues:**

1. **Non-deterministic results** - Same query can return different images on different builds:
   ```typescript
   // Build 1: Returns photo ID "abc123"
   // Build 2: Returns photo ID "xyz789" (Unsplash updated results)
   ```

2. **No caching mechanism** - Every build hits the API:
   ```typescript
   // 100 images × 3 builds = 300 API calls
   // Unsplash free tier: 50 requests/hour
   ```

3. **No download functionality** - Returns URLs only:
   ```typescript
   return result.results;  // Just URLs, nothing saved locally
   ```

4. **Parallel requests without rate limiting** (Line 149-156):
   ```typescript
   await Promise.all(
     queries.map(async (query) => {
       const searchResult = await client.searchPhotos(query, { perPage });
       // No delay between requests - will hit rate limits
     })
   );
   ```

---

### `/components/UnsplashImage.astro`

**Status: Critical Issues**

```astro
<img
  src={imageUrl}           <!-- Remote Unsplash URL -->
  alt={imageAlt}
  width={width}
  height={height}
  loading={loading}
  class="unsplash-image"
/>
```

**Issues:**

1. **Uses native `<img>` not Astro `<Image />`**
   - No automatic optimization
   - No format conversion (WebP, AVIF)
   - No responsive srcset generation
   - No build-time dimension validation

2. **Remote URL dependency**
   ```typescript
   imageUrl = photo.urls.regular;  // External URL
   // If Unsplash is slow/down, site loads slowly/breaks
   ```

3. **First result selection**
   ```typescript
   const photos = await searchUnsplashImages(query, 1, accessKey);
   if (photos.length > 0) {
     const photo = photos[0];  // Always first result - may not be best
   }
   ```

4. **Placeholder fallback exposes failure**
   ```typescript
   imageUrl = `https://via.placeholder.com/${width}x${height}?text=${encodeURIComponent(query)}`;
   // Users see "Loading..." placeholder in production if API fails
   ```

5. **Width/height are CSS hints only**
   ```typescript
   width={width}   // Just attributes, no actual image resizing
   height={height} // Actual image may be 4000x3000px
   ```

---

### `/components/UnsplashGallery.astro`

**Status: Same Issues + More**

```astro
<img
  src={photo.urls.small}  <!-- Remote URL -->
  alt={photo.alt_description || photo.description || query}
  loading="lazy"
  <!-- No width/height! CLS issues -->
/>
```

**Additional Issues:**

1. **No width/height attributes** - Causes Cumulative Layout Shift (CLS)

2. **Empty gallery on failure**
   ```typescript
   let photos = [];
   try {
     photos = await searchUnsplashImages(query, count, accessKey);
   } catch (error) {
     console.error('Failed to fetch Unsplash gallery:', error);
     // photos stays empty - gallery shows nothing
   }
   ```

---

## Why This Causes Cross-Repo Issues

### Connection to "FIXING IMAGES" Commits

| Observed Pattern | How This Integration Causes It |
|-----------------|-------------------------------|
| "fix image loading" | Remote URLs fail, need local fallback |
| "wrong image displayed" | Search results changed between builds |
| Images suddenly different | Unsplash algorithm updated rankings |
| "use imageKey instead of query" | Trying to pin specific images |
| Manifest.json hotspot | Attempts to cache/track correct images |

### The Cycle of Image Fixes

1. Developer uses `<UnsplashImage query="office" />`
2. Build succeeds, image looks good
3. Next week, rebuild - different image appears
4. Developer commits "fix: update office image"
5. Repeat forever

### Why `manifest.json` Becomes a Hotspot

Teams likely created manifest files to:
- Pin specific Unsplash photo IDs
- Cache which query returned which image
- Map image keys to specific photos

This is a **workaround for the fundamental problem** - the integration doesn't provide deterministic, local images.

---

## Recommendations

### Option 1: Deprecate This Integration (Recommended)

Replace with a two-phase approach:

**Phase 1: Fetch/Download (Development)**
```bash
# Use image-studio or similar CLI
image-studio fetch landscaping -o src/assets/images/photos/
```

**Phase 2: Use Local Images (Build)**
```astro
---
import { Image } from 'astro:assets';
import heroImage from '../assets/images/photos/landscaping_hero.jpg';
---
<Image src={heroImage} alt="Landscaping service" width={1200} />
```

### Option 2: Add Download Mode (Major Rewrite)

Add functionality to download images locally:

```typescript
// New function
export async function downloadUnsplashImage(
  query: string,
  outputDir: string,
  filename: string
): Promise<string> {
  const photos = await searchUnsplashImages(query, 1);
  if (photos.length === 0) throw new Error('No images found');

  const photo = photos[0];
  const response = await fetch(photo.urls.regular);
  const buffer = await response.arrayBuffer();

  const filepath = path.join(outputDir, `${filename}.jpg`);
  await fs.writeFile(filepath, Buffer.from(buffer));

  return filepath;
}
```

Then update components to use local files:

```astro
---
import { Image } from 'astro:assets';
// Reference downloaded image
const images = import.meta.glob('../assets/images/photos/*.jpg');
const heroImage = images[`../assets/images/photos/${imageKey}.jpg`];
---
<Image src={heroImage} alt={alt} width={1200} />
```

### Option 3: Add Caching Layer (Minimum Fix)

At minimum, add a caching layer to prevent different images on each build:

```typescript
// cache.json - tracks query → photo ID mappings
{
  "office modern": "photo_id_abc123",
  "team meeting": "photo_id_xyz789"
}

export async function getCachedOrFetchImage(query: string): Promise<UnsplashPhoto> {
  const cache = loadCache();

  if (cache[query]) {
    // Return specific photo by ID
    return client.getPhoto(cache[query]);
  }

  // First time - search and cache
  const results = await searchUnsplashImages(query, 1);
  if (results.length > 0) {
    cache[query] = results[0].id;
    saveCache(cache);
    return results[0];
  }
}
```

---

## Comparison: Current vs Recommended Architecture

### Current Architecture (Problematic)

```
Build Time:
  Component → Unsplash API → Remote URL in HTML

Runtime:
  Browser → Unsplash CDN → Display Image
```

**Problems:**
- External dependency at build time
- External dependency at runtime
- Non-deterministic results
- No optimization
- Rate limiting issues

### Recommended Architecture

```
Development Time:
  CLI Tool → Unsplash API → Download to src/assets/

Build Time:
  Component → Local File → Astro Optimization → Optimized output

Runtime:
  Browser → Your CDN → Display Optimized Image
```

**Benefits:**
- Deterministic builds
- Full Astro optimization (WebP, srcset, lazy loading)
- No runtime external dependency
- Works offline
- No rate limiting at build time

---

## Action Items

### Immediate (Stop the Bleeding)

1. **Document the non-deterministic behavior** in README
2. **Add rate limiting** to prevent API bans:
   ```typescript
   const delay = (ms: number) => new Promise(r => setTimeout(r, ms));

   for (const query of queries) {
     results[query] = await client.searchPhotos(query);
     await delay(100); // 100ms between requests
   }
   ```

### Short-term (Stabilize)

1. **Add photo ID pinning** - allow specifying exact photo ID:
   ```astro
   <UnsplashImage photoId="abc123" />  <!-- Deterministic -->
   ```

2. **Add build-time caching** - cache query→ID mappings

### Long-term (Fix Properly)

1. **Deprecate runtime fetching** - move to download-first model
2. **Create migration guide** - help users move to local images
3. **Integrate with image-studio** - use for download, this for components

---

## Migration Path for Existing Projects

### Step 1: Audit Current Usage

```bash
# Find all UnsplashImage/UnsplashGallery usage
grep -r "UnsplashImage\|UnsplashGallery" src/
```

### Step 2: Download Images Locally

```bash
# For each query found, download with image-studio
image-studio fetch "office modern" --save-as hero
image-studio fetch "team meeting" --save-as team
```

### Step 3: Replace Components

Before:
```astro
<UnsplashImage query="office modern" width={1200} />
```

After:
```astro
---
import { Image } from 'astro:assets';
import heroImage from '../assets/images/photos/hero.jpg';
---
<Image src={heroImage} alt="Modern office" width={1200} />
```

### Step 4: Remove Integration

```bash
npm uninstall astro-unsplash-integration
```

---

## Summary

**This integration's runtime-fetch architecture is fundamentally incompatible with stable, deterministic builds.** It should either be:

1. **Deprecated** in favor of download-first tools (recommended)
2. **Rewritten** to download images locally during development
3. **Enhanced** with caching to at least provide determinism

The high rate of image-related fixes across repositories (40%+) is directly explained by this integration's behavior of returning potentially different images on each build.

---

*Audit completed: January 2026*
*Package version: 1.0.0*
