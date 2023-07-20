library(shiny)
library(bs4Dash)
library(jpeg)
library(png)
library(webp)
library(grid)
library(EBImage)
library(shinyFiles)

values_switch = function(col) {
  values = switch(col,
                  "hilt_pommel_shape" = c("UNK",
                                          "0 - Rond médian",
                                          "1 - Rond allongé",
                                          "2 - Rond étalé",
                                          "3 - Rond cubique",
                                          "4 - Long médian",
                                          "5 - Long allongé",
                                          "6 - Urne",
                                          "7 - Ecrasé",
                                          "8 - Bipartite"),
                  "hilt_pommel_central_motif" = c('UNK', TRUE, FALSE),
                  "is_smallsword" = c(TRUE, FALSE)
  )
  return(values)
}

get_images = function(dir) {
  return(list.files(dir, pattern = "\\.(jpg|jfif|png|webp|jpeg)$"))
}
read_image = function(filepath) {
  ext = tools::file_ext(filepath)
  switch(ext,
         jpg = jpeg::readJPEG(filepath),
         jfif = jpeg::readJPEG(filepath),
         png = png::readPNG(filepath),
         webp = webp::read_webp(filepath),
         stop("Unsupported file format: ", ext))
}


# UI
smallswords_ui = function(id) {
  ns = NS(id)
  bs4Dash::tabsetPanel(
    type = "tabs",
    
    shiny::tabPanel(
      title = "Database",
      shiny::fluidRow(
        shiny::h2('Select database')
      ),
      shiny::fluidRow(
        shinyFiles::shinyDirButton(
          id = ns('select_database'),
          label = 'Browse',
          title = 'Select database folder',
          multiple = F
        )
      ),
      shiny::fluidRow(
        shiny::column(
          width = 4,
          shiny::h3('Filter database'),

          shiny::textInput(
            inputId = ns('start_name'),
            label = 'Start from Name',
            width = '100%'
          ),

          shiny::actionButton(
            inputId = ns('start_from_name'),
            label = 'Filter',
            width = '100%'
          ),

          shiny::selectInput(
            inputId = ns('filter_field'),
            label = 'Filter field',
            choices = character(0),
            selected = character(0),
            width = '100%'
          ),
          shiny::selectizeInput(
            inputId = ns('filter_values'),
            label = 'Values to filter',
            choices = character(0),
            selected = character(0),
            width = '100%'
          ),
          shiny::fluidRow(
            shiny::actionButton(
              inputId = ns('filter_keep'),
              label = 'Keep',
              width = '50%'
            ),
            shiny::actionButton(
              inputId = ns('filter_drop'),
              label = 'Drop',
              width = '50%'
            )
          ),
          shiny::actionButton(
            inputId = ns('filter_reset'),
            label = 'Reset',
            width = '100%'
          )
        )
      )
    ),
    
    shiny::tabPanel(
      title = "Curator",
      shiny::fluidRow(
        shiny::br(),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("prev_folder"),
            label = "Previous Folder",
            width = "100%")
        ),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("prev_image"),
            label = "Previous Image",
            width = "100%")
        ),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("next_image"),
            label = "Next Image",
            width = "100%")
        ),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("next_folder"),
            label = "Next Folder",
            width = "100%")
        )
      ),
      shiny::fluidRow(
        shiny::br()
      ),
      shiny::fluidRow(
        shiny::column(
          width = 10,
          shiny::plotOutput(
            outputId = ns("image_plot"),
            height = '750px'
          )
        ),
        shiny::column(
          width = 2,
          shiny::fluidRow(
            shiny::textOutput(
              outputId = ns('lot_name')
            )
          ),
          shiny::fluidRow(
            shiny::selectInput(
              inputId = ns('select_level_0'),
              label = 'Level 0',
              choices = c('Hilt', 'Blade'),
              selected = 'Hilt',
              width = "100%"
            )
          ),
          shiny::fluidRow(
            shiny::selectInput(
              inputId = ns('select_level_1'),
              label = 'Level 1',
              choices = c('Shell', 'Annelets', 'Ecusson', 'Branch', 'Handle', 'Pommel'),
              selected = 'Pommel',
              width = "100%"
            )
          ),
          shiny::fluidRow(
            shiny::selectInput(
              inputId = ns('select_level_2'),
              label = 'Level 2',
              choices = c('Shape', 'Style'),
              selected = 'Shape',
              width = "100%"
            )
          ),
          shiny::fluidRow(
            shiny::selectInput(
              inputId = ns('select_result'),
              label = 'Type',
              choices = c("0 - Rond médian",
                          "1 - Rond allongé",
                          "2 - Rond étalé",
                          "3 - Rond cubique",
                          "4 - Long médian",
                          "5 - Long allongé",
                          "6 - Urne",
                          "7 - Ecrasé",
                          "8 - Bipartite"),
              selected = 0,
              width = "100%"
            )
          ),
          shiny::fluidRow(
            shiny::actionButton(
              inputId = ns('set_value'),
              label = 'Set',
              width = "50%"
            ),
            shiny::actionButton(
              inputId = ns('reset_value'),
              label = 'Reset',
              width = "50%"
            )
          ),
          shiny::fluidRow(
            shiny::actionButton(
              inputId = ns('save_db'),
              label = 'Save changes',
              width = "100%"
            )
          )
        )
      )
    ),
    
    shiny::tabPanel(
      title = "Inspector",
      
      shiny::fluidRow(
        shiny::br(),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("prev_folder_inspector"),
            label = "Previous Folder",
            width = "100%")
        ),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("prev_image_inspector"),
            label = "Previous Image",
            width = "100%")
        ),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("next_image_inspector"),
            label = "Next Image",
            width = "100%")
        ),
        shiny::column(
          width = 3,
          actionButton(
            inputId = ns("next_folder_inspector"),
            label = "Next Folder",
            width = "100%")
        )
      ),
      
      shiny::fluidRow(
        EBImage::displayOutput(
          outputId = ns("inspector_img"),
          height = "750px")
      )
    ),
    
    shiny::tabPanel(
      title = "Descriptor",

      shiny::fluidRow(
        shiny::column(
          width = 8,
          shiny::h3("Reference: "),
          shiny::textOutput(outputId = ns('item_reference')),
          shiny::h3("Name: "),
          shiny::textOutput(outputId = ns('item_name')),
          shiny::h4('Description:'),
          shiny::textOutput(outputId = ns('item_description'))
        ),
        shiny::column(
          width = 4,
          shiny::h4('Auction location:'),
          shiny::textOutput(outputId = ns('auction_location')),
          shiny::h4('Auction house:'),
          shiny::textOutput(outputId = ns('auction_house')),
          shiny::h4('Auction name:'),
          shiny::textOutput(outputId = ns('auction_name'))
        )
      )
    ),

    shiny::tabPanel(
      title = "Statistics",
      shiny::fluidRow(
        shiny::selectInput(
          inputId = ns('stats_select_feature'),
          label = "Select a feature",
          choices = character(0),
          selected = character(0)
        )
      ),
      shiny::fluidRow(
        shinyWidgets::actionBttn(
          inputId = ns('run_plot'),
          label = 'Go',
          style = 'pill',
          color = 'success'
        )
      ),
      shiny::fluidRow(
        shiny::br()
      ),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          plotly::plotlyOutput(
            outputId = ns('freq_plot')
          )
        )
      )
    )
  )
}

