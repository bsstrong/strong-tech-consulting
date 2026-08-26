from __future__ import annotations

import csv
import hashlib
import json
from collections import Counter
from datetime import date, datetime, timezone
from decimal import Decimal
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parent
SOURCES = ROOT / "sources"
SNAPSHOT_DATE = date(2026, 8, 25)
RETRIEVED_AT = "2026-08-26T00:02:05+00:00"

URLS = {
    "oh_manifest": "https://thefinder.tax.ohio.gov/api/file-downloads?type=municipality",
    "oh_rates": "https://api.thefinder.tax.ohio.gov/finder/api/v1/tax-rates/downloads/Muni/OHMuniRateTable.csv",
    "oh_fips": "https://api.thefinder.tax.ohio.gov/finder/api/v1/tax-rates/downloads/OHMuniFIPSCodes.txt",
    "oh_jedd": "https://api.thefinder.tax.ohio.gov/finder/api/v1/tax-rates/downloads/JEDTaxRates.csv",
    "pa_official_page": "https://apps.dced.pa.gov/munstats-public/ReportInformation2.aspx?report=EitWithCollector_Dyn_Excel&type=O",
    "pa_official_download": "https://apps.dced.pa.gov/munstats-public/ReportToPdf.aspx?report=EitWithCollector_Dyn_Excel&paramList=O;2026",
    "pa_realtime_page": "https://apps.dced.pa.gov/munstats-public/ReportInformation2.aspx?report=EitWithCollector_Dyn_Excel&type=R",
    "pa_realtime_download": "https://apps.dced.pa.gov/munstats-public/ReportToPdf.aspx?report=EitWithCollector_Dyn_Excel&paramList=R;2026",
    "pa_philadelphia": "https://www.phila.gov/services/business-self-employment/business-taxes/wage-tax-employers/",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def decimal_text(value: object) -> str:
    text = str(value).strip()
    if not text:
        return "0"
    result = format(Decimal(text), "f")
    if "." in result:
        result = result.rstrip("0").rstrip(".")
    return result or "0"


def yyyymmdd(value: object) -> str:
    text = str(value).strip()
    return f"{text[0:4]}-{text[4:6]}-{text[6:8]}"


def write_csv(path: Path, rows: list[dict], fieldnames: list[str] | None = None) -> None:
    if fieldnames is None:
        fieldnames = list(rows[0]) if rows else []
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def write_jsonl(path: Path, rows: list[dict]) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False, sort_keys=True) + "\n")


