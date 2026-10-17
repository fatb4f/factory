#!/usr/bin/env python3
"""Official-byte acquisition and lossless candidate inventory; no legal inference.

The candidate inventory is NOT a second compendium model. It is an extraction
work queue feeding the existing CUE #RegulatoryCompendium after explicit review.
"""
import argparse
from datetime import datetime, timezone
import json
from functools import lru_cache
from pathlib import Path
import re
import subprocess
import urllib.request
from urllib.parse import urlsplit

import ivac_regulatory as spans

ROOT = spans.ROOT
DATA = ROOT / "personal/ivac/regulatory"
SOURCES = DATA / "sources"
CATALOG = (
    ("gazette-2021-39", "https://www.publicationsduquebec.gouv.qc.ca/fileadmin/gazette/pdf_encrypte/gaz_entiere/2139-F.pdf", "2021-09-29", "enacted-regulation", "initial-enactment"),
    ("act-2021-13", "https://www.publicationsduquebec.gouv.qc.ca/fileadmin/Fichiers_client/lois_et_reglements/LoisAnnuelles/fr/2021/2021C13F.PDF", "2021-05-13", "enacted-act", "initial-enactment"),
    ("gazette-2026-04", "https://www.publicationsduquebec.gouv.qc.ca/fileadmin/gazette/pdf_encrypte/gaz_entiere/2604-F.pdf", "2026-01-28", "proposal", "not-established"),
)
ALLOWED_HOSTS = {"www.publicationsduquebec.gouv.qc.ca", "www.legisquebec.gouv.qc.ca"}

