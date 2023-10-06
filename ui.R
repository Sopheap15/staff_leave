library(shiny)
library(plotly)
library(DT)
#library(shinyjs)

# Define UI for the application
fluidPage(
    # Load the CSS file
    includeCSS("styles.css"),
    # Initialize shinyjs
    shinyjs::useShinyjs(),

    div(class = "menu-bar",
        img(class = "logo", src = "logo.png", alt = "m4h IQLS logo"),
        # Application title
        titlePanel("m4h IQLS staff leave information")
    ),

    # Sidebar layout with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            wellPanel(
                p("This application is designed to streamline leave monitoring for m4h IQLS staff in Cambodia. Users can simply click the browse button to upload, choose the iCal file and selecting the relevant date range for tracking.")
            ),
            fileInput("file", "Choose an iCalendar file")
        ),

        # Main panel to display date input, summary, and plot
        mainPanel(
            fluidRow(
                column(6,
                       shiny::dateRangeInput(
                           "date",
                           start = "2022-11-1",
                           label = "Select Date Range",
                           format = "yyyy-M-dd"
                       )
                ),
                br(),
                column(6, style = "text-align: right;",
                       downloadButton("downloadData", "Download Data"),
                )
            ),
            #h2("Summary"),
            dataTableOutput("summary_leave"),
            plotlyOutput("summary")
        )
    )
)
