"""Check the observations practical using hand-worked and supplied cases."""

from pathlib import Path
import unittest

from observations_practice import load_observations, parse_count, summarise_site


DATA = Path(__file__).resolve().parents[1] / "data"


def row(site, date, count):
    """Return a small observation for a test fixture."""
    return {"site": site, "date": date, "count": count}


class ObservationTests(unittest.TestCase):
    def test_parse_count(self):
        self.assertEqual(parse_count("2"), 2)
        self.assertEqual(parse_count("0"), 0)
        self.assertIsNone(parse_count(""))
        for invalid in ("-1", "many", 2):
            with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                parse_count(invalid)

    def test_ordinary_file_and_input_unchanged(self):
        rows = load_observations(DATA / "bootcamp_observations.csv")
        original = [item.copy() for item in rows]
        self.assertEqual(summarise_site(rows, "A"), (2, 1))
        self.assertEqual(summarise_site(rows, "B"), (0, 0))
        self.assertEqual(summarise_site(rows, "Z"), (None, 0))
        self.assertEqual(rows, original)

    def test_boundary_file_and_empty_input(self):
        rows = load_observations(DATA / "bootcamp_observations_boundary.csv")
        self.assertEqual(summarise_site(rows, "C"), (None, 2))
        self.assertEqual(summarise_site(rows, "D"), (0, 0))
        self.assertEqual(summarise_site([], "D"), (None, 0))

    def test_invalid_file_rows_are_rejected_independently(self):
        rows = load_observations(DATA / "bootcamp_observations_invalid.csv")
        for record in rows:
            with self.subTest(record=record), self.assertRaises(ValueError):
                summarise_site([record], "A")
        with self.assertRaises(ValueError):
            summarise_site([row("A", "2026-10-02", "9"), rows[1]], "A")

    def test_invalid_schema(self):
        invalid_rows = [
            [{"site": "A", "count": "2"}],
            [dict(row("A", "2026-10-01", "2"), extra="x")],
            [row("", "2026-10-01", "2")],
            [row("A", "", "2")],
            [row("A", "2026-10-01", 2)],
            [row("A", 1, "2")],
            [row(1, "2026-10-01", "2")],
            ["not a row dictionary"],
            None,
        ]
        for invalid in invalid_rows:
            with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                summarise_site(invalid, "A")
        for invalid_site in ("", 2):
            with self.subTest(site=invalid_site), self.assertRaises(ValueError):
                summarise_site([], invalid_site)

    def test_duplicate_missing_and_nonzero_counts(self):
        known = row("C", "2026-10-01", "7")
        missing = row("C", "2026-10-02", "")
        self.assertEqual(summarise_site([known, missing, known.copy(), missing.copy()], "C"), (7, 1))
        self.assertEqual(summarise_site([missing, missing.copy()], "C"), (None, 1))

    def test_predicted_new_site_with_exact_text_keys(self):
        rows = [
            row("Fen", "2026-11-01", "4"),
            row("Fen", "2026-11-02", "4"),
            row("Fen", "2026-11-02", "04"),
            row("Fen", "2026-11-02", "4"),
            row("Fen", "2026-11-02", ""),
            row("Fen", "2026-11-03", "0"),
            row("Moor", "2026-11-01", "20"),
        ]
        # Different dates and count text are distinct; 4 + 4 + 4 + 0 = 12.
        self.assertEqual(summarise_site(rows, "Fen"), (12, 1))


if __name__ == "__main__":
    unittest.main()
