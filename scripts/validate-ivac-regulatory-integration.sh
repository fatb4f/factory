#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
export PYTHONDONTWRITEBYTECODE=1
python3 scripts/generate_ivac_regulatory_types.py --check
python3 scripts/test_ivac_regulatory_bulk.py
python3 scripts/test_ivac_regulatory_analytics.py
cue vet -c personal/ivac/regulatory/bulk-observations-20261017.json contracts/personal/ivac/*.cue -d '#RegulatoryBulkObservations'
