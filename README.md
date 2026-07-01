# VibeCording Settings

Best practice templates for Claude Code, Codex, and GitHub Copilot CLI.
Provides `settings.json` / `.codex/config.toml` / `.mcp.json` / `CLAUDE.md` / `AGENTS.md` / Skills / Agents / Rules / VSCode workspace configurations as a complete set.

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

This places the configuration in `~/.claude/settings.json` and `~/.codex/config.toml`, and every project where you run `claude` or `codex` will use those settings.
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
| `.codex/config.toml` / `~/.codex/config.toml` | — | — | — | Codex CLI / IDE extension settings and MCP servers |

**Recommended**: Place both `CLAUDE.md` (Claude Code specific) and `AGENTS.md` (universal) at your project root.
Setting `~/.copilot/copilot-instructions.md` applies to all projects.

## Directory Structure

```text
.
├── template/
│   ├── .claude/
│   │   ├── settings.json
│   │   ├── skills/             # 10 local skills
│   │   │   ├── explain-code/SKILL.md
│   │   │   ├── fix-issue/SKILL.md
│   │   │   ├── review-pr/SKILL.md
│   │   │   ├── generate-changelog/SKILL.md
│   │   │   ├── dependency-audit/SKILL.md
│   │   │   ├── create-issue/SKILL.md
│   │   │   ├── gh-workflow/SKILL.md
│   │   │   ├── obsidian-synthesis/SKILL.md
│   │   │   ├── sync-memory/SKILL.md
│   │   │   └── voice-input/SKILL.md   # 日本語音声入力の整形 + /voice & ローカル whisper セットアップ
│   │   └── rules/
│   │       ├── ecc/             # 55 rules from everything-claude-code
│   │       │   ├── common/      # 10 cross-language rules
│   │       │   ├── typescript/  # 5 TS/JS rules
│   │       │   ├── python/      # 5 Python rules
│   │       │   ├── golang/      # 5 Go rules
│   │       │   ├── rust/        # 5 Rust rules
│   │       │   ├── swift/       # 5 Swift rules
│   │       │   ├── java/        # 5 Java rules
│   │       │   ├── kotlin/      # 5 Kotlin rules
│   │       │   ├── cpp/         # 5 C++ rules
│   │       │   └── php/         # 5 PHP rules
│   │       ├── subagent-delegation.md
│   │       ├── team-coordination.md
│   │       └── obsidian-mcp.md
│   ├── .github/
│   │   ├── copilot-instructions.md
│   │   ├── instructions/
│   │   │   └── example.instructions.md   # path-targeted instructions (applyTo glob)
│   │   ├── skills/             # 2 SKILL.md packages (8 skills documented in copilot-instructions.md)
│   │   │   ├── code-reviewer/SKILL.md
│   │   │   └── test-runner/SKILL.md
│   │   └── agents/
│   │       ├── code-reviewer.agent.md
│   │       ├── github-workflow.agent.md
│   │       ├── code-explorer.agent.md
│   │       └── test-runner.agent.md
│   ├── .codex/
│   │   ├── config.toml
│   │   ├── hooks.json
│   │   └── hooks/
│   ├── .mcp.json
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── project.code-workspace
│   └── README.md
├── install.sh
├── .claude/settings.json
├── .codex/config.toml
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
| `Tool(param:value)` | Tool input parameter match | `Agent(model:opus)` |
| `MCPSearch` | MCP search | `MCPSearch` |

> **allow / deny の glob ルール（v2.1.166+ で検証強化）**: `allow` の tool-name 位置で glob を使えるのは `mcp__<server>__*` のようにリテラルプレフィックスでスコープを限定した後のみ。`mcp__*` のようなスコープ無しワイルドカードは**無効**で、起動時に警告付きでスキップされる（実効パーミッションには影響しない）。`deny` / `ask` はどの位置でも glob 可で、`deny` の tool-name 位置に `"*"` を置くと全ツールを拒否できる。

> **`Tool(param:value)` パラメータマッチ（v2.1.178+）**: ツール名に続けて `(param:value)` を書くと、そのツールの入力パラメータ値にマッチするルールを作れる（`value` 位置で `*` ワイルドカード可）。例: `Agent(model:opus)` を `deny` に置くと Opus を指定したサブエージェント起動をブロックできる。v2.1.186+ では `Agent(<type>)` の deny ルールおよび `Agent(x,y)` の allowed-types 制限が、名前付きサブエージェント起動（`subagent_type` 指定）に対しても確実に実効化されるよう修正された。

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

> **値列の出所**: 数値系（timeout / token 上限）は**公式 docs に明記される default** を記載し、公式に default が無いものは Description に「公式 default 記載なし（テンプレ値）」と明記する。フラグ系（`1` / `auto` / `haiku` 等）はテンプレが設定する推奨値。

| Variable | Description | Value |
|----------|-------------|-------------|
| `MCP_TIMEOUT` | MCP server **startup** timeout (ms)。**公式 docs に default 記載なし**。テンプレは `30000` を設定 | `30000`（テンプレ値） |
| `MAX_MCP_OUTPUT_TOKENS` | MCP ツール出力のトークン上限。**公式 default `25000`**。テンプレは default 同値 | `25000` |
| `BASH_MAX_TIMEOUT_MS` | model が設定できる長時間 Bash コマンドの最大 timeout (ms)。**公式 default `600000`（10 分）**。テンプレは default 同値 | `600000` |
| `BASH_DEFAULT_TIMEOUT_MS` | 長時間 Bash コマンドのデフォルト timeout (ms)。**公式 default `120000`（2 分）**。テンプレ未設定（公式 default に委ねる） | （未設定＝公式 `120000`） |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | 1 応答あたりの出力トークン上限。**公式 docs に default 記載なし（テンプレ選択）**。Opus 4.8 は最大 128k 対応だがテンプレは保守的に 64k。長文出力が多ければ `settings.local.json` で `128000` まで引き上げ可（Claude Code 側が内部 cap している場合は無効） | `64000`（テンプレ値） |
| `ENABLE_TOOL_SEARCH` | tool search（MCP ツールの遅延探索）の有効化。**公式: default で有効**。テンプレ未設定（既定の有効に委ねる） | `auto`（既定で有効） |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Autocompact 発火 token 数の上書き。**標準 200K ウィンドウでは設定しない**（native auto-compaction に委ね、`/context`・`/compact`・`/clear` で能動ハイジーン）。`1000000` は **1M context モード（`/model ...[1m]`）利用者専用の opt-in workaround**（1M モードで閾値が 400K に誤縮小する regression [#43989](https://github.com/anthropics/claude-code/issues/43989)、**未修正 OPEN** を回避）。標準窓で大きい値を入れると実上限前に発火せず逆効果。v2.1.172+ で 1M セッションが標準上限超過時にネイティブ auto-compaction が発動する安全網が追加されたが、#43989 自体は未修正のためワークアラウンドは継続 | 未設定（1M モードのみ `1000000`） |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable Agent Teams | `1` |
| `CLAUDE_CODE_AUTO_MEMORY_PATH` | Auto-memory save path | `""` (default) |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd hook の timeout (ms)。**公式 docs 未記載（テンプレ参考値）** | `5000`（テンプレ値） |
| `CLAUDE_CODE_DISABLE_CRON` | Disable `/loop` scheduled execution | `1` |
| `CLAUDE_CODE_SIMPLE` | Minimal mode (Skills/Memory/Hooks/MCP disabled) | `1` |
| `CLAUDE_CODE_SAFE_MODE` | 全カスタマイズ（CLAUDE.md/plugins/skills/hooks/MCP）を無効化して起動＝トラブルシュート用（CLI `--safe-mode` 同等、v2.1.169+） | `1` |
| `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` | 組み込み skills/workflows/built-in slash command をモデルから隠す（settings.json `disableBundledSkills: true` 同等、v2.1.169+） | `1` |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Disable built-in git instructions | `1` |
| `MAX_THINKING_TOKENS` | Thinking token limit（v2.1.166+ で `0` を指定するとデフォルト thinking モデルでも thinking を無効化。同等に CLI `--thinking disabled` / モデル別 thinking トグルでも無効化可） | Model-dependent |
| `refreshInterval` | Status line auto-refresh interval (seconds) | `30` |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Bedrock サービスティア（`default` / `flex` / `priority`）（v2.1.122+） | `default` |
| `CLAUDE_CODE_SESSION_ID` | セッション ID（Bash サブプロセスに自動設定、フック `session_id` と同値）（v2.1.132+）。v2.1.154+ で MCP stdio サーバーにも `CLAUDE_CODE_SESSION_ID` と `CLAUDECODE=1` が渡る。v2.1.163+ で `--resume` 時も stdio MCP サーバーに渡る | (auto) |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | フルスクリーン alt-screen レンダラーを無効化して通常の端末スクロールバックを維持（v2.1.132+） | `1` |
| `CLAUDE_CODE_DISABLE_MOUSE_CLICKS` | fullscreen モードでマウスのクリック/ドラッグ/ホバーを無効化（ホイールスクロールは維持）（v2.1.195+） | `1` |
| `CLAUDE_CODE_FORCE_SYNC_OUTPUT` | 同期出力を強制有効化（Emacs `eat` 等の自動検出が効かない端末向け）（v2.1.129+） | `1` |
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` | Homebrew/WinGet インストール時にバックグラウンドで自動アップグレード（v2.1.129+） | `1` |
| `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` | `/model` ピッカーでゲートウェイ `/v1/models` 探索を有効化（オプトイン）（v2.1.129+） | `1` |
| `CLAUDE_PROJECT_DIR` | MCP stdio サーバーおよびフックに自動設定されるプロジェクトルートパス（v2.1.139+） | (auto) |
| `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` | GitHub からのプラグインソース取得を SSH ではなく HTTPS で行う（SSH ブロック環境向け）（v2.1.141+） | `1` |
| `ANTHROPIC_WORKSPACE_ID` | Workload identity federation 用のワークスペース ID（エンタープライズ向け）（v2.1.141+） | (set if applicable) |
| `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` | Fast mode (`/fast`) を Opus 4.6 に固定。**削除済み（2026-06-01）** — Opus 4.8 デフォルト化（v2.1.154+）に伴い廃止。Opus 4.6 を Fast mode で使うには `/model claude-opus-4-6[1m]` → `/fast on` | （削除済み・使用不可） |
| `MCP_TOOL_TIMEOUT` | MCP ツール呼び出し 1 回あたりのフェッチ timeout（ms）。v2.1.142 でリモート HTTP/SSE サーバーの 60s ハードキャップを回避。**公式: 未設定時の default は事実上無制限（約 28h 相当）**、明示すると per-tool に短い上限を課す。テンプレ未設定 | （未設定。設定時の目安 `120000`） |
| `CLAUDE_CODE_MCP_TOOL_IDLE_TIMEOUT` | remote MCP ツール呼び出しの無応答 abort タイムアウト。v2.1.187+ で remote MCP ツールが 5 分無応答だと無限ハングせず error で abort するようになった。その閾値を上書き | `300000`（既定 5 分） |
| `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` | Stop フックが連続でブロックできる回数の上限（v2.1.143+、デフォルト `8`、無限ループ防止） | `8` |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Windows の PowerShell ツール有効化（v2.1.143 で Bedrock/Vertex/Foundry 利用時にデフォルト ON、`0` でオプトアウト） | `0` |
| `CLAUDE_CODE_POWERSHELL_RESPECT_EXECUTION_POLICY` | PowerShell ツールの `-ExecutionPolicy Bypass` デフォルトを無効化し、システムの ExecutionPolicy を尊重（v2.1.143+） | `1` |
| `OTEL_METRICS_INCLUDE_ENTRYPOINT` | OpenTelemetry metrics に `app.entrypoint`（セッション起動エントリ）属性を含める（v2.1.152+、opt-in） | `true` |
| `OTEL_LOG_TOOL_DETAILS` | `tool_decision` telemetry イベントに `tool_parameters`（bash コマンド・MCP/skill 名）を含める（v2.1.157+、opt-in） | `1` |
| `OTEL_LOG_ASSISTANT_RESPONSES` | `claude_code.assistant_response` OTel log event にモデル応答テキストを含める（v2.1.193+）。**未設定時は `OTEL_LOG_USER_PROMPTS` に追従** → prompt をログ済みの環境はアップグレードで応答内容も記録され始める。prompts のみに保つなら `0` を明示 | `0`（prompts-only に保つ） |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Bedrock / Vertex / Foundry で auto mode（Opus 4.7・4.8）を有効化する opt-in（v2.1.158+）。標準の Anthropic API 利用時は不要 | `1`（該当ゲートウェイ利用時のみ） |
| `OTEL_RESOURCE_ATTRIBUTES` | OpenTelemetry メトリクスのデータポイントにカスタムラベル（team・repo 等の任意ディメンション）を付与し、利用メトリクスをスライス可能にする（v2.1.161+） | `team=infra,repo=app` |
| `ENABLE_PROMPT_CACHING_1H` | 1 時間 TTL の prompt caching を有効化（標準 5 分 TTL の延長）。API Key / Bedrock / Vertex / Foundry 全対応で `ENABLE_PROMPT_CACHING_1H_BEDROCK` の上位互換（v2.1.108+）。テンプレ既定で有効 | `1` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | サブエージェント（Task / Explore 等）のデフォルトモデル。テンプレは軽量委任のため `haiku`（v2.1.141+） | `haiku` |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | フック / ツールが起動するサブプロセスへ渡す環境変数から機密（API キー等）をスクラブする | `1` |
| `CLAUDE_CODE_NO_FLICKER` | チラつきなし alt-screen レンダリング（v2.1.91+） | `1` |
| `CLAUDE_CLIENT_PRESENCE_FILE` | クライアント presence ファイルを指定してモバイル（Claude アプリ）への通知を抑制する（v2.1.181+） | （用途に応じパス） |
| `CLAUDE_CODE_RETRY_WATCHDOG` | unattended（CI / headless）セッション向けのリトライ監視。v2.1.186+ で `CLAUDE_CODE_MAX_RETRIES` は **15 が上限**にキャップされたため、無人運用で粘り強くリトライしたい場合はこちらを使う | `1` |
| `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP` | メモリ逼迫時のアイドル background シェルコマンド自動回収を無効化（v2.1.193+、既定は自動回収有効） | `1`（自動回収を止める場合） |
| `CLAUDE_ENABLE_STREAM_WATCHDOG` | 応答ストリームの idle watchdog。ストリームが 5 分間イベントを出さないと abort して自動 retry する。v2.1.196+ で**全プロバイダ既定 ON**（従来は一部のみ）。`0` で無効化 | `0`（無効化する場合） |

