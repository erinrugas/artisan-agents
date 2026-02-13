# Artisan Agents

Open-source lead agents, role-specific specs, and reusable skills for project AI workflows.

## Contents
- `agents/`: lead-role and workflow agents
- `specs/`: shared and role-specific spec templates
- `skills/`: reusable workflow skills (`SKILL.md` per skill)
- `install-agents.sh`: installer for common tool layouts

## Included agents
- `tech-lead-fullstack`
- `lead-product`
- `lead-security`
- `lead-qa-engineer`
- `lead-devops-engineer`
- `lead-ui-designer`
- `git-workflow`

## Included skills
- `api-endpoint`
- `auth-debug`
- `db-reset`
- `git-branch`
- `git-commit`
- `git-pr`
- `git-sync`
- `pest-testing`
- `tenant-setup`
- `vue-component`

## Quick start
1. Clone the repo:

```sh
git clone https://github.com/erinrugas/artisan-agents
cd artisan-agents
chmod +x install-agents.sh
```

2. Or run via curl (latest release asset):

```sh
curl -fsSL https://github.com/erinrugas/artisan-agents/releases/latest/download/install-agents.sh | sh -s -- --dest /path/to/project --platform claude
```

3. Install into a project (interactive by default):

```sh
./install-agents.sh --dest /path/to/project --platform claude
./install-agents.sh
```

Tip: install `gum` for a richer TUI installer.

## Installed structure
Example layout inside a project:

```text
<project-root>/
  .claude/
    agents/
    specs/
      specs.md
      fullstack-spec.md
      product-spec.md
      security-spec.md
      qa-spec.md
      devops-spec.md
      ui-spec.md
      workflow-spec.md
    skills/
      <skill-name>/
        SKILL.md
    config.json
    mcp.json
```

## Dynamic spec model
`specs/specs.md` is shared by all agents. Each lead agent also loads its role-specific spec:
- `tech-lead-fullstack` -> `specs/fullstack-spec.md`
- `lead-product` -> `specs/product-spec.md`
- `lead-security` -> `specs/security-spec.md`
- `lead-qa-engineer` -> `specs/qa-spec.md`
- `lead-devops-engineer` -> `specs/devops-spec.md`
- `lead-ui-designer` -> `specs/ui-spec.md`
- `git-workflow` -> `specs/workflow-spec.md`

## Install script
Use `install-agents.sh` to copy agents/specs/skills into a project:

```sh
./install-agents.sh --dest /path/to/project --platform claude
./install-agents.sh --dest /path/to/project --platform codex --model gpt-5
./install-agents.sh
```

## Supported platforms
- `claude` -> `.claude/{agents,specs,skills}`
- `codex` -> `.codex/{agents,specs,skills}`
- `opencode` -> `.opencode/{agents,specs,skills}`
- `cursor` -> `.cursor/{agents,specs,skills}`
- `agents` -> `.agents/{agents,specs,skills}`

## Config files
Installer creates platform-local files if they do not exist:
- `config.json` (`agents_path`, `specs_path`, `skills_path`, platform, default model)
- `mcp.json` (MCP server list placeholder)

`default_model` per platform:
- `claude`: `claude-4.5-sonnet`
- `codex`: `gpt-5`
- `opencode`, `cursor`, `agents`: `gpt-4.1`

Override with:
- `--model <name>`

## Optional alias

```sh
alias artisan-agents="/path/to/artisan-agents/install-agents.sh"
```

## Contributing
Issues and PRs are welcome. Keep content reusable and project-agnostic.

## License
MIT License. See `LICENSE`.
