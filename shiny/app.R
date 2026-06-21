## app.R ##

# 1. CHARGEMENT DES LIBRAIRIES ET DONNÉES -------------------------------------
library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)

# Chargement et fusion (Option 1)
athletes_events_part1 <- read_csv("../data/athletes_events-part1.csv")
athletes_events_part2 <- read_csv("../data/athletes_events-part2.csv")
athletes_full <- bind_rows(athletes_events_part1, athletes_events_part2)

# 2. INTERFACE UTILISATEUR (UI) -----------------------------------------------
ui <- dashboardPage(
  skin = "yellow", # On garde un skin sobre, les couleurs viendront des box
  dashboardHeader(title = "Observatoire JO"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard Efficacité", tabName = "dashboard", icon = icon("chart-bar")),
      menuItem("Analyse par sport", tabName = "sports", icon = icon("running"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "sports",
        
        # Sélecteur des sports
        fluidRow(
          box(
            title = "Sélection des sports",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            
            selectInput(
              inputId = "selected_sports",
              label = "Choisir un ou plusieurs sports :",
              choices = sort(unique(athletes_full$Sport)),
              selected = c("Basketball", "Swimming"),
              multiple = TRUE
            )
          )
        ),
        # Ligne 1 : Graphique âge et morpho
        
        fluidRow(
          box( 
            title = "Distribution âge des médaillés", 
            width = 6, 
            plotOutput("plot_age") ),
          box(
            title = "Distribution Taille-Poids",
            width = 6,
            
            
            radioButtons(
              inputId = "morpho_layout",
              label = "Affichage :",
              choices = c(
                "Par sport" = "facet",
                "Superposé" = "overlay"
              ),
              selected = "facet",
              inline = TRUE
            ),
            
            plotOutput("morpho_plot", height = "400px")
          )
          
        ),
        # Ligne 2 : Graphique poids et taille
        fluidRow(
          
          box(
            title = "Évolution taille moyenne",
            width = 6,
            plotOutput("plot_height")
          ),
          box(
            title = "Évolution poids moyen",
            width = 6,
            plotOutput("plot_weight")
          )
          
          
          
        ),
        #Ligne 3 : IMC
        fluidRow(
          box(
            title = "Distribution de l'IMC",
            width = 12,
            
            plotOutput("plot_imc", height = "400px")
          )
        )
      ),
      tabItem(
        tabName = "dashboard",
        
        # Titre dynamique selon l'année
        fluidRow(
          column(12, h2(uiOutput("dynamic_title")))
        ),

        # choix des jo
        fluidRow(
          box(
            title = "Sélection de l'édition",
            status = "warning", solidHeader = TRUE, width = 12,
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
  
  #Page 2
  
  #Filtrage
  data_sports_reactive <- reactive({
    req(input$selected_sports)
    
    athletes_full %>%
      filter(Sport %in% input$selected_sports) 
  })
  # Calcul IMC 
  data_imc_reactive <- reactive({
    req(input$selected_sports)
    
    athletes_full %>%
      filter(
        Sport %in% input$selected_sports,
        !is.na(Height),
        !is.na(Weight)
      ) %>%
      mutate(
        IMC = Weight / (Height / 100)^2
      )
  })
  #--- GRAPHIQUE 1 : AGE ---
  output$plot_age <- renderPlot({
    df <- data_sports_reactive() %>%
      filter(!is.na(Medal), !is.na(Age))
    
    ggplot(df, aes(x = Sport, y = Age, fill = Sport)) +
      geom_boxplot() +
      coord_flip() +
      theme_minimal() +
      theme(legend.position = "none")
  })
  #--- GRAPHIQUE 2 : MORPHO ---
  output$morpho_plot <- renderPlot({
    
    df_morpho <- data_sports_reactive() %>%
      filter(!is.na(Height), !is.na(Weight))
    
    # MODE 1 : facettes (premier graph)
    if (input$morpho_layout == "facet") {
      
      ggplot(df_morpho, aes(x = Weight, y = Height, color = Sport)) +
        geom_density_2d() +
        facet_wrap(~Sport) +
        labs(
          x = "Poids (kg)",
          y = "Taille (cm)"
        ) +
        theme_minimal()
    }
    
    # MODE 2 : superposé (deuxième graph)
    else {
      
      ggplot(df_morpho, aes(x = Weight, y = Height, color = Sport)) +
        geom_density_2d(linewidth = 0.8) +
        labs(
          x = "Poids (kg)",
          y = "Taille (cm)",
          color = "Sport"
        ) +
        theme_minimal()
    }
  })
  #--- GRAPHIQUE 3 : TAILLE ---
  output$plot_height <- renderPlot({
    
    df <- data_sports_reactive() %>%
      filter(!is.na(Medal), !is.na(Height)) %>%
      group_by(Year, Sport) %>%
      summarise(mean_height = mean(Height), .groups = "drop")
    
    sports_multi <- df %>%
      count(Sport) %>%
      filter(n > 1) %>%
      pull(Sport)
    
    sports_single <- df %>%
      count(Sport) %>%
      filter(n == 1) %>%
      pull(Sport)
    
    ggplot() +
      
      # Courbes lissées si plusieurs années
      geom_smooth(
        data = filter(df, Sport %in% sports_multi),
        aes(x = Year, y = mean_height, color = Sport),
        se = FALSE,
        linewidth = 1.2
      ) +
      
      # Point si une seule année
      geom_point(
        data = filter(df, Sport %in% sports_single),
        aes(x = Year, y = mean_height, color = Sport),
        size = 4
      ) +
      
      labs(
        x = "Année",
        y = "Taille moyenne (cm)"
      ) +
      
      theme_minimal()
    
  })
  #--- GRAPHIQUE 4 : POIDS ---
  output$plot_weight <- renderPlot({
    
    df <- data_sports_reactive() %>%
      filter(!is.na(Medal), !is.na(Weight)) %>%
      group_by(Year, Sport) %>%
      summarise(mean_weight = mean(Weight), .groups = "drop")
    
    sports_multi <- df %>%
      count(Sport) %>%
      filter(n > 1) %>%
      pull(Sport)
    
    sports_single <- df %>%
      count(Sport) %>%
      filter(n == 1) %>%
      pull(Sport)
    
    ggplot() +
      
      geom_smooth(
        data = filter(df, Sport %in% sports_multi),
        aes(x = Year, y = mean_weight, color = Sport),
        se = FALSE,
        linewidth = 1.2
      ) +
      
      geom_point(
        data = filter(df, Sport %in% sports_single),
        aes(x = Year, y = mean_weight, color = Sport),
        size = 4
      ) +
      
      labs(
        x = "Année",
        y = "Poids moyen (kg)"
      ) +
      
      theme_minimal()
    
  })
  
#--- GRAPHIQUE 5 : IMC ---
  output$plot_imc <- renderPlot({
    
    df <- data_imc_reactive()
    
    ggplot(
      df,
      aes(
        x = IMC,
        y = reorder(Sport, IMC, median),
        fill = Sport
      )
    ) +
      geom_density_ridges(
        alpha = 0.7,
        scale = 0.8
      ) +
      
      # Limites IMC
      geom_vline(
        xintercept = 18.5,
        color = "#e74c3c",
        linetype = "dashed",
        linewidth = 1
      ) +
      geom_vline(
        xintercept = 24.9,
        color = "#e74c3c",
        linetype = "dashed",
        linewidth = 1
      ) +
      
      # Texte au-dessus
      annotate(
        "text",
        x = 18.5,
        y = Inf,
        label = "18.5",
        color = "#e74c3c",
        vjust = 1.5
      ) +
      annotate(
        "text",
        x = 24.9,
        y = Inf,
        label = "24.9",
        color = "#e74c3c",
        vjust = 1.5
      ) +
      labs(
        x = "IMC",
        y = "Sport"
      ) +
      theme_minimal() +
      theme(legend.position = "none")
  })
}

# 4. RUN APP ------------------------------------------------------------------
shinyApp(ui, server)
