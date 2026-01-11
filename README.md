# Artisan Agents

Lead-level agent profiles and project specs for Laravel-focused AI coding workflows.

## Contents
- `agents/`: lead-level agent profiles
- `specs/`: reusable project specs template
- `install-agents.sh`: installer for common tool layouts

Included agents:
- lead-devops-engineer
- lead-product
- lead-qa-engineer
- lead-security
- lead-ui-designer
- tech-lead-fullstack

## Quick start
1) Clone the repo:

```sh
git clone https://github.com/erinrugas/artisan-agents
cd artisan-agents
chmod +x install-agents.sh
```

2) Or run via curl (no clone, latest release asset):

```sh
curl -fsSL https://github.com/erinrugas/artisan-agents/releases/latest/download/install-agents.sh | sh -s -- --dest /path/to/project --platform claude
```

3) Install into a project (interactive by default):

```sh
./install-agents.sh --dest /path/to/project --platform claude
./install-agents.sh
```

Tip: For a richer TUI experience, install `gum` and the installer will use it automatically.

To use release assets, create a release (or run the release workflow) so `install-agents.sh` is uploaded:

```sh
curl -fsSL https://github.com/erinrugas/artisan-agents/releases/latest/download/install-agents.sh | sh -s -- --dest /path/to/project --platform claude
```

## Installed structure
Example layout inside a project:

```
<project-root>/
  .claude/
    agents/
      lead-devops-engineer.md
      lead-product.md
      lead-qa-engineer.md
      lead-security.md
      lead-ui-designer.md
      tech-lead-fullstack.md
    specs/
      specs.md
    config.json
    mcp.json
```

4) Fill out the specs template:

```sh
$EDITOR /path/to/project/.claude/specs/specs.md
```

## Specs convention
Add the shared specs template to any new agent frontmatter:

```yaml
context_files:
  - specs/specs.md
```

## Specs template
Update `specs/specs.md` to match your project and keep it source-of-truth.

## Install script
Use `install-agents.sh` to copy agents/specs into a project:

```sh
./install-agents.sh --dest /path/to/project --platform claude
./install-agents.sh --dest /path/to/project --platform codex --model gpt-5
./install-agents.sh
```

## Supported platforms
- `claude` -> `.claude/agents` and `.claude/specs`
- `codex` -> `.codex/agents` and `.codex/specs`
- `opencode` -> `.opencode/agents` and `.opencode/specs`
- `cursor` -> `.cursor/agents` and `.cursor/specs`
- `agents` -> `.agents/agents` and `.agents/specs`

Adjust or extend in `install-agents.sh` if your tool expects a different layout.

## Config files
The installer also creates platform-local config files if they do not exist:
- `config.json` (paths + platform)
- `mcp.json` (MCP server list placeholder)

`config.json` defaults:
- `default_model` per platform: `claude-4.5-sonnet` (claude), `gpt-5` (codex), `gpt-4.1` (opencode/cursor)

Overrides:
- `--model <name>` to set `default_model`


## Optional alias
Add an alias so you can run the installer from anywhere (or accept the prompt during install):

```sh
alias artisan-agents="/path/to/artisan-agents/install-agents.sh"
```


## Contributing
Issues and PRs are welcome. Keep edits framework-agnostic unless the spec requires otherwise.

## License
MIT License. See `LICENSE`.
