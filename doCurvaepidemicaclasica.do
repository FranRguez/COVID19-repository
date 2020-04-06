********************************************************///
/// 	do-file Generación de Informes COVID-19 		///
/// 		Autor: Francisco Rodríguez Cabrera			///
///		R4 Medicina Preventiva y Salud Pública, ISCIII 	///
/// 			5 de abril de 2020 						///
///			 Contacto: rodcabfran@gmail.com				///
/// ****************************************************///

ssc install grstyle

cd "$path"
use basedatos_analizar, clear
rename *, lower
foreach var of varlist fecnacimiento fprimerossםntomas fdeclaraciףn {
gen `var'_nuevo=date(`var', "DMY")
format `var'_nuevo %tdDD/NN/CCYY
}
save "Dataviz\resultadosreveca_precurvaepidemica", replace


local fechadehoy : di %tdDD/NN/CCYY daily("$S_DATE", "DMY")


gen casos=1

preserve
collapse (sum) casos, by(fprimerossםntomas_nuevo)
rename (casos) (casos_fechainiciosintomas)
save "Dataviz\resultadosreveca_precurvaepidemica_primerossintomas", replace
restore
collapse (sum) casos, by(fdeclaraciףn_nuevo)
rename (casos fdeclaraciףn_nuevo) (casos_fechadeclaracion fprimerossםntomas_nuevo)
merge 1:1 fprimerossםntomas_nuevo using "Dataviz\resultadosreveca_precurvaepidemica_primerossintomas"
sort fprimerossםntomas_nuevo



*** SACAR CURVA
grstyle init
grstyle set plain, grid
grstyle set inten 30: bar
* 
capture gen sdate = string(fprimerossםntomas_nuevo, "%tdDD/NN") 
drop if fprimerossםntomas_nuevo<21960
labmask fprimerossםntomas_nuevo, values(sdate) 

graph bar casos_fechainiciosintomas casos_fechadeclaracion,  over(fprimerossםntomas_nuevo, lab(angle(90) labcolor(gray) labsize(small))) graphregion(col(white)) ylab(,angle(0)) bar(2, color(dkorange*0.7)) bar(1, color(lavender))  legend(label(2 "Fecha de declaración  ") label(1 "Fecha de inicio de síntomas"))  /*
*/ caption("Fuente: Servicio de Epidemiología. Datos actualizados a `fechadehoy'", size(vsmall)position(6)) ytitle("Casos confirmados")

graph export "Dataviz/curvaclasica.png", width(1600) replace

/*


* ALTERNATIVA
tw (bar casos_fechainiciosintomas fprimerossםntomas_nuevo, color(dkorange*0.75%65) barw(.7)) || (bar casos_fechadeclaracion fprimerossםntomas_nuevo, color(lavender%45) barw(.6)), ///
note(" A  ", size(large)position(10)) caption("Fuente: Servicio de Epidemiología y Prevención. Servicio Canario de Salud. Datos actualizados a `fechadehoy'", size(vsmall)position(6)) ///
scheme(s1mono) legend(on) xtitle("") ytitle("Casos confirmados") legend(label(2 "Fecha de declaración ") label(1 "Fecha de inicio de síntomas"))
*/


cd "$path\dataviz\"
!del *.dta





