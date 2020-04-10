* Qué día es hoy?
local update : di %tdCCYY-NN-DD daily("$S_DATE", "DMY")
local hoyformato : di %tdDD/NN/CCYY daily("$S_DATE", "DMY")
local hoy : di daily("$S_DATE", "DMY")

local asemesterago_formato : di  %tdDD/NN/CCYY  daily("$S_DATE", "DMY")-183
local ayearago : di daily("$S_DATE", "DMY")-365 
local asemesterago : di daily("$S_DATE", "DMY")-183 
local threemonthsago : di daily("$S_DATE", "DMY")-90

* Importar datos automáticamente
* import delimited "https://momo.isciii.es/public/momo/data", delimiter(",") clear 
* save "momodata`update'_ccaa", replace

use "momodata`update'", clear
gen date=date(fecha_defuncion, "YMD")
format %tdDD/NN/CCYY date
drop if ambito=="nacional"
keep if date>=`threemonthsago'

replace nombre_ambito="Andalucía" if nombre_ambito=="AndalucÃ­a"
replace nombre_ambito="Aragón" if nombre_ambito=="AragÃ³n"
replace nombre_ambito="Cataluña" if nombre_ambito=="CataluÃ±a"
replace nombre_ambito="Castilla y León" if nombre_ambito=="Castilla y LeÃ³n"
replace nombre_ambito="País Vasco" if nombre_ambito=="PaÃ­s Vasco"
replace nombre_ambito="Región de Murcia" if nombre_ambito=="Murcia, RegiÃ³n de"


collapse (sum) defunciones_observadas defunciones_esperadas defunciones_esperadas_q01 defunciones_esperadas_q99, by(date nombre_ambito)
	

qui sum defunciones_observadas
local max=`r(max)'
local min=`r(min)'

grstyle clear
grstyle init

grstyle set plain, grid
grstyle set legend 6, nobox
grstyle linewidth plineplot 0.5
grstyle set ci burd, select(11 13) opacity(60)
grstyle set color Set1, opacity(0):  p#markline
grstyle set color Set2, opacity(60): p#markfill
grstyle set symbolsize large
grstyle set symbol T T


* Descripción del trimestre.
twoway rarea defunciones_esperadas_q01 defunciones_esperadas_q99 date, color(lavender*0.6) || ///
line defunciones_observadas date, color(red*0.8) || line defunciones_esperadas date, color(gs3*0.8) lpattern(shortdash) ///
ytitle("Número de defunciones registradas") xtitle("Fecha de defunción") xlabel(`=`threemonthsago'' (30) `=d("`hoyformato'")', format(%tdDD/NN/CCYY) angle(90) labcolor(*0.4) labsize(3)) ///
legend(order (2 "Observadas" 1 "Rango de defunciones esperadas" 3 "Esperadas")) ///
yla(`min'(500)`max', angle(0))  by(nombre_ambito)
 graph export "MoMo_descripcion.png", replace

 
 
** Los datos de Ceuta y Melilla pueden desproporcionar mucho el incremento.



gen proporcionincremento=defunciones_observadas*100/defunciones_esperadas

qui sum proporcionincremento
local max=int(`r(max)')

twoway line proporcionincremento date, by(nombre_ambito) yla(1 `max') color(red*0.8) ///
ytitle("Proporción entre defunciones registradas y esperadas") xtitle("Fecha de defunción") xlabel(`=`threemonthsago'' (30) `=d("`hoyformato'")', format(%tdDD/NN/CCYY) angle(90) labcolor(*0.4) labsize(3)) ///
legend(order (2 "Observadas" 1 "Rango de defunciones esperadas" 3 "Esperadas")) 

 graph export "MoMo_proporcionobsesp.png", replace


