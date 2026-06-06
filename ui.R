ui <- page_navbar(
  id = "main_tabs", 
  title = tags$span(
    tags$img(
      src = "ufo_logo_4.png", 
      height = "70px",
      style = "margin-top: -5px; margin-bottom: -5px;"
    ), 
    "LittleGreenMenInYourArea"
  ),
  theme = ufo_theme,
  fillable = TRUE,
  sidebar = sidebar(
    title = "Controls",
    
    sliderInput("year_range", "Year of Sighting:",
                min = min_year, max = max_year,
                value = c(2000, max_year), step = 1, sep = ""),
    
    selectInput("shape_filter", "UFO Shape:",
                choices = c("All Shapes" = "All", available_shapes),
                selected = "All"),
    
    numericInput("min_duration", "Min Duration (Seconds):", 
                 value = 0, min = 0),
    
    conditionalPanel(
      condition = "input.main_tabs == 'The Radar'",
      sliderInput("map_points", "Max Map Points:",
                  min = 1000, max = 100000, 
                  value = 5000, step = 1000)
    )
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
            navset_pill(
              nav_panel("Time & Shape Analysis",
                        layout_columns(
                          col_widths = c(6, 6),
                          card(
                            card_header("When do the aliens appear? (Click a cell to filter)"),
                            plotlyOutput("time_heatmap", height = "500px")
                          ),
                          card(
                            card_header("What are the aliens flying?"),
                            plotlyOutput("dynamic_shape_bar", height = "500px")
                          )
                        )
              ),
              nav_panel("Entity Characteristics",
                        card(
                          card_header("Common Characteristics"),
                          plotlyOutput("characteristics_radar", height = "600px")
                        )
              ),
              nav_panel("Seasonal Analysis",
                        card(
                          card_header("The Seasonal Scanner: Sightings by Month"),
                          p("Analyzing the cyclical nature of anomalies.", 
                            style = "color: #aaaaaa; font-size: 0.9em; margin-left: 15px;"),
                          plotlyOutput("seasonal_rose", height = "550px") 
                        )
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