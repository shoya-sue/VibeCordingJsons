# 音声入力（voice）セットアップ — 日本語 × Claude Code 最適化

ターミナル（Claude Code CLI）で日本語の音声入力を快適に使うためのセットアップガイド。
2026 年 6 月時点の調査に基づく。`voice-input` スキル（[SKILL.md](./SKILL.md)）と併用する。

## TL;DR（推奨）

| 目的 | 推奨経路 | コスト | 処理 |
|---|---|---|---|
| **まず使い始める（最短）** | ネイティブ `/voice`（設定済み） | 無料 | クラウド |
| **任意アプリ/常用・GUI** | SuperWhisper（導入済み） | 買い切り or 無料枠 | ローカル(macOS) |
| **完全オフライン/SSH/スクリプト** | `scripts/voice-dictate.sh`（同梱） | 無料 | ローカル |

> 迷ったら **ネイティブ `/voice`** から。プライバシー重視・オフライン・SSH 越しなら **ローカルスクリプト**か **SuperWhisper**。

---

## 経路 1: ネイティブ `/voice`（第一推奨）

Claude Code CLI 内蔵のディクテーション（v2.1.69+、tap モードは v2.1.116+）。
テンプレ `settings.json` で **有効化済み**（`"voice": {"enabled": true, "mode": "tap"}`）＆
**日本語化済み**（`"language": "japanese"`）。`./install.sh ~` でグローバルにも反映される。

### 使い方

```text
/voice          # 有効/無効トグル（モードは維持）
/voice tap      # タップモード（1 回タップで録音開始、もう 1 回で送信）※既定
/voice hold     # 押している間だけ録音（Space 長押し）
/voice off      # 無効化
```

- **tap モード**: プロンプトが空の状態で **Space をタップ → 話す → もう一度 Space** で送信。
  3 語以上で自動送信。無音 15 秒 or 合計 2 分で自動停止。
- 開発用語（`regex` `OAuth` `JSON` `localhost` 等）に最適化され、プロジェクト名・git ブランチ名も認識ヒントに自動追加される。
- **無料**: 文字起こしは Claude のトークンを消費せず `/usage` にも計上されない。
- 言語は `/config` の `language`（`japanese` または `ja`）で切替。空だと英語にフォールバックして日本語が文字化けする。

### 制約（重要）

- 音声は **Anthropic サーバーへ送信**（ローカル処理ではない）。
- **Claude.ai アカウント認証が必須**。API キー / Amazon Bedrock / Google Vertex AI / Microsoft Foundry / HIPAA 有効組織では**使用不可**。
- マイクがローカルにある必要があるため **Claude Code on the web / SSH セッションでは不可**。WSL は WSLg 必須。
- macOS 初回は **マイク許可**が必要（後述）。

### キーの再割り当て（任意）

`~/.claude/keybindings.json` で `voice:pushToTalk`（既定 `Space`）を変更可能。
hold モードのウォームアップを避けたいなら修飾キー併用（例 `meta+k`）が快適:

```json
{ "bindings": [ { "context": "Chat", "bindings": { "meta+k": "voice:pushToTalk" } } ] }
```

### macOS マイク許可

システム設定 → プライバシーとセキュリティ → マイク → 使用中のターミナル（Terminal / iTerm2 等）を ON。
一覧に出ない場合は権限をリセットして再プロンプト:

```bash
tccutil reset Microphone com.googlecode.iterm2   # iTerm2 の例 / Terminal は com.apple.Terminal
# その後ターミナルを Cmd+Q で完全終了 → 再起動 → /voice で許可ダイアログに応答
```

### 無効化したい場合

`/voice off` で一時停止。恒久的に切るなら `settings.json` の `voice.enabled` を `false`、
日本語応答も止めるなら `language` を外す（`/voice` の日本語認識も英語に戻る点に注意）。

---

## 経路 2: SuperWhisper（GUI・任意アプリで常用）

`brew install --cask superwhisper` で導入済み。whisper-large-v3 ベースで日本語精度が高く、
**macOS は完全オンデバイス処理**。ターミナルを含む**あらゆるテキストフィールド**へ挿入でき、
Claude.ai ログイン不要・SSH 越しでも（手元の入力欄に対しては）使える。

### 日本語最適化のコツ

- アプリの設定で **モデルを multilingual（large-v3 等）**、**言語を日本語**に固定する。
- **カスタム辞書 / 置換**に固有名詞・社内用語・技術語（リポジトリ名、`VibeCordingJsons` 等）を登録して誤変換を減らす。
- ホットキーを押しやすいキーに割り当て、ターミナルにフォーカスした状態で発話 → 自動挿入。
- 料金（2026 時点）: サブスク（約 $8.49/月・$84.99/年）または買い切り（約 $249.99）。無料枠あり。

