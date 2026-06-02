library(shiny)
library(bslib)
library(leaflet)
library(plotly)
library(DT)
library(dplyr)
library(lubridate)
library(stringr)
library(leaflet.extras)

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

available_shapes <- sort(unique(ufo_data$Shape[!is.na(ufo_data$Shape)]))
min_year <- min(ufo_data$Year, na.rm = TRUE)
max_year <- max(ufo_data$Year, na.rm = TRUE)

HF_TOKEN <- Sys.getenv("HF_TOKEN")

calculate_cosine_similarity <- function(query_vec, db_matrix) {
  dot_products <- as.vector(db_matrix %*% query_vec)
  magnitudes <- sqrt(rowSums(db_matrix^2)) * sqrt(sum(query_vec^2))
  return(dot_products / magnitudes)
}