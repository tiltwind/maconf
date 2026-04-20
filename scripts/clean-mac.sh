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

# Clean a directory only if it hasn't been modified in N days (default 30)
clean_dir_if_stale() {
    local label="$1"
    local dir="$2"
    local days="${3:-30}"
    if [[ -d "$dir" ]]; then
        # Check if any file inside was modified within the last N days
        local recent
        recent=$(find "$dir" -type f -mtime -"$days" -print -quit 2>/dev/null)
        if [[ -n "$recent" ]]; then
            return  # Still in use, skip
        fi
        local size
        size=$(dir_size "$dir") || size=0
        size=${size:-0}
        if (( size > 0 )); then
            echo "  $label (stale ${days}d+): $(human_size "$size") — $dir"
            if [[ "$DRY_RUN" == false ]]; then
                rm -rf "$dir" 2>/dev/null || true
            fi
            TOTAL_FREED=$((TOTAL_FREED + size))
        fi
    fi
}

# Find and clean named directories recursively under a base path
clean_find_dirs() {
    local label="$1"
    local dirname="$2"
    local base="$3"
    local max_depth="${4:-6}"
    if [[ ! -d "$base" ]]; then
        return
    fi
    local tmpfile
    tmpfile=$(mktemp) || return
    find "$base" -maxdepth "$max_depth" -type d -name "$dirname" -not -path "*/.*" -print0 2>/dev/null > "$tmpfile"
    local total_size=0
    local count=0
    while IFS= read -r -d '' dir; do
        local size
        size=$(dir_size "$dir") || size=0
        size=${size:-0}
        if (( size > 0 )); then
            total_size=$((total_size + size))
            count=$((count + 1))
            if [[ "$DRY_RUN" == false ]]; then
                rm -rf "$dir" 2>/dev/null || true
            fi
        fi
    done < "$tmpfile"
    rm -f "$tmpfile"
    if (( total_size > 0 )); then
        echo "  $label: $(human_size "$total_size") ($count dirs)"
        TOTAL_FREED=$((TOTAL_FREED + total_size))
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

# Clean individual app caches only if not used in 30+ days
if [[ -d "$HOME/Library/Caches" ]]; then
    for cache_dir in "$HOME/Library/Caches"/*/; do
        [[ -d "$cache_dir" ]] || continue
        cache_name=$(basename "$cache_dir")
        clean_dir_if_stale "App cache [$cache_name]" "$cache_dir" 30
    done
fi
clean_dir_if_stale "User logs" "$HOME/Library/Logs" 30
clean_dir "Safari cache" "$HOME/Library/Safari/LocalStorage"
clean_dir "Composer cache" "$HOME/Library/Composer/cache"

# Clean .DS_Store files from home
if [[ "$DRY_RUN" == false ]]; then
    find "$HOME" -maxdepth 4 -name ".DS_Store" -delete 2>/dev/null || true
fi
echo "  .DS_Store files: cleaned (depth 4)"

echo ""

# ─── Xcode ─────────────────────────────────────────────────────────────────────

echo "🔨 Xcode"

XCODE_DEV="$HOME/Library/Developer/Xcode"
if [[ -d "$XCODE_DEV" ]] || [[ -d "$HOME/Library/Developer/CoreSimulator" ]]; then
    clean_dir "DerivedData" "$XCODE_DEV/DerivedData"
    clean_dir "Archives" "$XCODE_DEV/Archives"
    clean_dir "iOS DeviceSupport" "$XCODE_DEV/iOS DeviceSupport"
    clean_dir "watchOS DeviceSupport" "$XCODE_DEV/watchOS DeviceSupport"
    clean_dir "tvOS DeviceSupport" "$XCODE_DEV/tvOS DeviceSupport"
    clean_dir "visionOS DeviceSupport" "$XCODE_DEV/visionOS DeviceSupport"
    clean_dir "iOS Device Logs" "$XCODE_DEV/iOS Device Logs"
    clean_dir "Products" "$XCODE_DEV/Products"
    clean_dir "DocumentationCache" "$XCODE_DEV/DocumentationCache"
    clean_dir "UserData IB Support" "$XCODE_DEV/UserData/IB Support"
    clean_dir "UserData IDEEditorInteractivityHistory" "$XCODE_DEV/UserData/IDEEditorInteractivityHistory"
    clean_dir "Xcode app cache" "$HOME/Library/Caches/com.apple.dt.Xcode"
    clean_dir "SwiftPM cache" "$HOME/Library/Caches/org.swift.swiftpm"
    clean_dir "CoreSimulator caches" "$HOME/Library/Developer/CoreSimulator/Caches"
    clean_dir "CoreSimulator Temp" "$HOME/Library/Developer/CoreSimulator/Temp"

    # Delete unavailable / shutdown simulator devices
    if command -v xcrun &>/dev/null && [[ "$DRY_RUN" == false ]]; then
        xcrun simctl delete unavailable 2>/dev/null || true
    fi
else
    echo "  Xcode not installed, skipping."
fi

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

# Find and clean project-level Python venvs and caches
clean_find_dirs "venv (all projects)" "venv" "$HOME" 5
clean_find_dirs ".venv (all projects)" ".venv" "$HOME" 5
clean_find_dirs "__pycache__ (all projects)" "__pycache__" "$HOME" 8
clean_find_dirs ".eggs (all projects)" ".eggs" "$HOME" 6
clean_find_dirs "*.egg-info (all projects)" "*.egg-info" "$HOME" 6

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

# Find and clean all node_modules directories under $HOME
clean_find_dirs "node_modules (all projects)" "node_modules" "$HOME" 6

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

# ─── QQ ────────────────────────────────────────────────────────────────────────

echo "🐧 QQ"

QQ_WAS_RUNNING=false
QQ_CONTAINER="$HOME/Library/Containers/com.tencent.qq"
QQ_CONTAINER_NEW="$HOME/Library/Containers/com.tencent.QQ"
QQ_SUPPORT="$HOME/Library/Application Support/QQ"
if [[ -d "$QQ_CONTAINER" || -d "$QQ_CONTAINER_NEW" || -d "$QQ_SUPPORT" ]]; then
    if quit_app "QQ"; then
        QQ_WAS_RUNNING=true
    fi
    clean_dir "QQ system cache" "$HOME/Library/Caches/com.tencent.qq"
    clean_dir "QQ system cache (new)" "$HOME/Library/Caches/com.tencent.QQ"
    clean_dir "QQ container Caches" "$QQ_CONTAINER/Data/Library/Caches"
    clean_dir "QQ container Caches (new)" "$QQ_CONTAINER_NEW/Data/Library/Caches"
    # New QQ (NT) stores large media under Application Support
    if [[ -d "$QQ_SUPPORT" ]]; then
        clean_find_dirs "QQ nt_qq thumb" "thumb" "$QQ_SUPPORT" 8
        clean_find_dirs "QQ nt_qq temp" "temp" "$QQ_SUPPORT" 8
        clean_find_dirs "QQ nt_qq log" "log" "$QQ_SUPPORT" 6
    fi
else
    echo "  QQ not installed, skipping."
fi

echo ""

# ─── WeChat ────────────────────────────────────────────────────────────────────

echo "💬 WeChat"

WECHAT_WAS_RUNNING=false
WECHAT_CONTAINER="$HOME/Library/Containers/com.tencent.xinWeChat"
WECHAT_SUPPORT="$HOME/Library/Application Support/com.tencent.xinWeChat.WeChatAppEx"
WECHAT_SUPPORT_ALT="$HOME/Library/Application Support/WeChat"
if [[ -d "$WECHAT_CONTAINER" || -d "$WECHAT_SUPPORT" || -d "$WECHAT_SUPPORT_ALT" ]]; then
    if quit_app "WeChat"; then
        WECHAT_WAS_RUNNING=true
    fi
    if quit_app "微信"; then
        WECHAT_WAS_RUNNING=true
    fi
    clean_dir "WeChat system cache" "$HOME/Library/Caches/com.tencent.xinWeChat"
    clean_dir "WeChat container Caches" "$WECHAT_CONTAINER/Data/Library/Caches"
    clean_dir "WeChatAppEx cache" "$WECHAT_SUPPORT"

    # Chat media temp (safe: already-delivered cached media per account/session)
    if [[ -d "$WECHAT_CONTAINER/Data/Library/Application Support" ]]; then
        clean_find_dirs "WeChat MessageTemp" "MessageTemp" "$WECHAT_CONTAINER/Data/Library/Application Support" 8
        clean_find_dirs "WeChat CDNTemp" "CDNTemp" "$WECHAT_CONTAINER/Data/Library/Application Support" 8
        clean_find_dirs "WeChat wxacache" "wxacache" "$WECHAT_CONTAINER/Data/Library/Application Support" 8
        clean_find_dirs "WeChat WebKit cache" "WebKit" "$WECHAT_CONTAINER/Data/Library/Caches" 6
    fi
else
    echo "  WeChat not installed, skipping."
fi

echo ""

# ─── Feishu / Lark ─────────────────────────────────────────────────────────────

echo "🪶 Feishu / Lark"

LARK_WAS_RUNNING=false
LARK_SUPPORT="$HOME/Library/Application Support/Lark"
LARK_SUPPORT_CN="$HOME/Library/Application Support/Feishu"
LARK_SUPPORT_BD="$HOME/Library/Application Support/LarkShell"
if [[ -d "$LARK_SUPPORT" || -d "$LARK_SUPPORT_CN" || -d "$LARK_SUPPORT_BD" ]]; then
    # Try common process names for Lark/Feishu on macOS
    for proc in "Lark" "Feishu" "飞书" "LarkShell"; do
        if quit_app "$proc"; then
            LARK_WAS_RUNNING=true
        fi
    done

    for base in "$LARK_SUPPORT" "$LARK_SUPPORT_CN" "$LARK_SUPPORT_BD"; do
        [[ -d "$base" ]] || continue
        label=$(basename "$base")
        clean_dir "[$label] Cache" "$base/Cache"
        clean_dir "[$label] Code Cache" "$base/Code Cache"
        clean_dir "[$label] GPUCache" "$base/GPUCache"
        clean_dir "[$label] ShaderCache" "$base/ShaderCache"
        clean_dir "[$label] GrShaderCache" "$base/GrShaderCache"
        clean_dir "[$label] Service Worker/CacheStorage" "$base/Service Worker/CacheStorage"
        clean_dir "[$label] Service Worker/ScriptCache" "$base/Service Worker/ScriptCache"
        clean_dir "[$label] Crashpad" "$base/Crashpad"
        # Per-user sdk_storage media caches
        clean_find_dirs "[$label] sdk_storage image" "image" "$base" 6
        clean_find_dirs "[$label] sdk_storage video" "video" "$base" 6
        clean_find_dirs "[$label] sdk_storage file_cache" "file_cache" "$base" 6
        clean_find_dirs "[$label] log" "log" "$base" 6
    done

    clean_dir "Lark system cache" "$HOME/Library/Caches/com.electron.lark"
    clean_dir "Lark system cache (bd)" "$HOME/Library/Caches/com.bytedance.lark"
    clean_dir "Feishu system cache" "$HOME/Library/Caches/com.bytedance.feishu"
else
    echo "  Feishu/Lark not installed, skipping."
fi

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

# Remind about closed apps
if [[ "$CHROME_WAS_RUNNING" == true ]]; then
    echo ""
    echo "ℹ  Google Chrome was closed for cleaning. Restart it manually."
fi
if [[ "$FIREFOX_WAS_RUNNING" == true ]]; then
    echo ""
    echo "ℹ  Firefox was closed for cleaning. Restart it manually."
fi
if [[ "$QQ_WAS_RUNNING" == true ]]; then
    echo ""
    echo "ℹ  QQ was closed for cleaning. Restart it manually."
fi
if [[ "$WECHAT_WAS_RUNNING" == true ]]; then
    echo ""
    echo "ℹ  WeChat was closed for cleaning. Restart it manually."
fi
if [[ "$LARK_WAS_RUNNING" == true ]]; then
    echo ""
    echo "ℹ  Feishu/Lark was closed for cleaning. Restart it manually."
fi
