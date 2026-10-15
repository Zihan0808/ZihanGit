# Assignment 1: UNIX and shell scripting

This assignment practises UNIX commands on FASTA datasets, Bash delimiter conversion, and organising source files, inputs and generated outputs with Git.

## Files

- `code/unixPrac1.txt`: five FASTA questions, with commands, explanations and results.
- `code/tabtocsv.sh`: changes tabs into commas.
- `code/csvtospace.sh`: changes commas into spaces.
- `data/`: the supplied FASTA files, temperature CSV files and tab-separated example.
- `results/`: generated output files. These are not part of the submission.

## How to run

I use Bash and the commands `tr`, `wc`, `tail`, `grep` and `mkdir`. The last FASTA answer also needs `bc` for decimal division. Check that it is installed with `command -v bc`.

Run the following from the main `ZihanGit` folder:

```bash
bash code/tabtocsv.sh data/tab-example.tsv
```

This creates `results/tab-example.tsv.csv`.

For the temperature files, also run from the repository root:

```bash
bash code/csvtospace.sh data/temperatures/1800.csv
```

This creates `results/1800.csv.txt` in the main project folder. To convert all four temperature files from the repository root:

```bash
for file in data/temperatures/*.csv; do
    bash code/csvtospace.sh "$file"
done
```

The FASTA answers are in `code/unixPrac1.txt`. Run each numbered command separately from `code/` (use `cd code` from the repository root). The file includes explanations, so it should not be run as a shell script.

## Test notes

The converters were executed on the supplied inputs and temporary edge-case files:

- The tab example produced the same content with commas replacing tabs.
- All four temperature files produced the same content with spaces replacing commas.
- A filename containing spaces worked for both scripts.
- Consecutive tabs became consecutive commas, and consecutive commas became consecutive spaces. Empty fields were kept.
- Running a conversion twice replaced the output rather than adding duplicate rows.
- Missing arguments, extra arguments, a nonexistent file and a directory as input returned a non-zero exit status and an error message.
- The input files stayed unchanged after conversion.

The FASTA results were also checked:

| Question | Result |
| --- | --- |
| 1: newline counts | 27, 127 and 78104; total 78258 |
| 2: sequence lines | Starts at line 2, leaving out the header |
| 3: sequence length | 4686137 |
| 4: ATGC occurrences | 21968 |
| 5: AT/GC ratio | About 0.9692282285 |

The two numbered FASTA files have no final newline, so `wc -l` counts one fewer than the number of displayed lines. Sequence length includes ambiguous bases, but the AT/GC ratio uses only A, T, G and C.

These scripts only replace delimiters. They do not handle general quoted CSV or TSV data. For example, a comma inside a quoted CSV field would also become a space, and spaces already inside fields can make the output unclear.

The existing README attributes the practicals and tab converter starter to the MulQuaBio UNIX and Linux and Shell scripting course materials. No separate assignment specification is included locally.

## Exact FASTA commands

Start in the repository root, then enter `code/`. Execute Q1–Q5 in order:

```bash
cd code
wc -l ../data/fasta/*.fasta

tail -n +2 ../data/fasta/e_coli.fasta

tail -n +2 ../data/fasta/e_coli.fasta | grep -o . | wc -l

tail -n +2 ../data/fasta/e_coli.fasta | tr -d '\r\n' | grep -o 'ATGC' | wc -l

A=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'A' | wc -l); T=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'T' | wc -l); G=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'G' | wc -l); C=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'C' | wc -l); echo "$((A + T)) / $((G + C))"| bc -l
```

Q2 prints the full sequence body (78,103 lines), beginning with
`AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTC`.
The executed output was compared byte for byte with the input after its header.
Q3 includes ambiguity symbols; Q4 joins wrapped lines so boundary-spanning
motifs are counted. Q5 excludes ambiguity symbols and gives
`0.96922822848944879586` (bc omits the leading zero).

## Verification and repository policy

Checks executed during this revision:

| Test | Expected | Observed |
| --- | --- | --- |
| Supplied TSV and all four temperature CSVs | Exact delimiter replacement, exit 0 | Matched byte for byte; exit 0 |
| Repeated conversion | Replace output without duplication | Matched; exit 0 |
| Empty input; spaces in filename; repeated delimiters; no final newline | Preserve all bytes except target delimiters | Matched; exit 0 |
| No argument or two arguments | Usage error, exit 2 | Exit 2 with diagnostic |
| Nonexistent file or directory input | Validation error, exit 1 | Exit 1 with diagnostic |
| Output symlink pointing to input | Reject without changing input, exit 1 | Unchanged; exit 1 |
| Directory occupying output filename | Conversion failure, exit 1 | Exit 1 |
| Absent results directory | Create directory and fresh outputs | All five conversions succeeded |
| Input integrity | No input changes | SHA-256 hashes unchanged |

Bash syntax checks passed for both scripts. Python 3 was used only for
verification (byte comparisons, independent sequence counts and input hashes);
it is not required to run the assignment commands.

Assignment 1 generated results were removed from Git tracking during revision.
For Assignment 2, the three tree-survey result CSVs are included in Git, and
`results/` is no longer ignored. `/sandbox/` and Python caches remain ignored,
along with `*~` and `*.tmp` files. Check from the repository root with:

```bash
git ls-files results sandbox
git check-ignore sandbox/test.py
git status --short
```

The first command lists the three tree-survey result CSVs; the second prints
`sandbox/test.py`.
Converters overwrite outputs with the same basename, so inputs from different
directories with identical basenames share an output path.

## AI use

AI assistance was used to help me understand the assignment requirements and feedback, and to improve the clarity, structure, and content of the README documentation.

# Assignment 2: Silwood tree-cleaning practical

This assignment cleans a synthetic tree survey according to the supplied
metadata and counts accepted oak records.

## Files

- `data/silwood_trees_raw.csv`: unchanged input survey.
- `data/silwood_trees_metadata.md`: validation and output rules.
- `code/clean_silwood_trees.py`: cleaner and CSV writer.
- `code/test_silwood_trees.py`: eight simple checks of the main cleaning functions.
- `results/`: regenerated CSV outputs, included in Git.

## Plan

Plan (written before implementing the three functions): read the unchanged
`data/silwood_trees_raw.csv`, using `data/silwood_trees_metadata.md` as the
validation specification. `validate_record` receives a row, its source line
number and accepted identifiers, and returns a cleaned row or `None` plus
rejection reasons. `process_records` receives rows and returns accepted rows
and issue reports. `summarise_oaks` receives accepted rows and returns species
counts for exactly `Quercus`.

```text
load CSV records
start empty accepted records, issues and accepted identifiers
for each row in file order, numbering from 2:
    strip text and validate all fields against metadata
    collect every applicable reason in the specified order
    if there are reasons: append source row, identifier and reasons to issues
    otherwise: accept canonical record and reserve its identifier
sort accepted records by identifier
count accepted records whose genus equals Quercus, grouped by species
sort species counts by species
write accepted records, issues and oak counts to three replacement CSV files
```

## How to run

From the repository root, using Python 3.10 or later (standard library only):

```bash
python3 code/test_silwood_trees.py
python3 code/clean_silwood_trees.py
```

## Output files

Outputs are created in `results/` and included in Git:

- `silwood_trees_clean.csv`: accepted canonical records in input-column order,
  sorted by identifier.
- `silwood_tree_issues.csv`: rejected rows in source order, with `source_row`,
  stripped `record_id` and all `reasons` joined by `; `.
- `oak_species_counts.csv`: represented oak species and counts, sorted by species.

## Test notes

The test script uses ordinary functions and `assert` statements. Its eight tests
check that valid text is cleaned, missing and invalid values are rejected,
duplicate identifiers are rejected, accepted records are sorted, issue details
are recorded, and accepted oak records are counted by species. They also check
that a rejected row does not reserve its identifier and that two oaks of the
same species give a count of two. Running the script prints
`All 8 tests passed.` when every expected result is obtained.

All eight tests passed using small example records. Separately, the supplied
survey produced 24 accepted records and 12 rejected records. The oak summary
contains `petraea,4` and `robur,4`.
Misspellings and missing values are rejected rather than inferred; this cleaner
is specific to the supplied synthetic survey schema. The raw survey and
metadata and the three result CSVs belong in Git; Python caches do not.

## AI use

I used AI to help me understand the assignment requirements, clarify the validation rules, plan how to test the program, and improve the wording and structure of this README.
