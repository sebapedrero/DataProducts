#install.packages("geoR","XML","lubridate","plotGooglMaps")
library(XML)
library(lubridate)
library(geoR)
library(maptools)
library(rgdal)
library(plotGoogleMaps)
library(ggplot2)
##get the data from web
setwd("E:/CursoDataProducts")
u = "http://macam.mma.gob.cl/icap/macam_PM25.html"
doc = htmlParse(u)
tableNodes = getNodeSet(doc, "//table")
tryAsInteger = function(node) {
  val = xmlValue(node)
  ans = as.integer(gsub(",", "", val))
  if(is.na(ans))
    val
  else
    ans
}
tb = readHTMLTable(tableNodes[[1]], elFun = tryAsInteger, colClasses = c("character", rep("integer", 9)))
##nombre de las estaciones
estaciones<-c("Independencia","La Florida","Las Condes","Parque O'Higgins",
              "Pudahuel","Cerrillos","El Bosque","Cerro Navia","Puente Alto",
              "Talagante","Quilicura")
#shape de santiago
shape <- readShapePoly("Project/data/comunasrm.shp")
muni<-fortify(shape)
#localizacion de las estaciones UTM
pontos<-read.table("Project/data/loci.r", head=T)
#ahora el script 
library(shiny)
shinyServer(
  function(input,output){
    output$newPlot<-renderPlot({
      #grafico de variacion temporal
      ini<-as.POSIXct(paste(ymd(as.numeric(as.character(tb[1,1]))),paste(as.numeric(tb[1,2])/100,":00:",sep=''),sep=' '))
      fin<-as.POSIXct(paste(ymd(as.numeric(as.character(tb[24,1]))),paste(as.numeric(tb[24,2])/100,":00:",sep=''),sep=' '))
      tiempo<-seq(ini, fin, by=3600)
      conc<-c(tb[,3],tb[,4],tb[,5],tb[,6],tb[,7],tb[,8],tb[,9],tb[,10],tb[,11],tb[,12],tb[,13])
      temporal<-data.frame(Tiempo=rep(tiempo,times=11),Concentracion=conc,Estaciones=rep(estaciones,each=24))
      if (input$id2==0){
        ggplot(data=temporal,aes(x=Tiempo,y=Concentracion,group=Estaciones))+geom_line(aes(colour=Estaciones))+
          geom_hline(aes(yintercept=25),colour='red',lwd=2)+ scale_colour_hue("clarity")
      }
      else{
        ggplot(data=temporal,aes(x=Tiempo,y=Concentracion,group=Estaciones))+geom_line(aes(colour=Estaciones))+
        geom_hline(aes(yintercept=25),colour='red',lwd=2)+facet_wrap(~Estaciones)
      }
    })
    output$texto<-renderText({
      paste("Escojiste las: ",as.numeric(input$id1)/100,":00 horas",sep='')
    })
    output$mapa<-renderPlot({
      lastpm2.5<-as.numeric(tb[tb$Hora==input$id1,3:13])
      pm2.5<-data.frame(pontos,lastpm2.5)
      M.geo<-as.geodata(pm2.5, coords.col=2:3, data.col=5)
      M.pred.grid<-expand.grid(seq(325000,365000,l=100), seq(6275000,6315000,l=100))
      M.kc<-krige.conv(M.geo, location=M.pred.grid, krige=krige.control(cov.model="exp", cov.pars=c(1,5000), nugget=0))
      grid.M<-cbind(M.pred.grid,M.kc$predict) 
      names(grid.M)<-c("x","y","pm")
      ggplot(data=pm2.5,aes(x,y))+geom_tile(aes(x = x, y = y,fill=pm),
                                            data = grid.M, position = "identity")+scale_fill_gradient(low="green", high="red")+
        geom_polygon(data=muni,aes(x = long, y = lat, group = group),
                     colour ='white', alpha = .2, size = .2)+
        geom_point(data=pm2.5,aes(x,y),colour='black',size=3)+
        geom_text(data=pm2.5,aes(x,y,label=ID),hjust=0,vjust=0)+
        coord_equal(xlim=c(322500,367500), ylim=c(6272500,6317500))
      
      })
  }
)