---

## 経路 3: ローカル whisper.cpp スクリプト（完全オフライン）

同梱の `scripts/voice-dictate.sh` がマイク録音 → whisper.cpp 文字起こし → クリップボードを一発で行う。
**完全ローカル・無料・オフライン/SSH 可**。Claude.ai ログイン不要。

### 依存（macOS / Apple Silicon）

```bash
brew install whisper-cpp ffmpeg   # pbcopy は macOS 標準
```

### 日本語モデルの取得（初回のみ）

`large-v3-turbo` が日本語精度◎かつ Apple Silicon で高速:

```bash
mkdir -p ~/.cache/whisper
curl -L -o ~/.cache/whisper/ggml-large-v3-turbo.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
```

スクリプトは `~/.cache/whisper/`・`/opt/homebrew/share/whisper-cpp/`・`~/whisper.cpp/models/` 等を自動探索する。
別パスは `WHISPER_MODEL=...` で明示。

### 実行

```bash
bash scripts/voice-dictate.sh
# 録音開始 → 話す → 'q' + Enter で停止 → 文字起こし結果が表示＆クリップボードへ
```

主な環境変数: `WHISPER_MODEL` / `VOICE_LANG`(既定 ja) / `VOICE_AUDIO_INPUT`(既定 `:0`) /
`VOICE_MAX_SECONDS`(既定 120) / `VOICE_NO_CLIP`(1 でコピー抑止)。

マイクデバイス一覧は `ffmpeg -f avfoundation -list_devices true -i ""` で確認し、必要なら `VOICE_AUDIO_INPUT=":1"` 等で指定。
※ ffmpeg のマイク録音にも上記同様の macOS マイク許可が必要。

---

## 日本語認識の精度を上げる共通テクニック

- **語彙ヒント**: ローカル whisper は `initial_prompt` に専門用語を渡すと誤認識が激減する
  （`whisper-cli ... --prompt "refactor, middleware, commit, VibeCordingJsons"`）。
  SuperWhisper は辞書登録、ネイティブ `/voice` はプロジェクト名・branch を自動ヒント化。
- **ハイブリッド運用**: 「要件・背景・意図」は音声、「コード・パス・コマンド・記号」はキーボードが最効率。
  ネイティブ `/voice` はカーソル位置に挿入されるので音声とタイプを 1 メッセージ内で混在できる。
- **整形は AI に任せる**: 乱れた文字起こしは `voice-input` スキルでフィラー除去・句読点補正・
  同音異義語修正・構造化してから実行する。

---

## ツール比較（2026-06 調査・要約）

| ツール | 形態 | 日本語 | 処理 | 料金 | ターミナル挿入 |
|---|---|---|---|---|---|
| **Claude Code `/voice`** | CLI 内蔵 | ◎(`ja`) | クラウド | 無料(要 Claude.ai) | ◎(CLI/VS Code) |
| **SuperWhisper** | 商用アプリ | ◎(large-v3) | ローカル(mac) | 買い切り/サブスク | ◎(全フィールド) |
| **whisper.cpp 自作** | OSS/DIY | ○〜◎(モデル次第) | ローカル | 無料 | ○(クリップボード) |
| **VoiceInk** | OSS+買い切り | ○ | ローカル | $19 買い切り/DIY 無料 | ◎(ホットキー) |
| **Wispr Flow** | 商用アプリ | ○(多言語混在◎) | クラウド | 無料枠/有料 | ◎ |
| **macOS 標準ディクテーション** | OS 内蔵 | △(句読点弱) | ローカル/混在 | 無料 | ◎ |

### 出典

- [Claude Code Docs — Voice dictation](https://code.claude.com/docs/en/voice-dictation)
- [Claude Code Docs — Settings（`voice` / `language`）](https://code.claude.com/docs/en/settings)
- [Claude Code Docs — Keybindings（`voice:pushToTalk`）](https://code.claude.com/docs/en/keybindings)
- [GitHub — ggml-org/whisper.cpp](https://github.com/ggml-org/whisper.cpp)
- [GitHub — Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk)
- 比較記事: [Hanaseru](https://hanaseru.app/blog/aqua-voice-vs-superwhisper) / [Zenn(SuperWhisper vs Aqua Voice)](https://zenn.dev/yuukikawabata/articles/20260209-voice-input-comparison) / [dev.classmethod（/voice 日本語）](https://dev.classmethod.jp/articles/claude-code-voice-japanese/)
