"""Render the major incident directory from CUE-validated review bundles."""
import argparse
import html
import json
import os
from pathlib import Path
import subprocess
from urllib.parse import quote

PROJECT = Path(__file__).resolve().parent
ROOT = PROJECT.parents[1]
DIRECTORY = PROJECT / "global-major-cyber" / "incidents"
SCHEMA = "./contracts/projects/cyber-incidents"


def cell(value):
    """Keep source text inside one Markdown table cell."""
    value = html.escape(" ".join(value.split()), quote=False)
    for char in r"\|*_`[]":
        value = value.replace(char, f"&#{ord(char)};")
    return value


def render(directory):
    rows = []
    for path in sorted(directory.iterdir()):
        if not path.is_dir():
            continue
        bundle = path / "bundle.json"
        result = subprocess.run(
            [os.environ.get("CUE", "cue"), "export", SCHEMA, str(bundle),
             "-d", "#CatalogBundle", "--out", "json"],
            cwd=ROOT, check=True, capture_output=True, text=True,
        )
        record = json.loads(result.stdout)
        incident = record["incident"]
        if incident["id"] != path.name:
            raise ValueError(f"{bundle}: folder must match incident ID {incident['id']!r}")
        date = incident["catalogDate"]
        claim = incident["publicClaims"][date["publicClaimID"]]
        acquisition = record["acquisition"]
        links = []
        for citation in claim["citations"]:
            capture = acquisition["captures"][citation["captureID"]]
            publisher = acquisition["sources"][capture["sourceID"]]["publisher"]
            url = quote(capture["locator"], safe=":/?&=#;%+@,~!$'()-._")
            link = f"[{cell(publisher)}](<{url}>)"
            if link not in links:
                links.append(link)
        rows.append((date["day"],
                     f"| {date['day']} | [{cell(incident['title'])}]({path.name}/bundle.json) "
                     f"| {date['basis'].replace('-', ' ')} | {cell(claim['summary'])} "
                     f"| {', '.join(links)} |"))

    # Keep same-day incidents in stable ID order.
    rows.sort(key=lambda row: row[0], reverse=True)
    return "\n".join([
        "# Major cyber incidents worldwide", "",
        "Newest documented incident date first. Open an incident for its source revisions and citations.",
        "", "| Date | Incident | Date basis | What the source records | Date source |",
        "| --- | --- | --- | --- | --- |", *(row[1] for row in rows), "",
    ])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail if the index is stale")
    args = parser.parse_args()
    index = DIRECTORY / "README.md"
    try:
        content = render(DIRECTORY)
        if args.check:
            if content != index.read_text(encoding="utf-8"):
                parser.exit(1, f"Stale index: run python3 {Path(__file__).relative_to(ROOT)}\n")
        else:
            index.write_text(content, encoding="utf-8")
    except subprocess.CalledProcessError as exc:
        parser.exit(1, exc.stderr)
    except (OSError, ValueError) as exc:
        parser.exit(1, f"{exc}\n")


if __name__ == "__main__":
    main()
