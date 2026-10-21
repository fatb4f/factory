#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
export PYTHONDONTWRITEBYTECODE=1
python3 scripts/python_api_facts.py --check state/python-api/facts.json
python3 scripts/test_python_native_bindings.py
