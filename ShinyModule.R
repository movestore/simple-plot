library(leaflet)
library(leaflet.extras)
library(move)
library(sp)
library(pals)
library(mapview)

shinyModuleUserInterface <- function(id, label) {
  ns <- NS(id)
  tagList(
    titlePanel("Plot data"),
    leafletOutput(ns("mymap")),
    downloadButton(ns('savePlot'), 'Save Plot')
  )
}

shinyModule <- function(input, output, session, data) {
  #### interactive object to read in .RData file  ####
  mvObj <- reactive({ data })

  #### make map as reactive object to be able to save it ####
  mapFinal <- reactive({
    mv <- mvObj()
    cols <- colorFactor(gnuplot(), domain=namesIndiv(mv))
    map1 <- leaflet(mv) %>% addTiles()
    if(class(mv)=="MoveStack"){
      mvL <- move::split(mv)
      for(i in mvL){
        map1 <- addPolylines(map1, lng = coordinates(i)[,1],lat = coordinates(i)[,2],color=~cols(namesIndiv(i)),weight=5, opacity=0.7 ,highlightOptions = highlightOptions(color = "red",opacity = 1,weight = 2, bringToFront = TRUE))
      }
    }else{map1 <- addPolylines(map1, lng = coordinates(mv)[,1],lat = coordinates(mv)[,2],color=~cols(namesIndiv(mv)),weight=5, opacity=0.7 ,highlightOptions = highlightOptions(color = "red",opacity = 1,weight = 2, bringToFront = TRUE))}
    map1  %>% addLegend(position= "topright", pal=cols, values=namesIndiv(mv), labels=namesIndiv(mv) ,opacity = 0.7) %>%
      addScaleBar(position="bottomleft",options=scaleBarOptions(maxWidth = 100, metric = TRUE, imperial = F, updateWhenIdle = TRUE))
  })


  ### render map to be able to see it ####
  output$mymap <- renderLeaflet({
    mapFinal()
  })


  ### save map, takes some seconds ###
  output$savePlot <- downloadHandler(
    filename = function() {
      paste("SimplePlot.png", sep="")
    },
    content = function(file) {
      mymap <- mapFinal()
      mapshot( x =mymap
               , remove_controls = "zoomControl"
               , file = file
               , cliprect = "viewport"
               , selfcontained = FALSE)
    }
  )

  return(mvObj)
}
