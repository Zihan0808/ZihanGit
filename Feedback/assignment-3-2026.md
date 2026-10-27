# Assignment 3 formative feedback

This feedback is organised using the [Computing Bootcamp rubric](https://mulquabio.github.io/MQB/rubrics/Computing_Bootcamp_Rubric.html). It does not award a mark; use it to decide what to revise and check before final submission.

## Criterion 1: Repository organisation & workflow discipline

- All required paths are present, and the supplied inputs match the original files. Your Assignment 3 generated outputs are covered by `.gitignore`.

## Criterion 2: Code completeness & functional correctness

- The fixed and generalised tree-height programs both ran and produced CSVs matching their respective required output format and values. These are separate pieces of evidence; neither establishes that the function interface is correct.
- Before final submission, **Finish the reproducibility evidence.** Your tree-height manual-check table has a heading but no completed data row, so it does not yet demonstrate your independent check. Add the chosen measurements, independently calculated height, program result and a brief comparison. The run instructions also mix a shell command with R's `source()` in a Bash block and omit examples for the generalised script and wrapper. Separate shell and R-console instructions so another reader can reproduce both routes.

## Criterion 3: Code quality & style

As you revise, keep names descriptive, use comments to explain decisions rather than restating code, and avoid repeating the same calculation in several places.

## Criterion 4: Documentation

Give exact commands in the root `README.md`, together with each script’s input and output files, so that another student could repeat your checks.

## Criterion 5: Version-control practice

Commit each functional revision with a short message that says what changed; this makes your development easier to follow than one large final commit.

## Criterion 8: Basic error-handling & input validation

- The invalid-input runs stopped with useful messages about distance bounds and non-finite or missing numeric values. Your code also shows validation before output writing.

## Criterion 9: Problem-solving approach & method implementation

- Your Pound Hill source clearly separates species presence, quadrat richness and plot means. The README explains equal weighting of plots and distinguishes richness from abundance, with an appropriately cautious interpretation of causation. When I opened the figure, I found an informative figure title and readable axes.
- Before final submission, **Correct the tree-height function interface.** The direct call `TreeHeight(37, 40)` did not agree with the check. In both scripts, the function currently takes distance first; the required interface takes **angle in degrees first, horizontal distance second**. Internally consistent calls can still produce matching CSVs while hiding this mismatch. Review the definitions and their call sites together, then try the taught example call and compare it with a direct calculation using the degree-to-radian conversion.
- Before final submission, **Keep Pound Hill data identifiers separate from display labels.** Execution succeeded, but `results/pound_hill_plot_richness.csv` differed in its plot keys because cultivation labels had changed capitalisation. Inspect the distinct cultivation values in the input, after factor conversion and in the exported CSV. Preserve the required identifiers in the table while handling presentation labels separately. This observation identifies a key-format issue; check the richness values separately after correcting the keys.
- Before final submission, **Make outputs easier to inspect and regenerate.** Some figure points overlap, and the figure does not show a treatment summary. Adjust point placement to reveal nearby values; consider a clearly labelled summary alongside the individual plots. Check the PDF against the CSV and your biological interpretation. Three older generated CSVs remain tracked under `results/`; reconcile this with the coursework policy of regenerating results rather than committing them. Ignoring files alone will not untrack existing files.

## Criterion 10: Learning progression demonstration

Use this feedback as a revision checklist. Make the changes in small, descriptive commits, then add a short README note explaining what you changed and how you checked it. This will make your development from this formative checkpoint visible in the final portfolio.

## Priorities before final submission

- Run both tree-height routes from the directory containing `code/`, `data/` and the root `README.md`. For each, rerun one ordinary and one invalid case, inspecting the error message, exit status and whether a fresh output was produced. Regenerate the Pound Hill table and PDF, inspect identifiers and plotted values, then record the checks in the README and commit the changes descriptively.
