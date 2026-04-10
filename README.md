# VibeCording Settings

Best practice templates for Claude Code and GitHub Copilot CLI.
Provides `settings.json` / `.mcp.json` / `CLAUDE.md` / `AGENTS.md` / Skills / Agents / Rules / VSCode workspace configurations as a complete set.

## Table of Contents

- [Usage](#usage)
- [3 Patterns](#3-patterns)
- [settings.json vs settings.local.json](#settingsjson-vs-settingslocaljson)
- [Pattern Comparison](#pattern-comparison)
- [Instruction Files Read by AI Agents](#instruction-files-read-by-ai-agents)
- [Directory Structure](#directory-structure)
- [settings.json Configuration Reference](#settingsjson-configuration-reference)
  - [permissions](#permissions-3-tier-access-control)
  - [hooks](#hooks-event-hooks--all-21-events)
  - [env](#env-environment-variables)
  - [Other Settings](#other-settings)
- [Settings Hierarchy](#settings-hierarchy)
- [VSCode Workspace Settings](#vscode-workspace-settings)
- [Model Selection and Cost Optimization](#model-selection-and-cost-optimization)
- [Best Practices](#best-practices)
- [References](#references)

## Usage

### Global Install (Recommended for Personal Use)

Installing to your home directory **automatically applies to all projects**.
No per-project configuration files needed.

```bash
git clone https://github.com/shoya-sue/VibeCordingJsons.git
cd VibeCordingJsons
./install.sh full ~
```

This places the full configuration in `~/.claude/settings.json`, and every project where you run `claude` will use those settings.
If you need project-specific settings later, add `.claude/settings.json` in that project (array settings are merged, single-value settings are overridden).

### Project Install (For Team Development)

To place shared settings in a project:

```bash
./install.sh standard /path/to/your/project
```

### Manual Copy from GitHub

Open the directory of the pattern you want and copy the contents of each file.

## 3 Patterns

| Pattern | Use Case | Included Files |
|---------|----------|----------------|
| **[Minimal](minimal/)** | Code review and exploration only | `.claude/settings.json`, `CLAUDE.md`, `AGENTS.md`, VSCode workspace |
| **[Standard](standard/)** | Everyday development (**recommended**) | Above + `.mcp.json`, Skills, Rules |
| **[Full](full/)** | All features enabled | Above + Agents, Agent Teams, Auto Start |

Each directory's README has detailed copy destinations and installation instructions.

## settings.json vs settings.local.json

| File | Purpose | Git Tracked |
|------|---------|-------------|
| `settings.json` | Team-shared baseline settings | Yes |
| `settings.local.json` | Personal overrides (model selection, extra permissions, etc.) | No (gitignore) |

`settings.local.json` overrides `settings.json` settings.
Similarly, `CLAUDE.md` (team-shared) and `CLAUDE.local.md` (personal) form a corresponding pair.

## Pattern Comparison

| Feature | Minimal | Standard | Full |
|---------|---------|----------|------|
| **Claude Code** | | | |
| File read | src/tests/docs | src/tests/docs + config files | All files |
| File write | **None** | src/tests/docs | Major directories |
| Git operations | Read-only | add/commit | All operations |
| permissions.ask | None | git push, npm publish | + docker/terraform/kubectl |
| Package managers | **None** | npm/yarn/pnpm/bun | Same |
| Test execution | **None** | pytest/cargo/go | Same |
| Docker / K8s | **None** | **None** | docker/kubectl |
| MCP servers | **None** | 4 servers | 5 servers + full access |
| Skills | **None** | explain-code | + fix-issue, review-pr, generate-changelog, dependency-audit, create-issue, gh-workflow |
| Agents | None | None | 47 via ECC plugin (code-reviewer, architect, language reviewers, etc.) |
| Rules | None | code-style | 50 ECC rules (common + 8 languages) + subagent-delegation, team-coordination |
| Hooks | None | 5 events (logging) | All 26 events + ECC hooks (session continuity, cost tracking, MCP health) |
| Sandbox | None | None | Removed (use permissions deny list instead) |
| Agent Teams | None | None | Enabled |
| Attribution | None | Commit/PR signing | Same |
| **Copilot CLI** | | | |
| copilot-instructions.md | Read-only instructions | Standard dev instructions | Full-feature instructions |
| Skills | None | explain-code, code-reviewer | + fix-issue, review-pr, test-runner |
| Agents | None | None | code-reviewer, github-workflow, code-explorer, test-runner |
| AGENTS.md | Yes | Yes | Yes |
| **VSCode Workspace** | | | |
| Editor settings | Basic (formatOnSave, tabSize) | Full (autoSave, git, search) | Same + minimap: off |
| Extensions | Copilot only | + GitLens, Prettier, ESLint, EditorConfig | + Docker |
| Claude Code task | None | Background task x1 | + Auto Start (folderOpen) |
| Launch config template | None | None | Empty template included |

## Instruction Files Read by AI Agents

List of instruction files automatically loaded by each AI tool:

| File | Claude Code | Copilot CLI | Gemini CLI | Purpose |
|------|-------------|-------------|------------|---------|
| `CLAUDE.md` | Yes | Yes | — | Detailed instructions for Claude Code |
| `AGENTS.md` | — | Yes | Yes | Universal AI agent instructions |
| `.github/copilot-instructions.md` | — | Yes | — | Copilot project instructions |
| `~/.copilot/copilot-instructions.md` | — | Yes | — | Copilot user-level instructions |
| `~/.claude/CLAUDE.md` | Yes | — | — | Claude Code global instructions |

**Recommended**: Place both `CLAUDE.md` (Claude Code specific) and `AGENTS.md` (universal) at your project root.
Setting `~/.copilot/copilot-instructions.md` applies to all projects.

## Directory Structure

```text
.
├── minimal/
│   ├── .claude/
│   │   ├── settings.json
│   │   └── settings.local.json
│   ├── .github/
│   │   └── copilot-instructions.md
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   ├── project.code-workspace
│   └── README.md
├── standard/
│   ├── .claude/
│   │   ├── settings.json
│   │   ├── settings.local.json
│   │   ├── skills/explain-code/SKILL.md
│   │   └── rules/code-style.md
│   ├── .github/
│   │   ├── copilot-instructions.md
│   │   └── skills/
│   │       ├── explain-code/SKILL.md
│   │       └── code-reviewer/SKILL.md
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   ├── project.code-workspace
│   └── README.md
├── full/
│   ├── .claude/
│   │   ├── settings.json
│   │   ├── settings.local.json
│   │   ├── skills/
│   │   │   ├── explain-code/SKILL.md
│   │   │   ├── fix-issue/SKILL.md
│   │   │   ├── review-pr/SKILL.md
│   │   │   ├── generate-changelog/SKILL.md
│   │   │   ├── dependency-audit/SKILL.md
│   │   │   ├── create-issue/SKILL.md
│   │   │   └── gh-workflow/SKILL.md
│   │   └── rules/
│   │       ├── ecc/             # 50 rules from everything-claude-code
│   │       │   ├── common/      # 10 cross-language rules
│   │       │   ├── typescript/  # 5 TS/JS rules
│   │       │   ├── python/      # 5 Python rules
│   │       │   ├── golang/      # 5 Go rules
│   │       │   ├── rust/        # 5 Rust rules
│   │       │   ├── swift/       # 5 Swift rules
│   │       │   ├── java/        # 5 Java rules
│   │       │   ├── kotlin/      # 5 Kotlin rules
│   │       │   └── cpp/         # 5 C++ rules
│   │       ├── subagent-delegation.md
│   │       └── team-coordination.md
│   ├── .github/
│   │   ├── copilot-instructions.md
│   │   ├── instructions/
│   │   │   └── example.instructions.md   # path-targeted instructions (applyTo glob)
│   │   ├── skills/
│   │   │   ├── explain-code/SKILL.md
│   │   │   ├── code-reviewer/SKILL.md
│   │   │   ├── fix-issue/SKILL.md
│   │   │   ├── review-pr/SKILL.md
│   │   │   ├── test-runner/SKILL.md
│   │   │   ├── create-issue/SKILL.md
│   │   │   ├── generate-changelog/SKILL.md
│   │   │   └── dependency-audit/SKILL.md
│   │   └── agents/
│   │       ├── code-reviewer.agent.md
│   │       ├── github-workflow.agent.md
│   │       ├── code-explorer.agent.md
│   │       └── test-runner.agent.md
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── CLAUDE.local.md
│   ├── project.code-workspace
│   └── README.md
├── install.sh
├── .claude/settings.json
├── .mcp.json
├── AGENTS.md
├── CLAUDE.md
├── LICENSE
└── README.md
```

## settings.json Configuration Reference

### permissions (3-Tier Access Control)

```jsonc
{
  "permissions": {
    "allow": [...],  // Auto-allow
    "ask": [...],    // Prompt each time (between allow and deny)
    "deny": [...]    // Always deny
  }
}
```

Supported patterns:

| Pattern | Description | Example |
|---------|-------------|---------|
| `Read(glob)` | File read | `Read(src/**)` |
| `Write(glob)` | File write | `Write(src/**)` |
| `Edit(glob)` | File edit | `Edit(**/*.ts)` |
| `Bash(pattern)` | Shell command | `Bash(git *)` |
| `mcp__server__tool` | MCP tool | `mcp__context7__*` |
| `Skill(pattern)` | Skill execution | `Skill(explain-code:*)` |
| `MCPSearch` | MCP search | `MCPSearch` |

### hooks (Event Hooks — All 26 Events)

4 hook types: `command` (shell), `http` (HTTP request), `prompt` (LLM judgment), `agent` (subagent)

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "echo 'Before bash'", "timeout": 10 },
          // HTTP hooks: POST JSON to external URL (v2.1.69+)
          { "type": "http", "url": "http://localhost:3000/hooks/pre-tool", "timeout": 5 }
        ]
      }
    ]
  }
}
```

All events:

| Event | Timing | Blocking |
|-------|--------|----------|
| `SessionStart` | Session start | No |
| `UserPromptSubmit` | Before prompt submission | Yes |
| `PreToolUse` | Before tool execution | Yes |
| `PostToolUse` | After tool execution | No |
| `PostToolUseFailure` | After tool execution failure | No |
| `PermissionRequest` | On permission check | No |
| `Notification` | On notification | No |
| `SubagentStart` | On subagent start | No |
| `SubagentStop` | On subagent stop | Yes |
| `Stop` | On response stop | Yes |
| `TeammateIdle` | When teammate is idle | No |
| `TaskCompleted` | On task completion | No |
| `ConfigChange` | On config change | No |
| `WorktreeCreate` | On worktree creation | No |
| `WorktreeRemove` | On worktree removal | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction | No |
| `Elicitation` | When MCP server requests structured input | Yes |
| `ElicitationResult` | After MCP Elicitation response | No |
| `InstructionsLoaded` | On instruction file load | No |
| `SessionEnd` | Session end | No |

**timeout unit**: seconds (e.g., `"timeout": 10` = 10 seconds)

### env (Environment Variables)

| Variable | Description | Recommended |
|----------|-------------|-------------|
| `MCP_TIMEOUT` | MCP timeout (ms) | `10000`-`15000` |
| `MAX_MCP_OUTPUT_TOKENS` | MCP output token limit | `25000`-`50000` |
| `BASH_MAX_TIMEOUT_MS` | Bash timeout (ms) | `120000`-`300000` |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Output token limit (Opus 4.6: max 128k) | `64000` |
| `ENABLE_TOOL_SEARCH` | Enable tool search | `auto` |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Auto context compaction (%) | `50` |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable Agent Teams | `1` |
| `CLAUDE_CODE_AUTO_MEMORY_PATH` | Auto-memory save path | `""` (default) |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd hook timeout (ms) | `5000` |
| `CLAUDE_CODE_DISABLE_CRON` | Disable `/loop` scheduled execution | `1` |
| `CLAUDE_CODE_SIMPLE` | Minimal mode (Skills/Memory/Hooks/MCP disabled) | `1` |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Disable built-in git instructions | `1` |
| `MAX_THINKING_TOKENS` | Thinking token limit | Model-dependent |
| `refreshInterval` | Status line auto-refresh interval (seconds) | `30` |

### Other Settings

| Setting | Description |
|---------|-------------|
| `$schema` | Enable IDE auto-completion |
| `model` | Default model |
| `language` | Response language (e.g., `"japanese"`) |
| `autoMemoryEnabled` | Enable/disable auto-memory (default: `true`) |
| `attribution` | Commit/PR signature text |
| ~~`sandbox`~~ | Removed in v0.4.0 — use permissions deny list instead |
| `teammateMode` | Agent Teams display mode (`auto` / `in-process` / `tmux`) |
| `autoMemoryDirectory` | Auto-memory save directory |
| `modelOverrides` | Map model picker entries to different model IDs |
| `includeGitInstructions` | Enable/disable built-in git commit/PR instructions |
| `worktree.sparsePaths` | Paths to sparse-checkout when using `--worktree` |
| `enableAllProjectMcpServers` | Auto-enable `.mcp.json` servers |
| `enabledPlugins` | Enable/disable plugins (e.g., `{"formatter@acme-tools": true}`) |

## Settings Hierarchy

Claude Code applies settings in the following priority order (higher = higher priority):

1. CLI arguments (session-only)
2. `.claude/settings.local.json` (personal, gitignored)
3. `.claude/settings.json` (team-shared, git-tracked)
4. `~/.claude/settings.local.json` (global personal)
5. `~/.claude/settings.json` (global default)

**Global settings cascade**: Setting `~/.claude/settings.json` automatically applies to all projects, even without a project-level `.claude/settings.json`. For personal use, global settings alone are sufficient.

**Merge rules**:
- **Single values** (`model`, `language`, etc.) → higher priority fully overrides
- **Array values** (`permissions.allow`, `deny`, etc.) → values from all levels are merged

## VSCode Workspace Settings

Each pattern includes a `project.code-workspace` file. Load it via VSCode's "File > Open Workspace from File".

### Features by Pattern

| Feature | Minimal | Standard | Full |
|---------|---------|----------|------|
| Editor settings | formatOnSave, tabSize: 2 | + autoSave, search/watcher excludes | + minimap: off, vendor excludes |
| Recommended extensions | Copilot, Copilot Chat | + GitLens, Prettier, ESLint, EditorConfig | + Docker |
| Claude Code task | — | `Claude Code` (background) | + `Auto Start` (runs on folder open) |
| Launch config | — | — | Empty template |

### Claude Code Background Task

Standard / Full patterns can launch Claude Code as a background VSCode task.

```jsonc
// Task definition in project.code-workspace (excerpt)
{
  "label": "Claude Code",
  "type": "shell",
  "command": "claude -c || claude",
  "isBackground": true,
  "options": {
    "shell": { "executable": "/bin/zsh", "args": ["-l", "-c"] }
  }
}
```

- **Standard**: `Cmd+Shift+P` → `Tasks: Run Task` → `Claude Code` for manual start
- **Full**: Claude Code terminal starts automatically on folder open (`runOn: folderOpen`)

### Multi-Project Configuration

Edit the Full pattern's `project.code-workspace` to manage Claude Code across multiple projects in parallel.

```jsonc
{
  "folders": [
    { "path": ".", "name": "frontend" },
    { "path": "../backend", "name": "backend" }
  ],
  "tasks": {
    "tasks": [
      { "label": "Frontend Claude", "command": "cd ${workspaceFolder:frontend} && claude -c || claude", ... },
      { "label": "Backend Claude", "command": "cd ${workspaceFolder:backend} && claude -c || claude", ... }
    ]
  }
}
```

Use `presentation.group` to color-code task panels (see `full/README.md` for details).

## Model Selection and Cost Optimization

Claude Code lets you switch models mid-session with the `/model` command.

| Model Alias | Description | Recommended For |
|-------------|-------------|-----------------|
| `opus` | Opus 4.6 (highest performance) | Complex architecture design |
| `sonnet` | Sonnet 4.6 (balanced) | Everyday development |
| `haiku` | Haiku 4.5 (fast, low cost) | Simple questions, code review |
| **`opusplan`** | **Opus for planning → Sonnet for execution (auto-switch)** | **Cost-optimized (recommended)** |

**`/model opusplan` workflow**:
1. Plan mode (Shift+Tab) uses Opus 4.6 for complex thinking and design
2. After plan confirmation, automatically switches to Sonnet 4.6 for implementation
3. Saves weekly subscription quota while maintaining high-quality planning

Set `"model": "opusplan"` in `settings.local.json` to enable by default.

### Effort Level

Control model thinking depth with the `/effort` command:

| Level | Symbol | Use Case |
|-------|--------|----------|
| `low` | ○ | Simple tasks, quick responses |
| `medium` | ◐ | Normal development (Opus 4.6 default) |
| `high` | ● | Complex reasoning, deep analysis |
| `auto` | — | Reset to default |

Including "ultrathink" in your message enables high effort for the next turn only.

### Subagent Cost Optimization

Subagent usage does not count against billing quotas. Delegate aggressively:
- Read-only tasks → Explore agent (haiku)
- Code review → `everything-claude-code:code-reviewer` (sonnet)
- Security review → `everything-claude-code:security-reviewer` (sonnet)
- Architecture → `everything-claude-code:architect` (opus)
- Language reviews → `everything-claude-code:{lang}-reviewer` (sonnet)
- Tests → test-runner (built-in, sonnet)
- GitHub ops → always via `gh` CLI

### everything-claude-code Plugin

The Full pattern integrates the [everything-claude-code](https://github.com/affaan-m/everything-claude-code) plugin:

```bash
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code
```

Provides 47 agents, 181 skills, 60 commands. Rules must be installed separately via `install.sh` (plugins cannot auto-distribute rules).

## Best Practices

- **Least privilege**: Only add necessary permissions to `allow`
- **Use ask**: Require confirmation for push / publish operations via `ask`
- **Explicit deny**: Block dangerous operations with `deny`
- **Use `/model opusplan`**: Auto-switch Opus for planning, Sonnet for execution
- **Keep MCP servers to 4-5**: Too many slows startup and becomes counterproductive
- **Keep CLAUDE.md under 150 lines**: Ensures it fits in context reliably
- **Never write secrets**: Do not put `.env` or API keys in settings.json
- **Use hooks**: Visualize work with file change notifications and command logs
- **Avoid `--dangerously-skip-permissions`**: Major security risk
- **Place both CLAUDE.md + AGENTS.md**: Cover both Claude Code and Copilot CLI
- **Use project.code-workspace**: Unify editor settings, extensions, and Claude Code tasks across the team
- **Manage auto-memory with `/memory`**: Regularly review and organize context Claude has saved
- **Control costs with `/effort`**: Use `low` for simple tasks, `high` for complex design
- **HTTP hooks for integrations**: Use `type: "http"` to trigger Slack notifications, CI, or other external services
- **Agent `resume` is deprecated**: Migrated to `SendMessage({to: agentId})` in v2.1.77 (breaking change)
- **Delegate to subagents**: Subagent usage is free — use them for all delegatable tasks

## References

### Claude Code
- [Claude Code Official Documentation](https://code.claude.com/docs/en/overview)
- [Settings](https://code.claude.com/docs/en/settings)
- [Permissions](https://code.claude.com/docs/en/permissions)
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Skills](https://code.claude.com/docs/en/skills)
- [Sub-Agents](https://code.claude.com/docs/en/sub-agents)
- [MCP](https://code.claude.com/docs/en/mcp)
- [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Memory (CLAUDE.md)](https://code.claude.com/docs/en/memory)
- [Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [Changelog](https://code.claude.com/docs/en/changelog)

### GitHub Copilot CLI
- [Copilot CLI Official Documentation](https://docs.github.com/copilot/concepts/agents/about-copilot-cli)
- [Using Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [GitHub Copilot Best Practices](https://docs.github.com/copilot/using-github-copilot/best-practices-for-using-github-copilot)
- [Custom Instruction Files](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [Model Context Protocol](https://modelcontextprotocol.io/)

## License

[MIT](LICENSE)
