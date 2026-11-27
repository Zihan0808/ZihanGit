This cumulative portfolio keeps all 39 required scripts in `code/`, shared
inputs in `data/` and generated files in `results/`. Formative feedback is
under `Feedback/`. Source examples come from the MQB snapshot `e23caaa8451f`.
Run commands from the repository root, except for the FASTA commands (from
`code/`) and TIFF conversion (from the directory containing TIFF copies).

## Software and setup

- Linux with Bash, GNU coreutils, `grep` and `bc` (for the FASTA ratio).
- Python 3.10 or later with the standard library, including `doctest` and `pdb`.
- R with base graphics and the additional packages `reshape2`, `dplyr` and
  `tidyr`. ImageMagick (`magick` or `convert`) is needed for the TIFF exercise.

For a fresh checkout, install missing system dependencies with your Linux
package manager. For example, on Ubuntu or Debian:

```bash
sudo apt update
sudo apt install bc imagemagick
```

Check that `bc` and either `magick` or `convert` are available:

```bash
command -v bc
command -v magick || command -v convert
```

In an R console (start with `R --vanilla`), install the additional packages
if they are missing:

```r
install.packages(c("reshape2", "dplyr", "tidyr"),
                 repos = "https://cloud.r-project.org")
```

Use `tidyr` version 1.3.0 or later because `code/data_wrang_tidy.R` uses
the `cols_vary` argument of `pivot_longer()`. If an older version is installed,
update it with `install.packages("tidyr", repos = "https://cloud.r-project.org")`.
Check that all three packages and the required version are available:

```r
stopifnot(requireNamespace("reshape2", quietly = TRUE),
          requireNamespace("dplyr", quietly = TRUE),
          requireNamespace("tidyr", quietly = TRUE),
          packageVersion("tidyr") >= "1.3.0")
```

The programs create `results/` as needed. For exercises that use disposable
input copies, create `sandbox/` with `mkdir -p sandbox`. Git ignores both
directories, along with generated caches and local environment files.

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

The practicals and tab converter starter are from the MulQuaBio UNIX and Shell Scripting chapters. The Assignment 1 feedback asked for the `code/` working directory, reproducible counts and consistent root-based converter paths. Those paths and the counts were verified. The synthetic FASTA check also covered CRLF, no final newline, ambiguity and a motif spanning wrapped lines.

## Exact FASTA commands

Start in the repository root, then enter `code/`. Execute Q1–Q5 in order:

```bash
cd code
wc -l ../data/fasta/*.fasta

tail -n +2 ../data/fasta/e_coli.fasta

tail -n +2 ../data/fasta/e_coli.fasta | tr -d '\r\n' | wc -c

tail -n +2 ../data/fasta/e_coli.fasta | tr -d '\r\n' | grep -o 'ATGC' | wc -l

A=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'A' | wc -l); T=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'T' | wc -l); G=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'G' | wc -l); C=$(tail -n +2 ../data/fasta/e_coli.fasta | grep -o 'C' | wc -l); printf '%s / %s\n' "$((A + T))" "$((G + C))" | bc -l
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

Assignment 4 keeps generated results and disposable tests out of Git.
`git ls-files -- results/ sandbox/` should have no output. Check ignore rules
with `git check-ignore results/TreeHts.csv sandbox/test.txt`.
Converters overwrite outputs with the same basename, so inputs from different
directories with identical basenames share an output path. They reject output
links or special files and write to a temporary file before replacing the
destination. Checks covered aliases, output FIFOs and a simulated partial
conversion failure that left the previous result intact.

## Introductory Bash exercises

These three scripts adapt the introductory examples in
`content/notebooks/shell-scripting.ipynb` and the `boilerplate.sh` starter
from the supplied `MQB-main.zip`. Run the following commands from the
repository root. They need Bash; `variables.sh` also uses the external
`expr` command. They print to the terminal and do not create result files.

| Script | Purpose | Input |
| --- | --- | --- |
| `code/boilerplate.sh` | Demonstrate a shebang, descriptive header, output and successful exit. | None. |
| `code/MyExampleScript.sh` | Print `Hello` followed by the value of `USER`. | No arguments; reads the environment. |
| `code/variables.sh` | Display positional parameters, read text and add two integers. | Optional arguments, then prompted text and two integers. |

### Run the examples

```bash
bash code/boilerplate.sh
bash code/MyExampleScript.sh
bash code/variables.sh
bash code/variables.sh 1 "two words"
```

For each interactive `variables.sh` run, enter `hello Linux` at the text
prompt and `3 5` at the integer prompt. The sum is `8`. The no-argument run
reports zero parameters and empty first and second arguments. The quoted
`"two words"` is one argument, so the second invocation reports two
parameters. With no arguments, `printf` still prints an empty `Argument: <>`
line; the parameter count is the number reported by `$#`.

