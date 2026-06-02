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
  
  # output$ufo_map <- renderLeaflet({
  #   data <- filtered_data()
  #   
  #   leaflet(data) %>%
  #     addProviderTiles(providers$CartoDB.DarkMatter) %>%
  #     addHeatmap(
  #       lng = ~Longitude, lat = ~Latitude,
  #       blur = 20, 
  #       max = 0.05, 
  #       radius = 12,
  #       gradient = c("#002200", "#006600", "#39ff14", "#ffffff") 
  #     )
  # })
  
    output$ufo_map <- renderLeaflet({
    data <- filtered_data()
    
    if (nrow(data) > 10000) {
      set.seed(42)
      data <- data[sample(nrow(data), 10000), ]
    }
    
    leaflet(data, options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles(providers$CartoDB.DarkMatter) %>%
      addCircleMarkers(
        lng = ~Longitude, lat = ~Latitude,
        radius = 2.5,
        stroke = FALSE,
        fillColor = "#39ff14", 
        fillOpacity = 0.6,
        popup = ~paste("Date:", Occurred, "<br>Shape:", Shape)
      )
  })
  
  output$ufo_timeline <- renderPlotly({
    data <- filtered_data() %>%
      count(Year)
    
    p <- plot_ly(data, x = ~Year, y = ~n, type = 'scatter', mode = 'lines+markers',
                 line = list(color = '#39ff14'), marker = list(color = '#39ff14')) %>%
      layout(paper_bgcolor = 'transparent', plot_bgcolor = 'transparent',
             font = list(color = 'white'),
             xaxis = list(title = "Year"), yaxis = list(title = "Number of Sightings"))
    
    p
  })
  
  output$shape_treemap <- renderPlotly({
    shape_counts <- filtered_data() %>%
      filter(!is.na(Shape) & Shape != "") %>% 
      count(Shape) %>%
      arrange(desc(n)) %>%
      head(20)
    
    if(nrow(shape_counts) == 0) return(plotly_empty())
    
    plot_ly(
      data = shape_counts,
      type = "treemap",
      labels = ~Shape,
      parents = "UFO Shapes",
      values = ~n,
      textinfo = "label+value",
      marker = list(colorscale = "Greens", reversescale = TRUE)
    ) %>%
      layout(
        paper_bgcolor = 'transparent',
        plot_bgcolor = 'transparent',
        font = list(color = 'white'),
        margin = list(t = 0, b = 0, l = 0, r = 0)
      )
  })
  
  output$duration_boxplot <- renderPlotly({
    data <- filtered_data() %>%
      filter(!is.na(Shape) & Shape != "")
    
    if(nrow(data) == 0) return(plotly_empty())
    
    p <- plot_ly(
      data,
      x = ~Shape,
      y = ~Duration_Seconds,
      type = "box",
      color = I("#39ff14"),
      marker = list(color = "#39ff14", size = 2),
      line = list(color = "#39ff14")
    ) %>%
      layout(
        paper_bgcolor = 'transparent',
        plot_bgcolor = 'transparent',
        font = list(color = 'white'),
        xaxis = list(title = "", tickangle = 45),
        yaxis = list(title = "Duration (Seconds)")
      )
    
    if (input$log_scale) {
      p <- p %>% layout(yaxis = list(type = "log", title = "Duration (Seconds) [Log Scale]"))
    }
    
    p
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
                    style = "color: gray; font-style: italic;"))
    }
    
    incident <- filtered_data()[selected_row, ]
    
    tagList(
      h4(paste("Incident Location:", incident$Location), style = "color: #39ff14;"),
      tags$b("Reported Time: "), tags$span(incident$Occurred), tags$br(),
      tags$b("Duration: "), tags$span(incident$Duration), tags$br(),
      tags$hr(),
      tags$b("Summary:"),
      tags$p(incident$Summary),
      tags$b("Full Text:"),
      tags$blockquote(incident$Text, style = "border-left: 2px solid #39ff14; padding-left: 10px;")
    )
  })
  
  semantic_matches <- eventReactive(input$run_search, {
    query <- input$semantic_query
    
    if (nchar(trimws(query)) == 0) return(NULL)
    api_url <- "https://erqba-ufo-embeddings.hf.space/embed"
    
    req <- request(api_url) %>%
      req_body_json(list(text = query)) %>%
      req_timeout(60)
    
    resp <- req_perform(req)
    
    json_resp <- resp_body_json(resp)
    query_embedding <- unlist(json_resp$embedding)
    

    scores <- calculate_cosine_similarity(query_embedding, ufo_embeddings)

    results <- ufo_data
    results$score <- scores
    
    top_results <- results %>%
      arrange(desc(score)) %>%
      head(4)
    
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
          tags$p(res$Summary[i], style = "font-style: italic;")
        )
      )
    })
    
    do.call(tagList, card_list)
  })
}