def build_ohio() -> dict:
    raw_manifest = json.loads((SOURCES / "ohio_finder_manifest.json").read_text(encoding="utf-8-sig"))
    manifest = {
        "metadata": {
            "source_url": URLS["oh_manifest"],
            "retrieved_at": RETRIEVED_AT,
            "source_sha256": sha256(SOURCES / "ohio_finder_manifest.json"),
        },
        "payload": raw_manifest,
    }
    (ROOT / "ohio_finder_manifest_snapshot.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )

    rates = pd.read_csv(
        SOURCES / "ohio_municipal_rate_table.csv",
        header=None,
        names=["effective_start", "effective_end", "fips_code", "rate_name", "rate_fraction"],
        dtype={"effective_start": str, "effective_end": str, "fips_code": str, "rate_name": str, "rate_fraction": str},
        keep_default_na=False,
    )
    fips = pd.read_csv(
        SOURCES / "ohio_municipal_fips.csv",
        dtype=str,
        encoding="utf-8-sig",
        keep_default_na=False,
    ).rename(columns={"FIPS_CODE": "fips_code", "MUNI_NAME": "fips_name"})
    as_of = SNAPSHOT_DATE.strftime("%Y%m%d")
    active = rates[
        (rates["effective_start"] <= as_of)
        & (rates["effective_end"] >= as_of)
        & (rates["rate_fraction"].map(Decimal) > 0)
    ].copy()
    assert not active.duplicated("fips_code").any()
    joined = active.merge(fips, on="fips_code", how="left", validate="one_to_one", indicator=True)
    assert (joined["_merge"] == "both").all()
    assert (joined["rate_name"].str.strip().str.upper() == joined["fips_name"].str.strip().str.upper()).all()

    ohio_rows = []
    for row in joined.sort_values("fips_code").itertuples(index=False):
        rate_fraction = Decimal(str(row.rate_fraction))
        ohio_rows.append(
            {
                "fips_code": row.fips_code,
                "municipality_name": row.fips_name.strip(),
                "tax_category": "MUNICIPAL_INCOME_TAX",
                "rate_percent": decimal_text(rate_fraction * 100),
                "rate_fraction": decimal_text(rate_fraction),
                "effective_start_date": yyyymmdd(row.effective_start),
                "effective_end_date": yyyymmdd(row.effective_end),
                "snapshot_as_of_date": SNAPSHOT_DATE.isoformat(),
                "source_rate_url": URLS["oh_rates"],
                "source_fips_url": URLS["oh_fips"],
                "source_manifest_url": URLS["oh_manifest"],
                "retrieved_at": RETRIEVED_AT,
            }
        )
    write_csv(ROOT / "ohio_current_positive_municipal_rates.csv", ohio_rows)

    jedd = pd.read_csv(
        SOURCES / "ohio_jedd_jedz_rates.csv",
        dtype={"EffStartDate": str, "EffEndDate": str, "JEDD_ID": str, "Name": str, "Rate": str},
        keep_default_na=False,
    )
    jedd_active = jedd[
        (jedd["EffStartDate"] <= as_of)
        & (jedd["EffEndDate"] >= as_of)
        & (jedd["Rate"].map(Decimal) > 0)
    ].copy()
    assert not jedd_active.duplicated("JEDD_ID").any()
    jedd_rows = []
    for row in jedd_active.sort_values("JEDD_ID").itertuples(index=False):
        rate_percent = Decimal(str(row.Rate))
        upper_name = row.Name.upper()
        zone_type = "JEDZ" if "JEDZ" in upper_name else "JEDD" if "JEDD" in upper_name else "JEDD_JEDZ_UNSPECIFIED"
        jedd_rows.append(
            {
                "jedd_jedz_id": row.JEDD_ID,
                "name": row.Name.strip(),
                "zone_type_from_official_name": zone_type,
                "tax_category": "JEDD_JEDZ_INCOME_TAX",
                "rate_percent": decimal_text(rate_percent),
                "rate_fraction": decimal_text(rate_percent / 100),
                "effective_start_date": yyyymmdd(row.EffStartDate),
                "effective_end_date": yyyymmdd(row.EffEndDate),
                "snapshot_as_of_date": SNAPSHOT_DATE.isoformat(),
                "source_url": URLS["oh_jedd"],
                "retrieved_at": RETRIEVED_AT,
            }
        )
    write_csv(ROOT / "ohio_current_jedd_jedz_rates.csv", jedd_rows)

    return {
        "source_rate_rows": int(len(rates)),
        "source_fips_rows": int(len(fips)),
        "source_jedd_jedz_rows": int(len(jedd)),
        "current_positive_municipal_rows": len(ohio_rows),
        "current_positive_jedd_jedz_rows": len(jedd_rows),
        "current_positive_municipal_duplicate_fips": len(ohio_rows) - len({r["fips_code"] for r in ohio_rows}),
        "current_positive_jedd_jedz_duplicate_ids": len(jedd_rows) - len({r["jedd_jedz_id"] for r in jedd_rows}),
        "current_positive_rates_missing_official_fips": int((joined["_merge"] != "both").sum()),
        "official_fips_without_current_positive_rate": int(len(set(fips["fips_code"]) - set(active["fips_code"]))),
    }


PA_RENAME = {
    "Municipality ": "municipality_name_official",
    "Municipality ID": "municipality_id",
    "School District ID": "school_district_id",
    "School District Name": "school_district_name",
    "PSD Code": "psd_code",
    "Municipal Nonresident EIT (percent)": "municipal_nonresident_eit_percent",
    "Municipal Nonresident EIT Effective Date": "municipal_nonresident_eit_effective_date",
    "Municipal Resident EIT (percent)": "municipal_resident_eit_percent",
    "Municipal Resident EIT Effective Date": "municipal_resident_eit_effective_date",
    "School District EIT (percent)": "school_district_eit_percent",
    "School District EIT Effective Date": "school_district_eit_effective_date",
    "School District PIT (percent)": "school_district_pit_percent",
    "Total Resident Income Tax (percent)": "total_resident_income_tax_percent",
    "Municipal EIT LIE (dollars)": "municipal_eit_lie_dollars",
    "School District EIT LIE (dollars)": "school_district_eit_lie_dollars",
    "Municipal LST (dollars)": "municipal_lst_dollars",
    "Municipal LST Effective Date": "municipal_lst_effective_date",
    "School District LST (dollars)": "school_district_lst_dollars",
    "School District LST Effective Date": "school_district_lst_effective_date",
    "Total LST (dollars)": "total_lst_dollars",
    "Municipal LST LIE (dollars)": "municipal_lst_lie_dollars",
    "School District LST LIE (dollars)": "school_district_lst_lie_dollars",
    "EIT Collector": "eit_collector",
    "EIT Collector City": "eit_collector_city",
    "EIT Collector State": "eit_collector_state",
    "EIT Collector Zip": "eit_collector_zip",
    "EIT Collector Phone": "eit_collector_phone",
    "EIT Collector Email": "eit_collector_email",
    "EIT Collector Web Site": "eit_collector_website",
    "Municipal LST Collector": "municipal_lst_collector",
    "Municipal LST Collector Web Site": "municipal_lst_collector_website",
    "School District LST Collector": "school_district_lst_collector",
    "School District LST Collector Web Site": "school_district_lst_collector_website",
    "Tax Collection District Name": "tax_collection_district_name",
    "Date Last Updated": "date_last_updated",
}

PA_NUMERIC = [
    "municipal_nonresident_eit_percent",
    "municipal_resident_eit_percent",
    "school_district_eit_percent",
    "school_district_pit_percent",
    "total_resident_income_tax_percent",
    "municipal_eit_lie_dollars",
    "school_district_eit_lie_dollars",
    "municipal_lst_dollars",
    "school_district_lst_dollars",
    "total_lst_dollars",
    "municipal_lst_lie_dollars",
    "school_district_lst_lie_dollars",
]


def pa_type(name: str) -> str:
    token = name.strip().upper().split()[-1]
    mapping = {
        "TWP": "township",
        "TOWNSHIP": "township",
        "BORO": "borough",
        "BOROUGH": "borough",
        "CITY": "city",
        "TOWN": "town",
    }
    if token not in mapping:
        raise ValueError(f"Unknown official municipality suffix: {name!r}")
    return mapping[token]


def pa_date_max(values: list[str]) -> str:
    parsed = [pd.to_datetime(v, errors="coerce") for v in values if str(v).strip()]
    parsed = [v for v in parsed if not pd.isna(v)]
    return max(parsed).date().isoformat() if parsed else ""


def pa_text_variants(values: list[str]) -> str:
    return ";".join(sorted({str(value).strip() for value in values if str(value).strip()}))


def normalize_pa(path: Path, kind: str, as_of_date: str, page_url: str, download_url: str) -> tuple[list[dict], dict]:
    df = pd.read_csv(path, header=1, dtype=str, keep_default_na=False).rename(columns=PA_RENAME)
    if "date_last_updated" not in df:
        df["date_last_updated"] = ""
    df.columns = [str(c).strip() for c in df.columns]
    for column in PA_NUMERIC:
        df[column] = df[column].map(decimal_text)
    for column in ["psd_code", "municipality_id", "school_district_id"]:
        df[column] = df[column].str.strip()

    source_duplicate_psd_rows = int(df.duplicated("psd_code", keep=False).sum())
    source_duplicate_psd_keys = int(df.loc[df.duplicated("psd_code", keep=False), "psd_code"].nunique())
    rows = []
    stable_fields = [
        "municipality_name_official",
        "school_district_id",
        "school_district_name",
        *PA_NUMERIC,
        "eit_collector",
        "eit_collector_city",
        "eit_collector_state",
        "eit_collector_zip",
        "eit_collector_phone",
        "eit_collector_email",
        "eit_collector_website",
        "tax_collection_district_name",
    ]
    for psd_code, group in df.groupby("psd_code", sort=True):
        for field in stable_fields:
            values = {str(v).strip() for v in group[field]}
            if len(values) != 1:
                raise ValueError(f"PSD {psd_code}: inconsistent {field}: {sorted(values)}")
        first = group.iloc[0]
        municipal_nonresident = Decimal(first["municipal_nonresident_eit_percent"])
        municipal_resident = Decimal(first["municipal_resident_eit_percent"])
        school_eit = Decimal(first["school_district_eit_percent"])
        if municipal_nonresident > 0:
            scope_category = "MUNICIPAL_EIT_WORK_LOCATION"
        elif municipal_resident > 0:
            scope_category = "MUNICIPAL_EIT_RESIDENT_ONLY"
        elif school_eit > 0:
            scope_category = "SCHOOL_DISTRICT_EIT_ONLY"
        else:
            scope_category = "NO_EIT_POSITIVE"
        row = {
            "psd_code": psd_code,
            "counties": sorted({str(v).strip() for v in group["County"]}),
            "municipality_ids": sorted({str(v).strip() for v in group["municipality_id"]}),
            "municipality_name_official": str(first["municipality_name_official"]).strip(),
            "municipality_type_from_official_suffix": pa_type(str(first["municipality_name_official"])),
            "school_district_id": first["school_district_id"],
            "school_district_name": str(first["school_district_name"]).strip(),
            **{field: first[field] for field in PA_NUMERIC},
            "municipal_nonresident_eit_effective_date": pa_text_variants(group["municipal_nonresident_eit_effective_date"].tolist()),
            "municipal_resident_eit_effective_date": pa_text_variants(group["municipal_resident_eit_effective_date"].tolist()),
            "school_district_eit_effective_date": pa_text_variants(group["school_district_eit_effective_date"].tolist()),
            "municipal_lst_effective_date": pa_text_variants(group["municipal_lst_effective_date"].tolist()),
            "school_district_lst_effective_date": pa_text_variants(group["school_district_lst_effective_date"].tolist()),
            "eit_collector": str(first["eit_collector"]).strip(),
            "eit_collector_city": str(first["eit_collector_city"]).strip(),
            "eit_collector_state": str(first["eit_collector_state"]).strip(),
            "eit_collector_zip": str(first["eit_collector_zip"]).strip(),
            "eit_collector_phone": str(first["eit_collector_phone"]).strip(),
            "eit_collector_email": str(first["eit_collector_email"]).strip(),
            "eit_collector_website": str(first["eit_collector_website"]).strip(),
            "municipal_lst_collector": pa_text_variants(group["municipal_lst_collector"].tolist()),
            "municipal_lst_collector_website": pa_text_variants(group["municipal_lst_collector_website"].tolist()),
            "school_district_lst_collector": pa_text_variants(group["school_district_lst_collector"].tolist()),
            "school_district_lst_collector_website": pa_text_variants(group["school_district_lst_collector_website"].tolist()),
            "tax_collection_district_name": str(first["tax_collection_district_name"]).strip(),
            "date_last_updated": pa_date_max(group["date_last_updated"].tolist()),
            "source_row_count": int(len(group)),
            "scope_category": scope_category,
            "register_kind": kind,
            "register_as_of_date": as_of_date,
            "source_page_url": page_url,
            "source_download_url": download_url,
            "retrieved_at": RETRIEVED_AT,
        }
        rows.append(row)

    total_mismatches = 0
    for row in rows:
        component_total = (
            Decimal(row["municipal_resident_eit_percent"])
            + Decimal(row["school_district_eit_percent"])
            + Decimal(row["school_district_pit_percent"])
        )
        if component_total != Decimal(row["total_resident_income_tax_percent"]):
            total_mismatches += 1
    assert len(rows) == len({row["psd_code"] for row in rows})
    return rows, {
        "source_rows": int(len(df)),
        "normalized_psd_rows": len(rows),
        "source_duplicate_psd_rows": source_duplicate_psd_rows,
        "source_duplicate_psd_keys": source_duplicate_psd_keys,
        "normalized_duplicate_psd_keys": len(rows) - len({row["psd_code"] for row in rows}),
        "resident_total_component_mismatches": total_mismatches,
        "scope_category_counts": dict(sorted(Counter(row["scope_category"] for row in rows).items())),
        "municipal_lst_positive_psd_rows": sum(Decimal(row["municipal_lst_dollars"]) > 0 for row in rows),
        "school_district_lst_positive_psd_rows": sum(Decimal(row["school_district_lst_dollars"]) > 0 for row in rows),
    }


def build_pennsylvania() -> dict:
    official_rows, official_validation = normalize_pa(
        SOURCES / "pennsylvania_official_register_2026_utf8.csv",
        "official",
        "2026-06-15",
        URLS["pa_official_page"],
        URLS["pa_official_download"],
    )
    realtime_rows, realtime_validation = normalize_pa(
        SOURCES / "pennsylvania_realtime_register_2026_utf8.csv",
        "real_time",
        SNAPSHOT_DATE.isoformat(),
        URLS["pa_realtime_page"],
        URLS["pa_realtime_download"],
    )
    write_jsonl(ROOT / "pennsylvania_official_register_normalized.jsonl", official_rows)
    write_jsonl(ROOT / "pennsylvania_realtime_register_normalized.jsonl", realtime_rows)

    in_scope = [
        row
        for row in realtime_rows
        if row["scope_category"] in {"MUNICIPAL_EIT_WORK_LOCATION", "MUNICIPAL_EIT_RESIDENT_ONLY"}
    ]
    in_scope_fields = [
        "psd_code",
        "counties",
        "municipality_ids",
        "municipality_name_official",
        "municipality_type_from_official_suffix",
        "school_district_id",
        "school_district_name",
        "scope_category",
        "municipal_nonresident_eit_percent",
        "municipal_nonresident_eit_effective_date",
        "municipal_resident_eit_percent",
        "municipal_resident_eit_effective_date",
        "school_district_eit_percent",
        "school_district_pit_percent",
        "total_resident_income_tax_percent",
        "municipal_lst_dollars",
        "school_district_lst_dollars",
        "total_lst_dollars",
        "eit_collector",
        "eit_collector_website",
        "tax_collection_district_name",
        "date_last_updated",
        "register_as_of_date",
        "source_page_url",
        "source_download_url",
        "philadelphia_overlay_url",
        "retrieved_at",
    ]
    in_scope_csv = []
    for row in in_scope:
        record = dict(row)
        record["counties"] = ";".join(row["counties"])
        record["municipality_ids"] = ";".join(row["municipality_ids"])
        record["philadelphia_overlay_url"] = URLS["pa_philadelphia"] if row["psd_code"] == "510101" else ""
        in_scope_csv.append(record)
    write_csv(ROOT / "pennsylvania_current_in_scope_positive_municipal_eit.csv", in_scope_csv, in_scope_fields)

    official_by_psd = {row["psd_code"]: row for row in official_rows}
    realtime_by_psd = {row["psd_code"]: row for row in realtime_rows}
    assert set(official_by_psd) == set(realtime_by_psd)
    compare_fields = [
        "municipal_nonresident_eit_percent",
        "municipal_resident_eit_percent",
        "school_district_eit_percent",
        "school_district_pit_percent",
        "total_resident_income_tax_percent",
        "municipal_lst_dollars",
        "school_district_lst_dollars",
        "total_lst_dollars",
        "eit_collector",
    ]
    changes = []
    for psd_code in sorted(official_by_psd):
        old = official_by_psd[psd_code]
        new = realtime_by_psd[psd_code]
        for field in compare_fields:
            if str(old[field]) != str(new[field]):
                changes.append(
                    {
                        "change_key": f"{psd_code}|{field}",
                        "psd_code": psd_code,
                        "municipality_name_official": new["municipality_name_official"],
                        "field": field,
                        "official_2026_06_15_value": old[field],
                        "realtime_2026_08_25_value": new[field],
                        "official_source_url": URLS["pa_official_download"],
                        "realtime_source_url": URLS["pa_realtime_download"],
                    }
                )
    assert len(changes) == len({row["change_key"] for row in changes})
    write_csv(ROOT / "pennsylvania_official_to_realtime_changes.csv", changes)

    phila = realtime_by_psd["510101"]
    phila_overlay = {
        "psd_code": "510101",
        "municipality_name_official": phila["municipality_name_official"],
        "effective_date": "2026-07-01",
        "city_resident_wage_tax_percent": "3.735",
        "city_nonresident_wage_tax_percent": "3.425",
        "realtime_register_resident_percent": phila["municipal_resident_eit_percent"],
        "realtime_register_nonresident_percent": phila["municipal_nonresident_eit_percent"],
        "reconciliation_status": "MATCH",
        "overlay_behavior": "Source corroboration only; do not add a second tax row.",
        "city_source_url": URLS["pa_philadelphia"],
        "register_source_url": URLS["pa_realtime_download"],
        "retrieved_at": RETRIEVED_AT,
    }
    assert phila["municipal_resident_eit_percent"] == "3.735"
    assert phila["municipal_nonresident_eit_percent"] == "3.425"
    (ROOT / "pennsylvania_philadelphia_overlay.json").write_text(
        json.dumps(phila_overlay, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return {
        "official": official_validation,
        "real_time": realtime_validation,
        "current_in_scope_positive_municipal_eit_rows": len(in_scope),
        "current_in_scope_duplicate_psd_keys": len(in_scope) - len({row["psd_code"] for row in in_scope}),
        "official_to_realtime_changed_psd_keys": len({row["psd_code"] for row in changes}),
        "official_to_realtime_changed_fields": len(changes),
        "philadelphia_overlay_reconciliation": "MATCH",
    }


def main() -> None:
    ohio = build_ohio()
    pennsylvania = build_pennsylvania()
    source_files = {
        path.name: {"bytes": path.stat().st_size, "sha256": sha256(path)}
        for path in sorted(SOURCES.iterdir())
        if path.is_file()
    }
    output_names = [
        "ohio_finder_manifest_snapshot.json",
        "ohio_current_positive_municipal_rates.csv",
        "ohio_current_jedd_jedz_rates.csv",
        "pennsylvania_official_register_normalized.jsonl",
        "pennsylvania_realtime_register_normalized.jsonl",
        "pennsylvania_current_in_scope_positive_municipal_eit.csv",
        "pennsylvania_official_to_realtime_changes.csv",
        "pennsylvania_philadelphia_overlay.json",
    ]
    output_files = {
        name: {"bytes": (ROOT / name).stat().st_size, "sha256": sha256(ROOT / name)}
        for name in output_names
    }
    validation = {
        "snapshot_date": SNAPSHOT_DATE.isoformat(),
        "retrieved_at": RETRIEVED_AT,
        "ohio": ohio,
        "pennsylvania": pennsylvania,
        "output_files": output_files,
        "source_files": source_files,
        "source_urls": URLS,
    }
    (ROOT / "validation_summary.json").write_text(
        json.dumps(validation, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
