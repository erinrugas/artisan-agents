#!/usr/bin/env sh

# Usage: ./install-agents.sh [--dest <project_dir>] [--source <source_dir>] [--platform <name>] [--model <name>] [--interactive] [--non-interactive]

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR="$SCRIPT_DIR"
DEST_DIR="."
PLATFORM="claude"
DEFAULT_MODEL=""
INTERACTIVE=1

for p in "$HOME/.local/bin" /usr/local/bin /opt/homebrew/bin /usr/bin; do
  case ":$PATH:" in
    *":$p:"*) ;;
    *) PATH="$p:$PATH" ;;
  esac
done

if command -v gum >/dev/null 2>&1; then
  HAS_GUM=1
else
  HAS_GUM=0
fi

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET="$(printf '\033[0m')"
  C_BOLD="$(printf '\033[1m')"
  C_DIM="$(printf '\033[2m')"
  C_GREEN="$(printf '\033[32m')"
  C_YELLOW="$(printf '\033[33m')"
else
  C_RESET=""
  C_BOLD=""
  C_DIM=""
  C_GREEN=""
  C_YELLOW=""
fi

prompt_value() {
  prompt="$1"
  default="$2"
  if [ "$HAS_GUM" -eq 1 ]; then
    if [ -n "$default" ]; then
      result=$(gum input --prompt "$prompt " --value "$default") || result=""
    else
      result=$(gum input --prompt "$prompt ") || result=""
    fi
    if [ -n "$result" ] || [ -z "$default" ]; then
      printf "%s" "$result"
      return 0
    fi
    printf "%s" "$default"
    return 0
  fi
  if [ -n "$default" ]; then
    printf "%s%s%s [%s]: " "$C_BOLD" "$prompt" "$C_RESET" "$default" >&2
  else
    printf "%s%s%s: " "$C_BOLD" "$prompt" "$C_RESET" >&2
  fi
  read -r input
  if [ -n "$input" ]; then
    printf "%s" "$input"
  else
    printf "%s" "$default"
  fi
}

select_value() {
  prompt="$1"
  shift
  if [ "$HAS_GUM" -eq 1 ]; then
    result=$(gum choose --header "$prompt" "$@") || result=""
    if [ -n "$result" ]; then
      printf "%s" "$result"
      return 0
    fi
  fi
  while :; do
    i=1
    for opt in "$@"; do
      printf "  %d) %s\n" "$i" "$opt" >&2
      i=$((i + 1))
    done
    printf "%s%s%s [1]: " "$C_BOLD" "$prompt" "$C_RESET" >&2
    read -r choice
    [ -z "$choice" ] && choice=1
    case "$choice" in
      *[!0-9]*|"") ;;
      *)
        if [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
          j=1
          for opt in "$@"; do
            if [ "$j" -eq "$choice" ]; then
              printf "%s" "$opt"
              return 0
            fi
            j=$((j + 1))
          done
        fi
        ;;
    esac
    echo "${C_YELLOW}Invalid choice. Try again.${C_RESET}" >&2
  done
}

confirm_value() {
  prompt="$1"
  if [ "$HAS_GUM" -eq 1 ]; then
    if gum confirm "$prompt"; then
      return 0
    fi
    return 1
  fi
  printf "%s%s%s (Y/n): " "$C_BOLD" "$prompt" "$C_RESET" >&2
  read -r input
  case "$input" in
    n|N) return 1 ;;
    *) return 0 ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dest)
      DEST_DIR="$2"
      shift 2
      ;;
    --source)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --model)
      DEFAULT_MODEL="$2"
      shift 2
      ;;
    --interactive)
      INTERACTIVE=1
      shift 1
      ;;
    --non-interactive)
      INTERACTIVE=0
      shift 1
      ;;
    -h|--help)
      cat <<'USAGE'
Install artisan agents and specs into a project.

Options:
  --dest <project_dir>   Destination project root (default: current directory)
  --source <source_dir>  Source root containing agents/ and specs/ (default: script directory)
  --platform <name>      Platform: claude | codex | opencode | cursor | agents (default: claude)
  --model <name>         Override default model for config.json
  --interactive          Prompt for options (default)
  --non-interactive      Disable prompts and use flags only