All three scripts are executable, so `./code/boilerplate.sh`,
`./code/MyExampleScript.sh` and `./code/variables.sh 1 "two words"` are also
valid. `MyExampleScript.sh` normally prints `Hello zihan-gao` on this Linux
account. It demonstrates an environment variable; `USER` can be changed
and is not proof of identity.

The arithmetic example deliberately assumes two valid integers, as in the
chapter. It does not validate arbitrary numeric input or support decimals.
`IFS= read -r` preserves leading/trailing spaces and literal backslashes in
the text input. Bash's `echo -e` in the boilerplate interprets `\n` as a
newline; its `exit 0` reports successful completion.

### Verification

Executed on Linux on 2026-11-25: all 10 checks passed with exit status `0`.

| Check | Observed result |
| --- | --- |
| `bash -n` on each script (3 checks) | No syntax errors. |
| Boilerplate through Bash and direct execution (2 checks) | The expected message and blank lines; exit `0`. |
| Greeting through Bash with `USER=zihan-gao` | `Hello zihan-gao`. |
| Direct greeting with `USER="demo user"` | `Hello demo user`; spaces preserved. |
| Variables without arguments; text `hello Linux`, numbers `3 5` | Parameter count `0`, empty first/second arguments, sum `8`. |
| Variables with `1 "two words"`; the same prompted input | Parameter count `2`, both arguments preserved, sum `8`. |
| Direct variables run; text with spaces/backslash, numbers `-5 5` | Text preserved, sum `0`, exit `0`. |

Repeat the syntax checks and two reproducible input cases from the root:

```bash
bash -n code/boilerplate.sh
bash -n code/MyExampleScript.sh
bash -n code/variables.sh
printf 'hello Linux\n3 5\n' | bash code/variables.sh
printf 'hello Linux\n3 5\n' | bash code/variables.sh 1 "two words"
```

## AI use

AI assistance was used to help me understand the assignment requirements and feedback, and to improve the clarity, structure, and content of the README documentation.


# Assignment 2: Silwood tree-cleaning practical

This assignment cleans a synthetic tree survey according to the supplied
metadata and counts accepted oak records.

## Files

- `data/silwood_trees_raw.csv`: unchanged input survey.
- `data/silwood_trees_metadata.md`: validation and output rules.
- `code/clean_silwood_trees.py`: cleaner and CSV writer.
- `code/test_silwood_trees.py`: 12 test groups for validation, processing, summaries and the command-line workflow.
- `results/`: regenerated CSV outputs.

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

The script creates these files in `results/`.

- `silwood_trees_clean.csv`: accepted canonical records in input-column order,
  sorted by identifier.
- `silwood_tree_issues.csv`: rejected rows in source order, with `source_row`,
  stripped `record_id` and all `reasons` joined by `; `.
- `oak_species_counts.csv`: represented oak species and counts, sorted by species.

## Test notes

The 12 test groups passed. They cover normalization, missing and invalid
measurements, inclusive measurement bounds, reason order, duplicate IDs,
rejected IDs that do not reserve an identifier, near-match oak names and an
empty oak summary. In response to the Assignment 2 feedback, an integrated
case passes a valid oak and an invalid record to `process_records()`, then
checks that only the accepted collection contributes to `summarise_oaks()`.
The CLI test confirms quiet import, new output creation, headers and ordering,
and byte-identical reruns in an isolated directory.

