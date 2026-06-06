library(shiny)
library(bslib)
library(leaflet)
library(plotly)
library(DT)
library(dplyr)
library(lubridate)
library(stringr)
library(leaflet.extras)
library(httr2)
library(tidyr)
library(howler)

ufo_theme <- bs_theme(
  preset = "cyborg",
  primary = "#39ff14",
  base_font = font_google("Space Mono"),
  heading_font = font_google("Orbitron")
)

vdb <- readRDS("ufo_vector_db.rds")

ufo_data <- vdb$metadata
ufo_embeddings <- vdb$embeddings

rm(vdb)

ufo_data <- ufo_data %>%
  mutate(
    Occurred_Clean = str_remove(Occurred, " Local"),
    Occurred_Local = ymd_hms(Occurred_Clean),
    DayOfWeek = wday(Occurred_Local, label = TRUE, abbr = FALSE, week_start = 1),
    Hour = hour(Occurred_Local),
    Month = month(Occurred_Local, label = TRUE, abbr = FALSE)
  )

available_shapes <- sort(unique(ufo_data$Shape[!is.na(ufo_data$Shape)]))
min_year <- min(ufo_data$Year, na.rm = TRUE)
max_year <- max(ufo_data$Year, na.rm = TRUE)

calculate_cosine_similarity <- function(query_vec, db_matrix) {
  dot_products <- as.vector(db_matrix %*% query_vec)
  magnitudes <- sqrt(rowSums(db_matrix^2)) * sqrt(sum(query_vec^2))
  return(dot_products / magnitudes)
}