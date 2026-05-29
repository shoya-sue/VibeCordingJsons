# VibeCording Settings

Best practice templates for Claude Code and GitHub Copilot CLI.
Provides `settings.json` / `.mcp.json` / `CLAUDE.md` / `AGENTS.md` / Skills / Agents / Rules / VSCode workspace configurations as a complete set.

## Table of Contents

- [Usage](#usage)
- [settings.json vs settings.local.json](#settingsjson-vs-settingslocaljson)
- [Instruction Files Read by AI Agents](#instruction-files-read-by-ai-agents)
- [Directory Structure](#directory-structure)
- [settings.json Configuration Reference](#settingsjson-configuration-reference)
  - [permissions](#permissions-3-tier-access-control)
  - [hooks](#hooks-event-hooks--all-27-events)
  - [env](#env-environment-variables)
  - [Other Settings](#other-settings)
- [Settings Hierarchy](#settings-hierarchy)
- [VSCode Workspace Settings](#vscode-workspace-settings)
- [Model Selection and Cost Optimization](#model-selection-and-cost-optimization)
- [Best Practices](#best-practices)
- [References](#references)

## Usage

### Global Install (Recommended)

Installing to your home directory **automatically applies to all projects**.
No per-project configuration files needed.

```bash
git clone https://github.com/shoya-sue/VibeCordingJsons.git
cd VibeCordingJsons
./install.sh
```

This places the configuration in `~/.claude/settings.json`, and every project where you run `claude` will use those settings.
If you need project-specific settings later, add `.claude/settings.json` in that project (array settings are merged, single-value settings are overridden).

### Project Install

To place shared settings in a specific project directory:

```bash
./install.sh /path/to/your/project
```

### Manual Copy from GitHub

Open the `template/` directory on GitHub and copy the contents of each file directly.

## settings.json vs settings.local.json

| File | Purpose | Git Tracked |
|------|---------|-------------|
| `settings.json` | Team-shared baseline settings | Yes |
| `settings.local.json` | Personal overrides (model selection, extra permissions, etc.) | No (gitignore) |

`settings.local.json` overrides `settings.json` settings.
Similarly, `CLAUDE.md` (team-shared) and `CLAUDE.local.md` (personal) form a corresponding pair.

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
├── template/
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

### hooks (Event Hooks — All 27 Events)

5 hook types: `command` (shell), `http` (HTTP request), `prompt` (LLM judgment), `agent` (subagent), `mcp_tool` (MCP tool invocation)

`command` フックは `args: string[]` フィールドでシェルを経由しない exec 形式も使用可（v2.1.139+）。
PostToolUse フックは `continueOnBlock: true` でブロック時もターンを継続できる（v2.1.139+）。

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

All 27 events:

| Event | Timing | Blocking |
|-------|--------|----------|
| `SessionStart` | Session start | No |
| `UserPromptSubmit` | Before prompt submission | Yes |
| `PreToolUse` | Before tool execution | Yes |
| `PostToolUse` | After tool execution | No |
| `PostToolUseFailure` | After tool execution failure | No |
| `PermissionRequest` | On permission check | No |
| `PermissionDenied` | On permission denied (`retry: true` available) | No |
| `Notification` | On notification | No |
| `SubagentStart` | On subagent start | No |
| `SubagentStop` | On subagent stop | Yes |
| `Stop` | On response stop | Yes |
| `StopFailure` | On Stop hook failure | No |
| `TeammateIdle` | When teammate is idle | No |
| `TaskCreated` | On task creation | Yes |
| `TaskCompleted` | On task completion | No |
| `ConfigChange` | On config change | No |
| `CwdChanged` | On directory change | No |
| `FileChanged` | On file change detected | No |
| `WorktreeCreate` | On worktree creation | No |
| `WorktreeRemove` | On worktree removal | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction | No |
| `Elicitation` | When MCP server requests structured input | Yes |
| `ElicitationResult` | After MCP Elicitation response | No |
| `InstructionsLoaded` | On instruction file load | No |
| `MessageDisplay` | Just before an assistant message is displayed (can transform/hide text, v2.1.152+) | Yes |
| `SessionEnd` | Session end | No |

**timeout unit**: seconds (e.g., `"timeout": 10` = 10 seconds)

### env (Environment Variables)

| Variable | Description | Recommended |
|----------|-------------|-------------|
| `MCP_TIMEOUT` | MCP timeout (ms) | `10000`-`15000` |
| `MAX_MCP_OUTPUT_TOKENS` | MCP output token limit | `10000`-`25000` |
| `BASH_MAX_TIMEOUT_MS` | Bash timeout (ms) | `120000`-`300000` |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 1 応答あたりの出力トークン上限。Opus 4.8 は最大 128k 対応だがテンプレは保守的に 64k。長文出力が多ければ `settings.local.json` で `128000` まで引き上げ可（Claude Code 側が内部 cap している場合は無効） | `64000` |
| `ENABLE_TOOL_SEARCH` | Enable tool search | `auto` |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Autocompact 発火 token 数。1M context の Opus モデルで autocompact 閾値が 400K に下がる regression #43989（v2.1.92〜、**未修正 OPEN**）を回避 | `1000000` |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable Agent Teams | `1` |
| `CLAUDE_CODE_AUTO_MEMORY_PATH` | Auto-memory save path | `""` (default) |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd hook timeout (ms) | `5000` |
| `CLAUDE_CODE_DISABLE_CRON` | Disable `/loop` scheduled execution | `1` |
| `CLAUDE_CODE_SIMPLE` | Minimal mode (Skills/Memory/Hooks/MCP disabled) | `1` |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Disable built-in git instructions | `1` |
| `MAX_THINKING_TOKENS` | Thinking token limit | Model-dependent |
| `refreshInterval` | Status line auto-refresh interval (seconds) | `30` |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Bedrock サービスティア（`default` / `flex` / `priority`）（v2.1.122+） | `default` |
| `CLAUDE_CODE_SESSION_ID` | セッション ID（Bash サブプロセスに自動設定、フック `session_id` と同値）（v2.1.132+）。v2.1.154+ で MCP stdio サーバーにも `CLAUDE_CODE_SESSION_ID` と `CLAUDECODE=1` が渡る | (auto) |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | フルスクリーン alt-screen レンダラーを無効化して通常の端末スクロールバックを維持（v2.1.132+） | `1` |
| `CLAUDE_CODE_FORCE_SYNC_OUTPUT` | 同期出力を強制有効化（Emacs `eat` 等の自動検出が効かない端末向け）（v2.1.129+） | `1` |
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` | Homebrew/WinGet インストール時にバックグラウンドで自動アップグレード（v2.1.129+） | `1` |
| `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` | `/model` ピッカーでゲートウェイ `/v1/models` 探索を有効化（オプトイン）（v2.1.129+） | `1` |
| `CLAUDE_PROJECT_DIR` | MCP stdio サーバーおよびフックに自動設定されるプロジェクトルートパス（v2.1.139+） | (auto) |
| `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` | GitHub からのプラグインソース取得を SSH ではなく HTTPS で行う（SSH ブロック環境向け）（v2.1.141+） | `1` |
| `ANTHROPIC_WORKSPACE_ID` | Workload identity federation 用のワークスペース ID（エンタープライズ向け）（v2.1.141+） | (set if applicable) |
| `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` | Fast mode (`/fast`) を Opus 4.6 に固定。**非推奨（2026-06-01 削除予定）** — Opus 4.8 デフォルト化（v2.1.154+）に伴い廃止 | （使用しない） |
| `MCP_TOOL_TIMEOUT` | MCP ツール呼び出し 1 回あたりのフェッチタイムアウト（ms）。v2.1.142 でリモート HTTP/SSE サーバーの 60s ハードキャップを回避 | `120000` |
| `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` | Stop フックが連続でブロックできる回数の上限（v2.1.143+、デフォルト `8`、無限ループ防止） | `8` |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Windows の PowerShell ツール有効化（v2.1.143 で Bedrock/Vertex/Foundry 利用時にデフォルト ON、`0` でオプトアウト） | `0` |
| `CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY` | PowerShell ツールの `-ExecutionPolicy Bypass` デフォルトを無効化し、システムの ExecutionPolicy を尊重（v2.1.143+） | `1` |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | OpenTelemetry metrics に `app.entrypoint`（セッション起動エントリ）属性を含める（v2.1.152+、opt-in） | `true` |

### Other Settings

| Setting | Description |
|---------|-------------|
| `$schema` | Enable IDE auto-completion |
| `model` | Default model |
| `language` | Response language (e.g., `"japanese"`) |
| `autoMemoryEnabled` | Enable/disable auto-memory (default: `true`) |
| `autoScrollEnabled` | Auto-scroll in fullscreen mode (default: `true`) |
| `attribution` | Commit/PR signature text |
| `teammateMode` | Agent Teams display mode (`auto` / `in-process` / `tmux`) |
| `autoMemoryDirectory` | Auto-memory save directory |
| `modelOverrides` | Map model picker entries to different model IDs |
| `includeGitInstructions` | Enable/disable built-in git commit/PR instructions |
| `worktree.sparsePaths` | Paths to sparse-checkout when using `--worktree` |
| `enableAllProjectMcpServers` | Auto-enable `.mcp.json` servers |
| `enabledPlugins` | Enable/disable plugins (e.g., `{"formatter@acme-tools": true}`) |
| `effortLevel` | Default thinking depth (`"low"` / `"medium"` / `"high"` / `"xhigh"`) |
| `alwaysLoad` (in `.mcp.json` per server) | `true` → そのサーバーの全ツールを tool-search 遅延なしで常時利用可能にする（v2.1.121+） |
| `skillOverrides` | スキルの表示制御（`"off"`: 完全非表示 / `"user-invocable-only"`: モデルには非表示 / `"name-only"`: 説明を折り畳み）（v2.1.129+） |
| `worktree.baseRef` | ワークツリーのブランチ起点（`"fresh"`: ベースブランチから / `"head"`: 現在の HEAD から）（v2.1.133+） |
| `worktree.bgIsolation` | バックグラウンドセッションを worktree で分離するか（`"none"` で無効化し working copy を直接編集、v2.1.143+） |
| `parentSettingsBehavior` | admin 設定の結合方式（`"first-wins"`: 最上位優先 / `"merge"`: 全階層をマージ）（v2.1.133+） |
| `autoMode.hard_deny` | auto モード分類ルール — ユーザーの意図や allow 例外に関わらず無条件ブロック（v2.1.136+） |
| `allowAllClaudeAiMcps` | エンタープライズ managed 設定 — `managed-mcp.json` と並んで claude.ai クラウド MCP コネクタをロード（v2.1.149+） |
| `pluginSuggestionMarketplaces` | エンタープライズ managed 設定 — context-aware tips でプラグイン提案する組織 marketplace の allow リスト（v2.1.152+） |

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

The template includes a `project.code-workspace` file. Load it via VSCode's "File > Open Workspace from File".

| Feature | Included |
|---------|---------|
| Editor settings | formatOnSave, tabSize: 2, autoSave, minimap: off |
| Recommended extensions | Copilot, Copilot Chat, GitLens, Prettier, ESLint, Docker |
| Claude Code task | Background task + Auto Start (runs on folder open) |
| Launch config template | Empty template included |

### Claude Code Background Task

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

Claude Code terminal starts automatically on folder open (`runOn: folderOpen`).

### Multi-Project Configuration

Edit `project.code-workspace` to manage Claude Code across multiple projects in parallel.

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

## Model Selection and Cost Optimization

Claude Code lets you switch models mid-session with the `/model` command.

> **v2.1.153+ 挙動変更**: `/model` で選んだモデルはデフォルトで新セッションにも引き継がれる（IDE と同挙動）。現セッションのみ切り替えたい場合はモデルピッカーで `s` キーを押す。旧 keybinding `modelPicker:setAsDefault` は `modelPicker:thisSessionOnly` にリネーム（`d` アクションは `s` に置換）。

| Model Alias | Description | Recommended For |
|-------------|-------------|-----------------|
| `opus` | Opus 4.8 (highest performance, default) | Complex architecture design |
| `sonnet` | Sonnet 4.6 (balanced) | Everyday development |
| `haiku` | Haiku 4.5 (fast, low cost) | Simple questions, code review |
| **`opusplan`** | **Opus for planning → Sonnet for execution (auto-switch)** | **Cost-optimized (recommended)** |

**`/model opusplan` workflow**:
1. Plan mode (Shift+Tab) uses Opus 4.8 for complex thinking and design
2. After plan confirmation, automatically switches to Sonnet 4.6 for implementation
3. Saves weekly subscription quota while maintaining high-quality planning

Set `"model": "opusplan"` in `settings.local.json` to enable by default.

### Effort Level

Control model thinking depth with the `/effort` command:

| Level | Symbol | Use Case |
|-------|--------|----------|
| `low` | ○ | Simple tasks, quick responses |
| `medium` | ◐ | Normal development |
| `high` | ● | Complex reasoning, deep analysis (default) |
| `xhigh` | ◉ | Maximum reasoning (Opus 4.8, v2.1.111+) |
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

The template integrates the [everything-claude-code](https://github.com/affaan-m/everything-claude-code) plugin:

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
- **Run `claude plugin prune` periodically**: Remove orphaned auto-installed plugin dependencies; `plugin uninstall --prune` cascades (v2.1.121+)
- **Run `claude project purge` to clean up**: Remove stored project data; use `--dry-run` to preview, `--interactive` to select items (v2.1.126+)
- **Place both CLAUDE.md + AGENTS.md**: Cover both Claude Code and Copilot CLI
- **Use project.code-workspace**: Unify editor settings, extensions, and Claude Code tasks across the team
- **Manage auto-memory with `/memory`**: Regularly review and organize context Claude has saved
- **Control costs with `/effort`**: Use `low` for simple tasks, `xhigh` for complex design
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
