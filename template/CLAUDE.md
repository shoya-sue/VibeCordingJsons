# Project Name

## Overview

<!-- Describe your project here -->

## Tech Stack

<!-- List technologies used -->

## Project Structure

```text
src/           # Application source
tests/         # All tests (unit, integration, e2e)
docs/          # Documentation
scripts/       # Build and deploy scripts
.claude/       # Skills, agents, rules
```

## Conventions

- Naming: see `rules/ecc/common/coding-style.md` + language-specific rules
- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`)
- Tests: separated from production code in `tests/`

## Commands

```bash
npm test              # Run tests
npm run lint          # Lint
npm run build         # Build
docker compose up     # Start local environment
make deploy-staging   # Deploy to staging
```

## Infrastructure

<!-- Describe infrastructure here -->
- `terraform plan` is allowed; `terraform apply` requires manual confirmation
- `kubectl delete namespace/node` is forbidden

## Slash Commands

- `/model opusplan` — Auto-switch: Opus for planning, Sonnet for execution（v2.1.153+ で `/model` の選択はデフォルトで新セッションにも適用される。現セッションのみ切り替えたい場合はピッカーで `s` キー。旧 keybinding `modelPicker:setAsDefault` は `modelPicker:thisSessionOnly` にリネーム）
- `/effort low|medium|high|xhigh|max` — Set thinking level. `/effort auto` to reset（v2.1.162+ で選択したレベルはデフォルトで新セッションにも引き継がれる）
- `/voice [hold|tap|off]` — ターミナルで音声ディクテーション（v2.1.69+、tap モード v2.1.116+）。テンプレは `settings.json` で有効化＋日本語化済み（`voice.mode: tap` / `language: japanese`）。Space タップで録音開始→再タップで送信。文字起こしは無料（トークン非消費）。音声は Anthropic に送信（クラウド処理）・要 Claude.ai ログイン・SSH/Web 不可。乱れた日本語の整形やローカル offline 経路（whisper.cpp）は `voice-input` スキル → `.claude/skills/voice-input/SETUP.md`
- `/memory` — Manage auto-memory
- `/loop 5m check deploy` — Repeat a prompt on schedule
- `/plan <description>` — Start plan mode
- `/compact <summary>` — Compact context with focused summary
- `/powerup` — インタラクティブな学習レッスンを起動
- `/reload-plugins` — プラグインスキルを再起動なしで再読み込み
- `/plugin list [--enabled|--disabled]` — インストール済みプラグインの一覧をフィルタ表示（v2.1.163+）
- `/reload-skills` — スキルディレクトリをセッション再起動なしで再スキャン（v2.1.152+）
- `/team-onboarding` — チームメイト向けのランプアップガイドを生成
- `/proactive` — `/loop` のエイリアス（プロアクティブなループ実行）
- `/recap` — 離席後のセッションサマリーを手動表示
- `/cd <path>` — セッションの作業ディレクトリを変更（プロンプトキャッシュをセッション途中で壊さずに移動、v2.1.169+）
- `/tui [fullscreen]` — チラつきなし全画面レンダリングに切り替え
- `/terminal-setup` — エディタスクロール感度を設定（fullscreen モードのスムーズスクロール用）。v2.1.157+ では VS Code/Cursor/Windsurf 統合ターミナルの GPU acceleration も無効化し文字化けを防ぐ
- `/focus` — フォーカスビュー表示切り替え（Ctrl+O はノーマル/詳細トランスクリプト切り替えのみ）
- `/less-permission-prompts` — トランスクリプトをスキャンしてパーミッションプロンプトを減らす allow リストを提案
- `/ultrareview` — クラウドで並列マルチエージェント分析による包括的コードレビューを実行（引数なしで現ブランチ、`<PR#>` で特定 PR）。CI からは `claude ultrareview [target]` サブコマンドで非インタラクティブ実行可（`--json` で JSON 出力、終了コード 0/1）
- `/code-review [effort] [--comment] [--fix]` — 現在の diff のバグを effort レベル指定でレビュー（v2.1.146+ で `/simplify` から名称変更、v2.1.152+ で `/simplify` は `/code-review --fix` のエイリアス）。`low|medium` は high-confidence findings のみ、`high|max` で broader coverage。`--comment` で GitHub PR にインラインコメント投稿。`--fix` で findings を作業ツリーに自動適用（reuse / simplification / efficiency 改善を提案、v2.1.152+）
- `/color` — Remote Control 接続中にアクセントカラーを同期
- `/config [key=value]` — 設定を編集。`/config key=value` 構文でプロンプトから任意の設定キーを直接変更できる（v2.1.181+。例: `/config effortLevel=high`）。`/config --help` で指定可能な shorthand キー一覧を表示（v2.1.183+）。引数なしでインタラクティブ設定ピッカーを開く（v2.1.183+ では Enter/Space の両方で選択中の設定を変更、Esc は revert ではなく保存して閉じる）
- `/usage` — トークン使用量とコストを表示（`/cost` + `/stats` の統合版）。v2.1.149+ で skills/subagents/plugins/MCP サーバー別の上限消費内訳を表示
- `/goal <condition>` — 完了条件を設定、条件達成まで複数ターンで継続実行（v2.1.139+）
- `/scroll-speed` — マウスホイールのスクロール速度をライブプレビューで調整（v2.1.139+）。settings.json の `wheelScrollAccelerationEnabled: false` で fullscreen モードのホイールスクロール加速を無効化できる（v2.1.174+）
- `/workflows` — dynamic workflow の実行状況を表示（v2.1.154+）。プロンプトに `ultracode` キーワードを含めると数十〜数百エージェントをバックグラウンドでオーケストレーションする dynamic workflow が起動（v2.1.160 で起動キーワードが `workflow` から `ultracode` に変更）。v2.1.178+ では `ultracode` に加え "run a workflow" / "workflow:" のような明示句でも起動するようになった（purple shimmer でハイライト。ただし「workflow」という語の単なる言及では起動しない）。`/config` の「Workflow keyword trigger」でキーワード起動を無効化可

