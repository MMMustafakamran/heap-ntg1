#!/usr/bin/env bash
# HARNESS: starts every Antigravity-react server on its harness port (REPOS.md: never 3000/8000).
#   8040 quickstart agent (main.py)      8041 experimental_interrupt agent
#   8042 shared-state agent              8043 sub-agents supervisor     8044 tool-rendering agent
#   8060 R5 declarative gen-UI agents (r5_main.py)   8061 R6 tool-based + app-context agents (r6_main.py)
#   3040 Next.js frontend (runtime at /api/copilotkit)
# Backends use --env-file because the doc's .env is never loaded (FINDINGS.md #1).
cd "$(dirname "$0")"
mkdir -p logs
# CHANGED: every server runs in a real terminal (.qa/tools/ptyrun.cjs): logs/<name>.log as before,
# plus logs/<name>.log.pty, the raw terminal the recorder shows on a failed take.
PTYRUN="node $(pwd)/.qa/tools/ptyrun.cjs"
# HARNESS: Gemini key/model pool on 8049 (copied from the Google ADK repo, tools/gemini_pool.py): spreads requests
# over keys/models (Gemini has credit again, 2026-11-12). backend/.env (CI) sets GOOGLE_GEMINI_BASE_URL to it; OpenAI is the fallback.
(cd backend && PORT=8049 $PTYRUN ../logs/gemini-pool-8049.log --name "uv run python ../tools/gemini_pool.py" -- uv run --with httpx --with starlette python ../tools/gemini_pool.py) &
(cd backend && $PTYRUN ../logs/backend-8040.log --name "uv run uvicorn main:app --port 8040" -- uv run --env-file .env uvicorn main:app --port 8040) &
(cd backend && $PTYRUN ../logs/backend-8041.log --name "uv run uvicorn interrupt_main:app --port 8041" -- uv run --env-file .env uvicorn interrupt_main:app --port 8041) &
(cd backend && $PTYRUN ../logs/backend-8042.log --name "uv run uvicorn shared_state_main:app --port 8042" -- uv run --env-file .env uvicorn shared_state_main:app --port 8042) &
# HARNESS: subagents.py imports httpx, which the page install step never names (FINDINGS.md #27)
(cd backend && $PTYRUN ../logs/backend-8043.log --name "uv run uvicorn subagents_main:app --port 8043" -- uv run --env-file .env --with httpx uvicorn subagents_main:app --port 8043) &
(cd backend && $PTYRUN ../logs/backend-8044.log --name "uv run uvicorn tool_rendering_main:app --port 8044" -- uv run --env-file .env uvicorn tool_rendering_main:app --port 8044) &
(cd backend && $PTYRUN ../logs/backend-8045.log --name "uv run uvicorn state_rendering_main:app --port 8045" -- uv run --env-file .env uvicorn state_rendering_main:app --port 8045) &
# HARNESS: R5 pages (A2UI fixed/dynamic, JSON Render, Hashbrown, Open Generative UI) on :8060; the doc's
# agent files import ag_ui_a2ui_toolkit and httpx but no install step names them, so they ride on --with.
(cd backend && $PTYRUN ../logs/backend-8060.log --name "uv run uvicorn r5_main:app --port 8060" -- uv run --env-file .env --with ag-ui-a2ui-toolkit --with httpx uvicorn r5_main:app --port 8060) &
# HARNESS: R6 pages (Components as Tools, Agent Read-Only Context) on :8061; neither page shows a server.
(cd backend && $PTYRUN ../logs/backend-8061.log --name "uv run uvicorn r6_main:app --port 8061" -- uv run --env-file .env uvicorn r6_main:app --port 8061) &
# HARNESS: the Voice page's transcription-service.ts reads OPENAI_TRANSCRIPTION_API_KEY (the page never says to set it); same OpenAI key.
export OPENAI_TRANSCRIPTION_API_KEY="${OPENAI_TRANSCRIPTION_API_KEY:-${OPENAI_API_KEY:-}}"
(cd frontend && $PTYRUN ../logs/frontend-3040.log --name "npm run dev" -- npm run dev) &
wait
