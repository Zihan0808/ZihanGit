# Assignment 1 feedback - Zihan Gao

**Formative feedback | Rubric 2026.2**

The tab converter has a useful structure: clear argument and file checks, quoted paths and an explicit check on conversion success. Your own TSV includes an empty field, and the Unix explanations discuss ambiguity symbols and motifs spanning wrapped lines.

However, the Unix commands use data/... paths for the repository root rather than the required code/ starting directory. Q1-Q2 did not run successfully there, and Q3-Q4 returned incorrect counts. Q5 did not give a verifiable ratio. Start by fixing that shared path problem, then check the actual results; values already written beside a command do not establish that the command reproduces them.

The converters are inconsistent about their starting directory too. The tab script follows the root-based convention, while csvtospace.sh writes through ../results. Bring the CSV script into line without losing the tab script's useful validation. Update the inherited author/date placeholders and give the CSV script a concise, accurate header.

Several expected outputs are already committed, which prevented the corresponding fresh-output checks from running. Remove generated files from version control and ignore results/, while keeping scripts and required inputs. Then replace the one-line practice README with an Assignment 1 guide: purpose, exact commands, a few expected/observed tests, dependencies and any help used. Make the revision commits name the task changed rather than just the fact that files were uploaded.

---

## Project structure

Relevant tracked layout (simplified; missing required paths are marked):

```text
README.md
.gitignore
code/  unixPrac1.txt, tabtocsv.sh, csvtospace.sh
data/fasta/  3 required files present
data/temperatures/  4 required files present
data/tab-example.tsv
results/  5 files tracked
sandbox/  1 files tracked
```

All required Assignment 1 paths are present, including the own TSV. The problem is repository hygiene: five generated conversions are tracked in results/, and sandbox/test.py is also tracked. The ignore file currently covers only temporary filename patterns.

Untrack generated results and add rules for results/ and disposable sandbox contents. If test.py is useful source rather than a throwaway experiment, give it a suitable home in code/ instead of discarding it. Keep the input files committed and make the root README explain this distinction.

**Assessed snapshot:** `6335d7a901af43ea06f0de18bdc484a8ed13fbfe`
