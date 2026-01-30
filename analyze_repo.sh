#!/bin/bash
# Git History Analysis Script
# Usage: ./analyze_repo.sh [repo_path]
# If no path provided, analyzes current directory

set -e

# Determine repo path
if [ -n "$1" ]; then
    cd "$1"
fi

REPO_NAME=$(basename $(pwd))
OUTPUT_DIR="../git-audit-data/${REPO_NAME}"
mkdir -p "$OUTPUT_DIR"

echo "=============================================="
echo "  Git History Analysis: $REPO_NAME"
echo "=============================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""

# Basic Stats
echo "📊 Gathering basic stats..."
TOTAL_COMMITS=$(git rev-list --count HEAD)
FIX_COMMITS=$(git log --oneline -i --grep="fix" | wc -l)
FIRST_DATE=$(git log --reverse --format="%ad" --date=short | head -1)
LAST_DATE=$(git log -1 --format="%ad" --date=short)
CONTRIBUTORS=$(git shortlog -sn | wc -l)

echo ""
echo "=== BASIC STATS ===" | tee "$OUTPUT_DIR/stats.txt"
echo "Repository: $REPO_NAME" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Total commits: $TOTAL_COMMITS" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Fix commits: $FIX_COMMITS ($(echo "scale=1; $FIX_COMMITS * 100 / $TOTAL_COMMITS" | bc)%)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Date range: $FIRST_DATE to $LAST_DATE" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Contributors: $CONTRIBUTORS" | tee -a "$OUTPUT_DIR/stats.txt"
echo ""

# Commit Type Counts
echo "📝 Analyzing commit types..."
echo "" | tee -a "$OUTPUT_DIR/stats.txt"
echo "=== COMMIT TYPES ===" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Fix: $(git log --oneline -i --grep='fix' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Add/Feature: $(git log --oneline -i --grep='add\|feat\|implement' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Update: $(git log --oneline -i --grep='update\|change\|modify' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Refactor: $(git log --oneline -i --grep='refactor\|clean\|reorganize' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Remove: $(git log --oneline -i --grep='remove\|delete' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Style: $(git log --oneline -i --grep='style\|format\|lint' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo ""

# Component Mentions
echo "🔧 Analyzing component mentions..."
echo "" | tee -a "$OUTPUT_DIR/stats.txt"
echo "=== COMPONENT MENTIONS ===" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Header: $(git log --oneline -i --grep='header' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Footer: $(git log --oneline -i --grep='footer' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Hero: $(git log --oneline -i --grep='hero' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Navigation: $(git log --oneline -i --grep='nav' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Image: $(git log --oneline -i --grep='image\|img\|photo' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Color/Theme: $(git log --oneline -i --grep='color\|theme' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Layout: $(git log --oneline -i --grep='layout' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "Mobile: $(git log --oneline -i --grep='mobile\|responsive' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo "SEO: $(git log --oneline -i --grep='seo\|meta' | wc -l)" | tee -a "$OUTPUT_DIR/stats.txt"
echo ""

# Export data files
echo "📁 Exporting data files..."

# Commit data
git log --pretty=format:"%H|%ad|%an|%s" --date=short > "$OUTPUT_DIR/commits_full.csv"
git log --pretty=format:"%s" > "$OUTPUT_DIR/commit_messages.txt"

# File churn
git log --pretty=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn > "$OUTPUT_DIR/file_churn.txt"

# Fix-specific
git log --oneline -i --grep="fix" > "$OUTPUT_DIR/fix_commits.txt"
git log -i --grep="fix" --pretty=format: --name-only | grep -v '^$' | sort | uniq -c | sort -rn > "$OUTPUT_DIR/fix_files.txt" 2>/dev/null || echo "No fix commits found" > "$OUTPUT_DIR/fix_files.txt"

# Common words in commit messages
cat "$OUTPUT_DIR/commit_messages.txt" | \
  tr '[:upper:]' '[:lower:]' | \
  tr -cs '[:alpha:]' '\n' | \
  grep -v -E '^(the|a|an|to|for|of|in|on|and|or|is|it|this|that|with|from|as|be|by|at|co|authored|claude|code)$' | \
  grep -E '.{3,}' | \
  sort | uniq -c | sort -rn | head -30 > "$OUTPUT_DIR/common_words.txt"

echo ""
echo "=== TOP 10 HOTSPOT FILES ===" | tee -a "$OUTPUT_DIR/stats.txt"
head -10 "$OUTPUT_DIR/file_churn.txt" | tee -a "$OUTPUT_DIR/stats.txt"
echo ""

echo "=== TOP 10 FIX-RELATED FILES ===" | tee -a "$OUTPUT_DIR/stats.txt"
head -10 "$OUTPUT_DIR/fix_files.txt" | tee -a "$OUTPUT_DIR/stats.txt"
echo ""

echo "=== TOP 15 COMMON WORDS ===" | tee -a "$OUTPUT_DIR/stats.txt"
head -15 "$OUTPUT_DIR/common_words.txt" | tee -a "$OUTPUT_DIR/stats.txt"
echo ""

# List recent fixes
echo "=== RECENT FIX COMMITS (last 20) ===" | tee -a "$OUTPUT_DIR/stats.txt"
head -20 "$OUTPUT_DIR/fix_commits.txt" | tee -a "$OUTPUT_DIR/stats.txt"

echo ""
echo "=============================================="
echo "  Analysis Complete!"
echo "=============================================="
echo ""
echo "Files generated in $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"
echo ""
echo "Key files:"
echo "  - stats.txt         : Summary statistics"
echo "  - commits_full.csv  : All commits with metadata"
echo "  - file_churn.txt    : Files sorted by change frequency"
echo "  - fix_commits.txt   : All fix-related commits"
echo "  - fix_files.txt     : Files most involved in fixes"
echo "  - common_words.txt  : Most common commit message words"
echo ""