Examples:
  ./install-agents.sh --dest /path/to/project --platform claude
  ./install-agents.sh --dest . --platform codex --model gpt-5
  ./install-agents.sh --interactive
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
 done

AGENTS_SRC="$SOURCE_DIR/agents"
SPECS_SRC="$SOURCE_DIR/specs"

if [ "$INTERACTIVE" -eq 1 ]; then
  if [ "$HAS_GUM" -eq 1 ]; then
    gum style --border normal --padding "1 2" --bold "Artisan Agents Installer"
  else
    cat <<'BANNER'
+----------------------------------+
|      Artisan Agents Installer    |
+----------------------------------+
BANNER
  fi

  if [ "$HAS_GUM" -eq 1 ]; then
    echo "${C_DIM}Using gum for prompts.${C_RESET}" >&2
  else
    echo "${C_DIM}gum not found; using fallback prompts.${C_RESET}" >&2
  fi
  echo "" >&2
  echo "${C_DIM}Setup:${C_RESET}" >&2
  DEST_DIR=$(prompt_value "Destination project path" "$DEST_DIR")

  PLATFORM=$(prompt_value "Platform (claude/codex/opencode/cursor/agents)" "$PLATFORM")

  DEFAULT_MODEL=$(prompt_value "Default model (leave empty for platform default)" "$DEFAULT_MODEL")

  if confirm_value "Add shell alias for artisan-agents?"; then
      rc_file="$HOME/.bashrc"
      case "${SHELL:-}" in
        */zsh) rc_file="$HOME/.zshrc" ;;
      esac
      alias_line="alias artisan-agents=\"$SCRIPT_DIR/install-agents.sh\""
      if [ -f "$rc_file" ] && grep -q 'alias artisan-agents=' "$rc_file"; then
        echo "${C_DIM}Alias already exists in $rc_file${C_RESET}"
      else
        printf "\n%s\n" "$alias_line" >> "$rc_file"
        echo "${C_GREEN}Added alias to $rc_file${C_RESET}"
      fi
  fi
fi

if [ ! -d "$DEST_DIR" ]; then
  if [ "$INTERACTIVE" -eq 1 ]; then
    if confirm_value "Destination does not exist. Create it?"; then
      mkdir -p "$DEST_DIR"
    else
      echo "${C_YELLOW}Aborting: destination path does not exist.${C_RESET}" >&2
      exit 1
    fi
  else
    echo "Destination path does not exist: $DEST_DIR" >&2
    echo "Run with --interactive to create it." >&2
    exit 1
  fi
fi

case "$PLATFORM" in
  claude)
    [ -n "$DEFAULT_MODEL" ] || DEFAULT_MODEL="claude-4.5-sonnet"
    ;;
  codex)
    [ -n "$DEFAULT_MODEL" ] || DEFAULT_MODEL="gpt-5"
    ;;
  opencode)
    [ -n "$DEFAULT_MODEL" ] || DEFAULT_MODEL="gpt-4.1"
    ;;
  cursor)
    [ -n "$DEFAULT_MODEL" ] || DEFAULT_MODEL="gpt-4.1"
    ;;
  agents)
    [ -n "$DEFAULT_MODEL" ] || DEFAULT_MODEL="gpt-4.1"
    ;;
  *)
    echo "Unknown platform: $PLATFORM" >&2
    exit 1
    ;;
esac

case "$PLATFORM" in
  claude)
    CONFIG_DIR="$DEST_DIR/.claude"
    ;;
  codex)
    CONFIG_DIR="$DEST_DIR/.codex"
    ;;
  opencode)
    CONFIG_DIR="$DEST_DIR/.opencode"
    ;;
  cursor)
    CONFIG_DIR="$DEST_DIR/.cursor"
    ;;
  agents)
    CONFIG_DIR="$DEST_DIR/.agents"
    ;;
  *)
    echo "Unknown platform: $PLATFORM" >&2
    exit 1
    ;;
esac

