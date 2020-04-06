* COVID-19 Automate reports
* Author: Francisco Rodriguez Cabrera
* Resident in Public Health
* Spanish National Center of Epidemiology
* Contact: fdrodriguez@isciii.es



cd "$path"
local hoy $S_DATE

*** TASAS DE CRECIMIENTO DIARIO POR CADA ÁREA DE SALUD
foreach lname of newlist LAN FTV GCNEGRIN GCCHUIMI {
use COVID19_`lname'_casosconfirmados, clear
rename fecha_mod fecha

* Preparación de bases de datos
gen caso_`lname'=1
collapse (sum) caso_`lname', by(fecha)


preserve
* Comparativa casos Resto de España. Descargar datos de CNE
import delimited "https://covid19.isciii.es/resources/serie_historica_acumulados.csv", clear

* Las dos últimas observaciones son texto de aclaraciones.
drop if _n>=_N-1
drop if ccaacodigoiso!="CN"
gen fecha_mod=date(fecha, "DMY")
collapse (sum) casos, by(fecha_mod)
rename (casos fecha_mod) (casos_restosp fecha)
save COVID19_restospain, replace
restore


merge 1:1 fecha using COVID19_restospain
format fecha %tdDD/NN/CCYY
sort fecha


gen acumulado_restosp=sum(casos_restosp)
gen crecimiento=casos_restosp*100/acumulado[_n-1]
gen crecimiento_2dias=(crecimiento+crecimiento[_n-1])/2

gen acumulado_`lname'=sum(caso_`lname')
gen crecimiento_`lname'=caso_`lname'*100/acumulado_`lname'
* Aproximación al suavizado por medias móviles (¡de aquella manera!)
gen crecim2dias_`lname'=(crecimiento_`lname'+crecimiento_`lname'[_n-1])/2


** SCATTERPLOT PARA COMPARAR CRECIMIENTOS CAM-RESTO DE ESTADO
grstyle init
grstyle set plain
grstyle set ci burd, select(13 11) opacity(60)

twoway (scatter crecimiento_2dias fecha, mcolor(lavender*0.7)) ///
(scatter crecim2dias_`lname' fecha, mcolor(dkorange*0.7))  ///
(lpolyci crecimiento_2dias fecha, degree(4) clcolor(lavender*0.7) acolor(lavender*0.4)) ///
(lpolyci crecim2dias_`lname' fecha, degree(7) astyle(ci2) acolor(dkorange*0.4) acolor(lavender*0.7)), title("Tasa crecimiento diario `lname' por inicio de síntomas") ///
yscale(range(0(10)50)) ///
legend(order(2 "`lname'" 1 "España"))

graph export "Dataviz\COVID19_`lname'_`hoy'_casosconfirmadostotales_tasascrecimiento.png", width(1600) replace

}
