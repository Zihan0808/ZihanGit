#!/usr/bin/env python3
"""Validate and clean the synthetic Silwood tree survey."""

import csv
import math
import re
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
INPUT_PATH = PROJECT_ROOT / "data" / "silwood_trees_raw.csv"
RESULTS_DIR = PROJECT_ROOT / "results"

INPUT_FIELDS = [
    "record_id",
    "location",
    "genus",
    "species",
    "distance_m",
    "angle_degrees",
]
ISSUE_FIELDS = ["source_row", "record_id", "reasons"]
OAK_COUNT_FIELDS = ["species", "count"]


def load_records(path=INPUT_PATH):
    """Read the survey and check its column names."""
    with path.open(newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        if reader.fieldnames != INPUT_FIELDS:
            raise ValueError(
                f"Expected columns {INPUT_FIELDS}, found {reader.fieldnames}"
            )
        return list(reader)


def validate_record(row, source_row, accepted_ids):
    """Clean one record, or return the reasons it cannot be used."""
    cleaned = {}
    for field in INPUT_FIELDS:
        value = row.get(field)
        if value is None:
            value = ""
        cleaned[field] = value.strip()
    reasons = []
    record_id = cleaned["record_id"]
    if not record_id:
        reasons.append("missing record_id")
    elif not re.fullmatch(r"ST[0-9]{3}", record_id):
        reasons.append("invalid record_id")
    if record_id and record_id in accepted_ids:
        reasons.append("duplicate record_id")

    pairs = [
        ("Quercus", "robur"), ("Quercus", "petraea"),
        ("Acer", "pseudoplatanus"), ("Betula", "pendula"),
        ("Fagus", "sylvatica"), ("Fraxinus", "excelsior"),
    ]
    genera = []
    species_names = []
    for genus, species in pairs:
        if genus not in genera:
            genera.append(genus)
        if species not in species_names:
            species_names.append(species)

    permitted = {
        "location": ["Silwood Bottom", "Nash's Field", "Manor House", "Reactor Wood"],
        "genus": genera,
        "species": species_names,
    }
    recognised = []
    for field, values in permitted.items():
        value = cleaned[field]
        if not value:
            reasons.append(f"missing {field}")
        else:
            matched = False
            for permitted_value in values:
                if value.casefold() == permitted_value.casefold():
                    cleaned[field] = permitted_value
                    recognised.append(field)
                    matched = True
                    break
            if not matched:
                reasons.append(f"invalid {field}")
    if "genus" in recognised and "species" in recognised:
        if (cleaned["genus"], cleaned["species"]) not in pairs:
            reasons.append("invalid genus/species combination")

    for field in ("distance_m", "angle_degrees"):
        if not cleaned[field]:
            reasons.append(f"missing {field}")
            continue
        try:
            number = float(cleaned[field])
        except ValueError:
            reasons.append(f"invalid {field}")
            continue
        if not math.isfinite(number):
            reasons.append(f"invalid {field}")
        else:
            if field == "distance_m":
                in_range = 0 < number <= 100
            else:
                in_range = 0 < number < 90
            if in_range:
                cleaned[field] = str(number)
            else:
                reasons.append(f"{field} out of range")

    if reasons:
        return None, reasons
    else:
        return cleaned, reasons


def record_id_key(row):
    """Return the identifier used to sort records."""
    return row["record_id"]


def process_records(rows):
    """Sort records into accepted rows and issue reports."""
    accepted = []
    issues = []
    accepted_ids = []
    for source_row, row in enumerate(rows, start=2):
        cleaned, reasons = validate_record(row, source_row, accepted_ids)
        if cleaned is None:
            record_id = row.get("record_id")
            if record_id is None:
                record_id = ""
            issues.append({
                "source_row": str(source_row),
                "record_id": record_id.strip(),
                "reasons": "; ".join(reasons),
            })
        else:
            accepted.append(cleaned)
            accepted_ids.append(cleaned["record_id"])
    return sorted(accepted, key=record_id_key), issues


def summarise_oaks(clean_records):
    """Count accepted oak records by species."""
    counts = {}
    for row in clean_records:
        if row["genus"] == "Quercus":
            species = row["species"]
            if species in counts:
                counts[species] = counts[species] + 1
            else:
                counts[species] = 1
    summary = []
    for species in sorted(counts):
        summary.append({"species": species, "count": str(counts[species])})
    return summary


def write_csv(path, fieldnames, rows):
    """Write rows to a CSV file, replacing an older copy."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.DictWriter(destination, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main():
    """Clean the survey and write the three result files."""
    clean_records, issues = process_records(load_records())
    oak_counts = summarise_oaks(clean_records)

    write_csv(
        RESULTS_DIR / "silwood_trees_clean.csv",
        INPUT_FIELDS,
        clean_records,
    )
    write_csv(
        RESULTS_DIR / "silwood_tree_issues.csv",
        ISSUE_FIELDS,
        issues,
    )
    write_csv(
        RESULTS_DIR / "oak_species_counts.csv",
        OAK_COUNT_FIELDS,
        oak_counts,
    )


if __name__ == "__main__":
    main()