AGENTS_DEST="$CONFIG_DIR/agents"
SPECS_DEST="$CONFIG_DIR/specs"
CONFIG_PATH="$CONFIG_DIR/config.json"
MCP_PATH="$CONFIG_DIR/mcp.json"

if [ ! -d "$AGENTS_SRC" ]; then
  echo "Missing agents directory: $AGENTS_SRC" >&2
  exit 1
fi

if [ ! -d "$SPECS_SRC" ]; then
  echo "Missing specs directory: $SPECS_SRC" >&2
  exit 1
fi

mkdir -p "$AGENTS_DEST" "$SPECS_DEST"

for f in "$AGENTS_SRC"/*.md; do
  [ -e "$f" ] || continue
  cp -f "$f" "$AGENTS_DEST/"
done
for f in "$SPECS_SRC"/*.md; do
  [ -e "$f" ] || continue
  cp -f "$f" "$SPECS_DEST/"
done

SPEC_PATH="$SPECS_DEST/specs.md"
if [ "$INTERACTIVE" -eq 1 ]; then
  if [ -f "$SPEC_PATH" ]; then
    echo "" >&2
    printf "%sStack selection%s\n" "$C_BOLD" "$C_RESET" >&2
    echo "${C_DIM}Choose one per category:${C_RESET}" >&2
    backend=$(select_value "Backend" "Laravel (Action pattern, Boosts-friendly)" "Other")
    if [ "$backend" = "Other" ]; then
      backend=$(prompt_value "Backend name" "")
      [ -z "$backend" ] && backend="Other"
    fi

    database=$(select_value "Database" "PostgreSQL" "MySQL" "Other")
    if [ "$database" = "Other" ]; then
      database=$(prompt_value "Database name" "")
      [ -z "$database" ] && database="Other"
    fi

    cache=$(select_value "Cache/Queue" "Redis" "Database-backed queues" "Other")
    if [ "$cache" = "Other" ]; then
      cache=$(prompt_value "Cache/Queue" "")
      [ -z "$cache" ] && cache="Other"
    fi

    frontend=$(select_value "Frontend" "React + Inertia.js + Tailwind CSS" "Vue + Inertia.js" "Other")
    if [ "$frontend" = "Other" ]; then
      frontend=$(prompt_value "Frontend" "")
      [ -z "$frontend" ] && frontend="Other"
    fi

    infra=$(select_value "Infra" "Docker + Terraform" "Platform-managed infra" "Other")
    if [ "$infra" = "Other" ]; then
      infra=$(prompt_value "Infra" "")
      [ -z "$infra" ] && infra="Other"
    fi

    cicd=$(select_value "CI/CD" "GitHub Actions" "Other")
    if [ "$cicd" = "Other" ]; then
      cicd=$(prompt_value "CI/CD" "")
      [ -z "$cicd" ] && cicd="Other"
    fi

    echo "" >&2
    summary_block="Destination:    $DEST_DIR
Platform:       $PLATFORM
Model:          $DEFAULT_MODEL
Backend:        $backend
Database:       $database
Cache/Queue:    $cache
Frontend:       $frontend
Infra:          $infra
CI/CD:          $cicd"
    if [ "$HAS_GUM" -eq 1 ]; then
      printf "Summary\n%s\n" "$summary_block" | gum style --border normal --padding "1 2" --bold >&2
    else
      echo "${C_BOLD}Summary:${C_RESET}" >&2
      echo "${C_DIM}----------------------------------${C_RESET}" >&2
      echo "  Destination: $DEST_DIR" >&2
      echo "  Platform:    $PLATFORM" >&2
      echo "  Model:       $DEFAULT_MODEL" >&2
      echo "  Backend:     $backend" >&2
      echo "  Database:    $database" >&2
      echo "  Cache/Queue: $cache" >&2
      echo "  Frontend:    $frontend" >&2
      echo "  Infra:       $infra" >&2
      echo "  CI/CD:       $cicd" >&2
      echo "${C_DIM}----------------------------------${C_RESET}" >&2
    fi
    if ! confirm_value "Proceed with these settings?"; then
      echo "${C_YELLOW}Aborted.${C_RESET}" >&2
      exit 1
    fi

    summary="Backend=$backend; Database=$database; Cache/Queue=$cache; Frontend=$frontend; Infra=$infra; CI/CD=$cicd"
    tmp=$(mktemp)
    awk -v backend="$backend" -v database="$database" -v cache="$cache" -v frontend="$frontend" -v infra="$infra" -v cicd="$cicd" -v summary="$summary" '
      BEGIN { in_stack=0 }
      /^## Stack/ { in_stack=1; print; next }
      in_stack && /^## / { in_stack=0; print; next }
      in_stack && index($0, "- Backend:") == 1 { print "- Backend: " backend; next }
      in_stack && index($0, "- Database:") == 1 { print "- Database: " database; next }
      in_stack && index($0, "- Cache/Queue:") == 1 { print "- Cache/Queue: " cache; next }
      in_stack && index($0, "- Frontend:") == 1 { print "- Frontend: " frontend; next }
      in_stack && index($0, "- Infra:") == 1 { print "- Infra: " infra; next }
      in_stack && index($0, "- CI/CD:") == 1 { print "- CI/CD: " cicd; next }
      in_stack && index($0, "- Notes:") == 1 { print "- Notes: " summary; next }
      { print }
    ' "$SPEC_PATH" > "$tmp"
    mv "$tmp" "$SPEC_PATH"
  fi
fi

for f in "$AGENTS_DEST"/*.md; do
  [ -e "$f" ] || continue
  tmp=$(mktemp)
  sed "s/^model: .*/model: $DEFAULT_MODEL/" "$f" > "$tmp"
  mv "$tmp" "$f"
