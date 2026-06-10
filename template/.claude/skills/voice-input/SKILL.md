---
name: voice-input
description: Clean up and structure rough Japanese voice-dictated text into a clear, actionable prompt — strip fillers, fix homophone/STT errors, normalize punctuation, restate intent for confirmation, then carry out the request. Also documents Claude Code native /voice (Japanese) setup and ships a fully-local offline whisper.cpp dictation script. Use when the user dictated by voice and the text is messy, or when they invoke /voice-input.
user-invokable: true
---

# voice-input — 音声入力の整形と実行

音声ディクテーション（Claude Code ネイティブ `/voice`、SuperWhisper、ローカル whisper など）で
入力された **乱れた日本語テキストを、明確で実行可能な指示に整形**し、意図を確認してから実行する。

> セットアップ（どの経路を使うか／日本語最適化／macOS マイク許可／ツール比較）は
> **[SETUP.md](./SETUP.md)** を参照。ネイティブ `/voice` の有効化と日本語化はテンプレ
> `settings.json`（`"voice": {"enabled": true, "mode": "tap"}` / `"language": "japanese"`）で済んでいる。

## いつ起動するか

- ユーザーが音声入力した（と思われる）乱れた日本語をそのまま投げてきたとき
- `/voice-input` を明示的に呼んだとき
- 「これ音声で入れたから整えて」等の指示があったとき

## 入力経路（3 つ）

1. **ネイティブ `/voice`（第一推奨・ゼロ設定）** — ターミナルへ直接ディクテーション。
   `/voice` で有効化、Space をタップして開始 → もう一度タップで送信（tap モード）。
   日本語は `language: japanese` 設定済みで認識される。精度が高く整形不要なことも多い。
   フィラーや誤変換が残ったら本スキルで整える。クラウド処理・要 Claude.ai ログイン・SSH/Web 不可。
2. **ローカル offline スクリプト** — `scripts/voice-dictate.sh` を実行してマイク録音 →
   whisper.cpp 文字起こし → クリップボード。完全ローカル・無料・オフライン/SSH 可。
   音声を外部に送りたくないときに使う。
3. **任意の STT（SuperWhisper 等）経由** — 別アプリで文字化したテキストを貼り付け、整形対象にする。

## 整形ステップ（原意は変えない）

1. **フィラー除去** — 「えーと」「あの」「えっと」「まあ」「その」「うーん」「なんか」「ほぼほぼ」等
2. **句読点・改行の正規化** — 読点の過多/欠落を補正し、文単位で読みやすく整える
3. **同音異義語・誤変換の修正** — 文脈から推定（例:「機能/帰納」「参照/参道」、技術語の誤変換
   「コミット」「ブランチ」「リファクタ」「ミドルウェア」等）。**確信が持てない箇所は勝手に直さず候補を提示**する
4. **話し言葉の記号化** — 「かっこ」→`(`、「かっことじ」→`)`、「アロー」→`=>`、「ドット」→`.`、
   「スラッシュ」→`/`、「ハイフン」→`-`、「アットマーク」→`@`、「シャープ」→`#` 等。
   ただし**コード/パス/コマンドはキーボード入力を推奨**。確信のない記号は原文を残して確認する
5. **構造化** — 箇条書き・手順に分けると明瞭になる場合のみ整形（情報量は増減させない）

## 実行フロー

1. 整形後の「クリーンな指示」を **1〜数行で復唱**し、自分の解釈を提示する
2. 曖昧な箇所・誤変換の疑いがあれば **確認質問を 1〜2 個だけ**出す（無ければ省略）
3. ユーザーが了承（または明らかに自明）なら、その指示で **通常どおりタスクを実行**する

> 原則: **意図の確認 > 速度**。音声は誤認識が混じる前提。破壊的・不可逆な操作の前は必ず復唱確認する。

## ローカル文字起こしスクリプトの使い方

```bash
# 既定: マイク録音 → whisper.cpp(日本語) → 標準出力 + クリップボード(pbcopy)
bash "${CLAUDE_SKILL_DIR}/scripts/voice-dictate.sh"

# モデルや言語を上書き
WHISPER_MODEL="$HOME/.cache/whisper/ggml-large-v3-turbo.bin" VOICE_LANG=ja \
  bash "${CLAUDE_SKILL_DIR}/scripts/voice-dictate.sh"
```

依存（macOS / Apple Silicon）: `whisper-cli`(whisper.cpp) / `ffmpeg` / `pbcopy`。
日本語対応モデル（`ggml-large-v3-turbo` 等）が必要で、未導入時はスクリプトが取得手順を表示する。
詳細・トラブルシュートは **[SETUP.md](./SETUP.md)**。

## 出力言語

日本語で応答する。
