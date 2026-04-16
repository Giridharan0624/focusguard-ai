#!/bin/bash
# Load .env and run Flutter with API keys
set -a
source .env 2>/dev/null
set +a

flutter run --dart-define=GROQ_API_KEY="$GROQ_API_KEY" "$@"
