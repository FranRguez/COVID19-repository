library(maps)
library(geosphere)


# Crear base de datos
data <- rbind(
  Buenos_aires=c(-58,-34),
  Paris=c(2,49),
  Melbourne=c(145,-38),
  Saint.Petersburg=c(30.32, 59.93),
  Abidjan=c(-4.03, 5.33),
  Montreal=c(-73.57, 45.52),
  Nairobi=c(36.82, -1.29),
  Salvador=c(-38.5, -12.97)
)  %>% as.data.frame()
colnames(data)=c("long","lat")

# Generar las coordenadas
all_pairs <- cbind(t(combn(data$long, 2)), t(combn(data$lat, 2))) %>% as.data.frame()
colnames(all_pairs) <- c("long1","long2","lat1","lat2")

# Mapa de fondo
par(mar=c(0,0,0,0))
map('world',col="#f2f2f2", fill=TRUE, bg="white", lwd=0.05,mar=rep(0,4),border=0, ylim=c(-80,80) )

# Añadir las conexiones
for(i in 1:nrow(all_pairs)){
  plot_my_connection(all_pairs$long1[i], all_pairs$lat1[i], all_pairs$long2[i], all_pairs$lat2[i], col="skyblue", lwd=1)
}


# Añadir puntos
points(x=data$long, y=data$lat, col="slateblue", cex=2, pch=20)
# Poner las etiquetas
text(rownames(data), x=data$long, y=data$lat,  col="slateblue", cex=1, pos=4)




### Otras alternativas
# Mundial
map('world')
# Península, Baleares y Canarias 
map(regions=sov.expand("Spain"))
# Península, Baleares 
map(regions='Spain')
# Canarias 
map(regions='Canary Islands')
