#' home UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @import ggplot2 dplyr
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_home_ui <- function(id){
  ns <- NS(id)
  tagList(
    layout_sidebar(
      border = FALSE,
      fill = FALSE,
      bg = "#f7f1de",
      sidebar = sidebar(
        class = "bg_light",
        title = "Filtros",
        selectInput(ns("entidad"),
                    "Entidad federativa",
                    choices = sort(unique(pres$entidad_federativa))
        ),
        selectInput(ns("ramo"),
                    "Ramo",
                    choices = sort(unique(pres$desc_ramo))
        ),
        dateRangeInput(ns("fecha"), "Fecha", min = min(pres$fecha), max = max(pres$fecha),
                       start = min(pres$fecha), end = max(pres$fecha)),
        shinyWidgets::actionBttn(ns("filtrar"), "Filtrar", color = "primary", style = "minimal")
      ),
      layout_columns(
        fill = FALSE,
        card(
          card_header("Comparativa de montos"),
          plotOutput(ns("graf_1"))
        )
      )
    ),
  )
}

#' home Server Functions
#'
#' @noRd
mod_home_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    data <- reactive({
      input$filtrar
      pres |>
        filter(desc_ramo == isolate(input$ramo), entidad_federativa == isolate(input$entidad),
               fecha >= isolate(input$fecha)[[1]], fecha <= isolate(input$fecha)[[2]]) |>
        summarise(across(.cols = c("monto_aprobado","monto_modificado",
                                   "monto_pagado"),
                         .fns = ~sum(.x,na.rm = T)), .by = fecha)

    })

    output$graf_1 <- renderPlot({
      ggplot(data(), aes(x = fecha,monto_aprobado))+
        geom_point(aes(group = "Monto Aprobado",color = "Monto Aprobado"))+
        geom_point(aes(fecha,monto_modificado,group = "Monto Modificado",
                       color = "Monto Modificado"))+
        geom_point(aes(fecha,monto_pagado,group = "Monto Pagado",
                       color = "Monto Pagado"))+
        theme_minimal()+
        scale_y_continuous(labels = scales::dollar_format(scale = 1e-6))+
        labs(x = "Periodo",y = "Montos",
             title = "Comparativa entre monto_aprobado, monto_modificado y monto_pagado",
             legend.title = "Montos")
    })

  })
}

## To be copied in the UI
# mod_home_ui("home_1")

## To be copied in the server
# mod_home_server("home_1")
