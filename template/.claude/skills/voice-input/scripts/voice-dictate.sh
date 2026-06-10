#!/usr/bin/env bash
# voice-dictate.sh — マイク録音 → whisper.cpp(ローカル) で日本語文字起こし → クリップボード
#
# 完全ローカル・無料・オフライン/SSH 可。クラウドに音声を送らない音声入力経路。
# 依存(macOS / Apple Silicon): whisper-cli(whisper.cpp) / ffmpeg / pbcopy。
#
# 使い方:
#   bash voice-dictate.sh                     # 録音 → 'q' + Enter で停止 → 文字起こし
#   VOICE_LANG=ja bash voice-dictate.sh
#   WHISPER_MODEL=/path/ggml-large-v3-turbo.bin bash voice-dictate.sh
#
# 環境変数:
#   WHISPER_BIN        whisper.cpp 実行ファイル        (既定: whisper-cli)
#   WHISPER_MODEL      ggml モデルへのパス             (未指定なら既知ディレクトリを探索)
#   VOICE_LANG         認識言語                        (既定: ja)
#   VOICE_PROMPT       認識ヒント(専門用語など)        (任意, whisper --prompt に渡す)
#   VOICE_AUDIO_INPUT  ffmpeg avfoundation 入力指定    (既定: ":0" = 既定オーディオデバイス)
#   VOICE_MAX_SECONDS  録音上限秒                      (既定: 120)
#   VOICE_NO_CLIP      1 でクリップボードコピーを抑止  (既定: 0)
set -euo pipefail

WHISPER_BIN="${WHISPER_BIN:-whisper-cli}"
VOICE_LANG="${VOICE_LANG:-ja}"
VOICE_AUDIO_INPUT="${VOICE_AUDIO_INPUT:-:0}"
VOICE_MAX_SECONDS="${VOICE_MAX_SECONDS:-120}"

err()  { printf '\033[31m[voice-dictate] %s\033[0m\n' "$*" >&2; }
info() { printf '\033[36m[voice-dictate] %s\033[0m\n' "$*" >&2; }

# --- 依存チェック ---
command -v ffmpeg >/dev/null 2>&1 \
  || { err "ffmpeg が見つかりません。'brew install ffmpeg' を実行してください。"; exit 1; }
command -v "$WHISPER_BIN" >/dev/null 2>&1 \
  || { err "$WHISPER_BIN が見つかりません。'brew install whisper-cpp' を実行してください。"; exit 1; }

# --- 日本語対応モデルの解決 ---
resolve_model() {
  if [[ -n "${WHISPER_MODEL:-}" ]]; then
    [[ -f "$WHISPER_MODEL" ]] && { printf '%s' "$WHISPER_MODEL"; return 0; }
    err "WHISPER_MODEL が指すファイルがありません: $WHISPER_MODEL"; return 1
  fi
  local dirs=( "$HOME/.cache/whisper" "$HOME/Library/Application Support/whisper" \
               "/opt/homebrew/share/whisper-cpp" "$HOME/whisper.cpp/models" "$PWD/models" )
  # multilingual モデルのみ（*.en は日本語非対応なので除外）。精度の高い順に探索。
  local names=( ggml-large-v3-turbo.bin ggml-large-v3.bin ggml-large-v2.bin \
                ggml-medium.bin ggml-small.bin ggml-base.bin )
  local d n
  for d in "${dirs[@]}"; do
    for n in "${names[@]}"; do
      [[ -f "$d/$n" ]] && { printf '%s' "$d/$n"; return 0; }
    done
  done
  return 1
}

if ! MODEL="$(resolve_model)"; then
  err "日本語対応の whisper.cpp モデルが見つかりません。"
  cat >&2 <<'EOS'
取得例 (large-v3-turbo, 日本語◎ / Apple Silicon で高速):
  mkdir -p ~/.cache/whisper
  curl -L -o ~/.cache/whisper/ggml-large-v3-turbo.bin \
    https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin
取得後に再実行してください (または WHISPER_MODEL=/path/to/model.bin で明示)。
EOS
  exit 1
fi
info "モデル: $MODEL"

# --- 一時ファイル ---
WAV="$(mktemp -t voice-dictate-XXXXXX).wav"
cleanup() { rm -f "$WAV" "${WAV%.wav}"; }
trap cleanup EXIT

# --- 録音 (16kHz mono = whisper 推奨フォーマット) ---
info "録音開始。話し終えたら 'q' + Enter で停止 (最大 ${VOICE_MAX_SECONDS}s)。"
info "※初回は macOS のマイク許可が必要: システム設定 → プライバシーとセキュリティ → マイク → ターミナルを許可"
if ! ffmpeg -hide_banner -loglevel error \
      -f avfoundation -i "$VOICE_AUDIO_INPUT" \
      -ac 1 -ar 16000 -t "$VOICE_MAX_SECONDS" \
      -y "$WAV"; then
  err "録音に失敗しました。マイク許可と入力デバイス(VOICE_AUDIO_INPUT)を確認してください。"
  err "デバイス一覧: ffmpeg -f avfoundation -list_devices true -i \"\""
  exit 1
fi
[[ -s "$WAV" ]] || { err "録音データが空です。マイク入力レベル/デバイスを確認してください。"; exit 1; }

# --- 文字起こし (-nt: タイムスタンプ無し / stderr はシステム情報なので破棄) ---
info "文字起こし中 (lang=$VOICE_LANG)..."
WHISPER_ARGS=( -m "$MODEL" -f "$WAV" -l "$VOICE_LANG" -nt )
[[ -n "${VOICE_PROMPT:-}" ]] && WHISPER_ARGS+=( --prompt "$VOICE_PROMPT" )

TEXT="$("$WHISPER_BIN" "${WHISPER_ARGS[@]}" 2>/dev/null \
        | tr -d '\r' \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
        | sed '/^$/d')"

[[ -n "$TEXT" ]] || { err "認識結果が空でした（無音 or 言語不一致の可能性）。"; exit 1; }

# --- 出力 ---
printf '%s\n' "$TEXT"
if [[ "${VOICE_NO_CLIP:-0}" != "1" ]] && command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$TEXT" | pbcopy && info "クリップボードにコピーしました。"
fi
