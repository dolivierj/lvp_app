
# UI
treaties_ui = function(id) {
  ns = NS(id)
  bs4Dash::tabsetPanel(
    type = "tabs",
    
    shiny::tabPanel(
      title = "17th century",
      shiny::fluidRow(
        shiny::column(
          width = 5,
          shiny::h3('Johan Georg Pascha'),
          shiny::plotOutput(
            outputId = ns('img_pasch'),
            height = '200px'
          ),
          shiny::downloadButton(
            outputId = ns("dl_pasch"),
            label = "Download translation (fr)",
            style = "width:100%;"
          ),
          shiny::h3('Wernesson de Liancour'),
          shiny::plotOutput(
            outputId = ns('img_liancour'),
            height = '200px'
          ),
          shiny::downloadButton(
            outputId = ns("dl_liancour"),
            label = "Download transcription",
            style = "width:100%;"
          )
        ),
        shiny::column(
          width = 2,
          shiny::br()
        ),
        shiny::column(
          width = 5,
          shiny::h3('Philibert de la Touche'),
          shiny::plotOutput(
            outputId = ns('img_touche'),
            height = '200px'
          ),
          shiny::downloadButton(
            outputId = ns("dl_touche"),
            label = "Download transcription",
            style = "width:100%;"
          )
        )
      )
    ),
    
    shiny::tabPanel(
      title = "18th century",
      shiny::fluidRow(

        shiny::br(),
        shiny::column(
          width = 5,
          shiny::h3('Le Perche du Coudray'),
          shiny::plotOutput(
            outputId = ns('img_coudray'),
            height = '200px'
          ),
          shiny::downloadButton(
            outputId = ns("dl_coudray"),
            label = "Download transcription",
            style = "width:100%;")
        ),
        shiny::column(
          width = 2,
          shiny::br()
        ),
        shiny::column(
          width = 5,
          shiny::br()
        )
        
      )
    )
    
  )
}


# Server logic
treaties_server = function(id) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      

      output$img_pasch = shiny::renderPlot({
        grid::grid.raster(read_image('./files/img/pasch.jpg'))
      })
      
      output$img_touche = shiny::renderPlot({
        # read_image('./files/img/touche.png')
        grid::grid.raster(read_image('./files/img/touche.jpg'))
      })
      
      output$img_liancour = shiny::renderPlot({
        grid::grid.raster(read_image('./files/img/liancour.jpg'))
      })
      
      output$img_coudray = shiny::renderPlot({
        grid::grid.raster(read_image('./files/img/coudray.png'))
      })
      
      output$dl_pasch = downloadHandler(
        filename = "1661_Johann_Georg_Pasch.pdf",
        content = function(file) {
          file.copy("./files/treaties/1661_Johann_Georg_Pasch.pdf", file)
        }
      )
      
      output$dl_touche = downloadHandler(
        filename = "1670_Philibert_de_la_Touche.pdf",
        content = function(file) {
          file.copy("./files/treaties/1670_Philibert_de_la_Touche.pdf", file)
        }
      )
      
      output$dl_liancour = downloadHandler(
        filename = "1686_Wernesson_de_Liancour.pdf",
        content = function(file) {
          file.copy("./files/treaties/1686_Wernesson_de_Liancour.pdf", file)
        }
      )
      
      output$dl_coudray = downloadHandler(
        filename = "1740_Le_Perche_du_Coudray.pdf",
        content = function(file) {
          file.copy("./files/treaties/1740_Le_Perche_du_Coudray.pdf", file)
        }
      )


    }
  )
}

