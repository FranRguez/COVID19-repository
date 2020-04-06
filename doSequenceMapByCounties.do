* COVID-19 Automate reports
* Author: Francisco Rodriguez Cabrera
* Medical resident in Public Health
* Spanish National Center of Epidemiology
* Instituto de Salud Carlos III
* Contact: fdrodriguez@isciii.es

* Escribir el directorio donde está el Excel a analizar, ya seleccionado por islas.
cd "$path"
local hoy $S_DATE
clear

** MAPA COROPLÉTICO DE INCIDENCIA ACUMULADA DE CASOS
* Abrir un archivo cuyo nombre termine en RESULTADOS
local files : dir "" files "*RESULTADOS.xls"
foreach f of local files {
	import excel "`f'", firstrow clear
	save resultados, replace
	
}
capture gen casos_municipio=1

/*
count if Municipioresidencia==""
local observacionesvacias=`r(N)'
count if Municipioresidencia=="" & Municipiodeclarante!=""
local observacionesimputadas=`r(N)'
*/
replace Municipioresidencia=Municipiodeclarante if Municipioresidencia==""


gen fechadeclaracion=date(FDeclaraciףn, "DMY")
format fechadeclaracion %tdDD/NN/CCYY

save resultados_preparados, replace




* Mapa por fecha de declaración. Ir hacia atrás semanalmente, durante 6 semanas.
forvalues x=0(1)6 {
use resultados_preparados, clear
global lapsotiempo=int(daily("$S_DATE", "DMY"))-`x'*7
local fechaultima : di %tdDD\NN\CCYY daily("$S_DATE", "DMY")-`x'*7

drop if fechadeclaracion>=$lapsotiempo


collapse (sum) casos_municipio, by(Municipioresidencia)
save COVID19_casospormunicipio, replace

shp2dta using "Mapeo/recintos_municipales_inspire_canarias_wgs84.shp", database(mapamunicipios) coordinates(co_mapamunicipios) genid(id2) replace

use mapamunicipios, clear

** Asignar población a cada municipio
preserve
import excel "Mapeo\pobmun19", firstrow clear
keep if CPRO=="35" | CPRO=="38"
replace CMUN="34053535"+CMUN if CPRO=="35"
replace CMUN="34053838"+CMUN if CPRO=="38"
rename CMUN NATCODE
drop PROVINCIA NOMBRE
save poblacionmunicipios_Canarias,replace
restore

* Añado datos de población al shapefile
merge m:1 NATCODE using poblacionmunicipios_Canarias, nogenerate


* Ahora que tengo el shapefile preparado, le incorporo los casos por municipio 
merge m:m Municipioresidencia using COVID19_casospormunicipio

* BUSCAR LOS VALORES _MERGE=2 PORQUE SON FALLOS DEL CRUCE!!!
save COVID19_mapaconcasos, replace


replace casos_municipio=0 if casos_municipio==.
gen proporcion_casos=round(casos_municipio*100000/POB19)

capture sum proporcion_casos, detail

* Los colores elegidos serán por la distribución en quintiles de los municipios presentados al final del periodo analizado.
if `x'==0 {
_pctile proporcion_casos, p(20 40 60 80)
local p20 : di `r(r1)'
local p40 : di `r(r2)'
local p60 : di `r(r3)'
local p80 : di `r(r4)'
qui sum proporcion_casos
local min : di `r(min)'
local max : di `r(max)'


spmap proporcion_casos using co_mapamunicipios,  id(id2) fcolor(Reds) legstyle(2) legend(ring(1) position(3) symxsize(15) size(5)  ) ///
clmethod(custom) clbreaks(`min' `p20' `p40' `p60' `p80' `max') legend(on) note(" `fechaultima'  ", size(6)position(10)) ytitle("Casos confirmados")

}
if `x'>=10 {
* El resto sin leyenda, para que se vea mejor.
spmap proporcion_casos using co_mapamunicipios,  id(id2) fcolor(Reds)  ///
clmethod(custom) clbreaks(`min' `p20' `p40' `p60' `p80' `max') legend(off) note(" `fechaultima'  ", size(11)position(10)) ytitle("Casos confirmados")
}
graph export "Dataviz\Semanal\COVID19_casosconfirmadostotales_mapa`x'.png", width(1600)  replace
}

