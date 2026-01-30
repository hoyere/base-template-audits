# Image Studio Audit Report

> Audit of the `unsplash-image-fetcher` / `image-studio` tool
> Date: January 2026
> Context: Cross-repo analysis identified images as #1 problem (40%+ of issues)

---

## Executive Summary

**Overall Assessment: Solid Foundation with Key Gaps**

The Image Studio tool is well-architected with good TypeScript types, intelligent image selection, and multiple interfaces (CLI, API, Astro integration). However, several issues may contribute to the image problems identified in the cross-repo analysis.

### Critical Issues
1. **Inconsistent path format** - `localPath` stores `~/assets/images/photos/` which doesn't match actual filesystem paths
2. **No image dimension validation** - Downloaded images have no width/height constraints
3. **Temporary replacement only** - Toolbar integration doesn't persist changes

### Strengths
1. Correct default output directory (`./src/assets/images/photos`)
2. No `manifest.json` pattern (aligned with recommendations)
3. Automatic `ATTRIBUTION.md` generation
4. Intelligent image scoring for dark background suitability
5. Rate limiting built-in

---

## File-by-File Analysis

### `/src/types.ts`

**Status: Good**

Well-structured TypeScript interfaces covering:
- Unsplash API responses
- Search options with proper union types
- Generated image metadata
- Unified `ImageAsset` type for cross-source compatibility

**Issue Found:**
```typescript
export interface UnsplashImageMetadata {
  localPath: string;  // Stores ~/assets/images/photos/filename.jpg
  // But actual file is at outputDir/filename.jpg
}
```

The `localPath` field stores a hardcoded placeholder path that may not match the actual project structure.

---

### `/src/fetcher.ts`

**Status: Needs Fixes**

#### Issues Identified:

**1. Hardcoded localPath (Line 109)**
```typescript
localPath: `~/assets/images/photos/${localFileName}`,
```
This path format:
- Uses `~` which isn't a valid path on all systems
- Assumes a specific project structure
- Doesn't match the actual `outputDir` parameter

**Recommendation:** Use relative path from project root or store actual path:
```typescript
localPath: path.relative(process.cwd(), fullPath),
// or
localPath: fullPath,
```

**2. No image dimension validation**
The fetcher downloads images at their full `regular` size (1080px width typically) but doesn't:
- Allow specifying desired dimensions
- Track/store actual downloaded dimensions
- Offer resize options

**3. Filename sanitization could break matching**
```typescript
const sanitizedName = saveAs.replace(/[^a-z0-9-_]/gi, '-');
```
If `saveAs` is `hero section`, it becomes `hero-section`. This works but isn't documented.

**4. Silent failure on image exists**
```typescript
if (fs.existsSync(fullPath)) {
  if (this.verbose) console.log(`⏭️  Image "${saveAs}" already exists`);
  return null;  // Returns null for both "exists" and "failed"
}
```
Callers can't distinguish between "skipped because exists" vs "failed to fetch".

#### Strengths:

**Intelligent Image Selection (Lines 172-188)**
```typescript
private selectBestImage(images: UnsplashPhoto[]): UnsplashPhoto | null {
  const scoredImages = images.map(image => {
    const luminance = calculateLuminance(image.color || '#888888');
    const colorInfo = estimateDominantColor(image.color || '#888888');
    const score = (1 - luminance) * 0.5 + colorInfo.suitability * 0.5;
    return { image, score };
  });
  // Prefers darker images with suitable colors for text overlay
}
```
This is excellent for hero images where text readability matters.

---

### `/src/generator.ts`

**Status: Good with Minor Issues**

**Same localPath issue (Line 96)**
```typescript
localPath: `~/assets/images/photos/${filename}`,
```

**Strengths:**
- Model validation and size constraints
- GPT-4 Vision integration for reference-based generation
- Proper error handling with verbose mode
- MIME type detection

---

### `/src/analyzer.ts`

