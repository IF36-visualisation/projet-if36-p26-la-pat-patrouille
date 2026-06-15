## app.R ##

# 1. CHARGEMENT DES LIBRAIRIES ET DONNÉES -------------------------------------
library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)

# Chargement et fusion (Option 1)
athletes_events_part1 <- read_csv("./data/athletes_events-part1.csv")
athletes_events_part2 <- read_csv("./data/athletes_events-part2.csv")
athletes_full <- bind_rows(athletes_events_part1, athletes_events_part2)

# 2. INTERFACE UTILISATEUR (UI) -----------------------------------------------
ui <- dashboardPage(
  skin = "yellow", # On garde un skin sobre, les couleurs viendront des box
  dashboardHeader(title = "Observatoire JO"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard Efficacité", tabName = "dashboard", icon = icon("chart-bar")),
      
      # Sélecteur des 6 dernières éditions
      selectInput(
        inputId = "input_year", 
        label = "Édition des JO d'été :", 
        choices = c(
          "Rio 2016" = 2016,
          "Londres 2012" = 2012,
          "Pékin 2008" = 2008,
          "Athènes 2004" = 2004,
          "Sydney 2000" = 2000,
          "Atlanta 1996" = 1996
        ),
        selected = 2016
      )
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "dashboard",
        
        # Titre dynamique selon l'année
        fluidRow(
          column(12, h2(uiOutput("dynamic_title")))
        ),
        
        # Ligne 1 : Value Boxes
        fluidRow(
          valueBoxOutput("box_total_athletes", width = 4),
          valueBoxOutput("box_total_medals", width = 4),
          valueBoxOutput("box_best_ratio", width = 4)
        ),
        
        # Ligne 2 : Graphiques
        fluidRow(
          box(
            title = "Analyse du Rendement (Médailles vs Athlètes)", 
            status = "primary", solidHeader = TRUE, width = 7,
            plotlyOutput("scatter_efficacite", height = "500px")
          ),
          box(
            title = "Distribution de l'Efficacité par Taille", 
            status = "info", solidHeader = TRUE, width = 5,
            plotOutput("boxplot_dispersion", height = "500px")
          )
        )
      )
    )
  )
)

# 3. LOGIQUE SERVEUR ----------------------------------------------------------
server <- function(input, output) {
  
  # --- FILTRAGE RÉACTIF ---
  data_jo_reactive <- reactive({
    year_sel <- as.numeric(input$input_year)
    
    # Athlètes uniques
    ath <- athletes_full %>% 
      filter(Year == year_sel, Season == "Summer") %>%
      group_by(NOC) %>% 
      summarise(Taille_Delegation = n_distinct(ID), .groups = "drop")
    
    # Médailles uniques
    med <- athletes_full %>% 
      filter(Year == year_sel, Season == "Summer", !is.na(Medal)) %>%
      distinct(NOC, Event, Medal) %>% 
      group_by(NOC) %>% 
      summarise(Nb_Medailles = n(), .groups = "drop")
    
    # Fusion et Ratio
    ath %>% 
      left_join(med, by = "NOC") %>%
      mutate(
        Nb_Medailles = replace_na(Nb_Medailles, 0), 
        Ratio = Nb_Medailles / Taille_Delegation
      )
  })
  
  # --- TITRE DYNAMIQUE ---
  output$dynamic_title <- renderText({
    paste("Statistiques des Jeux de", input$input_year)
  })
  
  # --- VALUE BOXES ---
  output$box_total_athletes <- renderValueBox({
    total <- sum(data_jo_reactive()$Taille_Delegation)
    valueBox(total, "Athlètes Engagés", icon = icon("users"), color = "blue")
  })
  
  output$box_total_medals <- renderValueBox({
    total <- sum(data_jo_reactive()$Nb_Medailles)
    valueBox(total, "Médailles Distribuées", icon = icon("medal"), color = "teal")
  })
  
  output$box_best_ratio <- renderValueBox({
    top <- data_jo_reactive() %>% 
      filter(Taille_Delegation > 5) %>% 
      arrange(desc(Ratio)) %>% slice(1)
    
    res <- if(nrow(top) > 0) paste0(top$NOC, " (", round(top$Ratio*100,1), "%)") else "N/A"
    valueBox(res, "Meilleure Efficacité (>5 ath.)", icon = icon("bolt"), color = "orange")
  })
  
  # --- GRAPHIQUE 1 : SCATTER PLOT INTERACTIF ---
  output$scatter_efficacite <- renderPlotly({
    df <- data_jo_reactive()
    
    p <- ggplot(df, aes(x = Taille_Delegation, y = Nb_Medailles, 
                        text = paste("Pays:", NOC, "<br>Ratio:", round(Ratio, 3)))) +
      geom_point(aes(size = Ratio), color = "#2c3e50", alpha = 0.6) +
      geom_smooth(method = "lm", color = "red", linetype = "dashed", se = FALSE) +
      # On affiche le texte pour les pays marquants
      geom_text(
        data = filter(df, Taille_Delegation > 250 | Nb_Medailles > 20 | (Ratio > 0.18 & Nb_Medailles > 5)),
        aes(label = NOC), vjust = -1, size = 3, fontface = "bold"
      ) +
      labs(x = "Taille délégation", y = "Médailles uniques") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text")
  })
  
  # --- GRAPHIQUE 2 : BOXPLOT ---
  output$boxplot_dispersion <- renderPlot({
    df_box <- data_jo_reactive() %>%
      filter(Taille_Delegation > 5) %>% 
      mutate(Categorie_Taille = case_when(
        Taille_Delegation <= 50  ~ "Petite (6-50)",
        Taille_Delegation <= 100 ~ "Moyenne (51-100)",
        TRUE                     ~ "Grande (>100)"
      )) %>%
      mutate(Categorie_Taille = factor(Categorie_Taille, 
                                       levels = c("Petite (6-50)", "Moyenne (51-100)", "Grande (>100)")))
    
    ggplot(df_box, aes(x = Categorie_Taille, y = Ratio, fill = Categorie_Taille)) +
      geom_boxplot(alpha = 0.8, outlier.color = "red") +
      scale_fill_manual(values = c("#A3D9C9", "#5CB8A6", "#007A64")) +
      labs(x = "Catégorie", y = "Ratio d'Efficacité") +
      theme_minimal() +
      theme(legend.position = "none")
  })
}

# 4. RUN APP ------------------------------------------------------------------
shinyApp(ui, server)