library(shiny)
library(bslib)
library(leaflet)
library(plotly)
library(DT)
library(dplyr)
library(jsonlite)
library(lubridate)
library(stringr)
library(leaflet.extras)

ufo_theme <- bs_theme(
  preset = "cyborg",
  primary = "#39ff14",
  base_font = font_google("Space Mono"),
  heading_font = font_google("Orbitron")
)

# TODO saveRDS(ufo_data, "ufo_data.rds") and readRDS("ufo_data.rds")
ufo_data <- jsonlite::fromJSON("database.json") %>%
  mutate(
    Occurred_UTC = ymd_hms(Occurred_UTC),
    Year = year(Occurred_UTC),
    Shape = str_to_title(Shape) 
  )
available_shapes <- sort(unique(ufo_data$Shape[!is.na(ufo_data$Shape)]))
min_year <- min(ufo_data$Year, na.rm = TRUE)
max_year <- max(ufo_data$Year, na.rm = TRUE)