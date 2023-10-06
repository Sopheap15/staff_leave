library(shiny)
library(plotly)
library(DT)
#library(ical)
library(tidyverse)

# Define server logic required to draw a histogram
function(input, output, session) {
	# activate download button
	observe({
		# Check if a file has been uploaded
		if (!is.null(input$file)) {
			# Enable the download button if a file is uploaded
			shinyjs::enable("downloadData")
			# Enable the date input if a file is uploaded
			shinyjs::enable("date")
		} else {
			# Disable the download button if no file is uploaded
			shinyjs::disable("downloadData")
			# Disable the date input if no file is uploaded
			shinyjs::disable("date")
		}
	})


	event <- reactive({
		if (is.null(input$file)) {
			return(NULL)
		}
		al <- ical::ical_parse_df(input$file$datapath) %>%
			filter(between(start, input$date[1], input$date[2])) %>%
			filter(!is.na(summary)) %>%
			mutate(day = as.numeric(str_extract(description, "\\d+(\\.\\d+)?"))) %>%
			mutate(leave_type = case_when(str_detect(str_to_upper(summary), "AL(?![A-Z])|OFF") ~ "AL",
																		TRUE ~ "SL"),
						 name = case_when(str_detect(summary, "(?i)Ratt*") ~ "Rattanak",
						 								 str_detect(summary, "(?i)Sine*") ~ "Sineang",
						 								 str_detect(summary, "(?i)Soli") ~ "Solida",
						 								 str_detect(summary, "(?i)Soph*") ~ "Sopheap",
						 								 str_detect(summary, "(?i)clean*") ~ "Cleaner",
						 								 str_detect(summary, "(?i)VF|(?i)Viv") ~ "Vivian",
						 								 str_detect(summary, "(?i)JL|(?i)Jo") ~ "Joanne",
						 								 TRUE ~ "Unknown"
						 )) %>%
			filter(!name %in% c("Vivian", "Joanne"))

		return(al)
	})


# render datatable to summary leave
	output$summary_leave <- renderDataTable({

		# Check for missing file
	 event_data <- event()
	 if (!is.null(event_data)) {
	 	event_data %>%
	 		select(name, leave_type, "leave_day" = day, "date" = "start") %>%
	 		mutate(date = as.Date(date)) %>%
	 		group_by(name, leave_type, date) %>%
	 		summarise(leave_day) %>%
	 		datatable(rownames = F)
	 } else {
	 	NULL
	 }
	})


	# Download entire dataset as a CSV file
	output$downloadData <- downloadHandler(
		filename = function() {
			paste("Staff_leave_data_", Sys.Date(), ".csv", sep = "")
		},
		content = function(file) {
			event_data <- event()
			if (!is.null(event_data)) {
				write.csv(event_data, file, row.names = FALSE)
			}
		}
	)


# render plotly to summary
output$summary <- renderPlotly({

	event_data <- event()
	if (!is.null(event_data)) {
		plot <- event_data %>%
			select(name, leave_type, "leave_day"=day, "date" ="start") %>%
			mutate(date = as.Date(date)) %>%
			group_by(name, leave_type) %>%
			summarise(leave_day=sum(leave_day)) %>%
			mutate(leave_type = ifelse(leave_type=="AL", "Annual Leave", "Sick Leave"))

		colors <- c("orange", "blue")

		# Create plotly bar chart
	plot %>%
		plot_ly(
			x = ~name,
			y = ~leave_day,
			type = "bar",
			color = ~leave_type,
			colors = colors
		) %>%
			layout(
				xaxis = list(title = "Staff name"),
				yaxis = list(title = "Number of day Leave"),
				legend = list(
					title = "Leave Type",
					traceorder = "reversed",
					orientation = "h",
					y = 1.1,
					x = 0.5
				),
				barmode = "stack"
			)

	} else {
		NULL
	}
})

}
