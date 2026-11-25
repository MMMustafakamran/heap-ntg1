"use client";
// CHANGED: the A2UI overview page only shows fragments. Its recommended setup is the provider line
// below (verbatim); `myCatalog` is never defined on this page, so it is the Dynamic Schema page's
// catalog, and the agent is the quickstart agent (antigravity_agent, :8040) since the page names none.
import { CopilotKit, CopilotChat } from "@copilotkit/react-core/v2";
import { myCatalog } from "./dynamic-schema/a2ui/catalog"; // ADDED: myCatalog is never defined on this page, catalog from the Dynamic Schema page

export default function Page() {
  return (
    // --- Doc (verbatim) + CHANGED: agent ---
    <CopilotKit runtimeUrl="/api/copilotkit" agent="antigravity_agent" a2ui={{ catalog: myCatalog }}>
      <div className="h-screen w-full">
        <CopilotChat className="h-full" />
      </div>
    </CopilotKit>
  );
}
