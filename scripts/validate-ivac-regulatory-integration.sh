#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
export PYTHONDONTWRITEBYTECODE=1
export HYPOTHESIS_STORAGE_DIRECTORY="${TMPDIR:-/tmp}/factory-ivac-hypothesis"
python3 scripts/generate_ivac_regulatory_types.py --check
python3 scripts/test_ivac_legal_units.py
python3 scripts/test_ivac_review_desk.py
python3 scripts/test_ivac_regulatory_schedule_index.py
python3 scripts/test_ivac_regulatory_bulk.py
python3 scripts/test_ivac_regulatory_analytics.py
cue vet -c personal/ivac/regulatory/bulk-observations-20261017.json contracts/personal/ivac/*.cue -d '#RegulatoryBulkObservations'
python3 scripts/test_ivac_regulatory_interpretation.py

python3 scripts/generate_ivac_workbench_types.py --check
python3 scripts/test_ivac_workbench.py
python3 scripts/generate_ivac_timeline_types.py --check
python3 scripts/test_ivac_timeline.py
python3 scripts/generate_ivac_corpus_types.py --check
python3 scripts/test_ivac_official_corpus.py
