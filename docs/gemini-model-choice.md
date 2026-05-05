# Gemini model choice for MVP

The recommended default model for the MVP is **gemini-3-flash-preview** because the product is early stage, speed matters, and the goal is to stay on the bleeding edge with the newest fast Gemini model.[cite:41][cite:42]

## Default model

Use `gemini-3-flash-preview` for the primary recommendation flow. Google positions Gemini 3 Flash as a speed-oriented frontier model, which fits an MVP that turns recorded user text plus a fixed practice library into near-real-time recommendations.[cite:41][cite:42]

## Fallback model

Use `gemini-3.1-pro-preview` as the fallback for heavier processing. Google describes Gemini 3.1 Pro Preview as the stronger option for complex reasoning, improved thinking, and more demanding agentic or software-oriented tasks.[cite:29][cite:30]

## Practical rule

Route normal recommendation requests to `gemini-3-flash-preview`, and escalate to `gemini-3.1-pro-preview` when the transcript is long, the reasoning is ambiguous, multiple practices are close matches, or deeper synthesis is required.[cite:29][cite:41]
