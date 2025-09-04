#!/usr/bin/env bash

set -euo pipefail

API_URL="https://openrouter.ai/api/v1/chat/completions"
MODEL="${MODEL:-deepseek/deepseek-chat-v3.1:free}"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: This script requires 'jq'. Install jq and retry." >&2
  exit 1
fi

echo "Stateless LLM CLI (model: ${MODEL})"
echo "Type your prompt and press Enter. Ctrl-C to quit."

while true; do
  printf "> "
  if ! IFS= read -r PROMPT; then
    echo
    break
  fi
  if [[ -z "${PROMPT// }" ]]; then
    continue
  fi

  PAYLOAD=$(jq -nc --arg m "$MODEL" --arg c "$PROMPT" \
    '{model:$m, messages:[{role:"user", content:$c}] }')

  RESP=$(curl -sS --fail-with-body \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -d "$PAYLOAD" \
    "$API_URL" ) || {
      echo "Request failed." >&2
      continue
    }

  REPLY=$(printf "%s" "$RESP" | jq -r '.choices[0].message.content // empty')
  if [[ -z "${REPLY// }" ]]; then
    echo "(no content returned)"
  else
    echo "$REPLY"
  fi
done
