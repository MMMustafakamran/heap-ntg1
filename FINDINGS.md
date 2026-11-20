# Findings — Antigravity-react
Open doc defects only, for the reachable pages of the Google Antigravity React docs (`.qa/instructions/QA-RULES.md` §5, §9). Numbers are stable IDs (code cites `FINDINGS.md #N`), so gaps are removed findings. Checked against the rendered pages, including their Code tabs, on 2026-11-11.
Stack: `@copilotkit/react-core`/`runtime` 1.89.0 (npm latest, CI 2026-11-20), `@ag-ui/client` 1.0.4, `next` 16.4.5, `react` 19.3.0, `google-antigravity` 0.1.23, `ag-ui-antigravity` 0.2.1, `fastapi` 0.162.0, `uvicorn` 0.54.0, CLI `copilotkit` 4.33.1. Python 3.13.15, Windows 11. Docs: https://docs.copilotkit.ai/google-antigravity (snapshot 2026-11-04, drift-checked 2026-11-11)

## Dev blockers (seen with `npm run dev` and normal use of the page)

### [Components and surfaces](https://docs.copilotkit.ai/google-antigravity/generative-ui/components)
**#42 The page's only setup is an OpenAI/TanStack `BuiltInAgent`; with the existing Antigravity agent ("Do step 3 only") no component renders, the reply is plain text.**
- **Doc:** "Already have CopilotKit running? Do step 3 only … when the provider sends a catalog, the runtime gives that run a `render_ui` tool." The page's actual walkthrough is an OpenAI/TanStack `BuiltInAgent`, not Antigravity.
- **Result:** the Antigravity quickstart agent with the doc's `<CopilotKitProvider … generativeUI={{ ui: standardUI }}>` gets the doc's own prompt "Compare the Starter, Team, and Enterprise plans in a table". No `standardUI` component renders; the latest probe ended with an empty assistant reply after 105 s (earlier runs: a plain Markdown table). Re-checked 2026-11-12 (CI 43178874580) on the doc's own step-2 runtime shape (`[[...slug]]`, GET + POST, harness path `/api/copilotkit-gui`): reply "I don't have plan details…" as plain text, no component.

### [Dynamic Schema](https://docs.copilotkit.ai/google-antigravity/generative-ui/a2ui/dynamic-schema)
**#72 No dashboard renders; the chat shows "A2UI render error: Cannot read properties of undefined (reading 'map')".**
- **Doc:** Code tab `a2ui_dynamic.py`, `catalog.ts`, `definitions.ts`, `page.tsx`, `renderers.tsx`, `route.ts` (harness frontend files identical to the tabs).
- **Error:** `A2UI render error: Cannot read properties of undefined (reading 'map')` (same as LangGraph React).

### [Fixed Schema](https://docs.copilotkit.ai/google-antigravity/generative-ui/a2ui/fixed-schema)
**#73 The flight card renders but stays empty: no airline, airports or price, only "Flight Details" and the Book button.**
- **Doc:** Code tab `a2ui_fixed.py`, `flight_schema.json`, `catalog.ts`, `definitions.ts`, `renderers.tsx`, `route.ts` (harness frontend files identical to the tabs).
- **Result:** the agent says "Here is the United flight from SFO to JFK for $289." and the card renders empty. Re-checked 2026-11-12: card shows only "Flight Details", "1-stop · economy", blank TOTAL and "Book flight".

### [Surfaces](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/surfaces)
**#87 The agent calls `render_ui` but nothing renders, neither in the page target nor in the chat.**
- **Doc:** `<GenerativeUISurface id="featured" ui={shopUI} ... fallback={<ProductRow products={products} />} />`.
- **Result:** console `[CopilotKit] The agent called the tool "render_ui", and no renderer is registered for it`; the featured row keeps its fallback, the chat shows an empty assistant message. Same on the doc's own runtime shape (re-checked 2026-11-12, see #42).

