# Git History Audit Process

> Systematic analysis of git histories to identify patterns across template repositories
> Use this checklist for each repo, then compare findings

---

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      FOR EACH REPOSITORY                        │
├─────────────────────────────────────────────────────────────────┤
│  1. Setup & Clone                                               │
│  2. Generate Raw Data                                           │
│  3. Analyze Commit Patterns                                     │
│  4. Analyze File Churn                                          │
│  5. Categorize Changes                                          │
│  6. Document Findings                                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CROSS-REPO COMPARISON                        │
├─────────────────────────────────────────────────────────────────┤
│  7. Compare patterns across all repos                           │
│  8. Identify common issues                                      │
│  9. Update base template & audit docs                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Per-Repository Checklist

### Phase 1: Setup

**Repository:** ______________________
**Date Analyzed:** ______________________
**Total Commits:** ______________________
**Date Range:** ______________________ to ______________________

```bash
# Clone or navigate to repo
cd /path/to/repo

# Verify you're on main branch with full history
git checkout main
git pull

# Get basic stats
echo "Total commits: $(git rev-list --count HEAD)"
echo "First commit: $(git log --reverse --format="%ad" --date=short | head -1)"
echo "Last commit: $(git log -1 --format="%ad" --date=short)"
echo "Contributors: $(git shortlog -sn | wc -l)"
```

- [ ] Repository cloned/updated
- [ ] On main/master branch
- [ ] Full history available
- [ ] Basic stats recorded

---

### Phase 2: Generate Raw Data

Create an output directory for this repo's analysis:

```bash
REPO_NAME=$(basename $(pwd))
OUTPUT_DIR="../git-audit-data/${REPO_NAME}"
mkdir -p "$OUTPUT_DIR"
```

#### 2.1 Export Commit Log

```bash
# Full commit log with metadata
git log --pretty=format:"%H|%ad|%an|%s" --date=short > "$OUTPUT_DIR/commits_full.csv"

# Just messages for text analysis
git log --pretty=format:"%s" > "$OUTPUT_DIR/commit_messages.txt"

# Commits with file counts
git log --pretty=format:"%H|%ad|%s" --date=short --shortstat > "$OUTPUT_DIR/commits_with_stats.txt"
```

- [ ] `commits_full.csv` generated
- [ ] `commit_messages.txt` generated
- [ ] `commits_with_stats.txt` generated

#### 2.2 Export File Change Data

```bash
# All files ever changed (with frequency)
git log --pretty=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn > "$OUTPUT_DIR/file_churn.txt"

# Files changed per commit
git log --pretty=format:"COMMIT:%H|%s" --name-only > "$OUTPUT_DIR/files_per_commit.txt"
```

- [ ] `file_churn.txt` generated
- [ ] `files_per_commit.txt` generated

---

### Phase 3: Analyze Commit Patterns

#### 3.1 Commit Type Distribution

Run each command and record the count:

```bash
# Fix-related commits
FIX_COUNT=$(git log --oneline -i --grep="fix" | wc -l)
echo "Fix commits: $FIX_COUNT"

# Feature/Add commits
ADD_COUNT=$(git log --oneline -i --grep="add\|feat\|feature\|implement" | wc -l)
echo "Add/Feature commits: $ADD_COUNT"

# Update/Change commits
UPDATE_COUNT=$(git log --oneline -i --grep="update\|change\|modify\|adjust" | wc -l)
echo "Update commits: $UPDATE_COUNT"

# Refactor commits
REFACTOR_COUNT=$(git log --oneline -i --grep="refactor\|clean\|reorganize\|restructure" | wc -l)
echo "Refactor commits: $REFACTOR_COUNT"

# Style/Format commits
STYLE_COUNT=$(git log --oneline -i --grep="style\|format\|lint\|prettier" | wc -l)
echo "Style commits: $STYLE_COUNT"

# Remove/Delete commits
REMOVE_COUNT=$(git log --oneline -i --grep="remove\|delete\|drop" | wc -l)
echo "Remove commits: $REMOVE_COUNT"
```

**Record Results:**

| Type | Count | % of Total |
|------|-------|------------|
| Fix | | |
| Add/Feature | | |
| Update | | |
| Refactor | | |
| Style | | |
| Remove | | |
| Other | | |
| **Total** | | 100% |

- [ ] Commit types counted
- [ ] Percentages calculated

#### 3.2 Component-Specific Commits

Look for commits mentioning specific areas:

```bash
# By component area
echo "=== Component Mentions ==="
echo "Header: $(git log --oneline -i --grep="header" | wc -l)"
echo "Footer: $(git log --oneline -i --grep="footer" | wc -l)"
echo "Hero: $(git log --oneline -i --grep="hero" | wc -l)"
echo "Navigation/Nav: $(git log --oneline -i --grep="nav" | wc -l)"
echo "Image: $(git log --oneline -i --grep="image\|img\|photo" | wc -l)"
echo "Color/Theme: $(git log --oneline -i --grep="color\|theme\|style" | wc -l)"
echo "Layout: $(git log --oneline -i --grep="layout" | wc -l)"
echo "Content: $(git log --oneline -i --grep="content" | wc -l)"
echo "SEO: $(git log --oneline -i --grep="seo\|meta\|og:" | wc -l)"
echo "Mobile/Responsive: $(git log --oneline -i --grep="mobile\|responsive" | wc -l)"
echo "Form: $(git log --oneline -i --grep="form\|input\|contact" | wc -l)"
```

**Record Results:**

| Component | Commit Mentions |
|-----------|-----------------|
| Header | |
| Footer | |
| Hero | |
| Navigation | |
| Image | |
| Color/Theme | |
| Layout | |
| Content | |
| SEO | |
| Mobile/Responsive | |
| Form | |

- [ ] Component mentions recorded

#### 3.3 Keyword Analysis

Find the most common words in commit messages:

```bash
# Most common words (excluding common git words)
cat "$OUTPUT_DIR/commit_messages.txt" | \
  tr '[:upper:]' '[:lower:]' | \
  tr -cs '[:alpha:]' '\n' | \
  grep -v -E '^(the|a|an|to|for|of|in|on|and|or|is|it|this|that|with|from|as|be|by|at|co|authored|claude)$' | \
  sort | uniq -c | sort -rn | head -30 > "$OUTPUT_DIR/common_words.txt"

cat "$OUTPUT_DIR/common_words.txt"
```

**Top 10 Words:**

| Rank | Word | Count |
|------|------|-------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |
| 8 | | |
| 9 | | |
| 10 | | |

- [ ] Common words analyzed

---

### Phase 4: Analyze File Churn

#### 4.1 Most Changed Files

```bash
# Top 20 most frequently changed files
head -20 "$OUTPUT_DIR/file_churn.txt"
```

**Top 10 Hotspot Files:**

| Rank | Changes | File Path |
|------|---------|-----------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |
| 8 | | |
| 9 | | |
| 10 | | |

- [ ] Hotspot files identified

#### 4.2 Churn by Directory

```bash
# Changes by top-level directory
cat "$OUTPUT_DIR/file_churn.txt" | \
  awk '{print $2}' | \
  cut -d'/' -f1-2 | \
  sort | uniq -c | sort -rn | head -15
```

**Changes by Directory:**

| Changes | Directory |
|---------|-----------|
| | |
| | |
| | |
| | |
| | |

- [ ] Directory churn analyzed

#### 4.3 Churn by File Type

```bash
# Changes by file extension
cat "$OUTPUT_DIR/file_churn.txt" | \
  awk '{print $2}' | \
  sed 's/.*\.//' | \
  sort | uniq -c | sort -rn
```

**Changes by File Type:**

| Changes | Extension |
|---------|-----------|
| | .astro |
| | .ts |
| | .css |
| | .json |
| | .md |
| | .mjs |

- [ ] File type churn analyzed

---

### Phase 5: Categorize Changes

#### 5.1 Fix Commit Deep Dive

List all fix commits for manual review:

```bash
git log --oneline -i --grep="fix" > "$OUTPUT_DIR/fix_commits.txt"
cat "$OUTPUT_DIR/fix_commits.txt"
```

**Categorize Fix Types:**

| Fix Category | Count | Example Commit |
|--------------|-------|----------------|
| Styling/CSS | | |
| Image issues | | |
| Layout/spacing | | |
| Responsive/mobile | | |
| Content/typos | | |
| Build/config | | |
| TypeScript/types | | |
| Component props | | |
| SEO/meta | | |
| Other | | |

- [ ] Fix commits categorized

#### 5.2 Early vs Late Fixes

When in the project lifecycle did fixes occur?

```bash
# Get total commit count
TOTAL=$(git rev-list --count HEAD)
FIRST_HALF=$((TOTAL / 2))

# Fixes in first half of project
echo "Early fixes (first 50% of commits):"
git log --oneline -i --grep="fix" --skip=$FIRST_HALF | wc -l

# Fixes in second half
echo "Late fixes (last 50% of commits):"
git log --oneline -i --grep="fix" -n $FIRST_HALF | wc -l
```

**Timeline Distribution:**

| Period | Fix Count | Notes |
|--------|-----------|-------|
| First 25% | | |
| Second 25% | | |
| Third 25% | | |
| Final 25% | | |

- [ ] Timeline analysis complete

#### 5.3 Files Changed in Fix Commits

```bash
# What files are most often involved in fixes?
git log -i --grep="fix" --pretty=format: --name-only | \
  grep -v '^$' | sort | uniq -c | sort -rn | head -15 > "$OUTPUT_DIR/fix_files.txt"

cat "$OUTPUT_DIR/fix_files.txt"
```

**Most Fixed Files:**

