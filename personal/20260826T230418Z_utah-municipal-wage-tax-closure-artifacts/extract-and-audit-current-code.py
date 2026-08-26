from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

from pypdf import PdfReader


ROOT = Path(__file__).resolve().parent
CODE_DIR = ROOT / "current-code"

PHRASES = (
    "wage tax",
    "earnings tax",
    "payroll tax",
    "compensation tax",
    "municipal income tax",
    "city income tax",
    "local income tax",
    "political subdivision income tax",
)


def context(text: str, start: int, end: int, radius: int = 240) -> str:
    return text[max(0, start - radius) : min(len(text), end + radius)].strip()


files = []
phrase_results = {phrase: {"count": 0, "hits": []} for phrase in PHRASES}
proximity_hits = []
total_pages = 0
total_chars = 0

for pdf_path in sorted(CODE_DIR.glob("*.pdf")):
    reader = PdfReader(pdf_path, strict=False)
    pages = [(page.extract_text() or "") for page in reader.pages]
    raw_text = "\n\n".join(pages)
    text_path = pdf_path.with_suffix(".txt")
    text_path.write_text(raw_text, encoding="utf-8")
    normalized = re.sub(r"\s+", " ", raw_text)
    lowered = normalized.casefold()

    total_pages += len(pages)
    total_chars += len(raw_text)
    files.append(
        {
            "pdf": pdf_path.name,
            "pdf_bytes": pdf_path.stat().st_size,
            "pdf_sha256": hashlib.sha256(pdf_path.read_bytes()).hexdigest(),
            "pages": len(pages),
            "text": text_path.name,
            "text_bytes": text_path.stat().st_size,
            "text_sha256": hashlib.sha256(text_path.read_bytes()).hexdigest(),
        }
    )

    for phrase in PHRASES:
        for match in re.finditer(re.escape(phrase), lowered):
            phrase_results[phrase]["count"] += 1
            phrase_results[phrase]["hits"].append(
                {
                    "file": pdf_path.name,
                    "context": context(normalized, match.start(), match.end()),
                }
            )

    candidate_pattern = re.compile(
        r"(?:municipality|municipal|city|town|political subdivision).{0,300}"
        r"(?:wage|earnings|payroll|compensation).{0,120}tax|"
        r"(?:wage|earnings|payroll|compensation).{0,120}tax.{0,300}"
        r"(?:municipality|municipal|city|town|political subdivision)",
        re.IGNORECASE,
    )
    for match in candidate_pattern.finditer(normalized):
        proximity_hits.append(
            {
                "file": pdf_path.name,
                "context": context(normalized, match.start(), match.end(), 180),
            }
        )

audit = {
    "research_date": "2026-08-26",
    "official_current_titles": len(files),
    "total_pdf_bytes": sum(item["pdf_bytes"] for item in files),
    "total_pages": total_pages,
    "total_extracted_characters": total_chars,
    "phrase_results": phrase_results,
    "municipal_compensation_tax_proximity_hits": proximity_hits,
    "files": files,
}

(ROOT / "current-code-search-audit.json").write_text(
    json.dumps(audit, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
)

print(
    json.dumps(
        {
            "titles": len(files),
            "pages": total_pages,
            "characters": total_chars,
            "phrase_counts": {
                phrase: result["count"] for phrase, result in phrase_results.items()
            },
            "proximity_hits": len(proximity_hits),
        },
        indent=2,
    )
)