### [Catalogs](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/catalogs)
**#89 No Antigravity agent setup on the page (same as Components and surfaces); with the existing Antigravity agent no catalog component renders.**
- **Doc:** `createGenerativeUI({ id: "acme/shop@1", components: { ProductGrid, ProductCard } })` + `<CopilotKitProvider runtimeUrl="/api/copilotkit" generativeUI={{ ui: shopUI }}>`.
- **Result:** the agent calls `generate_image` instead of `render_ui`, then the run fails: `AntigravityExecutionError ... Error 400, Message: Multimodal function responses are not supported for this model., Status: INVALID_ARGUMENT`. No ProductGrid/ProductCard, empty assistant bubble. Seen in two CI takes of 2026-11-16 (CopilotKit 1.88.0); a third take that day failed with "Model produced invalid output" instead, same empty result; before that (2026-11-12) the run reached `render_ui` with "no renderer is registered".

### [Standard catalog](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/standard-catalog)
**#90 No standard component renders; the agent answers with a plain Markdown table.**
- **Doc:** `<CopilotKitProvider runtimeUrl="/api/copilotkit" generativeUI={{ ui: standardUI }}>`.
- **Result:** "Compare the Starter, Team, and Enterprise plans in a table" gets a Markdown table, no standard Table/Card. Same on the doc's own runtime shape (re-checked 2026-11-12).

### [State and actions](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/state-and-actions)
**#91 No product card renders: the page has no Antigravity agent setup (same as Components and surfaces), and the existing agent never renders the card.**
- **Doc:** `shopUI` with `state: { cart: cartSchema }`, `bind: { inCart }`, `functions: { addToCart }` + `useGenerativeUIState` / `useGenerativeUIFunction`.
- **Result:** no ProductCard ever shows up; every run ends in an empty reply or an "Agent run failed" toast (3 probes 2026-11-13). Same on the doc's own runtime shape (re-checked 2026-11-12).

### [Theming](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/theming)
**#94 Nothing renders, so the theme can't be seen.**
- **Doc:** `generativeUI={{ ui: standardUI, theme: { "--a2ui-color-accent": "#d97706", ... } }}`.
- **Result:** empty reply, no component. Same on the doc's own runtime shape (re-checked 2026-11-12).

### [Transports](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/transports)
**#95 No Antigravity agent setup on the page (only LangGraph `CopilotKitMiddleware`); with the Antigravity agent no UI renders.**
- **Doc:** "Your agent must use the tools and the context entries of the run. The built-in agent does this. For a LangGraph Python agent, add CopilotKitMiddleware."
- **Result:** with the Antigravity agent no generated UI ever shows up; the agent answers with a plain Markdown table (probes 2026-11-13) or the run fails with an "Agent run failed" toast (CI 2026-11-12). Same on the doc's own runtime shape (re-checked 2026-11-12).

### [Markdown mode](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/markdown-mode)
**#97 No generated UI; the page doesn't say how to pass the context to an Antigravity agent.**
- **Doc:** `generativeUI={{ ui: standardUI, transport: "markdown" }}`; "Any other agent needs one thing: put the run's context entries into its system prompt."
- **Result:** no a2ui block or surface ever shows up (3/3 probes 2026-11-13): the reply is empty, the run fails ("Agent run failed", CI 2026-11-12), or the agent writes `index.html`/`style.css`/`script.js` instead. Same on the doc's own runtime shape (re-checked 2026-11-12).

### [Adopt from A2UI](https://docs.copilotkit.ai/google-antigravity/generative-ui/components/from-a2ui)
**#99 No Airport/Arrow UI renders: `render_ui` gives nothing on Antigravity, same as Components and surfaces.**
- **Doc:** `createGenerativeUI({ id: "acme/flights@1", extends: [standardUI], components: { Airport, Arrow } })` + `generativeUI={{ ui: appUI }}`.
- **Result:** no Airport/Arrow UI ever shows up; runs end in an empty reply or a failed run (3 probes 2026-11-13). Same on the doc's own runtime shape (re-checked 2026-11-12).

