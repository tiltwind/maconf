#!/bin/bash
#
# clean-mac.sh - Clean macOS caches and development dependency caches
#
# Usage:
#   ./clean-mac.sh          # Run all clean tasks
#   ./clean-mac.sh --dry-run # Show what would be cleaned without deleting
#

set -uo pipefail

DRY_RUN=false
TOTAL_FREED=0

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "=== DRY RUN MODE (no files will be deleted) ==="
    echo ""
fi

# Get directory size in KB (returns 0 if not exists or on error)
dir_size() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        du -sk "$dir" 2>/dev/null | awk '{print $1}' || echo 0
    else
        echo 0
    fi
}

human_size() {
    local kb=${1:-0}
    kb=${kb//[^0-9]/}
    kb=${kb:-0}
    if (( kb >= 1048576 )); then
        printf "%.1f GB" "$(echo "scale=1; $kb / 1048576" | bc)"
    elif (( kb >= 1024 )); then
        printf "%.1f MB" "$(echo "scale=1; $kb / 1024" | bc)"
    else
        printf "%d KB" "$kb"
    fi
}

clean_dir() {
    local label="$1"
    local dir="$2"
    if [[ -d "$dir" ]]; then
        local size
        size=$(dir_size "$dir") || size=0
        size=${size:-0}
        if (( size > 0 )); then
            echo "  $label: $(human_size "$size") — $dir"
            if [[ "$DRY_RUN" == false ]]; then
                rm -rf "$dir" 2>/dev/null || true
            fi
            TOTAL_FREED=$((TOTAL_FREED + size))
        fi
    fi
}

clean_files() {
    local label="$1"
    local pattern="$2"
    local dir="$3"
    if [[ -d "$dir" ]]; then
        local size
        size=$(find "$dir" -name "$pattern" -exec du -sk {} + 2>/dev/null | awk '{s+=$1} END {print s+0}') || size=0
        size=${size:-0}
        if (( size > 0 )); then
            echo "  $label: $(human_size "$size")"
            if [[ "$DRY_RUN" == false ]]; then
                find "$dir" -name "$pattern" -delete 2>/dev/null || true
            fi
            TOTAL_FREED=$((TOTAL_FREED + size))
        fi
    fi
}

# Quit an app by bundle name if it is running, wait for it to exit
quit_app() {
    local app_name="$1"
    if pgrep -xq "$app_name" 2>/dev/null; then
        echo "  Quitting $app_name ..."
        if [[ "$DRY_RUN" == false ]]; then
            osascript -e "tell application \"$app_name\" to quit" 2>/dev/null || true
            # Wait up to 10s for the process to exit
            local i=0
            while pgrep -xq "$app_name" 2>/dev/null && (( i < 20 )); do
                sleep 0.5
                i=$((i + 1))
            done
            if pgrep -xq "$app_name" 2>/dev/null; then
                echo "  ⚠ $app_name did not quit in time, force killing ..."
                killall "$app_name" 2>/dev/null || true
            fi
        fi
        return 0
    fi
    return 1
}

# Track whether we closed a browser so we can inform the user
CHROME_WAS_RUNNING=false
FIREFOX_WAS_RUNNING=false

# ─── macOS App Caches ──────────────────────────────────────────────────────────

echo "🧹 macOS App Caches"

clean_dir "User cache" "$HOME/Library/Caches"
clean_dir "User logs" "$HOME/Library/Logs"
clean_dir "Safari cache" "$HOME/Library/Safari/LocalStorage"
clean_dir "Xcode DerivedData" "$HOME/Library/Developer/Xcode/DerivedData"
clean_dir "Xcode Archives" "$HOME/Library/Developer/Xcode/Archives"
clean_dir "Xcode iOS DeviceSupport" "$HOME/Library/Developer/Xcode/iOS DeviceSupport"
clean_dir "CoreSimulator caches" "$HOME/Library/Developer/CoreSimulator/Caches"
clean_dir "Composer cache" "$HOME/Library/Composer/cache"

# Clean .DS_Store files from home
if [[ "$DRY_RUN" == false ]]; then
    find "$HOME" -maxdepth 4 -name ".DS_Store" -delete 2>/dev/null || true
fi
echo "  .DS_Store files: cleaned (depth 4)"

echo ""

# ─── Google Chrome ─────────────────────────────────────────────────────────────

echo "🌐 Google Chrome"

CHROME_SUPPORT="$HOME/Library/Application Support/Google/Chrome"
if [[ -d "$CHROME_SUPPORT" ]]; then
    # Chrome must be closed to safely clean its caches
    if quit_app "Google Chrome"; then
        CHROME_WAS_RUNNING=true
    fi

    # Per-profile caches and data
    for profile_dir in "$CHROME_SUPPORT/Default" "$CHROME_SUPPORT"/Profile\ *; do
        [[ -d "$profile_dir" ]] || continue
        profile_name=$(basename "$profile_dir")
        clean_dir "[$profile_name] Cache" "$profile_dir/Cache"
        clean_dir "[$profile_name] Code Cache" "$profile_dir/Code Cache"
        clean_dir "[$profile_name] GPUCache" "$profile_dir/GPUCache"
        clean_dir "[$profile_name] Service Worker/CacheStorage" "$profile_dir/Service Worker/CacheStorage"
        clean_dir "[$profile_name] Service Worker/ScriptCache" "$profile_dir/Service Worker/ScriptCache"
        clean_dir "[$profile_name] Application Cache" "$profile_dir/Application Cache"
        clean_dir "[$profile_name] Font Cache" "$profile_dir/Font Cache"
    done

    # Top-level caches
    clean_dir "ShaderCache" "$CHROME_SUPPORT/ShaderCache"
    clean_dir "GrShaderCache" "$CHROME_SUPPORT/GrShaderCache"
    clean_dir "Crashpad" "$CHROME_SUPPORT/Crashpad"
else
    echo "  Chrome not installed, skipping."
fi

echo ""

# ─── Firefox ───────────────────────────────────────────────────────────────────

echo "🦊 Firefox"

FIREFOX_PROFILES="$HOME/Library/Application Support/Firefox/Profiles"
if [[ -d "$FIREFOX_PROFILES" ]]; then
    # Firefox must be closed to safely clean its caches
    if quit_app "firefox"; then
        FIREFOX_WAS_RUNNING=true
    fi

    for profile_dir in "$FIREFOX_PROFILES"/*; do
        [[ -d "$profile_dir" ]] || continue
        profile_name=$(basename "$profile_dir")
        clean_dir "[$profile_name] cache2" "$profile_dir/cache2"
        clean_dir "[$profile_name] OfflineCache" "$profile_dir/OfflineCache"
        clean_dir "[$profile_name] startupCache" "$profile_dir/startupCache"
        clean_dir "[$profile_name] thumbnails" "$profile_dir/thumbnails"
        clean_dir "[$profile_name] shader-cache" "$profile_dir/shader-cache"
        clean_dir "[$profile_name] jumpListCache" "$profile_dir/jumpListCache"
    done
else
    echo "  Firefox not installed, skipping."
fi

# Also clean Firefox top-level caches
clean_dir "Firefox Caches" "$HOME/Library/Caches/Firefox"
clean_dir "Firefox Crash Reports" "$HOME/Library/Application Support/Firefox/Crash Reports"

echo ""

# ─── Go ────────────────────────────────────────────────────────────────────────

echo "🐹 Go"

GOPATH="${GOPATH:-$HOME/go}"
GOCACHE="${GOCACHE:-$HOME/Library/Caches/go-build}"
GOMODCACHE="${GOMODCACHE:-$GOPATH/pkg/mod}"

clean_dir "Module cache" "$GOMODCACHE"
clean_dir "Build cache" "$GOCACHE"

# Use `go clean` if available
if command -v go &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    go clean -cache 2>/dev/null || true
    go clean -modcache 2>/dev/null || true
    go clean -testcache 2>/dev/null || true
fi

echo ""

# ─── Python ────────────────────────────────────────────────────────────────────

echo "🐍 Python"

clean_dir "pip cache" "$HOME/Library/Caches/pip"
clean_dir "pip cache (alt)" "$HOME/.cache/pip"
clean_dir "pipenv cache" "$HOME/.cache/pipenv"
clean_dir "poetry cache" "$HOME/Library/Caches/pypoetry"
clean_dir "conda pkgs" "$HOME/.conda/pkgs"
clean_dir "conda cache" "$HOME/miniconda3/pkgs"
clean_dir "mypy cache" "$HOME/.mypy_cache"
clean_dir "ruff cache" "$HOME/.cache/ruff"

# virtualenvs
if [[ -d "$HOME/.local/share/virtualenvs" ]]; then
    clean_dir "pipenv virtualenvs" "$HOME/.local/share/virtualenvs"
fi

# Use pip cache purge if available
if command -v pip3 &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    pip3 cache purge 2>/dev/null || true
fi

echo ""

# ─── Node.js / npm ─────────────────────────────────────────────────────────────

echo "📦 Node.js / npm"

clean_dir "npm cache" "$HOME/.npm/_cacache"
clean_dir "npm logs" "$HOME/.npm/_logs"
clean_dir "yarn cache" "$HOME/Library/Caches/Yarn"
clean_dir "yarn cache (alt)" "$HOME/.cache/yarn"
clean_dir "pnpm store" "$HOME/Library/pnpm/store"
clean_dir "pnpm cache" "$HOME/.cache/pnpm"
clean_dir "bun cache" "$HOME/.bun/install/cache"

# Use npm/yarn/pnpm cache clean if available
if command -v npm &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    npm cache clean --force 2>/dev/null || true
fi
if command -v yarn &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    yarn cache clean 2>/dev/null || true
fi
if command -v pnpm &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    pnpm store prune 2>/dev/null || true
fi

echo ""

# ─── Rust ──────────────────────────────────────────────────────────────────────

echo "🦀 Rust"

clean_dir "Cargo registry cache" "$HOME/.cargo/registry/cache"
clean_dir "Cargo registry src" "$HOME/.cargo/registry/src"
clean_dir "Cargo git checkouts" "$HOME/.cargo/git/checkouts"
clean_dir "Cargo git db" "$HOME/.cargo/git/db"

# Use cargo-cache if available, otherwise manual clean
if command -v cargo-cache &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    cargo-cache --autoclean 2>/dev/null || true
elif command -v cargo &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    cargo cache --autoclean 2>/dev/null || true
fi

echo ""

# ─── Misc Dev Caches ──────────────────────────────────────────────────────────

echo "🗂  Misc Dev Caches"

clean_dir "Gradle cache" "$HOME/.gradle/caches"
clean_dir "Maven repo" "$HOME/.m2/repository"
clean_dir "CocoaPods cache" "$HOME/Library/Caches/CocoaPods"
clean_dir "Homebrew cache" "$HOME/Library/Caches/Homebrew"
clean_dir "Docker builder cache" "$HOME/Library/Containers/com.docker.docker/Data/cache"

# Homebrew cleanup
if command -v brew &>/dev/null && [[ "$DRY_RUN" == false ]]; then
    brew cleanup --prune=all 2>/dev/null || true
fi

echo ""

# ─── macOS System Caches (optional, safe) ──────────────────────────────────────

echo "🍎 macOS System (safe)"

clean_dir "Font caches" "$HOME/Library/Caches/com.apple.FontRegistry"
clean_dir "Quick Look cache" "$HOME/Library/Caches/com.apple.QuickLook.thumbnailcache"

echo ""

# ─── Summary ────────────────────────────────────────────────────────────────────

echo "════════════════════════════════════════════════"
if [[ "$DRY_RUN" == true ]]; then
    echo "  Total reclaimable: $(human_size "$TOTAL_FREED")"
    echo "  Run without --dry-run to actually clean."
else
    echo "  Total freed: ~$(human_size "$TOTAL_FREED")"
fi
echo "════════════════════════════════════════════════"

# Remind about closed browsers
if [[ "$CHROME_WAS_RUNNING" == true ]]; then
    echo ""
    echo "ℹ  Google Chrome was closed for cleaning. Restart it manually."
fi
if [[ "$FIREFOX_WAS_RUNNING" == true ]]; then
    echo ""
    echo "ℹ  Firefox was closed for cleaning. Restart it manually."
fi
