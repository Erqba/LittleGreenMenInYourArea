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
                  min = 1000, max = 50000, 
                  value = 5000, step = 1000)
    ),
    
    howler(
      elementId = "xfiles_theme",
      tracks = c("xfiles.mp3"),
      options = list(
        autoplay = FALSE, 
        loop = TRUE,
        html5 = TRUE,
        preload = TRUE
      )
    ),
    tags$div(
      style = "position: absolute; bottom: 20px; left: 20px; right: 20px; text-align: center;",
      tags$div(
        style = "display: block; color: #39ff14; background-color: #111111; border-radius: 5px; border: 1px solid #39ff14; padding: 5px; transition: all 0.3s;",
        tags$span("Initialize Audio Logs"),
        howlerPlayPauseButton("xfiles_theme")
      )
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
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header("1. Seasonal Scanner (Click to filter below)"),
                plotlyOutput("seasonal_rose", height = "380px") 
              ),
              card(
                card_header("2. Temporal Matrix (Click to filter below)"),
                plotlyOutput("time_heatmap", height = "380px") 
              )
            ),
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header("3. Shape Profiler (Double-click others to reset)"),
                plotlyOutput("dynamic_shape_bar", height = "380px") 
              ),
              card(
                card_header("4. Entity Characteristics (Double-click others to reset)"),
                plotlyOutput("characteristics_radar", height = "380px") 
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
                card_header("Semantic Query"),
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
              style = "border: 1px solid #39ff14; background-color: #0a0a0a;",
              card_header(
                tags$strong("TOP SECRET", style = "color: #39ff14; font-family: 'Orbitron', sans-serif; font-size: 1.2em;")
              ),
              tags$div(
                style = "padding: 15px; font-family: 'Space Mono', monospace; line-height: 1.6; color: #cccccc;",
                
                tags$p(tags$b("STATUS: "), tags$span("ACTIVE", style = "color: #39ff14;")),
                tags$p("Welcome to the ", tags$b("LittleGreenMenInYourArea.", style = "color: white;"), "This dashboard analyzes over ", tags$b("100,000 UFO sightings", style = "color: white;"), " compiled from the NUFORC database."),
                
                tags$hr(style = "border-color: #333333; margin: 20px 0;"),
                
                tags$h5("GLOBAL PARAMETERS", style = "color: #39ff14; margin-bottom: 15px;"),
                tags$p("Use the primary controls in the sidebar to filter the phenomena by year of occurrence, reported shape, and minimum duration. ", tags$i("Initialize Audio Logs"), " to establish a more mysterious environment."),
                
                tags$h5("MODULES", style = "color: #39ff14; margin-top: 25px; margin-bottom: 15px;"),
                tags$ul(
                  tags$li(tags$b("The Radar:", style = "color: white;"), " Pinpoint sightings on the map and track UFO activity across the timeline."),
                  tags$li(tags$b("The Profiler:", style = "color: white;"), " An interactive cross-referencing matrix. Selecting variables within the Seasonal Scanner or Temporal Matrix will dynamically recalculate the Top Shapes and Entity Characteristics for that specific criteria."),
                  tags$li(tags$b("The X-Files:", style = "color: white;"), " The raw incident logs. Selecting a specific row within the data table will decrypt the full, unredacted witness testimony for that event."),
                  tags$li(tags$b("Deep Search:", style = "color: white;"), " Semantic Query system. Describe an encounter in natural language, and a vector embedding system will retrieve the closest historical matches from the archives.")
                ),
                
                tags$hr(style = "border-color: #333333; margin: 20px 0;"),
              )
            )
  )
)