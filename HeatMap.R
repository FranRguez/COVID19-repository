# install.packages("reshape")
library(reshape)

# Data 
set.seed(8)
m <- matrix(round(rnorm(200), 2), 10, 10)
colnames(m) <- paste("Col", 1:10)
rownames(m) <- paste("Row", 1:10)

# Transform the matrix in long format
df <- melt(m)
colnames(df) <- c("x", "y", "value")



# install.packages("ggplot2")
library(ggplot2)

ggplot(df, aes(x = x, y = y, fill = value)) +
  geom_tile()

# Note that depending on the plotting windows size 
#the tiles might not be squared. If you want to keep them squared use cood_fixed.
ggplot(df, aes(x = x, y = y, fill = value)) +
  geom_tile() +
  coord_fixed()


# Customizando los bordes de los cuadros
ggplot(df, aes(x = x, y = y, fill = value)) +
  geom_tile(color = "white",
            lwd = 1.5,
            linetype = 1) +
  coord_fixed()

# Se pueden añadir los datos y un color rojizo.

ggplot(df, aes(x = x, y = y, fill = value)) +
  geom_tile(color = "white",
            lwd = 1.5,
            linetype = 1) +
  geom_text(aes(label = value), color = "white", size = 4) +
  scale_fill_gradient(low = "white", high = "red") +
  coord_fixed()

  