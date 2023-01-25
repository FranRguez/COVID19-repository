library(jsonlite)
library(maptools)
library(rgdal)
library(ggplot2)
library(stringr)
library(dplyr)

setwd("/home/CCAES/MosquitoAlert")


################## ################## ################## ###########
################## IMPORTACIÓN DE TODOS LOS JSON ###################
################## ################## ################## ###########
archivo <- "mosquitoalert"
download.file("https://github.com/MosquitoAlert/Data/raw/master/all_reports.zip", paste0(archivo, ".zip"))
unzip(paste0(archivo, ".zip"))
#dat <- fromJSON("home/webuser/webapps/tigaserver/static/all_reports2014.json", simplifyVector = TRUE)
#datos <- fromJSON(file='home/webuser/webapps/tigaserver/static/all_reports2014.json')
  
archivos <- list.files("/home/CCAES/MosquitoAlert/home/webuser/webapps/tigaserver/static/", pattern="*.json")



for (i in archivos) {
  print(i)

  extraccion <- fromJSON(paste0("/home/CCAES/MosquitoAlert/home/webuser/webapps/tigaserver/static/", i))

  # Asignar el nombre a cada base de datos
nombresinjson <- str_replace(i, ".json", "")
  # Filtro bicho y latitud-longitud
  # Latitud 43.79 es la exacta, aunque he sumado un poco más para ver aquello que está por encima de los Pirineos y colinda con España.
extraccion <- extraccion %>% filter(lat<=43.95, lat>=27.63769, lon>=-18.16119, lon<=4.32747)
assign(nombresinjson, extraccion)

}


################## ################## ################## ###########
################## PREPARACIÓN DE MAPAS ############################
################## ################## ################## ###########

   # Canarias
limprov_pen <- readShapeSpatial("shapefiles/shp_prov/recintos_provinciales_inspire_peninbal_etrs89.shp")
limprov_can <- readShapeSpatial("shapefiles/shp_prov/recintos_provinciales_inspire_canarias_wgs84.shp")
# Mover Canarias para arriba. En este momento no nos interesa
#prov_can <- elide(limprov_can,shift=c(5.7,7))
limprov <- rbind (limprov_pen, limprov_can)
provincias <- fortify(limprov, region='INSPIREID')
provincias <- merge(provincias, limprov@data ,by.x='id',by.y='INSPIREID')


  # Península
  limprov_pen <- readOGR("shapefiles/shp_prov/recintos_provinciales_inspire_peninbal_etrs89.shp", use_iconv=TRUE, encoding="UTF-8")
limprov_pen <- limprov_pen[which(limprov_pen@data$NAMEUNIT!="Illes Balears"),]
proj4string(limprov_pen)<-CRS("+proj=longlat +init=epsg:4326")
limprov_pen@data$NAMEUNIT <- gsub("[[:space:]]", "", limprov_pen@data$NAMEUNIT)

  # Baleares
limmuni_bal <- readOGR("shapefiles/shp_muni/recintos_municipales_inspire_peninbal_etrs89.shp", use_iconv=TRUE, encoding="UTF-8")
limmuni_bal <- limmuni_bal[which(limmuni_bal@data$CODNUT2=="ES53"),]
proj4string(limmuni_bal)<-CRS("+proj=longlat +init=epsg:4326")
limmuni_bal@data$CODIGOINE <- as.character(limmuni_bal@data$NATCODE)
limmuni_bal@data$CODIGOINE <-substr(limmuni_bal@data$CODIGOINE, 7, 11)

  # Canarias
limmuni_can <- readOGR("shapefiles/shp_muni/recintos_municipales_inspire_canarias_wgs84.shp", use_iconv=TRUE, encoding="UTF-8")
limmuni_can <- elide(limmuni_can,shift=c(5.7,7))
proj4string(limmuni_can)<-CRS("+proj=longlat +init=epsg:4326")
limmuni_can@data$CODIGOINE <- as.character(limmuni_can@data$NATCODE)
limmuni_can@data$CODIGOINE <-substr(limmuni_can@data$CODIGOINE, 7, 11)

limprov_df <- fortify(limprov, region='INSPIREID')
limprov_df <- merge(limprov_df, limprov@data ,by.x='id',by.y='INSPIREID')



################## ################## ##################### ###########
################## REPRESENTACIÓN DE MAPAS ############################
################## ################## ###################### ##########
  
  
  # Asignar el nombre a cada base de datos
nombresinjson <- str_replace(i, ".json", "")

map2022 <- ggplot() + geom_polygon(data = limprov, aes(x = long, y = lat, group = group), colour = "black", fill = "antiquewhite") + 
    geom_point(data = all_reports2022, alpha = 0.5, aes(x=lon, y=lat, size=0.2, color=all_reports2022$movelab_annotation$classification), show.legend = NA) +
    labs(title="Detecciones de Mosquito Alert. Fecha 03/03/2022") +   theme(axis.title=element_blank(),
                                                                            axis.text=element_blank(),
                                                                            axis.ticks=element_blank(),
                                                                            legend.title=element_blank())
  
