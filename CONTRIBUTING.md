# Contributing

Thanks for helping improve Artisan Agents.

## How to contribute
- Use clear, minimal changes tied to a specific goal.
- Keep agent instructions general and reusable.
- Update `specs/specs.md` when standards change.
- Avoid project-specific assumptions in new agents.

## Adding a new agent
1) Create a new file in `agents/` with YAML frontmatter.
2) Reference the shared specs file:

```yaml
context_files:
  - specs/specs.md
```

3) Keep the role description short and specific.
4) Prefer platform-agnostic guidance unless the specs require otherwise.

## Testing
No automated tests currently. If you add scripts, document them in the README.

## License
By contributing, you agree that your contributions will be licensed under the MIT License.