### Other Settings

| Setting | Description |
|---------|-------------|
| `$schema` | Enable IDE auto-completion |
| `model` | Default model |
| `language` | Response language (e.g., `"japanese"`)。v2.1.176+ では session title もこの言語で自動生成され、`language` で特定言語にピン留めできる |
| `autoMemoryEnabled` | Enable/disable auto-memory (default: `true`) |
| `autoScrollEnabled` | Auto-scroll in fullscreen mode (default: `true`) |
| `wheelScrollAccelerationEnabled` | fullscreen モードのマウスホイールスクロール加速を無効化（`false`）（v2.1.174+） |
| `attribution` | Commit/PR signature text（web/Remote Control では `attribution.sessionUrl: false` で claude.ai セッションリンクを省略可、v2.1.183+） |
| `teammateMode` | Agent Teams display mode (`auto` / `in-process` / `tmux` / `iterm2`)。`iterm2` は v2.1.186+（`it2` CLI 必須、auto で未検出時は警告） |
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
| `autoMode.classifyAllShell` | auto モードで全 Bash/PowerShell コマンドを分類器に通す（既定は arbitrary-code-execution パターンのみ）。より厳格な auto モード運用向け（v2.1.193+） |
| `allowAllClaudeAiMcps` | エンタープライズ managed 設定 — `managed-mcp.json` と並んで claude.ai クラウド MCP コネクタをロード（v2.1.149+） |
| `pluginSuggestionMarketplaces` | エンタープライズ managed 設定 — context-aware tips でプラグイン提案する組織 marketplace の allow リスト（v2.1.152+） |
| `agent` | dispatched session（`claude agents` から起動）で使うデフォルトエージェント。`settings.json` の値が honored される（v2.1.157+）。CLI からは `--agent <name>` で override |
| `requiredMinimumVersion` / `requiredMaximumVersion` | managed settings — 組織内で利用可能な Claude Code バージョンの下限/上限を強制（v2.1.163+） |
| `fallbackModel` | プライマリモデルが過負荷／エラー時に順次フォールバックするモデル（最大 3 つを順番に試行）。CLI `--fallback-model` フラグは v2.1.166+ でインタラクティブセッションにも適用（従来は `-p`/print のみ） |
| `enforceAvailableModels` | managed settings — 有効時、`availableModels` allowlist が Default モデルも制約し（disallow に解決される Default は最初の allowed モデルにフォールバック）、user/project 設定で managed の `availableModels` を広げられなくなる（v2.1.175+） |
| `footerLinksRegexes` | フッター行に regex マッチの link badge を表示する設定（user または managed settings）（v2.1.176+） |
| `sandbox.allowAppleEvents` | macOS の sandboxed command が Apple Events（`osascript` 等で他アプリを制御）を送れるようにする opt-in（v2.1.181+。テンプレは未設定＝無効） |
| `sandbox.credentials` | macOS の sandboxed command が認証ファイル・機密 env（API キー等）を読み取るのをブロックする opt-in（v2.1.187+。テンプレは未設定。sandbox を能動有効化する場合のハードニング用） |
| `respondToBashCommands` | `!` で実行した bash コマンドの出力に Claude が自動応答するか（v2.1.186+、デフォルト `true`）。`false` で従来の context-only 挙動（出力を文脈に取り込むだけで応答しない）に戻す |

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
>
> **v2.1.196+ organization default model**: 管理者が org console で組織のデフォルトモデルを設定でき、ユーザーが自分でモデルを選んでいない場合は `/model` に「Org default」（またはロール別の「Role default」）として表示される。

