"""Read observations and report known and missing counts by site."""

import csv


FIELDS = {"site", "date", "count"}


def load_observations(path):
    """Read CSV rows as dictionaries without changing cell values."""
    with open(path, newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def parse_count(count_text):
    """Return a nonnegative integer or None for an empty count cell."""
    if not isinstance(count_text, str):
        raise ValueError("Count must be text")
    if count_text == "":
        return None
    try:
        number = int(count_text)
    except ValueError as error:
        raise ValueError(f"Invalid integer count {count_text!r}") from error
    if number < 0:
        raise ValueError("Count must be nonnegative")
    return number


def summarise_site(rows, site):
    """Return (known_total, missing_count) after validating each row."""
    if not isinstance(rows, list):
        raise ValueError("Rows must be a list of dictionaries")
    if not isinstance(site, str) or site == "":
        raise ValueError("Site must be nonempty text")

    seen = set()
    known_total = None
    missing_count = 0
    for position, row in enumerate(rows, start=1):
        if not isinstance(row, dict) or set(row) != FIELDS:
            raise ValueError(f"Record {position} must contain site, date and count")

        row_site, date, count_text = row["site"], row["date"], row["count"]
        if not isinstance(row_site, str) or row_site == "":
            raise ValueError(f"Record {position} has an invalid site")
        if not isinstance(date, str) or date == "":
            raise ValueError(f"Record {position} has an invalid date")
        try:
            count = parse_count(count_text)
        except ValueError as error:
            raise ValueError(f"Record {position}: {error}") from error

        # Use the original cell text so differing records stay distinct.
        key = (row_site, date, count_text)
        if key in seen:
            continue
        seen.add(key)
        if row_site != site:
            continue
        if count is None:
            missing_count += 1
        elif known_total is None:
            known_total = count
        else:
            known_total += count

    return known_total, missing_count


def main():
    """Print the summary for each site in the ordinary exercise file."""
    rows = load_observations("data/bootcamp_observations.csv")
    for site in sorted({row["site"] for row in rows}):
        known, missing = summarise_site(rows, site)
        known_text = "unavailable" if known is None else str(known)
        print(f"Site {site}: known total = {known_text}, missing counts = {missing}")


if __name__ == "__main__":
    main()
