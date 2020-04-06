********************************************************///
/// 	do-file Generación de Informes COVID-19 		///
///			R4 Medicina Preventiva y Salud Pública		///
///		Centro Nacional de Epidemiología (ISCIII)		///
///														///
/// 			5 de abril de 2020 						///
/// ****************************************************///

* Escribir el directorio donde está el Excel a analizar, ya seleccionado por islas.
cd "$path"

local hoy $S_DATE
di "`hoy'"


*** PIRÁMIDES DE POBLACIÓN CASOS
foreach lname of newlist areadearriba areadeabajo areadeladerecha areadelaizquierda {
import excel "ExcelYahecho.xls", sheet("`lname'") firstrow clear
rename *, lower
foreach var of varlist fecnacimiento  fprimerossםntomas fdeclaraciףn {
gen `var'_nuevo=date(`var', "DMY")
format `var'_nuevo %tdDD/NN/CCYY
}

gen edad_nuevo=round((fprimerossםntomas_nuevo-fecnacimiento_nuevo)/365.25)


*** DEFINICIÓN DE GRUPOS DE EDAD (Hecho por Belén Peñalver, r3 ISCIII).
egen gredad5=cut(edad_nuevo), at(0(10)90) icodes label
replace gredad5=9 if edad>=90 & edad!=.
capture label drop gredad5
capture label define gredad5 0 "<10" 1 "10-19" 2 "20-29" 3 "30-39" 4 "40-49" 5 "50-59" /*
*/ 6 "60-69" 7 "70-79" 8 "80-89" 9 "≥90" 
label values gredad5 gredad5
recode gredad5(9=8), gen(gredad5ine) 

*** DEFINICIÓN DE NUMERO DE HOMBRES Y MUJERES (Modificación de trabajo de Belén Peñalver, r3 ISCIII)
gen sexo_num=1 if sexo=="Hombre"
replace sexo_num=0 if sexo=="Mujer"

gen hombres=.
gen mujeres=.
local vpmax=0
	forvalues v=0(1)19 {
	
		count if sexo_num==1 & gredad5==`v' 
		replace hombres=-r(N) if gredad5==`v' & sexo_num==1 

			
		count if sexo_num==0 & gredad5==`v' 
		replace mujeres=r(N) if gredad5==`v' & sexo_num==0 
			
		}
	
grstyle init
grstyle set imesh, compact
*** PIRÁMIDE DE POBLACIÓN TOTAL DE CASOS COVID-19 (Modificación de trabajo de Belén Peñalver, r3 ISCIII).
twoway bar hombres gredad5, color(dkorange*0.7) horizontal || bar mujeres gredad5, color(lavender) horizontal title("Confirmados en `lname' por grupo de edad") /*
*/ xtitle("Número de casos") ytitle("Grupo de edad") xscale(range(0 30)) xlabel( /*-$vpmax "$vpmax"*/ -30 "30" -25 "25" -20 "20" -15 "15" -10 "10" -5 "5" 0(5)30 ) /*
*/ ylabel(0 "<10" 1 "10-19" 2 "20-29" 3 "30-39" 4 "40-49" 5 "50-59" /*
*/ 6 "60-69" 7 "70-79" 8 "80-89" 9 "≥90", nogrid angle(0)) legend(region(lcolor(white)) order(1 "Hombres" 2 "Mujeres")) graphregion(color(white)) 

graph export "Dataviz\COVID19_`lname'_`hoy'_casosconfirmadostotales_piramides.png", width(1600) replace

save COVID19_`lname'_casosconfirmados, replace

}
