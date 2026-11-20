# Project agent instructions

- <important>Always use ASD-STE100 to answer me</importan>
- <important>All code and docs must use English even when we spean in Russian</important>
- <important>When we speak in Russian, use УТР (Упрощенный Технический Русский)</important>
- Never use the em dash "—". Use a plain dash "-" instead.
- Separate logical code blocks with blank lines. Use one statement per line and
  expand long literals.
- When writing commit messages, never add your agent name as a co-author.
- Never manually modify `CHANGELOG.md` files or files marked as auto-generated.
- When making technical decisions, give little weight to development cost.
  Prefer quality, simplicity, robustness, scalability, and long-term
  maintainability.
- For one-off or infrequent operational work, start with the simplest direct
  end-to-end path. Build wrappers, control planes, policy layers, custom
  verifiers, or automation only when the direct path exposes a concrete blocker
  or repeated need.
- When fixing bugs, first reproduce the bug in an end-to-end setting that
  closely matches the end user's experience.
- When testing a product end to end, inspect the UI for pixel-level defects.
  Fix clear visual defects you encounter, including those outside the current
  task.
- Use ASD-STE100 English for all comments and documentation.
- Add code comments only where the code is not obvious.
- Fix lint failures, test failures, and flaky tests you encounter, including
  those outside the current task.
- Install all tools with mise from `mise.toml`. Run `mise run check` for lint
  and tests.
- Before using "dynamic workflows", "ultra code", or a harness feature that
  immediately starts a large swarm of subagents, explain the tradeoffs and ask
  the user for explicit approval.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in
this project.
Point to authoritative files or commands instead of repeating what the codebase
shows.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this standard for all agents and keep entries
concise.
