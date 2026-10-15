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

Scripts and all supplied input datasets are tracked. `/results/` and `/sandbox/`
are ignored; generated results were removed from Git tracking while local
outputs were retained. The empty, already locally deleted `sandbox/test.py`
was untracked. Existing `*~` and `*.tmp` ignore rules remain. Check from the
repository root with:

```bash
git ls-files results sandbox
git check-ignore results/1800.csv.txt sandbox/test.py
git status --short
```

The first command should print nothing; the second should print both paths.
Converters overwrite outputs with the same basename, so inputs from different
directories with identical basenames share an output path.

## AI use

AI assistance was used to help me understand the assignment requirements and feedback, and to improve the clarity, structure, and content of the README documentation.