**Status: Good**

Clean utility functions for:
- Luminance calculation (ITU-R BT.709 standard)
- Dominant color estimation
- Image scoring for dark background suitability

**Note:** Uses deprecated `substr` - should use `substring`:
```typescript
const r = parseInt(fullHex.substr(0, 2), 16);  // Line 25
// Should be:
const r = parseInt(fullHex.substring(0, 2), 16);
```

---

### `/src/cli.ts`

**Status: Good**

Well-structured CLI with:
- Multiple commands (fetch, generate, reference, server)
- Environment file discovery (searches parent directories)
- Proper argument parsing
- Legacy mode support

**Default output is correct:**
```typescript
outputDir: './src/assets/images/photos'  // Line 65
```

---

### `/src/server/api.ts`

**Status: Good with Security Note**

**CORS Configuration (Lines 88-90)**
```typescript
res.setHeader('Access-Control-Allow-Origin', '*');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
```
Wide-open CORS is fine for dev server but should be documented as dev-only.

**Same localPath issue in handleListImages (Line 331)**
```typescript
path: `~/assets/images/photos/${file}`,
```

---

### `/astro-integration/index.ts`

**Status: Good**

Clean Astro integration that:
- Registers dev toolbar app
- Injects Shift+Right-click handler via middleware
- Properly handles HTML content type detection

---

### `/astro-integration/toolbar-app.ts`

**Status: Needs Improvement**

**Critical Issue: Temporary Replacement Only**

```typescript
function useImage(url: string) {
  if (currentImage?.element) {
    window.dispatchEvent(new CustomEvent('image-studio:replace', {
      detail: { originalSrc: currentImage.src, newSrc: url, element: currentImage.element }
    }));
    // Shows toast: "Image replaced! (Note: This is temporary - download to keep)"
  }
}
```

The toolbar allows:
1. Searching/generating images
2. "Using" them (visual preview only)
3. But does NOT download to local project

**This is likely a major source of image issues** - users think they've replaced an image but it's only temporary.

**Recommendation:** Add a "Download & Replace" button that:
1. Downloads image to `outputDir`
2. Returns the new local path
3. Optionally updates source files

---

### `/config/default-queries.json`

**Status: Good**

Sensible default queries for common business types:
- common (hero, about, contact, 404)
- attorney, automobile, carpenter, handyman, landscaping, roofer, welding

---

## Summary of Issues

### Critical (Likely Contributing to Cross-Repo Problems)

| Issue | File(s) | Impact |
|-------|---------|--------|
| Hardcoded `~/assets/images/photos/` path | fetcher.ts:109, generator.ts:96, api.ts:331 | Path doesn't match actual location |
| Toolbar replacement is temporary | toolbar-app.ts:236 | Users think images are saved when they're not |
| No distinction between "exists" and "failed" | fetcher.ts:79-82 | Silent failures confuse batch operations |

### Medium

| Issue | File(s) | Impact |
|-------|---------|--------|
| No image dimension options | fetcher.ts | Can't request specific sizes |
| Uses deprecated `substr` | analyzer.ts:25-26 | Minor, but should fix |
| Wide-open CORS | api.ts:88 | Security (dev-only so acceptable) |

### Low

| Issue | File(s) | Impact |
|-------|---------|--------|
| No Astro Image integration docs | README.md | Users may not use optimized `<Image />` |
| No content collection integration | N/A | Missing opportunity for type-safe image refs |

---

## Recommendations

### 1. Fix localPath Storage (Critical)

**Current:**
```typescript
localPath: `~/assets/images/photos/${localFileName}`,
```

**Option A - Store relative path:**
```typescript
localPath: path.relative(process.cwd(), fullPath),
// Result: "src/assets/images/photos/hero.jpg"
```

**Option B - Make configurable:**
```typescript
// In types.ts
interface FetcherOptions {
  localPathPrefix?: string;  // Default: "~/assets/images/photos/"
}

// In fetcher.ts
localPath: `${this.localPathPrefix}${localFileName}`,
```

