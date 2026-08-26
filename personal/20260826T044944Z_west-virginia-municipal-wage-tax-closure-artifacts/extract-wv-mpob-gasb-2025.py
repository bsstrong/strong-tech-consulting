"""Download and extract the complete MPOB 2025 GASB funded-ratio universe."""

from __future__ import annotations

import csv
import hashlib
import html
import re
from pathlib import Path
from urllib.parse import quote, quote_plus, urljoin
from urllib.request import Request, urlopen

import pdfplumber


ROOT = Path(__file__).resolve().parent
PLAN_INPUT = ROOT / "MPOB-2024-individual-plan-funded-ratios.csv"
PDF_DIRECTORY = ROOT / "MPOB-GASB-2025"
OUTPUT = ROOT / "MPOB-2025-individual-plan-funded-ratios.csv"
RESULTS_URL = "https://mpob.wv.gov/municipalresults/Pages/default.aspx?Municipality={}"


def source_name(municipality: str) -> str:
    return "Saint Albans" if municipality == "St. Albans" else municipality


def get_bytes(url: str) -> bytes:
    request = Request(url, headers={"User-Agent": "municipal-tax-registry-research/1.0"})
    with urlopen(request, timeout=60) as response:
        return response.read()


def report_links(municipality: str) -> dict[str, str]:
    page_url = RESULTS_URL.format(quote_plus(source_name(municipality)))
    document = get_bytes(page_url).decode("utf-8", errors="replace")
    links: dict[str, str] = {}
    for href, label in re.findall(r'<a href="([^"]+)"[^>]*>([^<]+GASB Report 2025)</a>', document):
        raw_url = urljoin(page_url, html.unescape(href))
        links[html.unescape(label).strip()] = quote(raw_url, safe=":/?=&%")
    return links


def extract_report(path: Path) -> tuple[str, float, int]:
    with pdfplumber.open(path) as pdf:
        title = pdf.pages[0].extract_text() or ""
        result = pdf.pages[4].extract_text() or ""
        page_count = len(pdf.pages)
    date_match = re.search(r"Measurement Period Ending ([^)]+)", title)
    ratio_match = re.search(r"Plan fiduciary net position as a percentage\s+([\d.]+)%", result)
    if not date_match or not ratio_match:
        raise RuntimeError(f"Expected measurement date or funded ratio missing in {path.name}")
    return date_match.group(1).strip(), float(ratio_match.group(1)), page_count


def main() -> None:
    PDF_DIRECTORY.mkdir(exist_ok=True)
    with PLAN_INPUT.open(newline="", encoding="utf-8-sig") as source:
        plans = list(csv.DictReader(source))
    if len(plans) != 53:
        raise RuntimeError(f"Expected 53 source plans, found {len(plans)}")

    cached_links: dict[str, dict[str, str]] = {}
    results: list[dict[str, object]] = []
    for plan in plans:
        municipality = plan["municipality"]
        plan_type = plan["plan_type"]
        if municipality not in cached_links:
            cached_links[municipality] = report_links(municipality)
        municipality_links = cached_links[municipality]
        label = f"{source_name(municipality)} {plan_type} GASB Report 2025"
        if label not in municipality_links:
            raise RuntimeError(f"Missing current report link: {label}")
        url = municipality_links[label]
        destination = PDF_DIRECTORY / f"{label}.pdf"
        if not destination.exists():
            destination.write_bytes(get_bytes(url))
        measurement_date, ratio, page_count = extract_report(destination)
        content = destination.read_bytes()
        results.append(
            {
                "municipality": municipality,
                "plan_type": plan_type,
                "gasb_2025_fiduciary_net_position_percent": f"{ratio:.2f}",
                "measurement_period_end": measurement_date,
                "source_url": url,
                "source_file": destination.relative_to(ROOT).as_posix(),
                "sha256": hashlib.sha256(content).hexdigest().upper(),
                "bytes": len(content),
                "pages": page_count,
            }
        )

    if len(results) != 53 or len({(row["municipality"], row["plan_type"]) for row in results}) != 53:
        raise RuntimeError("The extracted GASB universe is not exactly 53 unique plans")
    with OUTPUT.open("w", newline="", encoding="utf-8-sig") as target:
        writer = csv.DictWriter(target, fieldnames=list(results[0]))
        writer.writeheader()
        writer.writerows(results)
    ratios = [float(row["gasb_2025_fiduciary_net_position_percent"]) for row in results]
    print(f"Wrote {len(results)} plans; minimum June 30, 2025 ratio={min(ratios):.2f}%")


if __name__ == "__main__":
    main()
