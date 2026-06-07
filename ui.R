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
  
  tags$head(
    tags$style(HTML("
      .card { border: 1px solid #1a5c1a !important; background-color: rgba(10, 10, 10, 0.8) !important; box-shadow: 0 0 10px rgba(57, 255, 20, 0.05); }
      .card-header { font-family: 'Orbitron', sans-serif !important; text-transform: uppercase; letter-spacing: 2px; color: #39ff14 !important; border-bottom: 1px solid #1a5c1a !important; background-color: #000000 !important; }
      .nav-link.active { text-shadow: 0 0 10px #39ff14; border-bottom: 2px solid #39ff14 !important; }
      .btn-primary { box-shadow: 0 0 10px rgba(57, 255, 20, 0.4); border: 1px solid #39ff14 !important; transition: 0.3s all; }
      .btn-primary:hover { box-shadow: 0 0 20px rgba(57, 255, 20, 0.8); background-color: #5eff33 !important; color: #000000 !important; }
      table.dataTable tbody tr.selected { background-color: rgba(57, 255, 20, 0.2) !important; }
      .terminal-box { background-color: #050505; border: 1px solid #39ff14; padding: 20px; color: #39ff14; font-family: 'Space Mono', monospace; box-shadow: inset 0 0 15px rgba(57, 255, 20, 0.1); border-radius: 5px; height: 100%; overflow-y: auto; }
      .terminal-box p { color: #cccccc; }
      .terminal-box b { color: #39ff14; }


      .bslib-sidebar-layout > aside {
        background-color: rgba(5, 5, 5, 0.98) !important;
        border-right: 1px solid #1a5c1a !important;
        box-shadow: inset -5px 0 20px rgba(57, 255, 20, 0.03);
      }
      

      .sidebar-title { font-family: 'Orbitron', sans-serif !important; color: #39ff14; text-transform: uppercase; letter-spacing: 2px; border-bottom: 1px dashed #1a5c1a; padding-bottom: 10px; margin-bottom: 20px; }
      .control-label { font-family: 'Space Mono', monospace; color: #aaaaaa !important; font-size: 0.9rem; margin-bottom: 5px;}
      

      .form-control, .form-select, .selectize-input { 
        background-color: #0a0a0a !important; 
        color: #39ff14 !important; 
        border: 1px solid #1a5c1a !important; 
        font-family: 'Space Mono', monospace;
        border-radius: 2px;
      }
      .form-control:focus, .form-select:focus, .selectize-input.focus {
        border-color: #39ff14 !important;
        box-shadow: 0 0 10px rgba(57, 255, 20, 0.3) !important;
      }
      

      .irs--shiny .irs-line { background: #111111 !important; border: 1px solid #1a5c1a !important; }
      .irs--shiny .irs-bar { background: #39ff14 !important; border-top: 1px solid #39ff14; border-bottom: 1px solid #39ff14; }
      .irs--shiny .irs-bar-edge { background: #39ff14 !important; border: 1px solid #39ff14; }
      .irs--shiny .irs-single, .irs--shiny .irs-from, .irs--shiny .irs-to {
        background: #000000 !important;
        color: #39ff14 !important;
        border: 1px solid #39ff14 !important;
        font-family: 'Space Mono', monospace;
        font-size: 11px;
        border-radius: 2px;
      }
      .irs--shiny .irs-handle {
        border: 2px solid #39ff14 !important;
        background-color: #000000 !important;
        box-shadow: 0 0 5px #39ff14 !important;
        border-radius: 0% !important;
        width: 14px !important;
        height: 14px !important;
        top: 22px !important;
      }
      .irs--shiny .irs-min, .irs--shiny .irs-max { color: #555555 !important; font-family: 'Space Mono', monospace; background: transparent !important; }
    "))
  ),
  
  fillable = TRUE,
  sidebar = sidebar(
    title = tags$h4("System Controls", class = "sidebar-title"),
    
    sliderInput("year_range", "Year of Sighting:",
                min = min_year, max = max_year,
                value = c(2000, max_year), step = 1, sep = ""),
    
    selectInput("shape_filter", "UFO Shape:",
                choices = c("All Shapes" = "All", available_shapes),
                selected = "All"),
    
    numericInput("min_duration", "Min Duration (Secs):", 
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
        style = "display: block; color: #39ff14; background-color: #0a0a0a; border-radius: 2px; border: 1px solid #1a5c1a; padding: 10px; font-family: 'Space Mono', monospace;",
        tags$p("AUDIO LOGS", style = "margin-bottom: 5px; font-weight: bold; font-size: 0.9rem;"),
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
                p("Describe a sighting in natural language to find the closest historical matches.", style="color: #aaaaaa;"),
                textAreaInput("semantic_query", "Witness Description:", 
                              placeholder = "e.g., a glowing green orb over the lake...",
                              width = "100%",
                              rows = 5),
                actionButton("run_search", "Initialize Search", 
                             class = "btn-primary", 
                             style = "background-color: transparent; color: #39ff14; font-weight: bold;")
              ),
              card(
                card_header("Top Classified Matches"),
                uiOutput("semantic_results")
              )
            )
  ),
  
  nav_panel("Classified Info",
            card(
              tags$div(
                class = "terminal-box",
                style = "line-height: 1.6;",
                tags$p("Welcome to the ", tags$b("LittleGreenMenInYourArea", style="color: #39ff14;"), " database. This dashboard analyzes over ", tags$b("100,000 UFO sightings", style="color: #39ff14;"), " compiled from the NUFORC database.", style="color: #cccccc;"),
                
                tags$hr(style = "border-color: #1a5c1a;"),
                
                tags$h5("GLOBAL PARAMETERS", style = "color: #39ff14; font-family: 'Orbitron', sans-serif;"),
                tags$p("Use the primary controls in the sidebar to filter the phenomena by year of occurrence, reported shape, and minimum duration. ", tags$i("Initialize Audio Logs"), " to establish a more mysterious environment.", style="color: #cccccc;"),
                
                tags$h5("MODULES", style = "color: #39ff14; font-family: 'Orbitron', sans-serif; margin-top: 25px; margin-bottom: 15px;"),
                tags$ul(style="color: #cccccc;",
                        tags$li(tags$b("The Radar:", style="color: #39ff14;"), " Pinpoint sightings on the map and track UFO activity across the timeline."),
                        tags$li(tags$b("The Profiler:", style="color: #39ff14;"), " An interactive cross-referencing matrix. Selecting variables within the Seasonal Scanner or Temporal Matrix will dynamically recalculate the Top Shapes and Entity Characteristics for that specific criteria."),
                        tags$li(tags$b("The X-Files:", style="color: #39ff14;"), " The raw incident logs. Selecting a specific row within the data table will decrypt the full, unredacted witness testimony for that event."),
                        tags$li(tags$b("Deep Search:", style="color: #39ff14;"), " Semantic Query system. Describe an encounter in natural language, and a vector embedding system will retrieve the closest historical matches from the archives.")
                ),
                
                tags$hr(style = "border-color: #1a5c1a;")
              )
            )
  )
)