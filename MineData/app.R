#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(tidyverse)

#### Load data ----
harlan_data <- read_csv("/Data/Raw/EIA_MineData_Harlan_Raw.csv")
harlan_data <- harlan_data %>%
    filter(depth_id > 0) %>%
    select(year, mine.name, production.stons)

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("superhero")
    titlePanel("Mine Production in Harlan County, Kentuck, 2000 - 2011"),
    sidebarLayout(
        sidebarPanel(
            sliderInput(selectInput(inputId = "y", 
                                    label = "Year",
                                    choices = c("2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011"), 
                                    selected = "2000")
        ),

        # Select depth
        checkboxGroupInput(inputId = "fill",
                           label = "Depth ID",
                           choices = unique(nutrient_data$depth_id),
                           selected = c(1, 7)),
        
        # Select lake
        checkboxGroupInput(inputId = "shape",
                           label = "Lake",
                           choices = c("Peter Lake", "Paul Lake"),
                           selected = "Peter Lake"),
        
        # Select date range to be plotted
        sliderInput(inputId = "x",
                    label = "Year",
                    min = "2000",
                    max = "2011",
                    value = c(as.Date("1995-01-01"), as.Date("1999-12-31")))),
        
        # Output
        mainPanel(
            plotOutput("scatterplot", brush = brushOpts(id = "scatterplot_brush")), 
            tableOutput("mytable")
        )))

#### Define server  ----
server <- function(input, output) {
    
    # Define reactive formatting for filtering within columns
    filtered_nutrient_data <- reactive({
        nutrient_data %>%
            filter(sampledate >= input$x[1] & sampledate <= input$x[2]) %>%
            filter(depth_id %in% input$fill) %>%
            filter(lakename %in% input$shape) 
    })
    
    # Create a ggplot object for the type of plot you have defined in the UI  
    output$scatterplot <- renderPlot({
        ggplot(filtered_nutrient_data(), 
               aes_string(x = "sampledate", y = input$y, 
                          fill = "depth_id", shape = "lakename")) +
            geom_point(alpha = 0.8, size = 2) +
            theme_classic(base_size = 14) +
            scale_shape_manual(values = c(21, 24)) +
            labs(x = "Date", y = expression(Concentration ~ (mu*g / L)), shape = "Lake", fill = "Depth ID") +
            scale_fill_distiller(palette = "YlOrBr", guide = "colorbar", direction = 1)
        #scale_fill_viridis_c(option = "viridis", begin = 0, end = 0.8, direction = -1)
    })
    
    # Create a table that generates data for each point selected on the graph  
    output$mytable <- renderTable({
        brush_out <- brushedPoints(filtered_nutrient_data(), input$scatterplot_brush)
    })
    
}

