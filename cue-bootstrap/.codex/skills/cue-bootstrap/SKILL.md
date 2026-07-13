---
name: cue-bootstrap
description: Execute one phase of the issue #109 single-pattern CUE bootstrap loop.
---

# CUE bootstrap

Read `../../AGENTS.md` and declare one session class before acting.

Resolve the selected requirement and assertion IDs from issue #109. Restrict
mutation to that class's allowed paths. Do not copy contracts or runner behavior
from the parent repository's current CUE skill.

For implementation sessions:

1. record authority revision and selected surface;
2. use the configured CUE-LSP or gopls MCP server where applicable;
3. make one bounded change;
4. run only structural checks appropriate to that surface;
5. stop before fixture execution or subject correction.

For execution sessions:

1. verify the locked workbook environment;
2. select registered fixture and assertion IDs;
3. run cue-py in isolated mode and the independent Go runner;
4. retain raw diagnostics and stderr;
5. compare normalized facts in the workbook;
6. do not mutate any source.

For diagnosis sessions, produce one classification and proposed correction. A
later correction session applies it to one surface.
