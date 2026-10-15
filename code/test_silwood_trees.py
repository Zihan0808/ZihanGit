#!/usr/bin/env python3
"""Run simple checks for the Silwood tree-cleaning functions."""

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
    print("All 8 tests passed.")


if __name__ == "__main__":
    main()