## Important Notes

- `.env.production` is read-prohibited (deny list)
- v2.1.160+ ではシェル起動ファイル（`.zshenv` / `.zlogin` / `.bash_login` / `~/.config/git/`）への書き込み、および `acceptEdits` モードでのビルドツール設定ファイル（`.npmrc` / `.yarnrc*` / `bunfig.toml` / `.bazelrc` / `.pre-commit-config.yaml` / `.devcontainer/` 等、コード実行を許す設定）書き込み前に確認プロンプトが入る（ビルトイン安全策、settings.json 設定不要）
- Auto mode は v2.1.152+ でオプトイン同意不要（以前は明示的な同意ステップが必要）。Bedrock/Vertex/Foundry では Opus 4.7/4.8 向けに `CLAUDE_CODE_ENABLE_AUTO_MODE=1` の opt-in が必要（v2.1.158+）。v2.1.178+ では subagent の起動も実行前に分類器が評価し、サブエージェント経由でブロック対象アクションが要求される穴を塞ぐ。v2.1.183+ では破壊的 git コマンド（`git reset --hard` / `git checkout -- .` / `git clean -fd` / `git stash drop`）をユーザーが破棄を依頼していない限りブロックし、`git commit --amend` は当該セッションでエージェントが作成したコミット以外をブロック、`terraform destroy`/`pulumi destroy`/`cdk destroy` は対象スタックを明示しない限りブロックする（CC ビルトイン安全網。settings.json の deny/ask や AGENTS.md Denied Operations とは別レイヤー）
- Safe mode（トラブルシュート用、v2.1.169+）: `--safe-mode` フラグまたは `CLAUDE_CODE_SAFE_MODE=1` で CLAUDE.md / plugins / skills / hooks / MCP サーバーをすべて無効化して起動。設定起因の不具合切り分けに使う
- Bundled skills 抑制（v2.1.169+）: `disableBundledSkills: true`（settings.json）または `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS=1` で組み込み skills / workflows / built-in slash command をモデルから隠す
- Agent Teams enabled (`teammateMode: auto`)
- ECC hooks: session continuity (SessionStart/Stop/SessionEnd), --no-verify guard (PreToolUse), auto-format JS/TS (PostToolUse), compact quality (PreCompact)
- Context hygiene: `CLAUDE_CODE_AUTO_COMPACT_WINDOW` is NOT set by default (1M-context opt-in workaround for [#43989](https://github.com/anthropics/claude-code/issues/43989) only). Standard 200K window → manage context actively: `/context`, `/compact <focus>`, `/clear`, `/goal`, subagent delegation; keep high-signal tokens small. See `.claude/rules/ecc/common/performance.md`
- Multi-repo context: `claude --add-dir ../docs --add-dir ../shared-libs` to include external directories (set `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` env var to also load their CLAUDE.md)
- `claude --bg` で起動した bg セッションは `claude agents` ビューで `Ctrl+T` によりピン留め可能（v2.1.147+）。ピン留めセッションはアイドル時も維持、メモリ圧迫時も非ピン留めが先に shed される
- Voice input（日本語）: ネイティブ `/voice` を `settings.json` で有効化（`voice.enabled: true` / `mode: tap`）＋ `language: japanese` で日本語ディクテーション最適化。`language` は応答言語も日本語化する。無効化は `/voice off` または `voice.enabled: false`。整形/オフライン経路は `voice-input` スキル（`.claude/skills/voice-input/`、ローカル whisper.cpp スクリプト同梱）。macOS は初回マイク許可が必要。v2.1.176+ では session title も `language` の言語で自動生成される（`language: japanese` なら日本語タイトル）
- Auto-memory enabled → `.claude/memory/`
- Subagent usage does not count against billing — delegate aggressively
- `gh` CLI for all GitHub operations, never raw `api.github.com`
- Output limit: template sets `CLAUDE_CODE_MAX_OUTPUT_TOKENS=64k` (Opus 4.8 supports up to 128k; raise in `settings.local.json` if you generate long outputs)
- Claude Fable 5（Mythos-class frontier model）は v2.1.170+ で利用可（model id `claude-fable-5`、`/model claude-fable-5`）。テンプレ既定は引き続き Opus 4.8 — Fable 5 は最大能力が要る分析/研究向けのオプトインで Fast mode 対象外。1M コンテキスト標準内蔵のため `[1m]` サフィックス不要（v2.1.173+ で自動除去）
- **Requires** the `ecc` plugin (ECC 2.0.0, from the `everything-claude-code` marketplace; renamed from `everything-claude-code` in 2.0.0) for agents and skills; agents are addressed as `ecc:<agent>`
- Rules: `ecc/common/` (10) + language-specific rules (9 languages × 5 = 45)
