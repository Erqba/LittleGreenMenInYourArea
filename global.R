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

ufo_data <- readRDS("ufo_data.rds")

available_shapes <- sort(unique(ufo_data$Shape[!is.na(ufo_data$Shape)]))
min_year <- min(ufo_data$Year, na.rm = TRUE)
max_year <- max(ufo_data$Year, na.rm = TRUE)