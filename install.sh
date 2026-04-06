#!/bin/bash
# /fp — First Principles Thinking for Software Engineering
# One-liner: curl -sL https://raw.githubusercontent.com/v1r3n/first-principles-skills/main/install.sh | bash

set -e

REPO_URL="https://github.com/v1r3n/first-principles-skills/archive/main.tar.gz"
TMP_DIR=$(mktemp -d)
INSTALLED=()
MANUAL=()

echo ""
echo "  /fp — First Principles Thinking for Software Engineering"
echo "  ========================================================="
echo ""
echo "  Downloading..."

curl -sL "$REPO_URL" | tar xz -C "$TMP_DIR"
SRC="$TMP_DIR/first-principles-skills-main"

# Each skill needs its own directory under ~/.claude/skills/ (or equivalent)
# plus a copy of the shared references so relative links resolve correctly.
install_skill() {
    local dest_root="$1"
    local mode="$2"
    local skill_dir="$dest_root/fp-$mode"

    mkdir -p "$skill_dir/references"
    cp "$SRC/skills/$mode/SKILL.md" "$skill_dir/"
    cp "$SRC/skills/shared/framework.md" "$skill_dir/references/"
    cp "$SRC/skills/shared/principle-catalog.md" "$skill_dir/references/"
    cp "$SRC/skills/shared/output-templates.md" "$skill_dir/references/"

    # Fix relative paths: ../shared/ → references/
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's|\.\./shared/|references/|g' "$skill_dir/SKILL.md"
    else
        sed -i 's|\.\./shared/|references/|g' "$skill_dir/SKILL.md"
    fi
}

install_all_skills() {
    local dest_root="$1"
    for mode in design architecture plan code; do
        install_skill "$dest_root" "$mode"
    done
}

# ── Claude Code ──────────────────────────────────────────────
if command -v claude &>/dev/null || [ -d "$HOME/.claude" ]; then
    echo "  ✓ Claude Code detected"
    install_all_skills "$HOME/.claude/skills"
    INSTALLED+=("Claude Code    → ~/.claude/skills/fp-*/        invoke: /fp-design, /fp-architecture, /fp-plan, /fp-code")
fi

# ── Codex CLI (OpenAI) ──────────────────────────────────────
if command -v codex &>/dev/null || [ -d "$HOME/.codex" ]; then
    echo "  ✓ Codex CLI detected"
    install_all_skills "$HOME/.codex/skills"
    INSTALLED+=("Codex CLI      → ~/.codex/skills/fp-*/")
fi

# ── OpenCode ─────────────────────────────────────────────────
if command -v opencode &>/dev/null || [ -d "$HOME/.config/opencode" ]; then
    echo "  ✓ OpenCode detected"
    install_all_skills "$HOME/.config/opencode/skills"
    INSTALLED+=("OpenCode       → ~/.config/opencode/skills/fp-*/")
fi

# ── Cursor ───────────────────────────────────────────────────
if command -v cursor &>/dev/null || [ -d "$HOME/.cursor" ]; then
    echo "  ✓ Cursor detected"
    echo "    Cursor rules are project-level. Saving templates to ~/.cursor/fp/"
    mkdir -p "$HOME/.cursor/fp"
    for mode in design architecture plan code; do
        cp "$SRC/skills/$mode/SKILL.md" "$HOME/.cursor/fp/$mode.md"
    done
    cp "$SRC/skills/shared/"*.md "$HOME/.cursor/fp/"
    MANUAL+=("Cursor         → Copy files from ~/.cursor/fp/ to .cursor/rules/ in any project")
fi

# ── Windsurf ─────────────────────────────────────────────────
if command -v windsurf &>/dev/null || [ -d "$HOME/.codeium/windsurf" ]; then
    echo "  ✓ Windsurf detected"
    mkdir -p "$HOME/.codeium/windsurf/rules"
    for mode in design architecture plan code; do
        cp "$SRC/skills/$mode/SKILL.md" "$HOME/.codeium/windsurf/rules/fp-$mode.md"
    done
    INSTALLED+=("Windsurf       → ~/.codeium/windsurf/rules/fp-*.md")
fi

# ── Cleanup ──────────────────────────────────────────────────
rm -rf "$TMP_DIR"

# ── Summary ──────────────────────────────────────────────────
echo ""
if [ ${#INSTALLED[@]} -eq 0 ] && [ ${#MANUAL[@]} -eq 0 ]; then
    echo "  No supported agents detected."
    echo ""
    echo "  Supported agents:"
    echo "    • Claude Code   (full plugin experience)"
    echo "    • Codex CLI     (skill-based)"
    echo "    • OpenCode      (skill-based)"
    echo "    • Cursor        (project rules)"
    echo "    • Windsurf      (global rules)"
    echo ""
    echo "  Manual install: https://github.com/v1r3n/first-principles-skills#installation"
else
    if [ ${#INSTALLED[@]} -gt 0 ]; then
        echo "  Installed:"
        for i in "${INSTALLED[@]}"; do
            echo "    $i"
        done
    fi
    if [ ${#MANUAL[@]} -gt 0 ]; then
        echo ""
        echo "  Manual step needed:"
        for i in "${MANUAL[@]}"; do
            echo "    $i"
        done
    fi
fi

echo ""
echo "  Start a new session and try: /fp-design"
echo "  Your assumptions are about to get uncomfortable."
echo ""
