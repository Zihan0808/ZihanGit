# Assignment 2 formative feedback

This feedback is organised by the relevant computing bootcamp criteria. Use it to decide what is already working, what you need to investigate, and what to revise before the cumulative submission.

The full criteria are in the [Computing Bootcamp assessment rubric](https://github.com/MulQuaBio/MQB/blob/main/content/rubrics/Computing_Bootcamp_Rubric.md).

## 1. Repository organisation and workflow discipline

- Your root README, `.gitignore`, cleaning script, test script and supplied data files are in the expected locations. The supplied CSV and metadata are unchanged, giving you a reproducible starting point.

## 2. Code completeness and functional correctness

- The required files are present, and the raw CSV and metadata match the supplied versions unchanged.
- **Make output generation independently reproducible.** I could not verify output creation from an empty results folder because `results/silwood_trees_clean.csv` was already committed. The generated tables were unavailable, so I could not inspect them, so their contents were not compared. This does not mean that your tables are wrong or missing. Make a separate copy of your repository in a new folder using `git clone` and confirm that the generated CSV files are not already present. Run the workflow there to check that the three writer calls create new files.
- Make a separate copy of your repository in a new folder using `git clone`, confirm that the generated CSV files are absent, and run the script there using the unchanged raw input. Inspect all three newly generated tables: check headers and ordering, verify a small selection of accepted and rejected rows against their expected outputs, and check that the oak summary uses the cleaned collection.

## 3. Code quality and style

- Your `main()` function gives the program a clear overall structure by connecting loading, processing, summarising and writing. Keep these stages distinct as you revise; use descriptive names and add short comments where the reason for a validation check or data-cleaning step is not obvious.

## 4. Documentation

- Your root README is in place. Make it useful to someone opening the repository for the first time: explain what the cleaner does, how to run the script and tests from the repository root, and which three files it creates. Test the instructions in a newly cloned copy of your repository (a separate folder created with `git clone`): enter that folder and run each README command exactly as written. If something fails, correct the command or add the missing step.

## 5. Version-control practice

- Since the previous formative feedback was added, the saved history contains 2 non-merge commits. `W2 first push` is the only recent message that could contain Assignment 2 work, but it does not say which files or behaviour were added. The other recent commit concerns Assignment 1 feedback.
- Before each commit, run `git diff --staged` to see exactly what will be recorded. Keep one coherent, working change per commit and write a concise message that names what changed—for example, the validation rule added, the failing test fixed or the README instruction clarified.
- `results/silwood_trees_clean.csv` is currently tracked by Git. After confirming that it is a generated file, run `git rm --cached results/silwood_trees_clean.csv`; this removes it from Git without deleting your local copy. Keep the results path in `.gitignore`, commit the change, and use `git status` to confirm that generated CSVs will not be included again.

## 8. Basic error handling and input validation

- Your separate test file includes checks for validation, accepted/rejected partitioning, duplicate IDs, oak summaries and end-to-end writing. The test run exited successfully; this is a useful start, but you should still check the important edge cases and output contents.
- Run the separate test file again. If the clean run reveals a discrepancy, add a small regression test targeting that specific step or boundary case rather than relying only on successful execution.
- Check that your root README explains the workflow and gives working run and test commands. Test the instructions in a newly cloned copy of your repository (a separate folder created with `git clone`): enter that folder and run each README command exactly as written. If something fails, correct the command or add the missing step.

## 9. Problem-solving approach and method implementation

- Before final submission, add or refine a small assertion-based test in `code/test_silwood_trees.py` using one valid and one invalid record. Check that `process_records()` places them in the cleaned and issues collections respectively, then pass the cleaned collection to `summarise_oaks()` and check that the invalid record does not contribute. Run the complete cleaner and inspect the three output files. Briefly explain this flow in your root README.
