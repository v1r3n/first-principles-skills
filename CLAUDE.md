# First Principles Skills

## Project Structure
- `skills/` — Claude Code skill files (SKILL.md) consumed by AI assistants
- `skills/shared/` — Shared references (framework, principles, templates) used by all skills
- `docs/` — Human-readable methodology documentation
- `.claude-plugin/` — Plugin manifest for Claude marketplace

## Conventions
- Skills are written in imperative form (instructions FOR Claude, not documentation ABOUT the skill)
- Each SKILL.md must stay under 500 lines; use shared references for detailed content
- The principle catalog is a reference, not a checklist — skills draw from it selectively
- Plugin name is "fp"; invocation is /fp:design, /fp:architecture, /fp:plan, /fp:code

## Testing
- Test locally: `claude --plugin-dir /path/to/first-principles-skills`
- Verify each skill loads and responds to its trigger phrases