| Fix Count | File |
|-----------|------|
| | |
| | |
| | |
| | |
| | |

- [ ] Fix file patterns identified

---

### Phase 6: Document Findings

#### 6.1 Summary Report

Create a summary for this repository:

```markdown
## Repository: [NAME]

### Quick Stats
- Total commits:
- Date range:
- Fix commit ratio: X%
- Most changed file:
- Most mentioned component:

### Key Patterns

**Top 3 Issue Areas:**
1.
2.
3.

**Most Unstable Files:**
1.
2.
3.

**Common Fix Types:**
1.
2.
3.

### Recommendations
-
-
-
```

- [ ] Summary report created
- [ ] Saved to `$OUTPUT_DIR/SUMMARY.md`

---

## Cross-Repository Comparison

After analyzing multiple repos, complete this section.

### Repositories Analyzed

| Repo | Commits | Fix % | Top Hotspot |
|------|---------|-------|-------------|
| | | | |
| | | | |
| | | | |
| | | | |

### Common Patterns Across Repos

#### Files That Are Frequently Changed Everywhere

| File/Pattern | Repo 1 | Repo 2 | Repo 3 | Total |
|--------------|--------|--------|--------|-------|
| Header.astro | | | | |
| Footer.astro | | | | |
| global.css | | | | |
| BaseLayout.astro | | | | |
| | | | | |

#### Common Fix Categories

| Fix Type | Repo 1 | Repo 2 | Repo 3 | Pattern? |
|----------|--------|--------|--------|----------|
| Image issues | | | | |
| Color/theme | | | | |
| Mobile/responsive | | | | |
| Layout spacing | | | | |
| Header stability | | | | |
| | | | | |

#### Component Instability Ranking

Rank components by how often they appear in fix commits across all repos:

1.
2.
3.
4.
5.

---

## Action Items

Based on cross-repo analysis, identify improvements for:

### Base Template Updates

| Issue Pattern | Frequency | Proposed Fix |
|---------------|-----------|--------------|
| | | |
| | | |
| | | |

### Audit Document Updates

| Audit Section | New Check Needed |
|---------------|------------------|
| v2_1 Code | |
| v2_2 Structure | |
| v2_3 Content | |
| v2_4 Theme | |

### New Checklist Items

Based on recurring issues, add these checks to the audit process:

- [ ]
- [ ]
- [ ]

---

## Quick Reference Commands

### One-Liner Reports

```bash
# Quick health check
echo "Commits: $(git rev-list --count HEAD) | Fixes: $(git log --oneline -i --grep=fix | wc -l) | Top file: $(git log --pretty=format: --name-only | sort | uniq -c | sort -rn | head -1)"

# Fix ratio
echo "scale=2; $(git log --oneline -i --grep=fix | wc -l) / $(git rev-list --count HEAD) * 100" | bc

# Recent fixes (last 30 days)
git log --since="30 days ago" --oneline -i --grep="fix"
```

### Export Everything Script

```bash
#!/bin/bash
# Save as: analyze_repo.sh

REPO_NAME=$(basename $(pwd))
OUTPUT_DIR="../git-audit-data/${REPO_NAME}"
mkdir -p "$OUTPUT_DIR"

echo "Analyzing: $REPO_NAME"
echo "Output: $OUTPUT_DIR"

# Basic stats
echo "=== Basic Stats ===" > "$OUTPUT_DIR/stats.txt"
echo "Total commits: $(git rev-list --count HEAD)" >> "$OUTPUT_DIR/stats.txt"
echo "Fix commits: $(git log --oneline -i --grep=fix | wc -l)" >> "$OUTPUT_DIR/stats.txt"
echo "Date range: $(git log --reverse --format='%ad' --date=short | head -1) to $(git log -1 --format='%ad' --date=short)" >> "$OUTPUT_DIR/stats.txt"

# Exports
git log --pretty=format:"%H|%ad|%s" --date=short > "$OUTPUT_DIR/commits.csv"
git log --pretty=format:"%s" > "$OUTPUT_DIR/messages.txt"
git log --pretty=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn > "$OUTPUT_DIR/file_churn.txt"
git log --oneline -i --grep="fix" > "$OUTPUT_DIR/fix_commits.txt"
git log -i --grep="fix" --pretty=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn > "$OUTPUT_DIR/fix_files.txt"

echo "Done! Check $OUTPUT_DIR"
```

---

## Checklist Summary

### Per-Repo Checklist

- [ ] Phase 1: Setup complete
- [ ] Phase 2: Raw data exported
- [ ] Phase 3: Commit patterns analyzed
- [ ] Phase 4: File churn analyzed
- [ ] Phase 5: Changes categorized
- [ ] Phase 6: Summary documented

### Cross-Repo Checklist

- [ ] All repos analyzed
- [ ] Patterns compared
- [ ] Common issues identified
- [ ] Base template updates listed
- [ ] Audit docs updates listed

---

*Git History Audit Process v1.0*
