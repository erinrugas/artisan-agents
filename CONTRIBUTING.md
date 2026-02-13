# Contributing

Thanks for helping improve Artisan Agents.

## How to contribute
- Keep changes focused and tied to a clear outcome.
- Keep agents and skills reusable across different projects.
- Avoid hard-coding company/product-specific assumptions in templates.
- Update role-specific specs when role behavior changes.

## Adding a new agent
1. Create a new file in `agents/` with YAML frontmatter.
2. Include `specs/specs.md` plus one role-specific spec file.

```yaml
context_files:
  - specs/specs.md
  - specs/<role-spec>.md
```

3. Keep the role description short and explicit.
4. Prefer framework-agnostic guidance unless intentionally stack-specific.

## Adding a new skill
1. Create `skills/<skill-name>/SKILL.md`.
2. Use clear `name` and `description` frontmatter fields.
3. Keep workflow steps concise and deterministic where needed.
4. Do not include project-private data or environment-specific secrets.

## Testing
- Run script checks before opening PRs:
  - `sh -n install-agents.sh`
  - `shellcheck install-agents.sh` (if installed)
- Smoke test installer in a temp folder and verify `agents/`, `specs/`, and `skills/` are copied.

## License
By contributing, you agree that your contributions are licensed under the MIT License.