done

if [ ! -f "$CONFIG_PATH" ]; then
  cat <<EOF > "$CONFIG_PATH"
{
  "agents_path": "agents",
  "specs_path": "specs",
  "platform": "$PLATFORM",
  "default_model": "$DEFAULT_MODEL"
}
EOF
fi

if [ ! -f "$MCP_PATH" ]; then
  cat <<'EOF' > "$MCP_PATH"
{
  "mcp_servers": []
}
EOF
fi

echo ""
result_block="Platform:            $PLATFORM
Installed agents to: $AGENTS_DEST
Installed specs to:  $SPECS_DEST
Config file:         $CONFIG_PATH
MCP config:          $MCP_PATH"
if [ "$HAS_GUM" -eq 1 ]; then
  printf "Result\n%s\n" "$result_block" | gum style --border normal --padding "1 2" --bold
else
  echo "${C_BOLD}Result:${C_RESET}"
  echo "${C_DIM}----------------------------------${C_RESET}"
  echo "Platform:          $PLATFORM"
  echo "${C_GREEN}Installed agents to:${C_RESET} $AGENTS_DEST"
  echo "${C_GREEN}Installed specs to:${C_RESET}  $SPECS_DEST"
  echo "Config file:         $CONFIG_PATH"
  echo "MCP config:          $MCP_PATH"
fi
echo ""
next_steps_text="1) Edit specs:        $SPEC_PATH
2) Fill Overview:     product summary, goals, non-goals
3) Review Stack:      update any Notes
4) Review sections:   update per project requirements
5) Review agents:     add/remove profiles to match your team needs"

if [ "$HAS_GUM" -eq 1 ]; then
  printf "Next steps:\n%s\n" "$next_steps_text" | gum style --border normal --padding "1 2" --bold
else
  max_len=0
  while IFS= read -r line; do
    [ "${#line}" -gt "$max_len" ] && max_len="${#line}"
  done <<EOF
Next steps:
$next_steps_text
EOF
  border_len=$((max_len + 2))
  printf "%s+%*s+%s\n" "$C_DIM" "$border_len" "" "$C_RESET" | tr " " "-"
  printf "%s| %-*s |%s\n" "$C_BOLD" "$max_len" "Next steps:" "$C_RESET"
  while IFS= read -r line; do
    printf "%s| %-*s |%s\n" "$C_RESET" "$max_len" "$line" "$C_RESET"
  done <<EOF
$next_steps_text
EOF
  printf "%s+%*s+%s\n" "$C_DIM" "$border_len" "" "$C_RESET" | tr " " "-"
fi