| Model Alias | Description | Recommended For |
|-------------|-------------|-----------------|
| `opus` | Opus 4.8 (highest performance; テンプレ既定 = settings.json で opus 固定) | Complex architecture design |
| `sonnet` | Sonnet 5 (v2.1.197+ の Claude Code 既定モデル・1M context 標準内蔵・`claude-sonnet-5`) | Everyday development |
| `haiku` | Haiku 4.5 (fast, low cost) | Simple questions, code review |
| `fable` | Fable 5 (Mythos-class frontier, v2.1.170+, `claude-fable-5`; 1M context built-in, `[1m]` suffix auto-stripped in v2.1.173+) | Frontier-grade analysis / research (opt-in, not fast-mode eligible) |
| **`opusplan`** | **Opus for planning → Sonnet for execution (auto-switch)** | **Cost-optimized (recommended)** |

> **v2.1.197+**: Claude Sonnet 5 が Claude Code の**既定モデル**に昇格（native 1M context、model id `claude-sonnet-5`）。導入当初は 8/31 まで $2/$10 per Mtok のプロモ価格。`sonnet` エイリアスの解決先が Sonnet 4.6 → Sonnet 5 に切替。テンプレは `settings.json` で `opus` を固定しているため既定挙動は不変 — 既定を Sonnet 5 にしたい場合は `model` を外すか `sonnet` を指定する。

