server <- function(input, output, session) {
  
  filtered_data <- reactive({
    df <- ufo_data %>%
      filter(Year >= input$year_range[1] & Year <= input$year_range[2],
             Duration_Seconds >= input$min_duration)
    
    if (input$shape_filter != "All") {
      df <- df %>% filter(Shape == input$shape_filter)
    }
    
    return(df)
  })
  
  output$ufo_map <- renderLeaflet({
    data <- filtered_data()
    
    point_limit <- input$map_points
    
    if (nrow(data) > point_limit) {
      set.seed(42)
      data <- data[sample(nrow(data), point_limit), ]
    }
    
    leaflet(data, options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addCircleMarkers(
        lng = ~Longitude, lat = ~Latitude,
        radius = 2.5,
        stroke = FALSE,
        fillColor = "#39ff14", 
        fillOpacity = 0.6,
        popup = ~paste("<b>Date:</b>", Occurred, "<br><b>Shape:</b>", Shape)
      )
  })
  
  output$ufo_timeline <- renderPlotly({
    data <- filtered_data() %>%
      count(Year)
    
    p <- plot_ly(
      data, x = ~Year, y = ~n, type = 'scatter', mode = 'lines+markers',
      line = list(color = '#39ff14'), marker = list(color = '#39ff14'),
      hoverinfo = "text",
      text = ~paste("<b>Year:</b>", Year, "<br><b>Sightings:</b>", n)
    ) %>%
      layout(
        paper_bgcolor = 'transparent', 
        plot_bgcolor = 'transparent',
        font = list(color = 'white'),
        xaxis = list(title = "Year"), 
        yaxis = list(title = "Number of Sightings"),
        hoverlabel = list(
          bgcolor = "#111111",      
          bordercolor = "#39ff14",  
          font = list(family = "Space Mono", color = "white", size = 12)
        )
      )
    
    p
  })
  
  output$time_heatmap <- renderPlotly({
    month_click <- event_data("plotly_click", source = "month_clicks")
    
    base_data <- filtered_data() %>% filter(!is.na(DayOfWeek) & !is.na(Hour))
    
    chart_title <- "Sightings by Day & Hour (All Months)"
    
    if (!is.null(month_click)) {
      selected_month <- month_click$customdata
      base_data <- base_data %>% filter(Month == selected_month)
      chart_title <- paste("Sightings by Day & Hour in", selected_month)
    }
    
    heat_df <- base_data %>% count(DayOfWeek, Hour)
    if(nrow(heat_df) == 0) {
      return(plotly_empty() %>% layout(
        title = list(text = "No sightings for this criteria", font = list(color = "#39ff14", size = 14)),
        paper_bgcolor = 'transparent', plot_bgcolor = 'transparent'
      ))
    }
    
    p <- plot_ly(
      data = heat_df,
      x = ~Hour,
      y = ~DayOfWeek,
      z = ~n,
      type = "heatmap",
      source = "heatmap_clicks", 
      
      xgap = 2, 
      ygap = 2,
      
      colorscale = list(
        c(0, "rgba(0,34,0,0.3)"), 
        c(0.4, "#004400"), 
        c(0.7, "#008800"), 
        c(1, "#39ff14")
      ),
      hoverinfo = "text",
      text = ~paste("<b>Day:</b>", DayOfWeek, "<br><b>Hour:</b>", sprintf("%02d:00", Hour), "<br><b>Sightings:</b>", n)
    ) %>%
      layout(
        title = list(text = chart_title, font = list(size = 14, color = "white")),
        paper_bgcolor = 'transparent',
        plot_bgcolor = 'transparent',
        font = list(color = 'white'),
        
        xaxis = list(
          title = "Hour of Day (Local Time)", 
          dtick = 2, 
          showgrid = FALSE, 
          zeroline = FALSE,
          tickfont = list(color = "#aaaaaa")
        ),
        
        yaxis = list(
          title = "", 
          autorange = "reversed", 
          showgrid = FALSE, 
          zeroline = FALSE,
          tickfont = list(color = "#aaaaaa", size = 13)
        ),
        
        hoverlabel = list(
          bgcolor = "#111111",      
          bordercolor = "#39ff14",  
          font = list(family = "Space Mono", color = "white", size = 12)
        ),
        margin = list(l = 50, r = 20, b = 50, t = 40)
      )
    
    p
  })
  
  output$dynamic_shape_bar <- renderPlotly({
    
    heatmap_click <- event_data("plotly_click", source = "heatmap_clicks")
    month_click <- event_data("plotly_click", source = "month_clicks")
    
    chart_data <- filtered_data() %>% filter(!is.na(Shape) & Shape != "")
    title_parts <- c()
    
    if (!is.null(month_click)) {
      selected_month <- month_click$customdata
      chart_data <- chart_data %>% filter(Month == selected_month)
      title_parts <- c(title_parts, paste("in", selected_month))
    }
    
    if (!is.null(heatmap_click)) {
      selected_hour <- heatmap_click$x
      selected_day <- heatmap_click$y
      chart_data <- chart_data %>% filter(Hour == selected_hour, DayOfWeek == selected_day)
      title_parts <- c(title_parts, paste0("on ", selected_day, " at ", selected_hour, ":00 Local"))
    }
    
    if (length(title_parts) > 0) {
      chart_title <- paste("Shapes seen", paste(title_parts, collapse = " "))
    } else {
      chart_title <- "Top Shapes (All Times)"
    }
    
    shape_counts <- chart_data %>%
      count(Shape) %>%
      arrange(n) %>% 
      tail(10)       
    
    if (nrow(shape_counts) == 0) {
      return(plotly_empty() %>% layout(
        title = list(text = "No sightings for this criteria", font = list(color = "#39ff14")),
        paper_bgcolor = 'transparent', plot_bgcolor = 'transparent'
      ))
    }
    
    plot_ly(
      data = shape_counts,
      x = ~n,
      y = ~factor(Shape, levels = Shape), 
      type = "bar",
      marker = list(color = "#39ff14", line = list(color = "black", width = 1)),
      
      textposition = "none",
      
      hoverinfo = "text",
      text = ~paste("<b>Shape:</b>", Shape, "<br><b>Sightings:</b>", n)
    ) %>%
      layout(
        title = list(text = chart_title, font = list(size = 14, color = "white")),
        paper_bgcolor = 'transparent',
        plot_bgcolor = 'transparent',
        font = list(color = 'white'),
        xaxis = list(title = "Number of Sightings", showgrid = TRUE, gridcolor = "#333333"),
        yaxis = list(title = "", showgrid = FALSE),
        margin = list(l = 100, r = 20, b = 50, t = 40),
        hoverlabel = list(
          bgcolor = "#111111",      
          bordercolor = "#39ff14",  
          font = list(family = "Space Mono", color = "white", size = 12)
        )
      )
  })
  
  output$characteristics_radar <- renderPlotly({
    
    heatmap_click <- event_data("plotly_click", source = "heatmap_clicks")
    month_click <- event_data("plotly_click", source = "month_clicks")
    
    chart_data <- filtered_data() %>% filter(!is.na(Characteristics) & Characteristics != "")
    title_parts <- c()
    
    if (!is.null(month_click)) {
      selected_month <- month_click$customdata
      chart_data <- chart_data %>% filter(Month == selected_month)
      title_parts <- c(title_parts, paste("in", selected_month))
    }
    
    if (!is.null(heatmap_click)) {
      selected_hour <- heatmap_click$x
      selected_day <- heatmap_click$y
      chart_data <- chart_data %>% filter(Hour == selected_hour, DayOfWeek == selected_day)
      title_parts <- c(title_parts, paste0("on ", selected_day, " at ", selected_hour, ":00 Local"))
    }
    
    if (length(title_parts) > 0) {
      chart_title <- paste("Traits reported", paste(title_parts, collapse = " "))
    } else {
      chart_title <- "Common Characteristics"
    }
    
    if (nrow(chart_data) == 0) {
      return(plotly_empty() %>% layout(
        title = list(text = "Not enough trait data to profile", font = list(color = "#39ff14", size = 14)),
        paper_bgcolor = 'transparent', plot_bgcolor = 'transparent'
      ))
    }
    
    clean_chars <- str_remove_all(chart_data$Characteristics, "[\\[\\]']")
    split_chars <- strsplit(clean_chars, ",\\s*")
    unlisted_chars <- unlist(split_chars)
    
    if (length(unlisted_chars) == 0) {
      return(plotly_empty() %>% layout(
        title = list(text = "Not enough trait data to profile", font = list(color = "#39ff14", size = 14)),
        paper_bgcolor = 'transparent', plot_bgcolor = 'transparent'
      ))
    }
    
    trait_counts <- as.data.frame(table(unlisted_chars), stringsAsFactors = FALSE)
    names(trait_counts) <- c("Characteristics", "n")
    
    traits_data <- trait_counts %>%
      filter(Characteristics != "") %>%
      arrange(desc(n)) %>%
      head(6)
    
    if(nrow(traits_data) < 3) {
      return(plotly_empty() %>% layout(
        title = list(text = "Not enough trait data to profile", font = list(color = "#39ff14", size = 14)),
        paper_bgcolor = 'transparent', plot_bgcolor = 'transparent'
      ))
    }
    
    traits_data <- rbind(traits_data, traits_data[1, ])
    
    plot_ly(
      data = traits_data,             
      type = 'scatterpolar',
      mode = 'lines+markers',         
      r = ~n,                         
      theta = ~Characteristics,       
      fill = 'toself',
      fillcolor = 'rgba(57, 255, 20, 0.2)', 
      line = list(color = '#39ff14', width = 2),
      marker = list(color = '#39ff14', size = 6),
      hoverinfo = "text",
      hoveron = "points",
      text = ~paste("<b>Characteristic:</b>", Characteristics, "<br><b>Sightings:</b>", n)
    ) %>%
      layout(
        title = list(text = chart_title, font = list(size = 14, color = "white"), y = 0.95),
        polar = list(
          radialaxis = list(visible = TRUE, gridcolor = "#333333", tickfont = list(color = "#aaaaaa"), linecolor = "#333333"),
          angularaxis = list(gridcolor = "#333333", tickfont = list(color = "white", size = 11), linecolor = "#333333"),
          bgcolor = "transparent"
        ),
        paper_bgcolor = 'transparent',
        plot_bgcolor = 'transparent',
        margin = list(t = 50, b = 40, l = 40, r = 40),
        hoverlabel = list(
          bgcolor = "#111111",      
          bordercolor = "#39ff14",  
          font = list(family = "Space Mono", color = "white", size = 12)
        )
      )
  })
  
  output$seasonal_rose <- renderPlotly({
    data <- filtered_data() %>%
      filter(!is.na(Month)) %>%
      count(Month)
    
    if(nrow(data) == 0) return(plotly_empty())
    
    plot_ly(
      data,
      r = ~n,
      theta = ~Month,
      
      customdata = ~as.character(Month), 
      source = "month_clicks",           
      
      type = "barpolar",
      marker = list(
        color = "rgba(57, 255, 20, 0.4)",
        line = list(color = "#39ff14", width = 1)
      ),
      hoverinfo = "text",
      text = ~paste("<b>Month:</b>", Month, "<br><b>Sightings:</b>", n)
    ) %>%
      layout(
        polar = list(
          angularaxis = list(
            direction = "clockwise",
            tickfont = list(color = "white", size = 11),
            linecolor = "#333333",
            gridcolor = "#333333"
          ),
          radialaxis = list(
            visible = TRUE,
            showticklabels = FALSE,
            linecolor = "#333333",
            gridcolor = "#333333"
          ),
          bgcolor = "transparent"
        ),
        paper_bgcolor = 'transparent',
        plot_bgcolor = 'transparent',
        margin = list(t = 40, b = 40, l = 40, r = 40),
        
        hoverlabel = list(
          bgcolor = "#111111",      
          bordercolor = "#39ff14",  
          font = list(family = "Space Mono", color = "white", size = 12)
        )
      )
  })
  
  output$ufo_table <- renderDT({
    data <- filtered_data() %>%
      select(Occurred, Location, Shape, Duration, Summary)
    
    datatable(data, 
              selection = "single",
              options = list(pageLength = 5, scrollX = TRUE),
              rownames = FALSE,
              class = 'cell-border stripe bg-dark text-light')
  })
  
  output$witness_narrative <- renderUI({
    selected_row <- input$ufo_table_rows_selected
    
    if (is.null(selected_row)) {
      return(tags$p("Select a row in the table above to decrypt the witness testimony...", 
                    class = "text-muted fst-italic"))
    }
    
    incident <- filtered_data()[selected_row, ]
    
    tagList(
      h4(paste("Incident Location:", incident$Location), class = "text-primary"),
      tags$b("Reported Time: "), tags$span(incident$Occurred),
      tags$b("Duration: "), tags$span(incident$Duration),
      tags$hr(),
      tags$b("Summary:"),
      tags$p(incident$Summary),
      tags$b("Full Text:"),
      tags$blockquote(incident$Text, class = "border-start border-primary border-2 ps-3")
    )
  })
  
  semantic_matches <- eventReactive(input$run_search, {
    query <- input$semantic_query
    
    if (nchar(trimws(query)) == 0) return(NULL)
    
    api_url <- "https://erqba-ufo-embeddings.hf.space/search"
    
    req <- request(api_url) %>%
      req_body_json(list(text = query, top_k = 3)) %>%
      req_timeout(60)
    
    resp <- req_perform(req)
    json_resp <- resp_body_json(resp)
    
    top_results <- bind_rows(json_resp$matches)
    
    return(top_results)
  })
  
  output$semantic_results <- renderUI({
    res <- semantic_matches()
    
    if (is.null(res)) {
      return(tags$p("Awaiting query input...", style = "color: gray; font-style: italic;"))
    }
    
    card_list <- lapply(1:nrow(res), function(i) {
      card(
        style = "border-left: 4px solid #39ff14; background-color: #111111; margin-bottom: 15px;",
        card_header(
          tags$strong(paste0("Similarity Match: ", round(res$score[i] * 100, 1), "%")),
          tags$span(paste(" | ID:", res$Sighting[i]), style = "color: #aaaaaa; float: right;")
        ),
        tags$div(
          style = "padding: 10px;",
          tags$p(tags$b("Location: "), res$Location[i], " | ", tags$b("Date: "), res$Occurred[i]),
          tags$p(tags$b("Shape: "), res$Shape[i]),
          tags$hr(style = "border-color: #333333;"),
          tags$p(tags$b("Summary: "), res$Summary[i]),
          tags$p(tags$b("Full Text: "), tags$span(res$Text[i], style = "font-style: italic; color: #cccccc;"))
        )
      )
    })
    
    do.call(tagList, card_list)
  })
}