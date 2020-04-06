************************************************************///
/// 	do-file Generación de Informes COVID-19 (Curva log)	///
///				R4 Medicina Preventiva y Salud Pública		///
///			Centro Nacional de Epidemiología (ISCIII)		///
///															///
/// 				5 de abril de 2020 						///
/// ********************************************************///

* Escribir el directorio donde está el Excel a analizar, ya seleccionado por islas.
cd "$path"

* Fecha de actualización hoy.
local fechaactualizacion : di %tdDD\NN\CCYY daily("$S_DATE", "DMY")


* Preparar datos resto de España
import delimited "https://covid19.isciii.es/resources/serie_historica_acumulados.csv", clear
gen fecha_mod=date(fecha, "DMY")
format %tdDD/NN/CCYY fecha_mod
collapse (sum) casos, by(fecha_mod ccaacodigoiso)

* Elimino 2 últimas filas (que tiene observaciones escritas) y posibles datos sin CCAA.
drop if ccaacodigoiso=="" | _n>=_N-1
* Coger los valores de la variable ccaacodigoiso

* Se definió momento de transmisión comunitaria el momento en el cual tuvieron 10 casos.
levelsof ccaacodigoiso, local(comunidadesautonomas)
foreach lname of local comunidadesautonomas {
drop if casos<10 & ccaacodigoiso=="`lname'"
}
bysort ccaacodigoiso (fecha_mod): gen diadeepidemia=_n
rename casos casos_totalsp
save COVID19_totalsp, replace

* Análisis por áreas
foreach lname of newlist LAN FTV GCCHUIMI GCNEGRIN {
use COVID19_`lname'_casosconfirmados, clear
gen caso_`lname'=1
collapse (sum) caso_`lname', by(fecha_mod)

* Tengo casos nuevos en cada día. Quiero acumulado para que sea comparable.
gen casosacum_`lname'=sum(caso_`lname')
drop caso_`lname'

* Mismo procedimiento que con datos CNE
drop if casosacum_`lname'<10
sort fecha_mod
gen diadeepidemia=_n

append using COVID19_totalsp

* Elimino fechas no rellenadas.
drop if fecha_mod==.


grstyle init
grstyle set imesh, compact 
grstyle set legend 4, nobox stack
grstyle linewidth plineplot 0.4
grstyle set color hue, n(4)

twoway  (line casos_totalsp diadeepidemia if ccaacodigoiso!="CN", yscale(log) color(gray*0.4)) ///
 (line casos_totalsp diadeepidemia if ccaacodigoiso=="CN", yscale(log)) ///
 (line casosacum_`lname' diadeepidemia, yscale(log) color(dkorange*0.8)), ylabel(10 "10" 100 "100" 1000 "1000" 10000 "10000") ///
 legend(label(1 "CCAA (salvo Canarias)") label(2 "Canarias") label(3 "`lname'")) xtitle("Día de epidemia (desde ≥10 casos)") ///
 caption("Fuente: Servicio de Epidemiología y Prevención. Informe del día `fechaactualizacion'", size(vsmall)position(6)) note(" B ", size(7)position(10))
 graph export "Dataviz\COVID19_`lname'__curvalogaritmica.png", replace

}