### 2. Add Persistent Download to Toolbar (Critical)

Add a "Download & Use" button that:
```typescript
async function downloadAndUse(url: string, filename: string) {
  // 1. Call /api/unsplash/download or save generated image
  const response = await fetch(`${API_BASE}/api/save`, {
    method: 'POST',
    body: JSON.stringify({ url, saveAs: filename })
  });

  // 2. Get the local path
  const { localPath } = await response.json();

  // 3. Show success with actual path
  toast(`Downloaded to ${localPath}`);
}
```

### 3. Add Return Type for "Already Exists" (Medium)

```typescript
interface FetchResult {
  status: 'downloaded' | 'exists' | 'failed';
  metadata?: UnsplashImageMetadata;
  error?: string;
}

async fetchImage(query: string, saveAs: string): Promise<FetchResult> {
  if (fs.existsSync(fullPath)) {
    return { status: 'exists', metadata: existingMetadata };
  }
  // ...
}
```

### 4. Add Image Dimension Options (Medium)

```typescript
interface FetchOptions {
  size?: 'raw' | 'full' | 'regular' | 'small' | 'thumb';
  maxWidth?: number;
  maxHeight?: number;
}
```

### 5. Add Astro Image Integration Docs (Low)

Add to README:
```markdown
## Using with Astro Image Component

Images are saved to `src/assets/images/photos/` for optimal use with Astro's `<Image />`:

```astro
---
import { Image } from 'astro:assets';
import heroImage from '../assets/images/photos/hero.jpg';
---

<Image src={heroImage} alt="Hero" width={1200} />
```
```

### 6. Fix Deprecated substr (Low)

In `analyzer.ts`:
```typescript
// Before
const r = parseInt(fullHex.substr(0, 2), 16);
const g = parseInt(fullHex.substr(2, 2), 16);
const b = parseInt(fullHex.substr(4, 2), 16);

// After
const r = parseInt(fullHex.substring(0, 2), 16);
const g = parseInt(fullHex.substring(2, 4), 16);
const b = parseInt(fullHex.substring(4, 6), 16);
```

---

## Connection to Cross-Repo Image Problems

Based on the cross-repo analysis finding that **images are the #1 problem (40%+ of issues)**, here's how this tool may be contributing:

| Cross-Repo Finding | Image Studio Connection |
|-------------------|------------------------|
| "fix image loading - use imageKey instead of query" | `localPath` uses placeholder path that doesn't match actual location |
| "FIXING IMAGES" commits | Toolbar replacement is temporary - users must manually download |
| Image path resolution issues | `~/assets/images/photos/` prefix may confuse path resolution |
| Missing images | Silent skip when image exists could hide failures |

**The most likely cause:** When users use the dev toolbar to "replace" images, they see the change visually but the image isn't actually saved. When they deploy or restart, the original image returns, leading to "fix image" commits.

---

## Verification Checklist

After fixes, verify:

- [ ] `localPath` in metadata matches actual filesystem location
- [ ] Toolbar has "Download & Keep" option that persists
- [ ] Batch fetch clearly reports exists/downloaded/failed counts
- [ ] Images download to `src/assets/images/photos/` (not `public/`)
- [ ] README documents Astro `<Image />` integration
- [ ] No deprecated `substr` calls

---

## Conclusion

Image Studio is a well-designed tool with the right architecture. The issues identified are relatively small fixes that could significantly reduce the image-related problems seen across the template repositories. The most impactful fix is making the toolbar integration persist downloads rather than just preview.

Priority order:
1. **Toolbar persistent download** - Highest impact
2. **Fix localPath format** - Prevents path confusion
3. **Better fetch result types** - Clearer debugging
4. **Documentation** - Prevent misuse

---

*Audit completed: January 2026*
*Tool version audited: 2.0.0*
