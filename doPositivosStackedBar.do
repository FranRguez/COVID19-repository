** Preparar base de datos.

cd "$directorio/CORREO LABORATORIOS/"
local files : dir "" files "*Gran Canaria*"
foreach f of local files {
import excel "`f'", firstrow clear	
gen positivo=1 if regexm(Resultado, "^POSITIVO ")==1
replace positivo=0 if positivo!=1
gen no_positivo=1 if positivo!=1
replace no_positivo=0 if positivo==1
keep FechaPetición positivo no_positivo
format %tdDD/NN/CCYY FechaPetición
gen area="GranCanariaCHUIMI"

save "COVID19_GCCHUIMI_CONF_total", replace

}


* FTV
local files : dir "" files "*Fuerteventura*"
foreach f of local files {
import excel "`f'", firstrow clear
drop if FechaPetición==. & Paciente==""
gen positivo=1 if regexm(Resultado, "^POSITIVO*")==1
replace positivo=0 if positivo!=1
gen no_positivo=1 if positivo!=1
replace no_positivo=0 if positivo==1
keep FechaPetición positivo no_positivo
format %tdDD/NN/CCYY FechaPetición
gen area="Fuerteventura"
save "COVID19_FTV_CONF_total", replace


}	


* GCNEGRIN Y LAN
local files : dir "" files "*Listado*"
foreach f of local files {
import excel "`f'", firstrow clear
drop if Criterio=="" & Nombre==""
capture rename Resultado resultado
capture rename RESULTADO resultado

gen FechaPetición=dofc(Fechapeticion)
format %tdDD/NN/CCYY FechaPetición 

* LAN
preserve
keep if Criterio=="Lanzarote"
gen positivo=1 if regexm(resultado, "^Positivo")==1
replace positivo=0 if positivo!=1
gen no_positivo=1 if positivo!=1
replace no_positivo=0 if positivo==1
keep FechaPetición positivo no_positivo

gen area="Lanzarote"
save "COVID19_LAN_CONF_total", replace
restore


* GCNEGRIN
keep if Criterio!="Lanzarote"
gen positivo=1 if regexm(resultado, "^Positivo$")==1
replace positivo=0 if positivo!=1
gen no_positivo=1 if positivo!=1
replace no_positivo=0 if positivo==1
keep FechaPetición positivo no_positivo
gen area="GranCanariaNegrin"
save "COVID19_GCNEGRIN_CONF_total", replace
}



append using COVID19_FTV_CONF_total
append using COVID19_LAN_CONF_total
append using COVID19_GCCHUIMI_CONF_total
	
gen totales=positivo+no_positivo

save peticionestotales, replace

grstyle init
grstyle set imesh, compact
grstyle set legend 2, nobox stack
grstyle set color Set3, opacity(40): p#markfill
grstyle set color Set2, opacity(0):  p#markline
grstyle symbolsize p

* foreach lname of newlist LAN FTV GCNEGRIN GCCHUIMI {

foreach lname of newlist GranCanariaNegrin GranCanariaCHUIMI Fuerteventura Lanzarote {

use peticionestotales, clear

keep if area=="`lname'"
collapse (sum) positivo totales, by(FechaPetición)
gen proporcion_positivos=positivo*100/totales


twoway bar positivo FechaPetición, color(dkorange*0.6)  || rbar positivo totales FechaPetición, color(gray*0.6) || ///
mspline proporcion_positivos FechaPetición, bands (8) yaxis(2) yscale(range(100) axis(2)) ///
ylabel(0(10)100, axis(2)) xlabel(,nogrid angle(90) labcolor(gray) labsize(2.5)) ///
legend(label(1 "Positivos") order(1 "Positivos" 2 "Negativos" 3 "Proporción positivos") ) color(red*0.6) ///
ytitle("Número de muestras") ytitle("Proporción de positivos", axis(2)) xtitle("Fecha de petición de muestra")  ///
note(" C ", size(7)position(10)) || scatter proporcion_positivos FechaPetición, yaxis(2)

graph export "Muestras_`lname'_.png", width(2000) replace

}

!del *.dta