The supplied survey independently yielded 24 accepted and 12 rejected
records. The oak summary was `petraea,4` and `robur,4`. All three recreated
tables matched the existing local outputs byte for byte, and the input hashes
were unchanged. These checks used disposable local copies. See the
[Fresh-clone check](#fresh-clone-check) under Portfolio verification.

## AI use

I used AI to help me understand the assignment requirements, clarify the validation rules, plan how to test the program, and improve the wording and structure of this README.

# Assignment 3: R programming and tree heights

This coursework practises base R functions, CSV files, input validation and
interactive debugging by calculating tree heights from distances and angles.

## Files

- `data/trees.csv`: unchanged input containing 120 tree records.
- `code/TreeHeight.R`: calculates heights for the supplied `trees.csv`.
- `code/get_TreeHeight.R`: accepts one input CSV file path.
- `code/run_get_TreeHeight.sh`: runs the general script on `trees.csv`.
- `results/`: generated height CSVs, ignored by `.gitignore`.

The R scripts and source CSV belong in Git.

## Calculation and validation

Both R scripts use `TreeHeight()` to calculate
`height_m = Distance.m * tan(Angle.degrees * pi / 180)`. Multiplying the angle
by `pi / 180` converts degrees to radians for R's `tan()` function. The input
must have exactly the three columns `Species`, `Distance.m`, and
`Angle.degrees`. Distances and angles must be finite numeric values, with
`0 < Distance.m <= 100` and `0 < Angle.degrees < 90`.

## How to run

From the repository root, using base R and Bash, run these terminal commands.

```bash
Rscript code/TreeHeight.R
Rscript code/get_TreeHeight.R data/trees.csv
bash code/run_get_TreeHeight.sh
```

Alternatively, start `R --vanilla` and enter `source("code/TreeHeight.R")`
at the R prompt to run the fixed-input exercise.

## Output files and checks

- `results/TreeHts.csv` is the fixed-input result.
- `results/trees_treeheights.csv` is the result from the argument-based script
  or the Bash runner. A different input uses its own basename without `.csv`.
  Inputs in separate directories with identical basenames share a destination.

Both scripts use the same validation and calculation, keep the original
columns and record order, and append `height_m`. All 120 rows were independently
compared with the trigonometric formula. The first row, *Populus tremula*, was
31.665833774 m away at 41.282636194 degrees and gives 27.802116144 m. A test
measurement of 8 m at 45 degrees also gave 8 m. Repeated runs reproduced the
same CSV. Missing and extra arguments, invalid paths, malformed CSVs, non-finite
measurements, out-of-range values and an output alias to the input were rejected.
The Bash runner returned a failure when the R input was unavailable.

## Step through the tree-height calculation

In a disposable working copy under `sandbox/`, keep `code/TreeHeight.R`,
`code/get_TreeHeight.R` and `data/trees.csv` at the same relative paths. In that
copy, insert `browser()` inside `main()` immediately before the assignment to
`trees$height_m`. From the copy's root, start R in the terminal:

```bash
R --vanilla --args data/trees.csv
```

At the R prompt and then the browser prompt, enter the following in order.
Enter `n` until the debugger has advanced past the assignment before checking
`trees$height_m[1]`.

```r
source("code/get_TreeHeight.R")
trees$Distance.m[1]
trees$Angle.degrees[1]
trees$Distance.m[1] * tan(trees$Angle.degrees[1] * pi / 180)
n
n
trees$height_m[1]
c
```

The predicted and stepped values matched in a live R session. The formal
script runs without a breakpoint.

# Assignment 3: Pound Hill cultivation timing and plant species richness

This practical compares mean plant species richness per quadrat among March,
May and October cultivation treatments, with total abundance as an additional
comparison. It follows Assignment 3's use of base R and the existing `code/`,
`data/` and `results/` directories.

## Files

- `data/pound_hill_data.csv`: unchanged species counts from the course dataset.
- `data/pound_hill_meta_data.csv`: unchanged descriptions of the data fields.
- `code/pound_hill_analysis.R`: prepares the data, summarises plots and draws
  the richness figure.

The inputs were downloaded from the supplied MulQuaBio
[data](https://mulquabio.github.io/MQB/_downloads/c14bb22a50a570bbd12f60c9d0b64db2/pound_hill_data.csv)
and [metadata](https://mulquabio.github.io/MQB/_downloads/821be5002cdaa8255040b23e38313e5c/pound_hill_meta_data.csv)
links.

## Analysis

The raw file has four rows identifying quadrats, followed by species count
rows. The script transposes it and makes a long table with one row per species
per quadrat. The metadata says blank species counts are observed absences, so
these become zero. Unrecorded quadrats are not added.

Quadrats are identified by `Cultivation`, `Block`, `Plot` and `Quadrat`
together. Richness counts species with `Count > 0`; abundance sums their
counts. The script calculates both measures per quadrat, then averages within
each plot. Treatment comparisons give each plot equal weight because plots
contain different numbers of quadrats (3–6).

## How to run

From the repository root, using base R with no additional packages:

```bash
Rscript code/pound_hill_analysis.R
```

## Output files

The script creates or overwrites three files in `results/`:

- `pound_hill_plot_richness.csv`: 12 rows with `Cultivation`, `Block`, `Plot`
  and `MeanRichness`.
- `pound_hill_plot_richness.pdf`: individual plot means for March, May and
  October, with mean species richness per quadrat on the y-axis.
- `pound_hill_plot_abundance.csv`: the same 12 plots with `MeanAbundance`.

## Test notes

The data contain 41 species, 59 distinct quadrats and 12 plots, with four plots
per treatment. The script ran twice successfully; both CSVs had the correct
columns and one row per plot, and were identical after rerunning. Independent
calculations from the original CSV matched every plot mean. Both input files
retained their original SHA-256 hashes. The PDF had one page, the expected
labels and pixel-identical renderings on rerun. Python was used to verify the
CSV results and the plot renderings.

Treatment means, giving each plot equal weight, were:

| Cultivation | Mean richness (species per quadrat) | Mean abundance (individuals per quadrat) |
| --- | --- | --- |
| March | 7.81 | 144.28 |
| May | 9.65 | 143.28 |
| October | 7.61 | 205.20 |

May had the highest mean richness, although plot values overlapped among
treatments. October had the highest abundance: many individuals of a few
dominant species can give high abundance without high richness. The figure
alone cannot establish causation; random treatment allocation within blocks
and comparable management and sampling would need confirmation.

# MQB Shell, Python and R exercises

The examples in this section come from the Shell Scripting, Python, R and Data
Wrangling chapters in `MQB-main.zip`. Run the commands from the repository root
unless a different working directory is shown. Bash, Python 3 and R are used.
TIFF conversion also needs ImageMagick; `data_wrang.R` needs `reshape2`, and
`data_wrang_tidy.R` needs `dplyr` and `tidyr`. Install and check these
dependencies as described in [Software and setup](#software-and-setup).

## Shell label and image exercises

The three introductory Bash scripts are documented under Assignment 1. For
the two additional text exercises, prepare disposable inputs and run:

```bash
mkdir -p sandbox
printf 'first\n' > sandbox/count-demo-first.txt
printf 'second' > sandbox/count-demo-second.txt
bash code/CountLines.sh sandbox/count-demo-first.txt
bash code/CountLines.sh sandbox/count-demo-second.txt
bash code/ConcatenateTwoFiles.sh sandbox/count-demo-first.txt sandbox/count-demo-second.txt results/combined.txt
```

`CountLines.sh` reports one newline for the first example and zero for the
second because the latter has no terminating newline. Concatenation writes
the first input before the second, preserves bytes, and replaces the output
on rerun. It requires a path under `results/` and rejects a destination that
refers to either input. Bad counts of arguments, missing inputs and failed
reads yielded nonzero status with diagnostics.

For the label exercise, run `bash code/CheckLabel.sh oak`. Both `oak` and `pine`
succeeded. Missing or extra arguments exit with status 2, and an unknown label
such as `birch` exits with status 1. Errors are written to standard error.

`tiff2_png.sh` uses lowercase `.tif` files in the **current directory**, with
no directory argument. For a reproducible test with disposable TIFF copies:

```bash
project_root=$PWD
mkdir -p sandbox
image_test=$(mktemp -d "$PWD/sandbox/tiff-check.XXXXXX")
mkdir "$image_test/originals" "$image_test/copies"
if command -v magick >/dev/null 2>&1; then
    tiff_tool=magick
else
    tiff_tool=convert
fi
"$tiff_tool" -size 12x8 gradient: "$image_test/originals/field notes.tif"
"$tiff_tool" -size 6x9 xc:blue "$image_test/originals/-sample.tif"
cp -- "$image_test/originals/"*.tif "$image_test/copies/"
cd "$image_test/copies"
bash "$project_root/code/tiff2_png.sh"
bash "$project_root/code/tiff2_png.sh"  # Regenerate the same PNGs.
cd "$project_root"
```

Running the script again replaces the existing PNGs. Both runs produced PNGs
that matched the source TIFF pixels, including after replacing one PNG with a
different test image before the second run. The TIFF copies stayed unchanged.
No matched files or a failed conversion returns status 1. A missing converter
returns status 127. The `./` prefix keeps a leading `-` in a filename
from being treated as a converter option.

## Python examples and tests

| Command | Behavior checked |
| --- | --- |
| `python3 code/cfexercises1.py` | The condition functions accept fixed arguments and return results. Factorial implementations agree for `0` through `10`, including `0! = 1`. |
| `python3 code/loops.py` | Prints `0` to `4`, the items of a mixed list, running totals ending in `1234`, then `1` to `100`. |
| `python3 code/cfexercises2.py` | The six calls print 4, 4, 14, 5, 8 and 6 greetings. In `hello_2`, each value prints at most once because of `elif`. `hello_6` stops at the `break` after printing `hello! 5`. |
| `python3 code/MyExampleScript.py` | Squares `2` and reports `4`. |
| `python3 code/boilerplate.py` | Prints the boilerplate message during direct execution. Importing it does not run `main()`. |
| `python3 code/using_name.py` | Reports `__main__` when run as a script. After import, `module_name()` returns `using_name`. |
| `python3 code/sysargv.py oak "two words"` | Reports two arguments. A run with no arguments reports zero. |
| `python3 code/control_flow.py` | Runs the parity, divisor and prime examples. |
| `python3 code/test_control_flow.py` | Imports functions from `control_flow.py` and checks their results. Success produces no output. |
| `python3 code/observations_practice.py` | Reports sites A `(2, 1)` and B `(0, 0)`, with known total first and missing count second. |
| `python3 code/test_observations_practice.py` | Seven groups cover the three CSVs, exact duplicates, empty and absent sites, invalid rows at other sites and preservation of inputs. The new Fen example gave `(12, 1)`. |
| `python3 code/debugme.py` | Catches the expected division by zero and reports the last valid quotient, `20.0`. |

The course tests cover normal parity, zero, a negative integer and rejection
of strings. They check the largest available divisor and the `None` case,
the smallest prime and nearby values, and bounds of the prime list. The
`count_above` test with `[9, 10, 11]` and threshold `10` confirms that equality
does not count. Other tests cover a regular list and an empty list.
`python3 -m doctest -v code/control_flow.py` passed all three examples.
With `PYTHONPATH=code python3 -c 'import using_name; print(using_name.module_name())'`,
the result was `using_name`. Importing the condition functions, observations
module and debugger exercise produced no report and read no input data.

### Observation rules and Python debugger

Validate every row before filtering by site. Deduplicate the complete record,
so a repeated count on another date still contributes. The supplied boundary
file gives C `(None, 2)` and D `(0, 0)`. C has no observed counts, while D has
an observed zero. Both invalid CSV rows were checked independently.

From Bash, start Pdb with a conditional breakpoint at the division:

```bash
python3 -m pdb -c 'break 13, y == 0' -c continue code/debugme.py
```

At `(Pdb)`, enter `p (i, x, y, last_quotient)` and `list`. The real session
paused with `(19, 20, 0, 20.0)`. Enter `continue` to execute the guarded division
and finish the report, then `quit` if Pdb restarts the program.

## R functions, control flow and debugging

| Command | Behavior checked |
| --- | --- |
| `Rscript code/boilerplate.R` | Identifies numeric and character arguments. |
| `Rscript code/control_flow.R` | Shows the logical branch, the squares from 1 to 100, and loops over character values. The message for the random draw appears only at or below 0.5. |
| `Rscript code/r_conditionals.R` | Shows parity, powers of two and primality for scalar whole numbers from −2,147,483,647 through 2,147,483,647. Checks include `2` prime, `49` composite and invalid inputs. |
| `Rscript code/break.R` | Prints 0 through 9 and stops at 10. |
| `Rscript code/next.R` | Skips even numbers and prints 1, 3, 5, 7 and 9. |
| `Rscript code/try.R` | The seeded run recorded all 15 trials, with 13 means and 2 caught errors. The list `result` retains the failures as `try-error` objects. The script sets a seed for a reproducible demonstration; the number of successes can change with another seed. |

For `browse.R`, start `R --vanilla` at the repository root. In a terminal
without a graphical display, open a temporary plot device before sourcing:

```r
pdf(tempfile(fileext = ".pdf"))
source("code/browse.R")
```

At `Browse[1]>`, try `ls()`, `t` and `N[t]`. The first pause showed `t = 2`
and `N[t] = 2.71828` (rounded). `n` steps to the next expression, `c` continues
until the next breakpoint or the end of the run, and `Q` aborts debugging and
returns to the R prompt. The breakpoint is inside the loop, so continuing a
full run requires `c` at each pause. After continuing through all iterations,
`dev.off()` closes the temporary PDF device. Inspection, stepping, aborting and
continuing to the plot were verified in an interactive R session.

## R file I/O and Pound Hill data

- `Rscript code/basic_io.R` reads `data/trees.csv` and creates `results/` if
  needed. It writes `results/MyData.csv`, appends a copy of the first record,
  then overwrites the file to demonstrate row names and omitting the header.
  The file had 121, 122, 121 and 120 physical lines after the four writes. The
  final CSV has the 120 original data rows plus a row-number field and no header.
- `Rscript code/data_wrang.R` reads the two Pound Hill CSVs. The metadata uses
  a semicolon delimiter. The script transposes the raw table, treats blank
  counts in sampled quadrats as observed zeroes and uses `reshape2::melt()` to
  reshape the species columns. `results/pound_hill_long.csv` contains 2,419
  rows for 59 recorded quadrats and 41 species. Every row was checked against
  the original counts. The source CSVs retained their original hashes.

- `Rscript code/data_wrang_tidy.R` repeats the Pound Hill reshaping with
  `dplyr` and `tidyr::pivot_longer()` and writes
  `results/pound_hill_long_tidy.csv`. Both versions produced identical
  identifiers, ordering, records and types. The four identifier columns and
  `Species` are factors in R, and `Count` is integer. The two output CSVs were
  byte-identical and remain separate files.
- `Rscript code/observations_practice.R` checks the ordinary and boundary data
  with `stopifnot()` and creates `results/observations_known_totals.pdf`. It
  agrees with Python on A `(2, 1)`, B `(0, 0)` and D `(0, 0)`. For C, R reports
  `(NA, 2)` and Python reports `(None, 2)`. The plot labels
  the observed zeros and annotates C as a site with no known counts.

In a shell, reproduce the expected invalid input failure with:

```bash
Rscript -e 'source("code/observations_practice.R"); read_observations("data/bootcamp_observations_invalid.csv")'
```

It exits nonzero and identifies CSV row 2 and count `-1`. The Python exercise
uses Python's `int()` conversion. The R exercise checks the specified digit
pattern and R's integer range before conversion. Both validate before
deduplicating and preserve missing versus observed zero.

Generated outputs and temporary image tests are covered by `.gitignore`.

## Portfolio verification

The nine practicals and 30 classroom files were checked on Linux from their
documented entry points. The checks included fresh output directories, repeat
runs, failures and three live debugger sessions. Input files supplied by MQB
were compared with the referenced snapshot. The existing `tab-example.tsv`
was preserved. The three previously tracked Silwood result CSVs were removed
from the Git index and kept locally. Clone the GitHub repository into a new
directory outside this repository and rerun the commands in this guide from
that clone's root.


## AI use for the portfolio

From November 20 to 27, 2026, I used OpenAI Codex to help me understand the
Shell, Python and R examples in the MQB textbook, troubleshoot runtime errors,
review and make suggestions on how to improve the code, and organize this README.

I checked the suggestions by reviewing the results of the Linux runs and
comparing them with the course requirements and original data. For example, I
used two TIFF copies to check conversion and reruns, and verified that the PNG
pixels matched those of the original TIFFs. I also compared the output of the
two Pound Hill data wrangling workflows in R and confirmed that their CSV
files were identical byte for byte.

## Revisions after formative feedback

### Assignment 1

The five FASTA commands already use `../data/fasta/` when run from `code/`.
Repeating them gave 27, 127 and 78,104 newlines (78,258 total), 78,103
header-free sequence lines, 4,686,137 sequence positions, 21,968 `ATGC`
matches and an AT/GC ratio of `.96922822848944879586`. An independent count
confirmed the results, including the treatment of ambiguity and wrapped
motifs. The two converters already follow the repository-root convention.
In an isolated local copy with no `results/`, they created the output for
the supplied TSV and all four temperature CSVs. All five outputs matched
the expected byte substitutions and were identical on rerun. Checks also
covered filenames with spaces, consecutive separators, missing or extra
arguments, and missing or unreadable inputs. The source hashes stayed the
same.

### Assignment 2

The Silwood cleaner now reports the physical starting line of a rejected
CSV record. The regression example includes a blank line and a quoted field
that spans lines. The integrated test passes a valid and invalid record
through `process_records()` and checks that only accepted records contribute
to `summarise_oaks()`.

```bash
python3 code/test_silwood_trees.py
python3 code/clean_silwood_trees.py
```

All 12 test groups passed. From an isolated local copy with no `results/`, the
cleaner produced all three CSVs twice with identical bytes. The supplied
survey gave 24 accepted records and 12 rejected records, with four each of
`petraea` and `robur`. Headers and record order matched the specification.
For example, source line 27 reported duplicate `ST004`; the reasons for
`ST036` appeared in metadata order. The raw CSV and metadata were unchanged.
Git's index contains no generated results. See the
[Fresh-clone check](#fresh-clone-check) under Portfolio verification.

### Assignment 3: Tree heights

`TreeHeight(degrees, distance)` now follows the taught argument order. The
fixed and general scripts both pass the angle first and share the same
calculation. `TreeHeight(37, 40)` gives `30.142162004112` m, matching the
independent calculation `40 * tan(37 * pi / 180)`.

Run these commands in a shell from the repository root:

```bash
Rscript code/TreeHeight.R
Rscript code/get_TreeHeight.R data/trees.csv
bash code/run_get_TreeHeight.sh
```

In an **R console** started from the same directory, run:

```r
source("code/TreeHeight.R")
TreeHeight(37, 40)
```

The fixed script reads `data/trees.csv` and writes `results/TreeHts.csv`.
The general script takes an input path, and its `data/trees.csv` example and
shell wrapper both write `results/trees_treeheights.csv`.

| Source record | Horizontal distance (m) | Angle (degrees) | Independent height (m) | Program height (m) |
| --- | ---: | ---: | ---: | ---: |
| CSV line 2, *Populus tremula* | 31.6658337740228 | 41.2826361937914 | 27.802116143854 | 27.802116143854 |

The reported heights agree to 12 decimal places for this row. An interactive
R session with `data/trees.csv` passed as an argument also confirmed the row
by stepping through the assignment to `height_m`. All 120 records matched an
independent calculation and retained input order. The three commands
reproduced identical CSV contents on rerun. In an isolated copy, a distance
of 101 m caused all three entry points to exit with status 1 and a distance
bound error, both with and without existing result files. No result was
created on failure or replaced if it already existed.

### Assignment 3: Pound Hill

`code/pound_hill_analysis.R` preserves the raw cultivation keys `march`, `may`
and `october` in both CSVs. The figure uses `March`, `May` and `October` for
display. Fixed horizontal offsets separate the 12 individual plot means,
and a different symbol marks each treatment mean. Each treatment mean gives
its four plots equal weight.

```bash
Rscript code/pound_hill_analysis.R
```

This reads `data/pound_hill_data.csv` and `data/pound_hill_meta_data.csv` and
regenerates `results/pound_hill_plot_richness.csv`,
`results/pound_hill_plot_abundance.csv` and
`results/pound_hill_plot_richness.pdf`. An independent calculation from the
raw data matched each plot key and all 12 richness and abundance values in
their respective CSVs. The 12 plotted values and three treatment means were
checked against the table. Mean richness per quadrat was 7.8083 for March,
9.6500 for May and 7.6125 for October. The CSV bytes and rendered PDF matched
on rerun.

### Fresh-clone check results

- Date: 2026-11-27
- Commit checked: `67c42b49f456df08034af82c46f223ef6e2366ed`
- Clone location: `../verification/ZihanGit-fresh` (a new directory outside
  this repository).
- Result: 39/39 required files passed; 36 passed initially, and the three
  checks blocked by missing dependencies passed on rerun. No checks remained
  failed or unrun.

The verification used Ubuntu 26.04.1 LTS, Python 3.14.4 and R 4.5.2. The
`bc` command was already available. The R packages `reshape2` (1.4.5),
`dplyr` (1.2.1) and `tidyr` (1.3.2) were installed from CRAN using an
R library inside the verification clone. ImageMagick 7.1.2-18 was downloaded
from the official Ubuntu package repository and unpacked with its dependencies
inside the verification clone because a system-wide installation required
interactive sudo authentication. No dependency files were reused from the
original repository.

After the initial run, the README setup instructions were clarified to
document the dependencies for a fresh clone and remove references to the
original checkout's local environment. No tracked files in the verification
clone were changed. The three failed checks were repeated after installing
the missing dependencies there.

| File | Initial run | Change before rerun | Rerun result |
| --- | --- | --- | --- |
| `code/tiff2_png.sh` | Failed: `magick` and `convert` were unavailable. The TIFF fixture creation failed, and the script returned exit 127 with a valid TIFF and no converter. | Installed ImageMagick locally from the official Ubuntu packages and made `magick` available in the test session. | Passed (exit 0); TIFF-to-PNG pixel comparison and repeated conversion succeeded. |
| `code/data_wrang.R` | Failed (exit 1): `there is no package called 'reshape2'`. | Installed `reshape2` from CRAN in the verification clone's R library. | Passed (exit 0); 2,419 records, with byte-identical CSV output on repeat. |
| `code/data_wrang_tidy.R` | Failed (exit 1): `there is no package called 'dplyr'`; `tidyr` was also missing. | Installed `dplyr` and `tidyr` from CRAN in the verification clone's R library. | Passed (exit 0); 2,419 records, with byte-identical CSV output on repeat. |

Both Pound Hill data wrangling scripts produced 2,419 records that matched
the source data. Their CSV outputs were byte-identical across both scripts
and repeated runs. TIFF conversions produced pixel-identical PNGs on
repeated runs; only PNG timestamp metadata differed. All 60 Git-tracked
files in the verification clone retained their original contents and
executable permissions.
