#!/usr/bin/env python3
"""Run simple checks for the Silwood tree-cleaning functions."""

import csv
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import clean_silwood_trees as trees


def make_record():
    """Return one valid record that can be changed in each test."""
    return {
        "record_id": "ST001",
        "location": "Silwood Bottom",
        "genus": "Quercus",
        "species": "robur",
        "distance_m": "12.5",
        "angle_degrees": "35",
    }


def test_valid_record():
    """A valid record should be accepted and cleaned."""
    row = make_record()
    row["location"] = " nASH's fIELD "
    row["genus"] = " quERCUS "
    row["species"] = " ROBUR "

    cleaned, reasons = trees.validate_record(row, 2, [])

    assert reasons == []
    assert cleaned["location"] == "Nash's Field"
    assert cleaned["genus"] == "Quercus"
    assert cleaned["species"] == "robur"
    assert cleaned["distance_m"] == "12.5"
    assert cleaned["angle_degrees"] == "35.0"


def test_missing_value():
    """A record with a missing value should be rejected."""
    row = make_record()
    row["location"] = ""

    cleaned, reasons = trees.validate_record(row, 2, [])

    assert cleaned is None
    assert reasons == ["missing location"]


def test_invalid_values():
    """Invalid identifiers, names and measurements should be reported."""
    row = make_record()
    row["record_id"] = "tree1"
    row["genus"] = "Acer"
    row["distance_m"] = "far"
    row["angle_degrees"] = "90"

    cleaned, reasons = trees.validate_record(row, 2, [])

    assert cleaned is None
    assert reasons == [
        "invalid record_id",
        "invalid genus/species combination",
        "invalid distance_m",
        "angle_degrees out of range",
    ]


def test_duplicate_record_id():
    """A repeated identifier should be rejected."""
    row = make_record()
    cleaned, reasons = trees.validate_record(row, 3, ["ST001"])

    assert cleaned is None
    assert reasons == ["duplicate record_id"]


def test_process_records():
    """Valid rows should be accepted, sorted and kept separate from issues."""
    first = make_record()
    first["record_id"] = "ST002"

    second = make_record()
    second["record_id"] = "ST001"

    invalid = make_record()
    invalid["record_id"] = "ST003"
    invalid["distance_m"] = "0"

    accepted, issues = trees.process_records([first, invalid, second])

    assert len(accepted) == 2
    assert accepted[0]["record_id"] == "ST001"
    assert accepted[1]["record_id"] == "ST002"
    assert issues == [{
        "source_row": "3",
        "record_id": "ST003",
        "reasons": "distance_m out of range",
    }]


def test_invalid_record_does_not_reserve_id():
    """A valid row can use the identifier of an earlier rejected row."""
    invalid = make_record()
    invalid["distance_m"] = "bad"
    valid = make_record()

    accepted, issues = trees.process_records([invalid, valid])

    assert len(accepted) == 1
    assert accepted[0]["record_id"] == "ST001"
    assert issues == [{
        "source_row": "2",
        "record_id": "ST001",
        "reasons": "invalid distance_m",
    }]


def test_oak_summary():
    """Accepted oak records should be counted by species."""
    first = make_record()
    second = make_record()
    second["record_id"] = "ST002"
    second["species"] = "petraea"
    third = make_record()
    third["record_id"] = "ST003"
    third["genus"] = "Acer"
    third["species"] = "pseudoplatanus"

    summary = trees.summarise_oaks([first, second, third])

    assert summary == [
        {"species": "petraea", "count": "1"},
        {"species": "robur", "count": "1"},
    ]


def test_repeated_oak_species():
    """Two trees of the same oak species should give a count of two."""
    first = make_record()
    second = make_record()
    second["record_id"] = "ST002"

    summary = trees.summarise_oaks([first, second])

    assert summary == [{"species": "robur", "count": "2"}]


def test_measurement_boundaries():
    """Distinguish valid limits, out-of-range values and nonfinite values."""
    valid = make_record()
    valid.update(distance_m="100", angle_degrees="89.999")
    cleaned, reasons = trees.validate_record(valid, 2, [])
    assert reasons == []
    assert float(cleaned["distance_m"]) == 100
    assert float(cleaned["angle_degrees"]) == 89.999
    small = dict(valid, distance_m="0.001", angle_degrees="0.001")
    assert trees.validate_record(small, 2, [])[0] is not None

    for distance, angle, expected in [
        ("0", "0", ["distance_m out of range", "angle_degrees out of range"]),
        ("100.01", "90", ["distance_m out of range", "angle_degrees out of range"]),
        ("NaN", "inf", ["invalid distance_m", "invalid angle_degrees"]),
        ("-inf", "-0.01", ["invalid distance_m", "angle_degrees out of range"]),
    ]:
        record = dict(valid, distance_m=distance, angle_degrees=angle)
        assert trees.validate_record(record, 2, []) == (None, expected)