@lru_cache(maxsize=1)
def structure():
    """Read the existing CUE inventory; Python does not own leaf-unit topology."""
    inventory = json.loads(subprocess.check_output(
        ["cue", "export", "./contracts/personal/ivac:ivac", "-e", "regulatorySourceInventory", "--out", "json"], cwd=ROOT))
    sections = [str(n) for n in range(1, inventory["functionalHeadings"] + 2)]
    units = [child for section in sections
             for child in inventory["groupChildren"].get(section, [section])]
    return sections, units


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def encoded(value):
    return (json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n").encode("utf-8")


def local(path):
    result = (ROOT / path).resolve()
    if not result.is_relative_to(SOURCES.resolve()):
        raise ValueError("source path outside sources directory")
    return result


def acquire(directory=SOURCES):
    """Network is opt-in; CI verifies the retained original bytes offline."""
    directory = Path(directory)
    directory.mkdir(parents=True, exist_ok=True)
    records = []
    for identity, url, publication, kind, effect in CATALOG:
        original = directory / f"{identity}.pdf"
        text = directory / f"{identity}.txt"
        # Do not overwrite immutable acquired files with a changing response.
        if original.exists() or text.exists():
            raise FileExistsError(f"use a new source directory for reacquisition: {identity}")
        with urllib.request.urlopen(url, timeout=45) as response:
            if urlsplit(response.url).scheme != "https" or urlsplit(response.url).hostname not in ALLOWED_HOSTS:
                raise ValueError("redirect outside official HTTPS origins")
            content = response.read()
            if not content.startswith(b"%PDF-"):
                raise ValueError("official endpoint did not return PDF bytes")
        acquired = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
        original.write_bytes(content)
        subprocess.run(["pdftotext", "-layout", "-enc", "UTF-8", str(original), str(text)], check=True)
        version = subprocess.run(["pdftotext", "-v"], capture_output=True, text=True, check=True).stderr.splitlines()[0]
        record = {"id": identity, "url": url, "retrievedAt": acquired,
                  "publicationDate": publication, "publicationKind": kind,
                  "artifactPath": str(original.relative_to(ROOT)),
                  "artifactDigest": spans.digest(content), "artifactBytes": len(content),
                  "mediaType": "application/pdf", "textPath": str(text.relative_to(ROOT)),
                  "textDigest": spans.digest(text.read_bytes()),
                  "conversion": "pdftotext -layout -enc UTF-8", "converterVersion": version,
                  "legalEffect": effect}
        spans.validate(record, "#RegulatoryAcquisition")
        (directory / f"{identity}.json").write_bytes(encoded(record))
        records.append(record)
    return records


def verify_acquisition(record, reconvert=False):
    spans.validate(record, "#RegulatoryAcquisition")
    original, text = local(record["artifactPath"]), local(record["textPath"])
    if original.stat().st_size != record["artifactBytes"] or spans.digest(original.read_bytes()) != record["artifactDigest"]:
        raise ValueError("original artifact integrity mismatch")
    if spans.digest(text.read_bytes()) != record["textDigest"]:
        raise ValueError("converted text integrity mismatch")
    if reconvert:
        result = subprocess.run(["pdftotext", "-layout", "-enc", "UTF-8", str(original), "-"], capture_output=True, check=True)
        if result.stdout != text.read_bytes():
            raise ValueError("conversion differs; retain the pinned converter or audit a new version")
    return text.read_bytes().decode("utf-8")


def citation(text, identity, start, end, locator):
    return {"sourceVersion": identity, "start": start, "end": end,
            "exactText": text[start:end], "locator": locator}


def build(record, text):
    """Keep every annex character. Headings and tokens are a review index only."""
    identity = record["id"]
    expected_sections, expected_units = structure()
    start = re.search(r"^ +ANNEXE I\s*$", text, re.M).start()
    end = re.search(r"^ +ANNEXE II\s*$", text[start:], re.M).start() + start
    annex = text[start:end]
    headings = [m for m in re.finditer(r"^ +([0-9]+)\. ([^\n]+)", annex, re.M)
                if m[2][:5].isupper()]
    if [m[1] for m in headings] != expected_sections:
        raise ValueError("unexpected annex section sequence")
    contents_end = start + headings[0].start()
    sections = []
    for i, match in enumerate(headings):
        a = start + match.start()
        b = start + headings[i + 1].start() if i + 1 < len(headings) else end
        sections.append({"number": match[1],
                         "heading": citation(text, identity, a, start + match.end(), f"Annexe I, rubrique {match[1]}"),
                         "text": citation(text, identity, a, b, f"Annexe I, rubrique {match[1]} (intégrale)")})
    labels = {}
    for match in re.finditer(r"^ +([0-9]+(?:\.[0-9]+)?)\.? +([^\n]+)", text[start:contents_end], re.M):
        number = match[1]
        if number in expected_units:
            if number in labels:
                raise ValueError("duplicate leaf unit label")
            labels[number] = citation(text, identity, start + match.start(), start + match.end(), f"Annexe I, unités, {number}")
    if set(labels) != set(expected_units):
        raise ValueError("missing or unexpected leaf unit labels")
    chapter_start = text.index("CHAPITRE III", text.index("Décret 1266-2021, 22 septembre 2021"))
    chapter_end = text.index("CHAPITRE IV", chapter_start)
    markers = []
    patterns = {"severity": r"(?i)GRAVITÉ\s+[0-9]+", "percentage": r"[0-9]+(?:,[0-9]+)?\s*%",
                "alternative": r"\bou\b", "evaluation-rules": r"RÈGLES D’ÉVALUATION"}
    for kind, pattern in patterns.items():
        for match in re.finditer(pattern, annex):
            a, b = start + match.start(), start + match.end()
            markers.append({"kind": kind, "citation": citation(text, identity, a, b, f"Annexe I, marqueur {kind}")})
    markers.sort(key=lambda x: (x["citation"]["start"], x["kind"]))
    return {"format": "ivac.regulatory-serialization/v1", "status": "candidate", "acquisition": record,
            "annex": citation(text, identity, start, end, "Annexe I (texte intégral)"),
            "contents": citation(text, identity, start, contents_end, "Annexe I, liste des unités"),
            "sections": sections,
            "units": [{"number": n, "kind": "aesthetic" if n.split(".")[0] == expected_sections[-1] else "functional",
                       "label": labels[n], "section": n.split(".")[0]} for n in expected_units],
            "globalRules": [citation(text, identity, chapter_start, chapter_end, "Chapitre III, évaluation et somme forfaitaire")],
            "markers": markers,
            "coverage": {"text": "complete-annex-partition", "semantics": "pending-review",
                         "amendmentHistory": "incomplete", "caseApplicability": "unresolved"},
            "blockers": ["Later consolidated versions and exhaustive amendment audit unavailable: Légis Québec HTTP 502.",
                         "All class rows, conditional percentages, alternative logic, exclusions and weighted tables require explicit semantic review into #RegulatoryCompendium.",
                         "Original Act transitional provisions are retained; subsequent changes and case applicability remain unresolved."]}


def verify_candidate(candidate, text):
    # A deterministic source-derived inventory proves partition, leaf identity,
    # marker coverage and absence of silently dropped table content.
    expected = build(candidate["acquisition"], text)
    if candidate != expected:
        raise ValueError("candidate differs from complete source-derived inventory")
    spans.validate(candidate, "#RegulatorySerializationCandidate")
    for c in spans.citations(candidate):
        spans.verify_span(c, text, candidate["acquisition"]["id"])


def compare(before, after):
    """Text differences are not amendments and never establish applicability."""
    old = {s["number"]: s["text"]["exactText"] for s in before["sections"]}
    new = {s["number"]: s["text"]["exactText"] for s in after["sections"]}
    return {"format": "ivac.regulatory-text-diff/v1", "authority": "none",
            "before": before["acquisition"]["id"], "after": after["acquisition"]["id"],
            "added": sorted(new.keys() - old.keys()), "removed": sorted(old.keys() - new.keys()),
            "changed": sorted(k for k in new.keys() & old.keys() if new[k] != old[k]),
            "legalEffect": "not-determined"}


def verify_audit(audit):
    spans.validate(audit, "#RegulatoryHistoryAudit")
    texts = {identity: verify_acquisition(record) for identity, record in audit["artifacts"].items()}
    for finding in audit["findings"]:
        c = finding["citation"]
        spans.verify_span(c, texts[c["sourceVersion"]], c["sourceVersion"])
        if finding["kind"] == "proposal" and audit["artifacts"][c["sourceVersion"]]["publicationKind"] != "proposal":
            raise ValueError("proposal finding requires a proposal artifact")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["acquire", "build", "verify", "audit", "compare"])
    parser.add_argument("paths", nargs="*", type=Path)
    args = parser.parse_args()
    if args.mode == "acquire":
        if len(args.paths) > 1:
            parser.error("acquire takes at most one new source directory")
        acquire(args.paths[0] if args.paths else SOURCES)
    elif args.mode == "build":
        if len(args.paths) != 1:
            parser.error("build requires an acquisition record")
        record = read_json(args.paths[0])
        value = build(record, verify_acquisition(record))
        verify_candidate(value, local(record["textPath"]).read_bytes().decode("utf-8"))
        print(encoded(value).decode("utf-8"), end="")
    elif args.mode == "verify":
        if len(args.paths) != 1:
            parser.error("verify requires a candidate file")
        value = read_json(args.paths[0])
        verify_candidate(value, verify_acquisition(value["acquisition"]))
    elif args.mode == "audit":
        if len(args.paths) != 1:
            parser.error("audit requires a history audit file")
        verify_audit(read_json(args.paths[0]))
    else:
        if len(args.paths) != 2:
            parser.error("compare requires two independently verified candidates")
        values = [read_json(p) for p in args.paths]
        for value in values:
            verify_candidate(value, verify_acquisition(value["acquisition"]))
        print(encoded(compare(*values)).decode("utf-8"), end="")


if __name__ == "__main__":
    main()