**`/model opusplan` workflow**:
1. Plan mode (Shift+Tab) uses Opus 4.8 for complex thinking and design
2. After plan confirmation, automatically switches to Sonnet 5 for implementation
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

> **v2.1.162+ 挙動変更**: `/effort` で選んだレベルはデフォルトで新セッションにも引き継がれる（`/model` の v2.1.153+ 永続化と同挙動）。

### Subagent Cost Optimization

Subagent usage does not count against billing quotas. Delegate aggressively:
- Read-only tasks → Explore agent (haiku)
- Code review → `ecc:code-reviewer` (sonnet)
- Security review → `ecc:security-reviewer` (sonnet)
- Architecture → `ecc:architect` (opus)
- Language reviews → `ecc:{lang}-reviewer` (sonnet)
- Tests → test-runner (built-in, sonnet)
- GitHub ops → always via `gh` CLI

### everything-claude-code Plugin

The template integrates the [everything-claude-code](https://github.com/affaan-m/everything-claude-code) plugin:

```bash
/plugin marketplace add affaan-m/everything-claude-code
/plugin install ecc@everything-claude-code
```

> ECC 2.0.0 renamed the plugin `everything-claude-code` → `ecc` (the marketplace/repo name stays `everything-claude-code`). Agents are addressed as `ecc:<agent>`.

Provides 64 agents, 261 skills, 84 commands (ECC 2.0.0; plugin-provided counts are version-specific). Rules must be installed separately via `install.sh` (plugins cannot auto-distribute rules).

## Best Practices

- **Least privilege**: Only add necessary permissions to `allow`
- **Use ask**: Require confirmation for push / publish operations via `ask`
- **Explicit deny**: Block dangerous operations with `deny`
- **Use `/model opusplan`**: Auto-switch Opus for planning, Sonnet for execution
- **Keep MCP servers lean**: Too many slows startup. `obsidian` / `github` / `plaud` are environment-specific — remove any you don't use.
- **Keep CLAUDE.md under 150 lines**: Ensures it fits in context reliably
- **Never write secrets**: Do not put `.env` or API keys in settings.json
- **Use hooks**: Visualize work with file change notifications and command logs
- **Avoid `--dangerously-skip-permissions`**: Major security risk
- **Run `claude plugin prune` periodically**: Remove orphaned auto-installed plugin dependencies; `plugin uninstall --prune` cascades (v2.1.121+)
- **Run `claude project purge` to clean up**: Remove stored project data; use `--dry-run` to preview, `--interactive` to select items (v2.1.126+)
- **Scaffold local plugins with `claude plugin init <name>`**: Places them in `.claude/skills`, which now auto-load without a marketplace (v2.1.157+)
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
