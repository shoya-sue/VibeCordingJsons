# Performance Optimization

## Model Selection Strategy

**Haiku 4.5** (90% of Sonnet capability, 3x cost savings):
- Lightweight agents with frequent invocation
- Pair programming and code generation
- Worker agents in multi-agent systems

**Sonnet 4.6** (Best coding model):
- Main development work
- Orchestrating multi-agent workflows
- Complex coding tasks

**Opus 4.8** (Deepest reasoning, v2.1.154+ のデフォルト):
- Complex architectural decisions
- Maximum reasoning requirements
- Research and analysis tasks

**Fable 5** (Mythos-class frontier, v2.1.170+, model id `claude-fable-5`):
- 最大能力が要る分析・研究タスク向けの**オプトイン**（テンプレ既定は引き続き Opus 4.8）
- `/model claude-fable-5` で選択。**Fast mode 対象外**（`/fast` は Opus 4.8/4.7/4.6 のみ）

## Fast Mode

`/fast` で Claude Opus を高速出力モードで利用できる（小型モデルへのダウングレードではない、品質維持のままレイテンシ低減）。

- v2.1.154+ のデフォルト: **Opus 4.8**（Fast mode は標準レートの 2x コストで約 2.5x 高速）
- v2.1.142–153: Opus 4.7
- `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` は **削除済み（2026-06-01）**。Opus 4.8 デフォルト化に伴い廃止。Opus 4.6 を Fast mode で使うには `/model claude-opus-4-6[1m]` → `/fast on`

## Context Window Management

> **方針 (Anthropic 公式: "effective context engineering")**: コンテキストは「最大化」ではなく **"find the smallest set of high-signal tokens that maximize the desired outcome"**。文脈は積むほど **context rot / lost-in-the-middle**（中盤の注意希薄化）で recall・指示追従が落ちる。**能動的に小さく保つ**のがベストプラクティス。

### 能動ハイジーン（推奨ワークフロー）

| タイミング | アクション |
|---|---|
| 5〜10 プロンプト毎 | `/context` で利用率を監視（目安: ~40% から劣化が出始め、60% 超で要注意。※経験則） |
| 区切り / 利用率が上がってきたら | `/compact <焦点>` — 自動の lossy 要約より、残す内容を自分で制御（ゴール忠実度が高い） |
| タスクが変わったら | `/clear` でリセット（kitchen-sink セッションを避ける） |
| 長期タスク | `/goal <条件>`（Opus 4.8 は明示ゴールで再アンカーが効く） |
| 重い探索 | **subagent に委任**（ファイル読み込みで本体コンテキストを汚さない） |
| 恒久状態 | CLAUDE.md / `.claude/memory/` / Obsidian に外部化 |

### 自動圧縮の閾値設定

- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` は自動圧縮の発火ウィンドウ（`/context` の分母）を上書きする env var。
- **デフォルトでは設定しない**（CC ネイティブの閾値に任せる）。実ウィンドウより大きい値を入れると、実上限の前に自動圧縮が発火せず「圧縮されない」状態になる。
- `=1000000` は **1M context モード（`/model ...[1m]`）利用者**が upstream バグ [#43989](https://github.com/anthropics/claude-code/issues/43989)（1M モードで閾値が 400K に誤縮小、OPEN/未修正）を回避する **opt-in workaround**。標準 200K ウィンドウの利用者は設定不要（むしろ有害）。自分のウィンドウは `/context` の分母で確認する。

### effort と context のトレードオフ

- Opus 4.8 は **`high` を既定にして eval でスイープ**（`xhigh`/`max` はコーディング/エージェント用途で検討）。effort を上げるほど thinking + tool call が増え、200K ウィンドウでは context rot 帯に早く到達する点に留意。

### 低コンテキスト感度タスク（窓を気にせず可）

- Single-file edits / Independent utility creation / Documentation updates / Simple bug fixes

## Extended Thinking + Plan Mode

Extended thinking is enabled by default, reserving up to 31,999 tokens for internal reasoning.

Control extended thinking via:
- **Toggle**: Option+T (macOS) / Alt+T (Windows/Linux)
- **Config**: Set `effortLevel: "low" | "medium" | "high" | "xhigh"` in settings.json (v2.1.68+, `"xhigh"` は v2.1.111 で追加、Opus 4.8 が `xhigh` を活用、default `"high"`)
- **Disable thinking**: `MAX_THINKING_TOKENS=0` / CLI `--thinking disabled` / モデル別 thinking トグル — デフォルトで thinking するモデルでも thinking を完全に無効化（v2.1.166+）
- **Verbose mode**: Ctrl+O to see thinking output
- **Display summaries**: Set `showThinkingSummaries: true` in settings.json (v2.1.89+, display-only)
- **No-flicker mode**: `CLAUDE_CODE_NO_FLICKER=1` — チラつきなし alt-screen レンダリング（v2.1.91+）
- **Disable alt-screen**: `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1` — alt-screen を無効化して通常スクロールバックを維持（v2.1.132+）
- **Force sync output**: `CLAUDE_CODE_FORCE_SYNC_OUTPUT=1` — Emacs eat 等で同期出力を強制有効化（v2.1.129+）

For complex tasks requiring deep reasoning:
1. Ensure extended thinking is enabled (on by default)
2. Enable **Plan Mode** for structured approach
3. Use multiple critique rounds for thorough analysis
4. Use split role sub-agents for diverse perspectives

### スキル単位の effort 上書き (v2.1.80+)

SKILL.md の frontmatter で個別スキルの effort を指定可能:

```yaml
effort: low   # このスキル実行時は low に固定
```

軽量なユーティリティ系スキルに `low` を指定するとコスト削減になる。

SKILL.md のコンテンツ内では `${CLAUDE_EFFORT}` 変数で現在の effort レベル（`low`/`medium`/`high`/`xhigh`）を参照可能（v2.1.120+）。
effort に応じてスキルの動作を切り替えたい場合に使用する。

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix
