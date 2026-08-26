import csv
import re
import sys
from pathlib import Path

import pdfplumber


COLUMNS = (
    "city_source_name",
    "county",
    "fy2023_population",
    "fy2023_payroll_rate",
    "fy2023_net_profits_rate",
    "fy2023_gross_receipts_rate",
)

TABLE_SETTINGS = {
    "vertical_strategy": "explicit",
    "explicit_vertical_lines": [36.2, 188.1, 313.1, 390.6, 493.5, 618.6, 755.6],
    "horizontal_strategy": "lines",
    "snap_tolerance": 3,
    "join_tolerance": 3,
    "intersection_tolerance": 5,
}


def normalize_cell(value: str | None) -> str:
    return re.sub(r"\s+", " ", value or "").strip()


def extract_rows(pdf_path: Path) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    with pdfplumber.open(pdf_path) as document:
        for page_number, page in enumerate(document.pages, start=1):
            table = page.extract_table(TABLE_SETTINGS) or []
            for cells in table:
                if len(cells) != len(COLUMNS):
                    continue
                values = [normalize_cell(value) for value in cells]
                city, county, population, *_ = values
                if not city or not county or not re.fullmatch(r"[\d,]+", population):
                    continue
                row = dict(zip(COLUMNS, values, strict=True))
                row["city_name"] = city.rstrip("*").strip()
                row["source_page"] = str(page_number)
                rows.append(row)
    return rows


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: extract-kentucky-klc-rates.py INPUT.pdf OUTPUT.csv")

    pdf_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    rows = extract_rows(pdf_path)
    if len(rows) != 410:
        raise ValueError(f"expected 410 FY2023 active-city rows, found {len(rows)}")

    fieldnames = ("city_name",) + COLUMNS + ("source_page",)
    with output_path.open("w", newline="", encoding="utf-8-sig") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    payroll_rows = [row for row in rows if re.search(r"\d+(?:\.\d+)?%", row["fy2023_payroll_rate"])]
    print(f"active_cities={len(rows)}")
    print(f"percentage_payroll_rows={len(payroll_rows)}")


if __name__ == "__main__":
    main()
