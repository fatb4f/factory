#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
cue vet -c=false ./contracts/personal/ivac:ivac
cue vet -c=false ./contracts/personal/ivac/evaluations:ivaceval
PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_ivac_regulatory.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_ivac_regulatory_sources.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_ivac_regulatory_bulk.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_ivac_medico_legal.py
