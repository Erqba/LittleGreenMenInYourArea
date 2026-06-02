ui <- page_navbar(
  title = "LittleGreenMenInYourArea",
  theme = ufo_theme,
  fillable = TRUE,
  
  sidebar = sidebar(
    title = "Radar Controls",
    sliderInput("year_range", "Year of Sighting:",
                min = min_year, max = max_year,
                value = c(2000, max_year), step = 1, sep = ""),
    
    selectInput("shape_filter", "UFO Shape:",
                choices = c("All Shapes" = "All", available_shapes),
                selected = "All"),
    
    numericInput("min_duration", "Min Duration (Seconds):", 
                 value = 0, min = 0)
  ),
  
  nav_panel("The Radar",
    layout_columns(
      col_widths = c(12, 12),
      card(
        card_header("Sighting Hotspots"),
        leafletOutput("ufo_map", height = "50vh")
      ),
      card(
        card_header("Activity Timeline"),
        plotlyOutput("ufo_timeline", height = "30vh")
      )
    )
  ),
  
  nav_panel("The Profiler",
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Common Shapes (Click to filter Box Plot)"),
        plotlyOutput("shape_treemap")
      ),
      card(
        card_header("Duration by Shape"),
        checkboxInput("log_scale", "Log Scale (Y-Axis)", value = TRUE),
        plotlyOutput("duration_boxplot")
      )
    )
  ),
  
  nav_panel("The X-Files",
    layout_columns(
      col_widths = c(12, 12),
      card(
        card_header("Classified Incident Logs"),
        DTOutput("ufo_table")
      ),
      card(
        card_header("Witness Testimony"),
        uiOutput("witness_narrative") 
      )
    )
  ),
  
  nav_panel("Deep Search",
            layout_columns(
              col_widths = c(4, 8),
              card(
                card_header("AI Semantic Query"),
                p("Describe a sighting in natural language to find the closest historical matches."),
                textAreaInput("semantic_query", "Witness Description:", 
                              placeholder = "e.g., a glowing green orb over the lake...",
                              width = "100%",
                              rows = 5),
                actionButton("run_search", "Initialize Search", 
                             class = "btn-primary", 
                             style = "background-color: #39ff14; color: black; font-weight: bold;")
              ),
              card(
                card_header("Top Classified Matches"),
                uiOutput("semantic_results")
              )
            )
  ),
  
  nav_panel("Classified Info",
    card(
      card_header("About This Database"),
      p("Welcome to LittleGreenMenInYourArea. This dashboard analyzes over 100,000 geocoded, time-normalized sightings from the NUFORC database."),
      p("Use the sidebar to filter the data globally. Clicking on table rows in 'The X-Files' tab will reveal the original witness statements.")
    )
  )
)