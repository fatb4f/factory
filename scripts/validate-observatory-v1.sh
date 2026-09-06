#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Observatory V1 is the convergence of the core semantic/context runtime,
# presentation adapter, and industrial-signals reference workbook. Optional
# downstream exploratory adapters (for example property graph) are qualified
# separately and are intentionally not V1 completion dependencies.
bash scripts/validate-observatory.sh
bash scripts/validate-marimo-adapter.sh
bash scripts/validate-industrial-workbook.sh

echo "observatory v1 validation passed"