def test_collect_all_rejection_reasons_in_order():
    """Keep duplicate, missing, taxon and measurement reasons together."""
    row = dict(
        make_record(),
        record_id=" ST001 ",
        location="Unknown",
        genus="Acer",
        species="robur",
        distance_m="",
        angle_degrees="n/a",
    )
    assert trees.validate_record(row, 3, ["ST001"]) == (
        None,
        [
            "duplicate record_id",
            "invalid location",
            "invalid genus/species combination",
            "missing distance_m",
            "invalid angle_degrees",
        ],
    )
    missing = trees.validate_record({}, 2, [])[1]
    assert missing == [f"missing {field}" for field in trees.INPUT_FIELDS]


def test_only_accepted_oaks_contribute():
    """Pass the accepted output of process_records to the oak count."""
    valid_oak = dict(make_record(), genus=" quercus ", species=" ROBUR ")
    invalid_oak = dict(make_record(), record_id="ST002", distance_m="0")
    near_oak = dict(make_record(), record_id="ST003", genus="Quercuss")
    accepted, issues = trees.process_records([valid_oak, invalid_oak, near_oak])
    assert [row["record_id"] for row in accepted] == ["ST001"]
    assert issues == [
        {"source_row": "3", "record_id": "ST002", "reasons": "distance_m out of range"},
        {"source_row": "4", "record_id": "ST003", "reasons": "invalid genus"},
    ]
    assert trees.summarise_oaks(accepted) == [{"species": "robur", "count": "1"}]
    assert trees.summarise_oaks([near_oak]) == []
    non_oak = dict(make_record(), genus="Acer", species="pseudoplatanus")
    assert trees.summarise_oaks(trees.process_records([non_oak])[0]) == []
    assert trees.summarise_oaks([]) == []


def test_import_and_fresh_outputs():
    """Create all three correctly formatted files twice in an isolated copy."""
    project_root = Path(__file__).resolve().parents[1]
    sandbox = project_root / "sandbox"
    sandbox.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=sandbox, prefix="silwood-test-") as temp:
        copy_root = Path(temp)
        code_dir = copy_root / "code"
        data_dir = copy_root / "data"
        results_dir = copy_root / "results"
        code_dir.mkdir()
        data_dir.mkdir()
        shutil.copyfile(project_root / "code" / "clean_silwood_trees.py",
                        code_dir / "clean_silwood_trees.py")
        # The input is deliberately absent during import.
        imported = subprocess.run(
            [sys.executable, "-B", "-c", "import clean_silwood_trees"],
            cwd=code_dir, capture_output=True, text=True, check=True, timeout=15,
        )
        assert not imported.stdout and not imported.stderr
        assert not results_dir.exists()

        fixture = (
            "record_id,location,genus,species,distance_m,angle_degrees\n"
            'ST002," silwood bottom \n",quercus,ROBUR,100,45\n'
            "\n"
            'ST005,"Silwood Bottom\n",Quercus,petraea,0,91\n'
            "ST001,Reactor Wood,Quercus,petraea,5,35\n"
            "ST002,Manor House,Quercus,robur,15,40\n"
        )
        raw = data_dir / "silwood_trees_raw.csv"
        raw.write_text(fixture, encoding="utf-8")
        input_before = raw.read_bytes()

        def run_cleaner():
            completed = subprocess.run(
                [sys.executable, "-B", "code/clean_silwood_trees.py"],
                cwd=copy_root, capture_output=True, text=True, check=True, timeout=15,
            )
            assert not completed.stdout and not completed.stderr
            return {path.name: path.read_bytes() for path in results_dir.iterdir()}

        first = run_cleaner()
        assert set(first) == {
            "silwood_trees_clean.csv", "silwood_tree_issues.csv", "oak_species_counts.csv",
        }
        assert list(csv.reader(first["silwood_trees_clean.csv"].decode().splitlines())) == [
            ["record_id", "location", "genus", "species", "distance_m", "angle_degrees"],
            ["ST001", "Reactor Wood", "Quercus", "petraea", "5.0", "35.0"],
            ["ST002", "Silwood Bottom", "Quercus", "robur", "100.0", "45.0"],
        ]
        # Issue lines count the blank line and both parts of quoted fields.
        assert list(csv.reader(first["silwood_tree_issues.csv"].decode().splitlines())) == [
            ["source_row", "record_id", "reasons"],
            ["5", "ST005", "distance_m out of range; angle_degrees out of range"],
            ["8", "ST002", "duplicate record_id"],
        ]
        assert list(csv.reader(first["oak_species_counts.csv"].decode().splitlines())) == [
            ["species", "count"], ["petraea", "1"], ["robur", "1"],
        ]
        assert run_cleaner() == first
        assert raw.read_bytes() == input_before


def main():
    """Run each test and print a short success message."""
    test_valid_record()
    test_missing_value()
    test_invalid_values()
    test_duplicate_record_id()
    test_process_records()
    test_invalid_record_does_not_reserve_id()
    test_oak_summary()
    test_repeated_oak_species()
    test_measurement_boundaries()
    test_collect_all_rejection_reasons_in_order()
    test_only_accepted_oaks_contribute()
    test_import_and_fresh_outputs()
    print("All 12 tests passed.")


if __name__ == "__main__":
    main()
