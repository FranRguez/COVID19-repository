* Francisco Rodríguez Cabrera
* MIR Medicina Preventiva y Salud Pública
* Contacto: rodcabfran@gmail.com

** Generar informe automáticamente a partir de base de datos de ejemplo.
* PRIMERA PARTE: Texto sencillo
putdocx begin
putdocx paragraph
putdocx text ("En el presente informe, se estudia primero un ensayo sobre el cáncer, y luego la evolución de la esperanza de vida en Estados Unidos de 1900 a 1999."), linebreak 
* Linebreak para crear espacio entre este texto y el siguiente.
putdocx save saludogacetasanitaria.docx,replace


** SEGUNDA PARTE: Añadir tabla con datos.
* Cargo primero la base de datos.
sysuse cancer, clear
putdocx begin
putdocx paragraph
putdocx text ("Tabla 1. Análisis descriptivo de la muestra del ensayo.")
statsby n=r(N) Medi=round(r(mean),.01) Máx=r(max) Mín=r(min), by(drug): summarize age
rename drug Medicamento
putdocx table tablagaceta = data("Medicamento n Medi Máx Mín"), varnames border(start, nil) border(insideV, nil) border(end, nil)
* ¡Yups! Acabo de ver que tengo una errata en el título.
putdocx table tablagaceta(1,3)=("Media")
putdocx save tablagacetasanitaria.docx, replace


********* TERCERA PARTE: Añadir imágenes. En este caso, utilizaremos la base de datos de ejemplo de Stata sobre esperanza de vida en Estados Unidos, ya que nos da una evolución temporal muy bonita de mostrar.
*********
sysuse uslifeexp, clear
putdocx begin
putdocx paragraph
putdocx text ("Tabla 1. Evolución de la esperanza de vida en mujeres y hombres en el periodo 1900-1999 en Estados Unidos")
quietly line le_female le_male year
graph export graficolineas.png, replace
putdocx paragraph, halign(center)
putdocx image graficolineas.png
putdocx save graficolineas.docx, replace



********* CUARTA PARTE: Complicando el texto. 
*********
putdocx begin
putdocx paragraph

* Quiero que Stata me evalúe automáticamente si ha disminuido, aumentado o permanecido estable mis datos en los últimos 5 años.
* Para ello, primero extraigo la esperanza de vida del último año.
sort year
quietly summarize year		
local esperanzadevida_ultimoano : display round(le[r(N)],.01)

* Extraigo esperanza de vida del año anterior (lo envolvemos con "round" para que no me salgan muchos decimales).
local esperanzadevida_anoanterior : display round(le[r(N)-10],.01)

* Creo otra variable que contenga la diferencia entre ambas esperanzas de vida.
local diferenciaesperanzas : display %4.2f (le[r(N)] - le[r(N)-10])


putdocx text ("La esperanza de vida en Estados Unidos ")

* Y ahora creo condiciones para que el texto difiera según difieran mis datos.
if `diferenciaesperanzas'>0 {
	putdocx text ("aumentó en `diferenciaesperanzas' años")
	} 	
else if `diferenciaesperanzas'<0 {
	putdocx text ("disminuyó en `diferenciaesperanzas' años")
	}
else if `diferenciaesperanzas'==0 {
	putdocx text ("ha permanecido estable")
	}
putdocx text (" durante los últimos 10 años del análisis.")

putdocx save trabajandoconmacros.docx, replace



* Junto las cuatro partes realizadas y voilà! Ya tengo mi documento.
putdocx append saludogacetasanitaria.docx tablagacetasanitaria.docx graficolineas.docx trabajandoconmacros, saving("notametodologica.docx", replace)
