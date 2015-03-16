library(shiny)
shinyUI(pageWithSidebar(
  #Application title
  headerPanel("Calidad del aire"),
  sidebarPanel(
    h5("Concentraciones de PM2,5 (ug/m3) en Santiago, Chile"),
    h6("Puedes cambiar el formato del grafico, si prefieres puedes dividir por estaciones"),
    selectInput("id2","cambia el grafico",
                choices=list("Grafico Unico"= 0,
                             "Grafico por estacion"=100)),
    h6("Selecciona la hora que deseas analizar"),
    selectInput("id1","Selecciona hora",
                choices=list("01:00"=100,
                             "02:00"=200,
                             "03:00"=300,
                             "04:00"=400,
                             "05:00"=500,
                             "06:00"=600,
                             "07:00"=700,
                             "08:00"=800,
                             "09:00"=900,
                             "10:00"=1000,
                             "11:00"=1100,
                             "12:00"=1200,
                             "13:00"=1300,
                             "14:00"=1400,
                             "15:00"=1500,
                             "16:00"=1600,
                             "17:00"=1700,
                             "18:00"=1800,
                             "19:00"=1900,
                             "20:00"=2000,
                             "21:00"=2100,
                             "22:00"=2200,
                             "23:00"=2300,
                             "24:00"=2400))
    ),
  mainPanel(
    p("En este grafico puedes revisar la variacion horaria de las 
      concentraciones (en ug/m3), de las ultimas 24 horas.
      "),
    plotOutput('newPlot'),
    p("En el mapa puedes analizar la distribucion espacial para una hora escojida"),
    textOutput('texto'),
    plotOutput('mapa')
  )
))