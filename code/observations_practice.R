# MQB observations practice. Run from the repository root with Rscript.
read_observations <- function(path) {
    data <- read.csv(path, colClasses = "character", na.strings = "",
                     check.names = FALSE, row.names = NULL, fill = FALSE)
    if (!identical(names(data), c("site", "date", "count"))) {
        stop(sprintf("%s: expected CSV columns site,date,count in that order.", path),
             call. = FALSE)
    }

    for (field in c("site", "date")) {
        invalid <- which(is.na(data[[field]]) | !nzchar(data[[field]]))
        if (length(invalid)) {
            stop(sprintf("%s: CSV row %d, column '%s': expected non-empty text.",
                         path, invalid[1] + 1L, field), call. = FALSE)
        }
    }

    known <- !is.na(data$count)
    valid <- grepl("^(0|[1-9][0-9]*)$", data$count)
    invalid <- which(known & !valid)
    if (length(invalid)) {
        row <- invalid[1]
        stop(sprintf(paste0("%s: CSV row %d, column 'count': found '%s'. ",
                            "Expected an empty field or a non-negative integer."),
                     path, row + 1L, data$count[row]), call. = FALSE)
    }

    counts <- suppressWarnings(as.integer(data$count))
    out_of_range <- which(known & is.na(counts))
    if (length(out_of_range)) {
        row <- out_of_range[1]
        stop(sprintf("%s: CSV row %d, column 'count': '%s' exceeds R's integer range.",
                     path, row + 1L, data$count[row]), call. = FALSE)
    }
    data$count <- counts
    data
}

summarise_observations <- function(data) {
    data <- unique(data)
    sites <- sort(unique(data$site))
    totals <- vapply(sites, function(site) {
        counts <- data$count[data$site == site]
        if (all(is.na(counts))) NA_real_ else sum(counts, na.rm = TRUE)
    }, numeric(1))
    missing <- vapply(sites, function(site) {
        sum(is.na(data$count[data$site == site]))
    }, integer(1))

    data.frame(site = sites, total_known = unname(totals),
               missing_count = unname(missing))
}

plot_known_totals <- function(summary, path) {
    known <- !is.na(summary$total_known)
    missing_sites <- summary$site[!known]

    grDevices::pdf(path, width = 7, height = 4.5)
    on.exit(grDevices::dev.off())
    par(mar = c(5.8, 4.1, 4.1, 2.1))
    if (any(known)) {
        totals <- summary$total_known[known]
        padding <- max(1, max(totals)) * 0.15
        positions <- barplot(totals, names.arg = summary$site[known],
                            ylim = c(0, max(totals) + padding), col = "steelblue",
                            main = "Known observation totals by site",
                            ylab = "Known count", xlab = "Site")
        text(positions, totals + padding / 3, labels = totals)
    } else {
        plot.new()
        title(main = "Known observation totals by site")
    }
    if (length(missing_sites)) {
        mtext(paste("No known counts:", paste(missing_sites, collapse = ", ")),
              side = 1, line = 4.4)
    }
}

main <- function() {
    ordinary <- read_observations("data/bootcamp_observations.csv")
    boundary <- read_observations("data/bootcamp_observations_boundary.csv")
    summary <- summarise_observations(rbind(ordinary, boundary))
    stopifnot(
        identical(summary$site, c("A", "B", "C", "D")),
        identical(summary$total_known, c(2, 0, NA_real_, 0)),
        identical(summary$missing_count, c(1L, 0L, 2L, 0L))
    )
    print(summary, row.names = FALSE)

    dir.create("results", showWarnings = FALSE)
    plot_known_totals(summary, "results/observations_known_totals.pdf")
}

if (sys.nframe() == 0L) {
    main()
}