## Minor notes
- #49 [Sub-Agents](https://docs.copilotkit.ai/google-antigravity/multi-agent/subagents): the install step leaves out `httpx`, which `subagents.py` imports (`ModuleNotFoundError: No module named 'httpx'` since google-genai 3); `pip install httpx` fixes it.
- #61 [Reasoning Messages](https://docs.copilotkit.ai/google-antigravity/custom-look-and-feel/reasoning-messages): the page only names `gpt-6-luna`; the Antigravity agent's model comes from `agents/_common.py` in the linked showcase source. Works on that setup (tested with the OpenAI fallback, Gemini key out of credit).
- #63 [Voice](https://docs.copilotkit.ai/google-antigravity/voice): `page.tsx` imports `./voice-chat`, which is only in the linked source; the page says to render `CopilotChat` in its place, and the route's `/voice` agent is never shown (any agent works).
- #80 [Render agent state in your app](https://docs.copilotkit.ai/google-antigravity/shared-state/rendering-in-app): the backend comes from the linked Shared State page (`experimental_app_state`); this page shows only the frontend.
- #64 [Reasoning](https://docs.copilotkit.ai/google-antigravity/generative-ui/reasoning): `useReasoningCustomSuggestions` and `agents._common` are only in the linked showcase source. Works on that setup (tested with the OpenAI fallback).
- **#71 [A2UI](https://docs.copilotkit.ai/google-antigravity/generative-ui/a2ui):** the overview shows fragments only; `myCatalog` and the agent come from the linked Dynamic Schema page, whose failure is reported on its own row.
- #1 Quickstart: `main.py` reads `os.environ["GEMINI_API_KEY"]` but nothing loads the `.env` the page creates (no `load_dotenv`, start command has no `--env-file`): `KeyError: 'GEMINI_API_KEY'` on start. Harness starts it with `uv run --env-file .env`.
- #2 Quickstart: `npx copilotkit@latest init --framework antigravity` fails on CLI 4.33.1 with `Unsupported framework "antigravity"`. The page's callout anticipates this.
- #3 `/google-antigravity` serves the same content as `/google-antigravity/quickstart` (byte-identical `.md`).
- #4 Quickstart: `workspaces=["/srv/agents/w1"]` is a Unix path. On Windows it silently creates `C:\srv\agents\w1` at the drive root, and the page says nothing about Windows.
- #5 Quickstart: the `route.ts` snippet exports only `POST`, so the browser's `GET /api/copilotkit/info` 404s on every load, while the page's own file list names `src/app/api/copilotkit/[[...slug]]/route.ts`.
- #6 Quickstart: a fresh `create-next-app@latest` (16.4.5) enables `cacheComponents`; `<CopilotKit>` in `layout.tsx` then raises "encountered the unstable value `require('node:crypto').randomUUID()` in a Client Component" on every route. Chat still works.
- #7 Frontend Tools: the "Tell the model when to call it" snippet is `gen_ui_tool_based.py`, a chart prompt (`render_bar_chart`/`render_pie_chart`), not anything about `change_background`.
- #8 Frontend Tools: that snippet starts with `from agents._common import build`; `_common.py` is in no tab (`ModuleNotFoundError: No module named 'agents'`).
- #9 Frontend Tools: the Code tab `page.tsx` imports `./background` and `./suggestions`, which no tab shows.
- #10 Frontend Tools: step 1 says the tool is "registered with `useComponent`", but the code uses `useFrontendTool`.
- #11 Frontend Tools: `zod` is in no install command (present only transitively).
- #12 HITL: the Code tab `route.ts` maps `hitl-in-chat` (and every demo agent) to `${AGENT_URL}/<name>` on a Python `agent_server` whose mounting/registry the page never shows; `hitl.py` itself builds on `agents._common` (#14).
- #13 HITL: LangGraph text on an Antigravity page: "A server-side `interrupt()` call in your LangGraph agent" and "`langgraph.interrupt()` as the server-side contract", against the page's own `experimental_interrupt()` step.
- #14 HITL: `hitl.py` imports `build` from the unpublished `agents._common` (as #8).
- #15 HITL: the second snippet ("fed a static list of candidate slots") repeats the whole import block when only `DEFAULT_SLOTS` is new.
- #16 HITL: the install step is `pip install ag-ui-antigravity google-antigravity`, while the quickstart uses `uv add`.
- #17 HITL: the `ask_question` callout says a parked turn "would wait forever" and that the tool is off "in this showcase". `AntigravityAgent` defaults to `enable_ask_question=True` and the quickstart `main.py` doesn't disable it.
- #18 HITL: `experimental_interrupt()` is shown inside `schedule_meeting`, but registering that tool on the agent (`AntigravityAgent(tools=[...])`) isn't.
- #24 Shared State: `shared_state.py` calls `build(...)` (from `agents._common`, see #8), and the `set_notes` snippet uses `experimental_get_state`/`experimental_set_state` without importing them (they come from `ag_ui_antigravity`). With the harness supplying both, read and write work.
- #25 Shared State: the frontend is only fragments of `shared-state-read-write/page.tsx` (no Code tab). `Preferences`, `RWAgentState`, `notes`, the imports and the component body are never shown; `NotesCard` uses `Card`/`Button`/`CardHeader` from an unshown UI kit; agent `shared-state-read-write` is registered nowhere on the page.
- #27 [Sub-Agents](https://docs.copilotkit.ai/google-antigravity/multi-agent/subagents): `subagents.py` imports `MODEL, aimock_headers, api_key, gemini_base_url` and `build` from the unpublished `agents._common` (`ModuleNotFoundError: No module named 'agents'` as published). `aimock_headers` is CopilotKit's test-mock plumbing shown as user code. With the showcase's `_common.py` (harness), the supervisor delegates research → writing → critique.
- #29 [Generative UI](https://docs.copilotkit.ai/google-antigravity/generative-ui) hub: "Your Components" links to `/google-antigravity/generative-ui/your-components` (404). "Display Only" and "Interactive" link to `/generative-ui/display` and `/generative-ui/interactive`, which redirect (301) out of the Antigravity docs.
- #33 [WebMCP](https://docs.copilotkit.ai/google-antigravity/webmcp): `searchOrders(status)` is called but defined in neither `OrderSearch.tsx` nor the `webmcp.ts` tab. The second snippet imports `@copilotkit/core`, which no install step adds. With a harness `searchOrders` stub, both snippets work on Chromium 156.
- #35 Inspector: the "disable Inspector" snippet `<CopilotKit runtimeUrl="/api/copilotkit" enableInspector={false}>` has no `agent`, so against the Antigravity runtime it throws `useAgent: Agent 'default' not found after runtime sync`.
- #36 [Tool Rendering](https://docs.copilotkit.ai/google-antigravity/generative-ui/tool-rendering): the prose says the catch-all handles "`get_stock_price` and `roll_dice`", but the tool in the Code tab's `tool_rendering.py` is `roll_d20`; `tool_rendering.py` builds on the unpublished `agents._common`.
- #39 [State Rendering](https://docs.copilotkit.ai/google-antigravity/generative-ui/state-rendering): `gen_ui_agent.py`'s `set_steps` uses `experimental_get_state`/`experimental_set_state` without imports, and the frontend `useAgent({ agentId: "shared-state-streaming" })` is a fragment naming an agent the page never registers. With imports added, `set_steps` streams one `STATE_SNAPSHOT` per call mid-run.
- #40 Quickstart / every page: the quickstart's `AntigravityAgent(...)` leaves all built-in tools on (web search, file and shell work, artifacts); only the HITL callout mentions `CapabilitiesConfig(enabled_tools=[BuiltinTools.FINISH])`. Seen on Windows: a run called `search_web`, wrote an artifact outside the allowed directory and died with `RUN_ERROR AntigravityExecutionError: … is not a valid artifact path`.
- #41 Components and surfaces: `import { standardUI } from "@copilotkit/react-core/v2/generative-ui"` fails with `Module not found: Can't resolve 'maplibre-gl'` (optional peer dependency); the React install line doesn't add it (it's named only in the Angular optional-libraries note). Harness installs `maplibre-gl`.
- #44 MCP Apps "with Intelligence" example uses `BuiltInAgent({ model: "openai/gpt-6-luna" })`, not an Antigravity agent.
- #45 [A2UI](https://docs.copilotkit.ai/google-antigravity/generative-ui/a2ui): `from copilotkit import a2ui` needs the Python `copilotkit` package, which no Antigravity install step adds; `myCatalog` and the runtime example's `myAgent` are undefined.
- #47 HITL overview vs. useInterrupt/Headless: the overview tells Antigravity users to pause a server tool with `experimental_interrupt()`, while the useInterrupt and Headless Interrupts pages say "Google Antigravity doesn't support Human in the Loop: Interrupts".
- #50 [Inspector](https://docs.copilotkit.ai/google-antigravity/inspector): the "Whether the Runtime answers" row links "Proving it works" to `/google-antigravity/react-native#proving-it-works`, a 404.
- #52 CopilotChat: Code tab `page.tsx` imports `useAgenticChatSuggestions` from `./suggestions`, which the page never shows.
- #53 CopilotSidebar: Code tab `page.tsx` imports `MainContent` from `./main-content` and `Suggestions` from `./suggestions-mount`; neither file is shown.
- #54 CopilotPopup: same as #53 (`./main-content`, `./suggestions-mount` never shown).
- #55 Open, close, and feedback: `analytics.track("feedback", …)` in the feedback snippet, never defined or imported.
- #56 CSS Customization: the CSS Variables snippet imports `CopilotKitCSSProperties` from `@copilotkit/react-ui` (v1), which the quickstart never installs; the rest of the page is v2.
- #57 CSS Customization: the Custom Icons snippet uses undefined `YourOpenIconComponent` / `YourCloseIconComponent`.
- #59 Slots (Subcomponents): the "Two levels" snippet uses `CustomToolbar` and `CustomCopyButton`, defined nowhere (the Code tab's `slot-wrappers.tsx` defines the other custom slots).
- #60 Headless UI: snippets are fragments: `useAgent({ agentId: "headless-simple" })` is registered in no route (the Code tab is the headless-complete demo), no `Avatar` import, `AttachmentChip` never defined; the `console.error` label says `langgraph-python:headless-simple`.
- #62 Multimodal Attachments: Quick start uses the `agentId="my-agent"` placeholder with no note to swap in your own agent id; the snippet is a bare JSX fragment.
- #67 Threads Drawer: the page shows no runtime code for the Intelligence connection it needs (only a signup link).
- #69 Headless Threads: `server.ts` uses `agent` and calls `verifyAppSession`, neither defined nor imported, and shows no route handler.
- #74 JSON Render: no install command; `@json-render/react` and `@json-render/core` 0.18.0 (with Zod 4) are named only in prose.
- #75 Hashbrown: `@hashbrownai/core` / `@hashbrownai/react` are beta (0.5.0-beta.4).
- #78 Components as Tools: `gen_ui_tool_based.py` imports `build` from the unpublished `agents._common`.
- #79 Render agent state in your app: the page relies on an agent named "default"; the Antigravity quickstart registers `antigravity_agent`.
- #81 Agent Read-Only Context: `app_context.py` imports `build` from the unpublished `agents._common`.
- #82 Agent Read-Only Context: Code tab `page.tsx` imports `./demo-layout` and `./suggestions`, which no tab shows.
- #83 Agent Read-Only Context: the text says entries are surfaced by `CopilotKitMiddleware` into message history, contradicting the Antigravity `get_app_context()` step above.
- #84 Governed Action Approval UI: the useInterrupt path needs a backend that raises an interrupt with `metadata.action`; no Antigravity backend code is shown.
- #85 Governed Action Approval UI: `handleApproval` calls `executeSideEffect`, never defined.
- #86 Governed Action Approval UI: generic page with no Antigravity-specific code (no Code tab).
- #88 Surfaces: `Product`, `ProductRow` and `./catalog` are used but never shown.
- #92 State and actions: the page shows two different `app/catalog.tsx` and never the combined file; `Cart` is never defined.
- #96 Transports: only built-in / LangGraph Python agent guidance on an Antigravity page (see #95).
- #98 Markdown mode: only built-in / LangGraph Python agent guidance (see #97).
- #100 Adopt from A2UI: `Airport` and `Arrow` React components are never shown (only the A2UI "Before" definitions).
- #101 Components as Tools: Code tab `page.tsx` imports `PieChart`/`pieChartPropsSchema` from `./pie-chart` and `useSuggestions` from `./suggestions`; no tab shows either file (the tabs are `gen_ui_tool_based.py`, `page.tsx`, `bar-chart.tsx`, `route.ts`).
- #102 [Components and surfaces](https://docs.copilotkit.ai/google-antigravity/generative-ui/components) (also Surfaces, Standard catalog, State and actions, Theming): the new React Native links go to `/google-antigravity/react-native`, a 404 (added 2026-11-12).

## Build-only (`tsc` / `next build`; `npm run dev` runs fine)