# Server logic
smallswords_server = function(id) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      dir_path = shiny::reactiveVal()
      dirs = shiny::reactiveVal()
      fixed_path = shiny::reactiveVal()
      db_table = shiny::reactiveValues(
        df = NULL,
        df_filtered = NULL
      )
      # columns = shiny::reactiveVal()
      
      
      shinyDirChoose(input, 'select_database', roots=c(wd='.'), filetypes=c('', 'txt'))
      shiny::observeEvent(input$select_database,{
        if ('path' %in% names(input$select_database)) {
          db_path = c()
          for (i in 2:length(input$select_database$path)){
            db_path = c(db_path, input$select_database$path[[i]])
          }
          dir_path(db_path)
          db_table$df = read.csv(paste(c('.', dir_path(), 'database.csv'), collapse = '/'),
                                 header = T,
                                 sep = ',',
                                 check.names = FALSE,
                                 fileEncoding = "ISO-8859-2")
          rownames(db_table$df) = as.numeric(db_table$df$Index)
          db_table$df_filtered = db_table$df
          fixed_path(paste(c('.', dir_path(), 'items'), collapse = '/'))
          dirs(paste0(fixed_path(), '/', db_table$df_filtered[,'Name'], '/'))
          shiny::updateSelectInput(
            session = session,
            inputId = "stats_select_feature",
            choices = colnames(db_table$df)[3:length(colnames(db_table$df))]
          )
          
          shiny::updateSelectInput(
            session = session,
            inputId = "filter_field",
            choices = colnames(db_table$df)[3:length(colnames(db_table$df))]
          )
        }
      })
      
      shiny::observe({
        shiny::req(db_table$df_filtered)
        # columns(colnames(db_table$df_filtered[3:length(colnames(db_table$df_filtered))]))
        shiny::updateSelectInput(
          session = session,
          inputId = 'select_level_2',
          choices = colnames(db_table$df_filtered[3:length(colnames(db_table$df_filtered))])
        )
      })
      
      shiny::observeEvent(input$select_level_2,{
        
        shiny::updateSelectInput(
          session = session,
          inputId = 'select_result',
          choices = values_switch(input$select_level_2)
        )
        
      })
      
      current_dir_index = shiny::reactiveVal(1)
      current_image_index = shiny::reactiveVal(1)
      current_item_name = shiny::reactiveVal("")
      
      shiny::observeEvent(input$filter_field, {
        shiny::updateSelectizeInput(
          inputId = 'filter_values',
          choices = c('Missing', unique(db_table$df[,input$filter_field]))
        )
      })
      
      
      shiny::observe({
        shiny::req(db_table$df_filtered)
        current_item_name(strsplit(dirs()[current_dir_index()], '/')[[1]][4])
      })
      

      
      output$lot_name = renderText({
        current_item_name()
      })
      
      
      shiny::observeEvent(input$start_from_name, {
        if (input$start_name != "") {
          idx = which(db_table$df$Name == input$start_name)
          idx = db_table$df[idx,'Index']
          keep_idx = rownames(db_table$df)[as.numeric(rownames(db_table$df)) >= as.numeric(idx)]
          db_table$df_filtered = db_table$df[keep_idx,]
          # fixed_path = paste(c('.', dir_path(), 'items'), collapse = '/')
          dirs(paste0(fixed_path(), '/', db_table$df_filtered[,'Name'], '/'))
          shiny::updateTextInput(
            inputId = 'start_name',
            value = ""
          )
        }
      })
      
      shiny::observeEvent(input$filter_keep, {
        if (input$filter_values == 'Missing') {
          keep_idx = rownames(db_table$df_filtered)[db_table$df_filtered[,input$filter_field] == ""]
        } else {
          keep_idx = rownames(db_table$df_filtered)[db_table$df_filtered[,input$filter_field] == input$filter_values]
        }
        db_table$df_filtered = db_table$df_filtered[as.character(keep_idx),]
        dirs(paste0(fixed_path(), '/', db_table$df_filtered[,'Name'], '/'))
      })
      
      shiny::observeEvent(input$filter_drop, {
        if (input$filter_values == 'Missing') {
          drop_idx = rownames(db_table$df_filtered)[db_table$df_filtered[,input$filter_field] == ""]
        } else {
          drop_idx = rownames(db_table$df_filtered)[db_table$df_filtered[,input$filter_field] == input$filter_values]
        }
        db_table$df_filtered = db_table$df_filtered[-as.character(drop_idx),]
        dirs(paste0(fixed_path(), '/', db_table$df_filtered[,'Name'], '/'))
      })
      
      output$image_plot = shiny::renderPlot({
        shiny::req(dirs())
        current_dir = dirs()[current_dir_index()]
        images = get_images(current_dir)
        current_image = images[current_image_index()]
        img = read_image(file.path(current_dir, current_image))
        grid::grid.raster(img)
      },
      bg = "black")
      
      shiny::observeEvent(input$set_value, {
        item_name = strsplit(dirs()[current_dir_index()], '/')[[1]][4]
        idx = which(db_table$df$Name == item_name)
        db_table$df[idx, input$select_level_2] = input$select_result
      })
      
      shiny::observeEvent(input$reset_value, {
        item_name = strsplit(dirs()[current_dir_index()], '/')[[1]][4]
        idx = which(db_table$df$Name == item_name)
        db_table$df[idx, input$select_level_2] = NA
      })
      
      shiny::observeEvent(input$save_db, {
        shiny::req(dir_path())
        write.csv(db_table$df,
                  file.path('./', dir_path(),"database.csv"),
                  na = "",
                  row.names = FALSE,
                  fileEncoding = "ISO-8859-2")
      })
      
      
      shiny::observeEvent(c(input$next_image, input$next_image_inspector), {
        shiny::req(dirs())
        current_image_index(current_image_index() + 1)
        if (current_image_index() > length(get_images(dirs()[current_dir_index()]))) {
          current_image_index(1)
        }
      })
      
      shiny::observeEvent(c(input$prev_image, input$prev_image_inspector), {
        shiny::req(dirs())
        if (current_image_index() > 1) {
          current_image_index(current_image_index() - 1)
        } else {
          current_image_index(length(get_images(dirs()[current_dir_index()])))
        }
      })
      
      shiny::observeEvent(c(input$next_folder, input$next_folder_inspector, input$set_value), {
        shiny::req(dirs())
        if (current_dir_index() < length(dirs())) {
          current_dir_index(current_dir_index() + 1)
          current_image_index(1)  # Reset image index
        } else {
          current_dir_index(1)
        }
      })
      
      shiny::observeEvent(c(input$prev_folder, input$prev_folder_inspector), {
        shiny::req(dirs())
        if (current_dir_index() > 1) {
          current_dir_index(current_dir_index() - 1)
          current_image_index(1)  # Reset image index
        } else {
          current_dir_index(length(dirs()))
        }
      })
      
      # Zoomable image
      output$inspector_img = EBImage::renderDisplay({
        shiny::req(dirs())
        current_dir_inspector = dirs()[current_dir_index()]
        images_inspector = get_images(file.path(current_dir_inspector, 'inspector'))
        current_image_inspector = images_inspector[current_image_index()]
        EBImage::display(
          EBImage::readImage(file.path(current_dir_inspector, 'inspector', current_image_inspector))
        )
      })
      
      # Descriptor
      shiny::observe({
        shiny::req(dirs())
        item_path =dirs()[current_dir_index()] # './database/items/A00001'
        list_dir = list.files(item_path)
        if ('lotDescription.txt' %in% list_dir) {
          desc = base::readLines(file.path(item_path, 'lotDescription.txt'),
                                         encoding = "UTF-8",
                                         warn = F)[[1]]
        } else {desc = 'Description unavailable'}
        
        if ('lotTitle.txt' %in% list_dir){
          item_name = base::readLines(file.path(item_path, 'lotTitle.txt'),
                                      encoding = "UTF-8",
                                      warn = F)[[1]]
        } else {item_name = 'Name unavailable'}
        
        if ('lotAuctionLocation.txt' %in% list_dir) {
          location = base::readLines(file.path(item_path, 'lotAuctionLocation.txt'),
                                 encoding = "UTF-8",
                                 warn = F)[[1]]
        } else {location = 'Location unavailable'}
        
        if ('lotAuctioneer.txt' %in% list_dir) {
          auction_house = base::readLines(file.path(item_path, 'lotAuctioneer.txt'),
                                     encoding = "UTF-8",
                                     warn = F)[[1]]
        } else {auction_house = 'Auction house unavailable'}
        
        if ('lotAuctionName.txt' %in% list_dir) {
          auction_name = base::readLines(file.path(item_path, 'lotAuctionName.txt'),
                                          encoding = "UTF-8",
                                          warn = F)[[1]]
        } else {auction_name = 'Name unavailable'}
        
        output$item_reference = shiny::renderText({
          strsplit(item_path, '/')[[1]][4]
        })
        
        output$item_name = shiny::renderText(item_name)
        output$item_description = shiny::renderText(desc)
        output$auction_location = shiny::renderText(location)
        output$auction_house = shiny::renderText(auction_house)
        output$auction_name = shiny::renderText(auction_name)
      })
      
      # Statistics 
      shiny::observeEvent(input$run_plot, {
        freq = base::table(db_table$df[,input$stats_select_feature])
        # print(names(freq))
        fig = plotly::plot_ly(
          x = names(freq),
          y = freq,
          name = "Feature distribution",
          type = "bar"
        )
        
        output$freq_plot = plotly::renderPlotly({
          fig
        })
      })
    }
  )
}
