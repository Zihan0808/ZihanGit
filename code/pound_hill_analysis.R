
raw_data <- read.csv("data/pound_hill_data.csv", header = FALSE,
                     colClasses = "character", na.strings = NULL)
metadata <- read.csv("data/pound_hill_meta_data.csv", sep = ";",
                     strip.white = TRUE)
print(dim(raw_data))
str(raw_data[, 1:6])
print(head(raw_data[, 1:6]))
print(metadata)

wide_data <- as.data.frame(t(as.matrix(raw_data[, -1])),
                           stringsAsFactors = FALSE)
names(wide_data) <- raw_data[, 1]
identifiers <- c("Cultivation", "Block", "Plot", "Quadrat")
species_names <- names(wide_data)[-(1:4)]
# Keep the input codes for grouping and CSV output. Label the figure separately.
cultivation_keys <- c("march", "may", "october")
wide_data$Cultivation <- factor(wide_data$Cultivation, levels = cultivation_keys)
wide_data$Plot <- as.integer(wide_data$Plot)
stopifnot(!anyNA(wide_data[identifiers]),
          !anyDuplicated(wide_data[identifiers]))


long_data <- data.frame()
for (species in species_names) {
    species_records <- wide_data[identifiers]
    species_records$Species <- species
    species_records$Count <- wide_data[[species]]
    long_data <- rbind(long_data, species_records)
}

long_data$Count[trimws(long_data$Count) == ""] <- "0"
long_data$Count <- as.numeric(long_data$Count)
if (any(!is.finite(long_data$Count)) || any(long_data$Count < 0)) {
    stop("Species counts must be finite, non-negative numbers.")
}
cat("Distinct species:", length(unique(long_data$Species)), "\n")
cat("Distinct quadrats:", nrow(unique(long_data[identifiers])), "\n")
cat("Distinct plots:",
    nrow(unique(long_data[c("Cultivation", "Block", "Plot")])), "\n")

long_data$Present <- as.integer(long_data$Count > 0)
quadrat_richness <- aggregate(Present ~ Cultivation + Block + Plot + Quadrat,
                              data = long_data, FUN = sum)
names(quadrat_richness)[5] <- "Richness"
quadrat_abundance <- aggregate(Count ~ Cultivation + Block + Plot + Quadrat,
                               data = long_data, FUN = sum)
names(quadrat_abundance)[5] <- "Abundance"

plot_richness <- aggregate(Richness ~ Cultivation + Block + Plot,
                           data = quadrat_richness, FUN = mean)
names(plot_richness)[4] <- "MeanRichness"
plot_abundance <- aggregate(Abundance ~ Cultivation + Block + Plot,
                            data = quadrat_abundance, FUN = mean)
names(plot_abundance)[4] <- "MeanAbundance"
plot_richness <- plot_richness[order(plot_richness$Cultivation,
                                    plot_richness$Block, plot_richness$Plot), ]
plot_abundance <- plot_abundance[order(plot_abundance$Cultivation,
                                      plot_abundance$Block, plot_abundance$Plot), ]
stopifnot(nrow(plot_richness) == 12, nrow(plot_abundance) == 12)
print(plot_richness, row.names = FALSE)
print(plot_abundance, row.names = FALSE)
cat("Treatment means, giving each plot equal weight:\n")
treatment_richness <- aggregate(MeanRichness ~ Cultivation, data = plot_richness,
                                FUN = mean)
print(treatment_richness, row.names = FALSE)
print(aggregate(MeanAbundance ~ Cultivation, data = plot_abundance, FUN = mean))

dir.create("results", showWarnings = FALSE)
write.csv(plot_richness, "results/pound_hill_plot_richness.csv", row.names = FALSE)
write.csv(plot_abundance, "results/pound_hill_plot_abundance.csv", row.names = FALSE)

# Offset plot points in fixed order so nearby values stay visible on reruns.
# Place the equally weighted treatment mean beside the individual plots.
axis_positions <- seq_along(cultivation_keys)
axis_labels <- c("March", "May", "October")
plot_positions <- match(plot_richness$Cultivation, cultivation_keys)
for (position in axis_positions) {
    rows <- which(plot_richness$Cultivation == cultivation_keys[position])
    plot_positions[rows] <- position + seq(-0.26, 0.04, length.out = length(rows))
}
mean_positions <- match(treatment_richness$Cultivation, cultivation_keys) + 0.23
richness_range <- range(plot_richness$MeanRichness)
plot_colour <- "#246B75"
mean_colour <- "#AA5622"

pdf("results/pound_hill_plot_richness.pdf", width = 7, height = 5)
par(mar = c(4.5, 4.6, 3, 1.2))
plot(NA_real_, NA_real_, type = "n", xlim = c(0.5, tail(axis_positions, 1) + 0.5),
     ylim = richness_range + c(-0.3, 1.3), xaxt = "n", bty = "l",
     xlab = "Cultivation treatment", ylab = "Mean species richness per quadrat",
     main = "Pound Hill: species richness by cultivation timing")
axis(1, at = axis_positions, labels = axis_labels)
abline(h = axTicks(2), col = "#E4EAEC", lwd = 0.8)
points(plot_positions, plot_richness$MeanRichness, pch = 19, col = plot_colour)
points(mean_positions, treatment_richness$MeanRichness, pch = 23,
       col = mean_colour, bg = "#EAA461", cex = 1.25)
legend("topleft", inset = c(0.01, 0.01), horiz = TRUE, bty = "n",
       legend = c("Individual plot mean", "Treatment mean"), pch = c(19, 23),
       col = c(plot_colour, mean_colour), pt.bg = c(NA, "#EAA461"), cex = 0.87)
dev.off()

# May has the highest mean plot richness (9.65 species per quadrat), compared
# with March (7.81) and October (7.61).
# Plot means overlap across treatments: March ranges from 6.33 to 10.00,
# May from 7.40 to 11.60, and October from 6.40 to 10.25.
# The figure alone cannot establish causation; random treatment allocation
# within blocks and comparable management and sampling would need confirmation.

# October has the highest mean abundance (205.20 individuals per quadrat),
# compared with March (144.28) and May (143.28), unlike the richness pattern.
# Abundance can be high when a few species dominate, whereas richness counts
# how many species are present regardless of their individual counts.
